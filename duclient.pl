#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print $html->header;

open(FILE2,"echecom.txt");
@echeancier_dat=<FILE2>;
close(FILE2);

$date = `/bin/date '+%d%m%y'`;   
chop($date);  
$total=$pass=$nb=$ok=0;
foreach (@echeancier_dat) {
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
	$ec_no_fact+=0;
	$ec_dt+=0;
	$ec_dt_reg+=0;
	$reste=$ec_mont -$ec_reg;
	
	$mois=(($ec_dt/100)%100);
	$dnb{$mois}+=1;
	if ($reste<0){
		$avoir{$mois}+=$ec_mont;
		next;}

	if (($reste>=60)||($ec_dt_reg==0)){
		$null{$mois}+=$ec_mont;
		next;
		}

	$delai=&nbjour($ec_dt_reg)-&nbjour($ec_dt);
	if ($delai <0) {
		$neg{$mois}+=$ec_mont;
		next;}

	if ($delai <6){$d6{$mois}+=$ec_mont;}
	if (($delai >=6)&&($delai <31)){$d30{$mois}+=$ec_mont;}
	if (($delai >=31)&&($delai <57)){$d57{$mois}+=$ec_mont;}
	if (($delai >=57)&&($delai <84)){$d84{$mois}+=$ec_mont;}
	if ($delai >=84){$d85{$mois}+=$ec_mont;}

}
	print "<table border=1><tr><td>mois</td><td><6</td><td><31</td><td><57</td><td><84</td><td>>84</td><td>non soldé</td><td>avoir</td><td>total</td></tr>";

 for ($i=2;$i<10;$i++){
	
	print "<tr><td>$i</td><td>";
	print $d6{$i};
	print "</td><td>";
	print $d30{$i};
	print "</td><td>";
	print $d57{$i};
	print "</td><td>";
	print $d84{$i};
	print "</td><td>";
	print $d85{$i};
	print "</td><td>";
	print $null{$i};
	print "</td><td>";
	print $avoir{$i};
	print "</td><td>";
	print $dnb{$i};
	print "</td></tr>\n";
	
	}

print "</table>";
print "</body></html>";