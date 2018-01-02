#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
@base=("corsica","dfc","cameshop");

	
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

</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF


	
if ($action eq ""){
	&save("create temporary table produit_groupe (code bigint(14),ref_four varchar(20),four int(8),marque varchar(30),desi varchar(50),prix_aerien decimal(8,2),prix_corse decimal(8,2),prix_cameshop decimal (8,2),primary key (code) )");
	$query="select pr_cd_pr,pr_refour,pr_desi,pr_prac,pr_four from corsica.produit where (pr_sup=0 or pr_sup=3) and pr_four in (select fo_cd_fo from dfc.fournis_parf)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($pr_cd_pr,$pr_refour,$pr_desi,$pr_prac,$pr_four)=$sth->fetchrow_array){
		$marque=&get("select marque from corsica.produit_desi where code='$pr_cd_pr'");
		$pr_prac=$pr_prac/100;
		my($query)="select valeur from corsica.remise_four where four='$four' order by rang";
		my($sth)=$dbh->prepare($query);
		$sth->execute();
		while (($valeur)=$sth->fetchrow_array){
			$pr_prac=$pr_prac-$valeur*$pr_prac/100;
		}
		$pr_desi=~s/\'//g;
		&save("insert into produit_groupe values ('$pr_cd_pr','$pr_refour','$pr_four','$marque','$pr_desi','0','$pr_prac','0')","af");
	}
	$query="select pr_cd_pr,pr_codebarre,pr_refour,pr_desi,pr_prac,pr_four from dfc.produit where (pr_sup=0 or pr_sup=3) and pr_four in (select fo_cd_fo from dfc.fournis_parf)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($pr_cd_pr,$pr_codebarre,$pr_refour,$pr_desi,$pr_prac,$pr_four)=$sth->fetchrow_array){
		$marque=&get("select marque from dfc.produit_desi where code='$pr_cd_pr'");
		$pr_prac=$pr_prac/100;
		$pr_desi=~s/\'//g;
		if ($pr_codebarre>100000){$pr_cd_pr=$pr_codebarre;}
		&save("insert ignore into produit_groupe values ('$pr_cd_pr','$pr_refour','$pr_four','$marque','$pr_desi','$pr_prac','0','0')","af");
		&save("update produit_groupe set prix_aerien='$pr_prac' where code='$pr_cd_pr'","af");
	}
	$query="select pr_cd_pr,pr_refour,pr_desi,pr_prac,pr_four from cameshop.produit where (pr_sup=0 or pr_sup=3) and pr_four in (select fo_cd_fo from dfc.fournis_parf)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($pr_cd_pr,$pr_refour,$pr_desi,$pr_prac,$pr_four)=$sth->fetchrow_array){
		$marque=&get("select marque from cameshop.produit_desi where code='$pr_cd_pr'");
		$pr_prac=$pr_prac/100;
		$pr_desi=~s/\'//g;
		&save("insert ignore into produit_groupe values ('$pr_cd_pr','$pr_refour','$pr_four','$marque','$pr_desi','0','0','$pr_prac')","af");
		&save("update produit_groupe set prix_cameshop='$pr_prac' where code='$pr_cd_pr'","af");
		# if ($pr_cd_pr==3351500957712){print "ici $pr_prac**";}
	}
	
	
	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des produits</h3>";
	print "	</div>";
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Code</th>";
	print "<th>Ref Four</th>";
	print "<th>Code Four</th>";
	print "<th>Marque</th>";
	print "<th>Designation</th>";
	print "<th>Prix aerien</th>";
	print "<th>Prix corse</th>";
	print "<th>prix douala</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from produit_groupe order by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	
	while (($pr_cd_pr,$pr_refour,$pr_four,$marque,$pr_desi,$pr_prac_af,$pr_prac_corsica,$pr_prac_mag)=$sth->fetchrow_array){
		print "<tr><td>$pr_cd_pr</td><td>";
		$multiple=0;
		$pass=0;
		foreach (@base){
			$refour=&get("select pr_refour from $_.produit where pr_cd_pr='$pr_cd_pr' and (pr_sup=0 or pr_sup=3)");
			if ($refour ne ""){
				if ($pass==0){
					$refour_ref=$refour;
					$pass=1;
				}
				else {
					if ($refour ne $refour_ref){
						$multiple=1;
						# print "*$_*$four*$four_ref*<br>";
					}
				}				
			}
		}
		if ($multiple==1){
			foreach (@base){
				$refour=&get("select pr_refour from $_.produit where pr_cd_pr='$pr_cd_pr' and (pr_sup=0 or pr_sup=3)");
				if ($refour ne ""){
					print "$_:$refour<br>";
				}	
			}
		}	
		else { print $pr_refour;} 
		print "</td><td>";
		$multiple=0;
		$pass=0;
		foreach (@base){
			$four_r=&get("select pr_four from $_.produit where pr_cd_pr='$pr_cd_pr' and (pr_sup=0 or pr_sup=3)");
			if ($four_r ne ""){
				if ($pass==0){
					$four_ref=$four_r;
					$pass=1;
				}
				else {
					if ($four_r ne $four_ref){
						$multiple=1;
						# print "*$_*$four*$four_ref*<br>";
					}
				}				
			}
		}
		if ($multiple==1){
			foreach (@base){
				$four=&get("select pr_four from $_.produit where pr_cd_pr='$pr_cd_pr' and (pr_sup=0 or pr_sup=3)");
				if ($four ne ""){
					$fo_add=&get("select fo2_add from $_.fournis where fo2_cd_fo='$four' ");
					($fo_nom)=split(/\*/,$fo_add);
					print "$_:$four $fo_nom<br>";
				}	
			}
		}	
		else { 
			$fo_add=&get("select fo2_add from dfc.fournis where fo2_cd_fo='$pr_four' ");
			($fo_nom)=split(/\*/,$fo_add);
			print "$pr_four $fo_nom";
		} 
		print "</td><td>";
		$multiple=0;
		$pass=0;
		foreach (@base){
			$marque_r=&get("select marque from $_.produit_desi,$_.produit where code='$pr_cd_pr' and code=pr_cd_pr and (pr_sup=0 or pr_sup=3)");
			if ($marque_r ne ""){
				if ($pass==0){
					$marque_ref=$marque_r;
					$pass=1;
				}
				else {
					if ($marque_r ne $marque_ref){
						$multiple=1;
						# print "*$_*$four*$four_ref*<br>";
					}
				}				
			}
		}
		if ($multiple==1){
			foreach (@base){
				$marque=&get("select marque from $_.produit_desi,$_.produit where code='$pr_cd_pr' and code=pr_cd_pr and (pr_sup=0 or pr_sup=3)");
				if ($marque ne ""){
					print "$_:$marque<br>";
				}	
			}
		}	
		else { print $marque;} 
		print "</td><td>$pr_desi</td>";
		print "<td align=right>$pr_prac_af</td><td align=right>$pr_prac_corsica</td><td align=right>$pr_prac_mag</td>";
		$prix_ref=0;
		$diff=0;
		if ($pr_prac_af!=0){
			$prix_ref=$pr_prac_af;
		}	
		if ($pr_prac_corsica!=0){
			if (($prix_ref!=0)&&($pr_prac_corsica!=$prix_ref)){$diff=1}
			$prix_ref=$pr_prac_af;
		}	
		if ($pr_prac_mag!=0){
			if (($prix_ref!=0)&&($pr_prac_mag!=$prix_ref)){$diff=1}
			$prix_ref=$pr_prac_af;
		}
		if ($diff){print "<td bgcolor=red>X</td>";}else{print "<td>&nbsp;</td>";}
		print "</tr>";
	}
	print "</table>";
}
print "		
		</div>
	</div>
</div>";
