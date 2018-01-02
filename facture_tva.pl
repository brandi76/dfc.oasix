#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;

require "./src/connect.src";
                
for ($i=1;$i<7;$i++){
$min="2008-0".$i."-01";
$max="2008-0".$i."-31";                
$query="select distinct tva_nom  from corsica_tva where tva_date >='$min' and  tva_date <='$max' order by tva_nom";                 
$sth2=$dbh->prepare($query);
$sth2->execute;
while (($tva_nom)=$sth2->fetchrow_array){
	$total=0;
	print "<b>$tva_nom du $min au $max</b><br>";
	print "<table border=0><tr><th>Produit</th><th>Désignation</th><th>Qte</th><th>Prix</th><th>montant</th></tr>";
	$query="select tva_refour,tva_desi,tva_prac,sum(tva_qte)  from corsica_tva where tva_nom='$tva_nom' and tva_date >='$min' and  tva_date <='$max' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') group by tva_refour";                 
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($tva_refour,$tva_desi,$tva_prac,$tva_qte)=$sth->fetchrow_array){
		$type=&get("select pr_type from produit where pr_cd_pr='$tva_refour' and (pr_type=1 or pr_type=5) and pr_sup!=5 and pr_sup!=6");
		if ($type ne ""){$tva_prac=&prac($tva_refour);}
		$pr_prac*=1.2;
		$som=$tva_prac*$tva_qte;
		print "<tr><td>$tva_refour</td><td>$tva_desi</td><td>$tva_qte</td><td>$tva_prac</td><td>$som</td><td></tr>";
		$total+=$som;
	}
	
	print "</table><br><b>Total:$total</b><br>";
}
}