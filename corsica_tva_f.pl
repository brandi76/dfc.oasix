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
                
$min="2009-03-01";
$max="2009-03-31";                
$an="2009";
$mois="03";

#  $query="select distinct tva_nom  from corsica_tva where tva_date >='$min' and  tva_date <='$max' and tva_nom='MEGA 1' order by tva_nom";                 
 $query="select distinct tva_nom  from corsica_tva where tva_date >='$min' and  tva_date <='$max' order by tva_nom";                 

$sth=$dbh->prepare($query);
$sth->execute;
while (($navire)=$sth->fetchrow_array){
	$total_ca=$total_tva19=$total_tva10=$total_tva4=$total_tva0=0;
	print "<b>$navire</b><br>";
	print "<table border=1 cellspacing=0 width=60%><tr><th align=right>Jour</th><th align=right>CA Jour IBS</th><th  align=right>19.6%</th><th align=right>5.5%</th><th align=right>0%</th></tr>";
	$max=&get("select extract(day from last_day('$min'))");
	
	#$max=25;
	for ($i=1;$i<=$max;$i++){
		$jour=$i;
		if ($i<10){$jour="0".$jour;}
		$date="$an-$mois-$jour";
		$tva19=&get("select sum(tva_prixv) from corsica_tva where tva_nom='$navire' and tva_date ='$date' and (tva_leg not like 'S%' and tva_leg not like 'R%' and tva_leg not like 'L%' and tva_leg not like 'V%' and tva_leg not like 'P%') and tva_tva=19.60","af")+0;
		$tva10=&get("select sum(tva_prixv) from corsica_tva where tva_nom='$navire' and tva_date ='$date' and (tva_leg not like 'S%' and tva_leg not like 'R%' and tva_leg not like 'L%' and tva_leg not like 'V%' and tva_leg not like 'P%') and tva_tva=5.5")+0;
		$tva0=&get("select sum(tva_prixv) from corsica_tva where tva_nom='$navire' and tva_date ='$date' and (tva_leg not like 'S%' and tva_leg not like 'R%' and tva_leg not like 'L%' and tva_leg not like 'V%' and tva_leg not like 'P%') and tva_tva=0 ")+0;
		$ca=$tva19+$tva10+$tva0;
# 		print &ligne_tab("","$date","$ca","$tva19","$tva10","$tva0");
		$total_ca+=$ca;
		$total_tva19+=$tva19;
		$total_tva10+=$tva10;
		$total_tva0+=$tva0;

	}
	print &ligne_tab("<b>","Total","$total_ca","$total_tva19","$total_tva10","$total_tva0");
	print "</table>";
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
