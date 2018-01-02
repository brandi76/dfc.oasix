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
                
for ($index=10;$index<13;$index++){
$min="2008-".$index."-01";
$max="2008-".$index."-31";                
$an="2008";
$mois=$index;
$query="select distinct tva_nom  from corsica_tva where tva_date >='$min' and  tva_date <='$max' and tva_nom not like 'VICTORIA' and tva_nom not like 'REGINA' order by tva_nom";                 

 $sth=$dbh->prepare($query);
 $sth->execute;
 while (($navire)=$sth->fetchrow_array){
	$total_ca=$total_tva19=$total_20=$total_tva10=$total_tva4=$total_tva0=0;
	print "<b>$navire</b><br>";
	print "<table border=1 cellspacing=0 width=60%><tr><th align=right>Jour</th><th align=right>CA Jour OASIS</th><th  align=right>20%</th><th  align=right>19.6%</th><th align=right>10%</th><th align=right>4%</th><th align=right>0%</th></tr>";
	$max=&get("select extract(day from last_day('$min'))");
	
	#$max=25;
	for ($i=1;$i<=$max;$i++){
		$jour=$i;
		if ($i<10){$jour="0".$jour;}
		$date="$an-$mois-$jour";
		$tva20=&get("select sum(tva_prixv) from corsica_tva where tva_date ='$date' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') and tva_tva=20 and tva_nom='$navire'","af")+0;
		$tva19=&get("select sum(tva_prixv) from corsica_tva where tva_date ='$date' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') and tva_tva=19.60 and tva_nom='$navire'","af")+0;
		$tva10=&get("select sum(tva_prixv) from corsica_tva where tva_date ='$date' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') and (tva_tva=5.5 or tva_tva=10) and tva_nom='$navire'")+0;
		$tva4=&get("select sum(tva_prixv) from corsica_tva where  tva_date ='$date' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') and tva_tva=2.5 and tva_nom='$navire'")+0;
		$tva0=&get("select sum(tva_prixv) from corsica_tva where  tva_date ='$date' and (tva_leg like 'S%' or tva_leg like 'R%' or tva_leg like 'L%' or tva_leg like 'V%' or tva_leg like 'P%') and tva_tva=0 and tva_nom='$navire'")+0;
		$ca=$tva20+$tva19+$tva10+$tva4+$tva0;
 		 print &ligne_tab("","$date","$ca","$tva20","$tva19","$tva10","$tva4","$tva0");
		$total_ca+=$ca;
		$total_tva20+=$tva20;
		$total_tva19+=$tva19;
		$total_tva10+=$tva10;
		$total_tva4+=$tva4;
		$total_tva0+=$tva0;

	}
	print &ligne_tab("<b>","Total","$total_ca","$total_tva20","$total_tva19","$total_tva10","$total_tva4","$total_tva0");
	print "</table>";
 }
}
#  if ($q eq "A"){return("<font size=-1>Ajaccio:$_[1]</font>");}
#  if ($q eq "S"){return("<b>Vado:$_[1]</b>");}
#  if ($q eq "B"){return("<font size=-1>Bastia:$_[1]</font>");}
#  if ($q eq "T"){return("<b>Toulon:$_[1]</b>");}
#  if ($q eq "R"){return("<font size=-1>Golfo:$_[1]</font>");}
#  if ($q eq "L"){return("<b>Livourne:$_[1]</b>");}
#  if ($q eq "N"){return("<b>Nice:$_[1]</b>");}
#  if ($q eq "V"){return("<font size=-1>Civitavecc:$_[1]</font>");}
#  if ($q eq "C"){return("<font size=-1>Calvi:$_[1]</font>");}
#  if ($q eq "I"){return("<font size=-1>Ile rousse:$_[1]</font>");}
#  if ($q eq "P"){return("<font size=-1>Piombino:$_[1]</font>");}
