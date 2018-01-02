#!/usr/bin/perl                  
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/./outils_corsica.pl";

require "./src/connect.src";
print $html->header;

print "<title>$0</title>";

print "<table border=1>";
$query="select tva_nom,sum(tva_qte) from corsica_tva,produit where tva_date >='2008-08-01' and tva_date <='2008-08-31' and tva_refour=pr_cd_pr and (pr_type=1 or pr_type=5) group by tva_nom"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($tva_nom,$tva_qte)=$sth->fetchrow_array){
	$qte=0;
	print "<tr><td>$tva_nom</td><td>$tva_qte</td>";
	$navire=&get("select nav_number from navire where nav_nom='$tva_nom'","af")+0;
	$qte=&get("select sum(vda_qte) from vendu_corsica_auto,produit where vda_date >='2008-08-01' and vda_date <='2008-08-31' and vda_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and vda_navire=$navire")+0;
	print "<td>$qte</td>";
	$pour=int(($tva_qte-$qte)*100/$tva_qte);
	print "<td>$pour%</td></tr>"; 
	
}
print "</table>";
print "<table border=1>";

$query="select tva_date,sum(tva_qte) from corsica_tva,produit where tva_date >='2008-08-01' and tva_date <='2008-08-31' and tva_refour=pr_cd_pr and (pr_type=1 or pr_type=5) and tva_nom='MEGA 1'  group by tva_date order by tva_date"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($tva_date,$tva_qte)=$sth->fetchrow_array){
	$qte=0;
	print "<tr><td>$tva_date</td><td>$tva_qte</td>";
	$navire=&get("select nav_number from navire where nav_nom='MEGA 1'","af")+0;
	$qte=&get("select sum(vda_qte) from vendu_corsica_auto,produit where vda_date='$tva_date' and vda_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and vda_navire=$navire")+0;
	print "<td>$qte</td></tr>"; 
	
}
print "</table>";

$query="select tva_refour,sum(tva_qte) from corsica_tva,produit where tva_date ='2008-08-10' and tva_refour=pr_cd_pr and (pr_type=1 or pr_type=5) and tva_nom='MEGA 1'  group by tva_refour order by tva_refour"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($tva_refour,$tva_qte)=$sth->fetchrow_array){
	$qte=&get("select sum(vda_qte) from vendu_corsica_auto where vda_date='2008-08-10' and vda_cd_pr=$tva_refour and vda_navire=1")+0;
	if ($qte!=$tva_qte){
		print "$tva_refour $tva_qte $qte<br>";
	}
}
print "<hr>";
$query="select vda_cd_pr,sum(vda_qte) from vendu_corsica_auto,produit where vda_date ='2008-08-10' and vda_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and vda_navire=1  group by vda_cd_pr order by vda_cd_pr"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($vda_cd_pr,$vda_qte)=$sth->fetchrow_array){
	$qte=&get("select sum(tva_qte) from corsica_tva where tva_date='2008-08-10' and tva_refour=$vda_cd_pr and tva_nom='MEGA 1'")+0;
	if ($qte!=$vda_qte){
		print "$vda_cd_pr $vda_qte $qte<br>";
	}
}
