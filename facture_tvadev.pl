#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;

require "./src/connect.src";
                
$min="2008-01-01";
$max="2008-03-31";                
print "<table border=1 cellspacing=0 width=60%><tr><th align=right>Code neptune</th><th>Désignation</th><th align=right>CA Jour OASIS</th></tr>";
$query="select tva_cd_pr,tva_desi,sum(tva_prixv) from corsica_tva where tva_date >='$min' and tva_date <='$max' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') and (tva_tva=20 or tva_tva=19.60 or tva_tva=5.5 or tva_tva=2.5 or tva_tva=0) group by tva_cd_pr ";
$sth=$dbh->prepare($query);
$sth->execute;
while (($tva_refour,$tva_desi,$montant)=$sth->fetchrow_array){
	print &ligne_tab("","$tva_refour","$tva_desi","$montant");
	$total+=$montant;
}

print &ligne_tab("<b>","&nbsp;","&nbsp;","$total");
print "</table>";
