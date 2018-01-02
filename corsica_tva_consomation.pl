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
                
$date_min="2008-03-01";
$date_max="2008-03-31";                
print "<h2>Mars</h2><br>";
# $query="select distinct tva_nom  from corsica_tva where tva_date >='$date_min' and  tva_date <='$date_max' and tva_nom='MEGA 3' order by tva_nom";                 
$query="select distinct tva_nom  from corsica_tva where tva_date >='$date_min' and  tva_date <='$date_max' order by tva_nom";                 

$sth=$dbh->prepare($query);
$sth->execute;
while (($navire)=$sth->fetchrow_array){
	$total_ca=$total_tva19=$total_tva10=$total_tva4=$total_tva0=0;
	print "<b>$navire</b><br>";
	print "<table border=1 cellspacing=0 width=60%><tr><th align=right>Code</th><th align=right>Designation</th><th  align=right>prix de vente</th><th align=right>qte</th><th align=right>total</th></tr>";
	$max=&get("select extract(day from last_day('$date_min'))");
	$total_prac=0;
	$query="select tva_refour,tva_neptune,tva_qte,tva_prac,tva_desi from corsica_tva  where tva_nom='$navire' and tva_date >='$date_min' and tva_date<='$date_max' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') and tva_tva=19.60";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	while (($tva_refour,$tva_neptune,$tva_qte,$tva_prac,$tva_desi)=$sth2 ->fetchrow_array){
		$type=&get("select pr_type from produit where pr_cd_pr='$tva_refour'");
		$desi="";
		if (($type==1)or($type==5)){
			$sup=&get("select pr_sup from produit where pr_cd_pr='$tva_refour'");
		        if ($sup!=5 && $sup!=6){
		        	$tva_prac=&get("select pr_prac/100 from produit where pr_cd_pr='$tva_refour'");
		        }
		}
		$tva_prac*=1.20;
		$tva_prac=int($tva_prac*100)/100;
		$prac=$tva_prac*$tva_qte;
	
		print &ligne_tab("","$tva_neptune","$tva_desi","$tva_prac","$tva_qte","$prac");
		$total_prac+=$prac;
	}
	print "</table>";
	print "total facture HT:$total_prac<br>";
}
