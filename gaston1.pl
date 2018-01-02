#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;

$query="select distinct npr_ventil from newventil";
$sth3 = $dbh->prepare($query);
$sth3->execute;

while (($ventil)= $sth3->fetchrow_array) {
$totals=0;
$total=0;
$diff=0;
print "<b>$ventil<table border=1 cellspacing=0><tr><th>code</th><th>designation</th><th>déclaré</th><th>compté</th><th>ecart</th></tr>";
if ($ventil==6) {
	$query="select produit.pr_cd_pr,pr_desi,pr_flag,gaston.pr_stock,produit.pr_pdn*produit.pr_deg*produit.pr_stanc/10000,gaston.pr_pdn*gaston.pr_deg*gaston.pr_stock/100 from produit,gaston,newventil where produit.pr_cd_pr=gaston.pr_cd_pr and produit.pr_cd_pr=npr_cd_pr and npr_ventil=$ventil";
 }
 else
 {
 $query="select produit.pr_cd_pr,pr_desi,pr_flag,gaston.pr_stock,produit.pr_pdn*produit.pr_stanc,gaston.pr_pdn*gaston.pr_stock*100 from produit,gaston,newventil where produit.pr_cd_pr=gaston.pr_cd_pr and produit.pr_cd_pr=npr_cd_pr and npr_ventil=$ventil";
}
$sth = $dbh->prepare($query);
$sth->execute;
while (($pr_cd_pr,$pr_desi,$flag,$pr_stock,$stanc,$stock)= $sth->fetchrow_array) {
	if ($flag==0){
		$totalb+=$pr_stock;
	}
	$nb=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1","af")+0;
	$actif="&nbsp;";
	if ($nb>0){$stock=$stanc;$actif="actif";}
	$com7="&nbsp;";
	if ($flag>0){$com7="com7";}
	$stanc/=10000000;
	$stock/=10000000;
	$diff=&deci($stock-$stanc,7);
	$stanc=&deci($stanc,7);
	$stock=&deci($stock,7);
	#if ($stanc>0){
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stanc</td><td align=right>$stock</td></td><td align=right>$diff</td></tr>";
	#}
	$total+=$stanc;
	$totals+=$stock;
	
}
$diff=$totals-$total;
print "<tr><th colspan=2>total</th><th>";
print &deci($total,7);
print "</th><th>";
print &deci($totals,7);
print "</th><th>";
print &deci($diff,7);
print "</th></tr>";
print "</table></b>";
if ($ventil==6){
	print "accises 1450 euro/hectolitre alcool pur:";
	$val=-1450*$diff;
	print &deci($val,2);
	print " secu 1.30 par litre:";
	$lit=$diff*10000/40; # degree moyen
	$val=-1.30*$lit;
	print &deci($val,2);
	print " tva 19.6:";
	$val=$lit*-12*19.6/100; # prix moyen  5 euro + 5.70 euro accise +1.30 secu=12
	print &deci($val,2);
	print "<br>";
	}
if ($ventil==3){
	print "accises 214 euro/hectolitre:";
	$val=-214*$diff;
	print &deci($val,2);
	print " tva 19.6:";
	$val=$diff*-7*19.6; # prix moyen  5 euro + 2 euro accise =7
	print &deci($val,2);
	print "<br>";
	}
if ($ventil==1){
	print "accises 3.4 euro/hectolitre:";
	$val=-3.4*$diff;
	print &deci($val,2);
	print " tva 19.6:";
	$val=$diff*-3*19.6; # prix moyen  3 euro + 0 euro accise =3
	print &deci($val,2);
	print "<br>";
	}
if ($ventil==4){
	print "accises 54 euro/hectolitre:";
	$val=-54*$diff;
	print &deci($val,2);
	print " tva 19.6:";
	$val=$diff*-3.54*19.6; # prix moyen  3 euro + 0.54 euro accise =3.54
	print &deci($val,2);
	print "<br>";
	}
}

