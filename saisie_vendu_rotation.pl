#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$option=$html->param("option");
$code=$html->param("code");
$pr_cd_pr=$html->param("pr_cd_pr");

if ($action eq "go"){
	$etat=get("select at_etat from etatap where at_code='$code'");
	if ($etat != 5){$message="Impossible il n'y a pas eu de saiappauto sur ce bon";$action="";}
}	

print <<EOF;
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	<style>
	.gras {
		font-weight:bold;
		}
	.right {
		text-align:right;
	}	
	</style>	
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
if ($action eq ""){
if ($message ne ""){
	print "<div class=\"alert alert-danger\">$message</div>";
}
print <<EOF;
			<div class="alert alert-info" >
			<h3>Saisie des ventes par rotation</h3>
			</div>
			<form role="form">
				<fieldset>
					<div class="form-group">
						<label for="dtp_input2" class="control-label">No appro</label>
						<input class="form-control" size="16" type="text" value="" id=dtp_input2 name=code>
						<input type="hidden" name=action value="go" />
					</div>
				</fieldset>
			<button type="submit" class="btn btn-info">Submit</button>
			</form>
EOF
}

if ($action eq "plus"){
	&plus();
	$action="go";
}

if ($action eq "plus_tous"){
	$query="select distinct ro_cd_pr from rotation where ro_code=$code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$nb_rot=0;
	while ($pr_cd_pr=$sth->fetchrow_array){
		&plus();
	}
	$action="go";
}
if ($action eq "moins_tous"){
	$query="select distinct ro_cd_pr from rotation where ro_code=$code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$nb_rot=0;
	while ($pr_cd_pr=$sth->fetchrow_array){
		&moins();
	}
	$action="go";
}

if ($action eq "moins"){
	&moins();
	$action="go";
}


if ($action eq "go"){
	print "<h3>$code</h3>";
	$query="select * from vol where v_code='$code'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$nb_rot=0;
	while ($vol[$nb_rot]=$sth->fetchrow_hashref){$nb_rot++;}
	print "<table class=\"table table-condensed table-bordered table-hover table-striped \">";
	print "<thead>";
	print "<tr class=\"info small\">";
	print "<th>Produit</th><th>Prix</th><th class=small>Deplacer les ventes vers la rotation suivante</th>";
	for ($i=0;$i<$nb_rot;$i++){
		print "<th>";
		print "Leg:";
		print $vol[$i]->{v_rot};
		print " ";
		print $vol[$i]->{v_vol};
		print " ";
		print $vol[$i]->{v_dest};
		print "</th>";
	}	
	print "<th class=small>Deplacer les ventes vers la rotation précedente</td>";
	print "</tr>";
	print "</thead>";
	$query="select * from flyhead where fl_date_sql='$date'";

	$query="select ap_cd_pr,pr_desi,ap_prix from appro ,produit where ap_cd_pr=pr_cd_pr and ap_code='$code' order by ap_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$ap_prix)=$sth->fetchrow_array){
		$ap_prix=$ap_prix/100;
		$vendu=&get("select sum(ro_qte) from rotation where ro_code=$code and ro_cd_pr='$pr_cd_pr'")+0;
		if ($vendu ==0){next;};
		print "<tr><td class=small>$pr_cd_pr $pr_desi</td><td>$ap_prix</td>";
		print "<td class=text-center>";
		print "<a href=?code=$code&pr_cd_pr=$pr_cd_pr&action=plus class=\"btn btn-info btn-sm\">
          <span class=\"glyphicon glyphicon-step-forward\"></span>
        </a>";
		print "</td>";
		for ($i=0;$i<$nb_rot;$i++){
			$rot=$i+1;
			$vendu=&get("select ro_qte from rotation where ro_code='$code' and ro_cd_pr='$pr_cd_pr' and ro_rot='$rot'")+0;
			$vendu=int($vendu/100);
			print "<td class=right>$vendu</td>";
			$total[$i]+=$vendu*$ap_prix;
		}	
		print "<td class=text-center>";
		print "<a href=?code=$code&pr_cd_pr=$pr_cd_pr&action=moins class=\"btn btn-info btn-sm\">
          <span class=\"glyphicon glyphicon-step-backward\"></span>
        </a>";
		
		print "</tr>";
	}
	print "<tr><th colspan=2>Total</th>";
	print "<td class=text-center>";
	print "<a href=?code=$code&pr_cd_pr=$pr_cd_pr&action=plus_tous class=\"btn btn-danger btn-sm\">
	  <span class=\"glyphicon glyphicon-step-forward\"></span>
	</a>";
	print "</td>";
	for ($i=0;$i<$nb_rot;$i++){
		print "<td align=right class=gras>$total[$i]</td>";
	}
	print "<td class=text-center>";
	print "<a href=?code=$code&pr_cd_pr=$pr_cd_pr&action=moins_tous class=\"btn btn-danger btn-sm\">
	  <span class=\"glyphicon glyphicon-step-backward\"></span>
	</a>";
	print "</td>";
	print "</tr>";
	print "</table>";
}

print <<EOF;			
		</div>
	</div>
</div>
EOF

sub plus {
	$nb_rot=&get("select max(v_rot) from vol where v_code='$code'");
	$rot=&get("select min(ro_rot) from rotation where ro_code='$code' and ro_cd_pr='$pr_cd_pr' and ro_qte>0","af")+0;
	if ($rot<$nb_rot){
		$rot_run=$rot+1;
		$vendu=&get("select ro_qte from rotation where ro_code=$code and ro_cd_pr='$pr_cd_pr' and ro_rot='$rot_run'","chec")+0;
		$vendu+=100;
		&save("replace into rotation values ('$code','$rot_run','$pr_cd_pr','$vendu')","chec");
		&save("update rotation set ro_qte=ro_qte-100 where ro_code='$code' and ro_cd_pr='$pr_cd_pr' and ro_rot='$rot'","chec")+0;
	}
}

sub moins {
	$nb_rot=&get("select max(v_rot) from vol where v_code='$code'");
	$rot=&get("select max(ro_rot) from rotation where ro_code='$code' and ro_cd_pr='$pr_cd_pr' and ro_qte>0","af")+0;
	if ($rot>1){
		$rot_run=$rot-1;
		$vendu=&get("select ro_qte from rotation where ro_code=$code and ro_cd_pr='$pr_cd_pr' and ro_rot='$rot_run'","chec")+0;
		$vendu+=100;
		&save("replace into rotation values ('$code','$rot_run','$pr_cd_pr','$vendu')","chec");
		&save("update rotation set ro_qte=ro_qte-100 where ro_code='$code' and ro_cd_pr='$pr_cd_pr' and ro_rot='$rot'","chec")+0;
	}
}