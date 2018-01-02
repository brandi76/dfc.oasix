#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print "<b>Facturation Guerlain Decembre 2011, Janvier 2012 AIR TOGO</b><br><br>";
require "./src/connect.src";
$query="select v_code,v_date,v_vol,v_cd_cl from vol,rotation,produit where (v_date%10000=1211 or v_date%1000=112) and ro_cd_pr=pr_cd_pr and pr_desi like \"guerl%\" and ro_code=v_code group by v_code";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_date,$v_vol,$v_cd_cl)=$sth->fetchrow_array){
	$query="select cl_nom from client where cl_cd_cl=$v_cd_cl";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	($cl_nom)=$sth3->fetchrow_array;
	print "<b>$cl_nom Vol:$v_vol du $v_date bon appro No:$v_code<br><table border=1 width=500><tr><th>Code</th><th>Produit</th><th>qte</th><th>prix</th><th>ca</th></tr>";
	$query="select ro_cd_pr,pr_desi,floor(ro_qte/100) from rotation,produit where ro_cd_pr=pr_cd_pr and pr_desi like \"guerl%\" and ro_code=$v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$total=0;
	$total_ca=0;
	while (($pr_cd_pr,$pr_desi,$qte)=$sth2->fetchrow_array){
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td>";
		$prix=&get("select ap_prix from appro where ap_code='$v_code' and ap_cd_pr='$pr_cd_pr'")/100;
		$ca=$qte*$prix;
		print "<td>$prix</td><td>$ca</td></tr>";
		$total+=$qte;
		$total_ca+=$ca;
	}
	print "<tr><th colspan=2>TOTAL</th><th align=right>$total</th><th>&nbsp;</td><th>$total_ca</th></tr></table>";
	$totalgen+=$total;
	$totalgenca+=$total_ca;
}
print "Qte :$totalgen Chiffe d'affaire:$totalgenca<br>";;