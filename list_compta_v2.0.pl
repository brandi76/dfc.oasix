#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$date=$html->param("date");
($an,$mois)=split(/_/,$date);
$debut="$an-$mois-01";
$fin="$an-$mois-31";

print <<EOF;
<html>
  <head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
 <script>
 function change(id)
 {
	if (document.getElementById(id).style.display=="none"){
		document.getElementById(id).style.display="block";
	}
	else
	{
		document.getElementById(id).style.display="none";
	}
 }
 
 </script>
 </head>
  <body>
    <div class="container">
		<div class="row">
			<div class="col-lg-12">
EOF

if ($action eq ""){
	print "<h3>Choisir un mois</h3>";
	print "<form role=form>";
	print "<select class=form-control name=date style=width:300px>";
	$query="SELECT distinct year(es_dt) as an,month(es_dt) as mois from enso order by an desc ,mois desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total_qte=0;
	$pass=0;
	while (($an,$mois)=$sth->fetchrow_array){
		print "<option value=${an}_${mois}>$an $mois</option>";
	}
	print "</select>";	
	print "<input type=hidden name=action value=go>";
	print "<button type=submit class=btn btn-default>Submit</button>";
	print "</form>";
}
else {
	print "<h3>Periode:$mois/$an</h3>";
	print "<h2>ENTREE EN COMPTA MATIERE:</h2>";
	$query="select min(es_no_do),max(es_no_do) from enso where es_dt>'$debut' and es_dt<='$fin' and es_qte_en!=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($min,$max)=$sth->fetchrow_array;
	print "<table class=\"table table-condensed table-bordered table-hover \">";
	print "<thead>";
	print "<caption>Entree No:$min à $max<br>LTA:";
	$query="select distinct livh_lta from dfc.livraison_h,enthead,enso where enh_no=es_no_do and enh_document=livh_id and es_dt>'$debut' and es_dt<='$fin' and es_qte_en!=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($lta)=$sth->fetchrow_array){
		print "$lta ";
	}
	print "</caption>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Code Douane</th>";
	print "<th>Qte</th>";
	print "</tr>";
	print "</thead>";
	$query="select es_cd_pr,pr_desi,es_no_do,es_qte_en,pr_douane from enso,produit where es_dt>'$debut' and es_dt<='$fin' and es_cd_pr=pr_cd_pr and es_qte_en!=0 order by pr_douane,es_no_do";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total_qte=0;
	$pass=0;
	while (($pr_cd_pr,$pr_desi,$es_no_do,$es_qte,$pr_douane,)=$sth->fetchrow_array){
		if ($pr_douane eq ""){$pr_douane="Nil";}
		if ($pass==0){
			print "<tbody id=\"${pr_douane}\" style=display:none>\n";
			$douane_run=$pr_douane;
			$lta_run=$lta;
			$no_do_run=$es_no_do;
			$pass=1;
		}	
		$es_qte=int($es_qte/100);
		if ($pr_douane != $douane_run){
			print "</tbody>\n";
			print "<tr><td><a href=\"#${douane_run}\" onclick=change(\"${douane_run}\")>$douane_run</a></td><td align=right>$total_qte</td></tr>\n";
			print "<tbody id=\"${pr_douane}\" style=display:none>\n";
			$total_qte=0;
			$douane_run=$pr_douane;
		}	
		$lta=&get("select livh_lta from dfc.livraison_h,enthead where enh_no='$es_no_do' and enh_document=livh_id"); 
		print "<tr class=\"success\"><td>Entree:$es_no_do</td><td>lta:'$lta'</td><td>$pr_douane</td><td>$pr_desi</td><td align=right>$es_qte</td>";
		$total_qte+=$es_qte;
		print "</tr>\n";
	}
	print "</tbody>\n";
	print "<tr><td><a href=\"#${douane_run}\" onclick=change(\"${douane_run}\")>$douane_run</a></td><td align=right>$total_qte</td></tr>\n";
	print "</table>";
	$query="select min(es_no_do),max(es_no_do) from enso where es_dt>'$debut' and es_dt<='$fin' and es_qte!=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($min,$max)=$sth->fetchrow_array;
	print "<h2>SORTIE EN COMPTA MATIERE:</h2>";
	print "<table class=\"table table-condensed table-bordered table-hover \">";
	print "<thead>";
	print "<caption>Bon d'appro No:$min à $max</caption>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Code douane</th>";
	print "<th>Qte</th>";
	print "</tr>";
	print "</thead>";
	$query="select es_cd_pr,pr_desi,es_no_do,es_qte,pr_douane from enso,produit where es_dt>'$debut' and es_dt<='$fin' and es_cd_pr=pr_cd_pr and es_qte!=0 order by pr_douane,es_no_do";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total_qte=0;
	$pass=0;
	while (($pr_cd_pr,$pr_desi,$es_no_do,$es_qte,$pr_douane,)=$sth->fetchrow_array){
		if ($pr_douane eq ""){$pr_douane="Nil";}
		if ($pass==0){
			print "<tbody id=\"${pr_douane}\" style=display:none>\n";
			$douane_run=$pr_douane;
			$pass=1;
		}	
		$es_qte=int($es_qte/100);
		if (($pr_douane != $douane_run)){
			print "</tbody>\n";
			print "<tr><td><a href=\"#${douane_run}\" onclick=change(\"${douane_run}\")>$douane_run</a></td><td align=right>$total_qte</td></tr>\n";
			print "<tbody id=\"${pr_douane}\" style=display:none>\n";
			$total_qte=0;
			$douane_run=$pr_douane;
		}	
		$v_dest=&get("select v_dest from vol where v_code='$es_no_do' and v_rot=1");
		print "<tr class=\"success\"><td>$pr_douane</td><td>Appro:$es_no_do</td><td>$v_dest</td><td align=right>$es_qte</td>";
		$total_qte+=$es_qte;
		print "</tr>\n";
	}
	print "</tbody>\n";
	print "<tr><td><a href=\"#${douane_run}\" onclick=change(\"${douane_run}\")>$douane_run</a></td><td align=right>$total_qte</td>\n";
	print "</table>";
	print "</div></div></div>";
}
