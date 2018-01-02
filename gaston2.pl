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
	if ($ventil==6) {
		$query="select produit.pr_cd_pr,pr_desi,pr_flag,gaston.pr_stock,produit.pr_pdn*produit.pr_deg*produit.pr_stanc/10000,gaston.pr_pdn*gaston.pr_deg*gaston.pr_stock/100,gaston.pr_deg,gaston.pr_pdn from produit,gaston,newventil where produit.pr_cd_pr=gaston.pr_cd_pr and produit.pr_cd_pr=npr_cd_pr and npr_ventil=$ventil";
	}
	else
	{
		$query="select produit.pr_cd_pr,pr_desi,pr_flag,gaston.pr_stock,produit.pr_pdn*produit.pr_stanc,gaston.pr_pdn*gaston.pr_stock*100,gaston.pr_deg,gaston.pr_pdn from produit,gaston,newventil where produit.pr_cd_pr=gaston.pr_cd_pr and produit.pr_cd_pr=npr_cd_pr and npr_ventil=$ventil";
	}
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($pr_cd_pr,$pr_desi,$flag,$pr_stock,$stanc,$stock,$pr_deg,$pr_pdn)= $sth->fetchrow_array) {
		$nb=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1","af")+0;
		$actif="&nbsp;";
		if ($nb>0){
			&save("update produit set pr_ventil=$ventil where pr_cd_pr='$pr_cd_pr'");
			next;
		}
		next;
		$pr_stock*=100;
		&save("update produit set pr_stre=$pr_stock,pr_stanc=$pr_stock,pr_diff=0,pr_ventil=$ventil,pr_deg=$pr_deg,pr_pdn=$pr_pdn where pr_cd_pr='$pr_cd_pr'","aff");
	}
}