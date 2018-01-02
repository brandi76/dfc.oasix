#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print "<b>Facturation bar mai-juin 2004 AIR TOGO</b><br><br>";
require "./src/connect.src";
$query="select v_code,v_date,v_vol from vol where v_code>17160 group by v_code";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_date,$v_vol)=$sth->fetchrow_array){
	print "<b>Vol:$v_vol du $v_date bon appro No:$v_code<br><table border=0 width=500>";
	$query="select ro_cd_pr,pr_desi,floor(ro_qte/100) from rotation,produit where ro_cd_pr=pr_cd_pr and pr_cd_pr=220430 and ro_code=$v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$pr_desi,$qte)=$sth2->fetchrow_array){
		$prix=0;
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td>";
		$total+=$qte;
		print "<td align=right>$prix</td><td align=right>$mont</td></tr>";
	}
	# print "<tr><td>&nbsp;</td><td>Mise à bord</td><td align=right>1</td><td align=right>13</td><td align=right>13</td></tr>";
	# $total+=13;
	print "<tr><th colspan=4>TOTAL</th><th align=right>$total</th></table>";
}
print "Total à facturer:$total";