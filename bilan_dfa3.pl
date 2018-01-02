#!/usr/bin/perl
use DBI();
use CGI();
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
$html=new CGI;
print $html->header();
$query="select distinct es_no_do,date(es_dt) from corsica.enso where es_type=10 and date(es_dt)>='2016-01-04' and date(es_dt)<='2017-01-04'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($es_no_do,$date)=$sth->fetchrow_array){
	$enh_document=&get("select enh_document from corsica.enthead where enh_no=$es_no_do");
	($livh_four,$livh_date)=&get("select livh_four,livh_date from dfc.livraison_h where livh_id='$enh_document'");
	$local=&get("select fo2_identification from corsica.fournis where fo2_cd_fo=$livh_four ");
	$montant_fac=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$enh_document'");
	$montant=int($montant*100)/100;
	$query="select es_cd_pr,es_qte_en/100 from enso where es_no_do=$es_no_do";
	$montant_entree+=0;
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($code,$qte)=$sth2->fetchrow_array){
		$pr_prac=&prac_corsica($code);
		$montant_entree+=$qte*$pr_prac
	}
	$fo2_add=&get("select fo2_add from corsica.fournis where fo2_cd_fo=$livh_four");
	($fo2_add)=split(/\*/,$fo2_add);
	print "$enh_document;$date;$four $fo2_add;$montant_fac;$montant_entree<br>";
}	
