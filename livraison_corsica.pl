#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>corsica</title>";
require "./src/connect.src";



print "<h1>Livraison corsica</h1>";

$query="select distinct vdu_navire from vendu_corsica_mois where vdu_mois>=901 and vdu_mois<=912 and vdu_navire!='0'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire)=$sth->fetchrow_array)
{
	push (@navire,$navire);
}
$query="select distinct vdu_mois from vendu_corsica_mois where vdu_mois >=901 and vdu_mois<=912 order by vdu_mois";
$sth=$dbh->prepare($query);
$sth->execute();
while (($mois)=$sth->fetchrow_array)
{
	push (@mois,$mois);
}



print "<table><tr><td align=center>";

print "<table border=1 cellspacing=0><tr><td>&nbsp;</td>";
foreach $mois (@mois) {
	print "<th>$mois</th>";
	$totv{$mois}=0;
	$tota{$mois}=0;
}
print "<th>Total</th></tr>";
$totalvg=$totalag=0;
foreach $navire (@navire) {
	print "<tr><td>$navire</td>";
	$total=0;
	$totalvm=0;

	foreach $mois (@mois) {
		$debut=1000000+$mois*100;
		$fin=1000032+$mois*100;
		if ($mois==901){
			$fin=1090220;
			}
		if ($mois==902){
			$debut=1090219;
			}

		$totalv=0;
		$totalv=&get("select sum(coc_qte*coc_puni)/10000 from comcli,infococ2 where coc_no=ic2_no and ic2_date>'$debut' and ic2_date<'$fin' and ic2_com1='$navire' and ic2_no!=12320","af");
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			print "<td align=right>$totalv</td>";
		}
		$totalvm+=$totalv;
		$totv{$mois}+=$totalv;
		$totvm+=$totalv;

	}
	print "<th align=right>$totalvm</th>";

	print "</tr>";

}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	print "<th align=right>".$totv{$mois}."</th>";
}
print "<th align=right>".$totvm."</th>";

print "</tr></table>";

