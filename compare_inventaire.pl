#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";

$date1="2007-09-9";
$date2="2007-09-23";
$fac1=9692;
$fac2=9659;
$navire="MEGA 2";

$query="select distinct pr_cd_pr,pr_desi from navire2,produit where nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and nav_nom='$navire' and nav_type=10 and (nav_date='$date1' or nav_date='$date2')";
$sth = $dbh->prepare($query);
$sth->execute;
print "<table><tr><td>&nbsp;</td><td>inventaire $date1</td><td>inventaire $date2</td><td>livraison</td><td>ventes (deduction)</td></tr>";
while (($pr_cd_pr,$pr_desi) = $sth->fetchrow_array) {
        $qte1=&get("select nav_qte from navire2 where nav_cd_pr=$pr_cd_pr and nav_nom='$navire' and nav_type=10 and nav_date='$date1'")+0;
        $qte2=&get("select nav_qte from navire2 where nav_cd_pr=$pr_cd_pr and nav_nom='$navire' and nav_type=10 and nav_date='$date2'")+0;
        $liv=&get("select sum(coc_qte)/100 from comcli where (coc_no=$fac1 or coc_no=$fac2) and coc_cd_pr=$pr_cd_pr")+0;
        $vendu=($qte1+$liv)-$qte2;
	print "<tr><td>$pr_cd_pr $pr_desi</td><td>$qte1</td><td>$qte2</td><td>$liv</td><td>$vendu</td></tr>";
	if ($vendu>0){
	$total+=$vendu;}
	else {$totalm+=$vendu;
	}
}
print "</table><br>total ventes:$total total produit en plus:$totalm"	;