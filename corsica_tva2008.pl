#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$texte=$html->param('texte');
$save=$html->param('save');
$type=$html->param('type');

require "./src/connect.src";
                
$min="2008-01-01";
$max="2008-12-31";                
$query="select tva_refour,tva_cd_pr,sum(tva_qte),sum(tva_prixv) from corsica_tva where tva_date >='$min' and tva_date<='$max' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') group by tva_refour";
$sth=$dbh->prepare("$query");
$sth->execute();
while (($pr_cd_pr,$neptune,$qte,$priv)=$sth->fetchrow_array){
	$query2="select prac,priv,flag from prix311208 where code='$pr_cd_pr'";
	$sth3=$dbh->prepare($query2);
	$sth3->execute();
	($pr_prac,$pr_priv,$flag)=$sth3->fetchrow_array;
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
	print "$pr_cd_pr; $pr_desi ;$qte ;$pr_prac; $priv<br>";
}

