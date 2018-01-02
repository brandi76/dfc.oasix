#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>corsica</title>";
require "./src/connect.src";

@liste=("PUBLIC","EQUIPAGE","Remise 5%","Remise 20%","Remise 40%","Remise 50%");

$query="select distinct tva_nom from corsica_tva where tva_date>='2008-01-01' and tva_date<='2008-12-31'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire)=$sth->fetchrow_array)
{
	push (@navire,$navire);
}
$query="select distinct month(tva_date) as mois from corsica_tva where tva_date>='2008-01-01' and tva_date<='2008-12-31' order by mois";
$sth=$dbh->prepare($query);
$sth->execute();
while (($mois)=$sth->fetchrow_array)
{
	push (@mois,$mois);
}

print "<h3>Parfumerie </h3><br>";
$totalvg=$totalag=0;
print "<table cellspacing=20>";
foreach $navire (@navire) {
	print "<tr><td><b>$navire</b></td>";
	foreach $mois (@mois) {
		print "<td>";
		print "<b>" ;
		print &cal($mois,'l');
		print "</b><br>";
		%table={};
		$total=0;
		$query="select tva_type,sum(tva_qte) from corsica_tva where tva_famille='PARFUMS' and tva_date>'2008-01-00' and month(tva_date)='$mois' and tva_nom='$navire' group by tva_type";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($type,$qte)=$sth->fetchrow_array)
		{
			$table{"$type"}=$qte;
			$total+=$qte;
		}
		print "<table border=1 cellspacing=0>";
		foreach $type (@liste) {
			if ($total==0){$total=1;}
			$pour=int($table{"$type"}/$total*100);
			$color="white";
			if (($type eq "PUBLIC")&&($pour<50)){$color="red";}
			if (($type eq "Remise 40%")&&($pour>20)){$color="red";}
			if (($type eq "Remise 50%")&&($pour>20)){$color="red";}
			if (($type eq "Remise 20%")&&($pour>20)){$color="red";}
			if ($pour==0){$color="#efefef";}

			print "<tr bgcolor=$color><td>$type</td><td>".$table{"$type"}."</td><td>";
			print "$pour";
			print "%</td></tr>";
		}
		print "</table>";
		print "<td>";
	}
	print "</tr>";
}
print "</table>";