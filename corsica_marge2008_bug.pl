#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>corsica</title>";
require "./src/connect.src";
print "<center>Marge Navire base vente neptune , prix achat dernier prix ibs (parfums) ou neptune du mois (autres)<br>";

$query="select distinct vdu_navire from vendu_corsica_mois where vdu_mois>=801 and vdu_mois<=812 and vdu_navire!='0' and vdu_navire='MEGA 3'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire)=$sth->fetchrow_array)
{
	push (@navire,$navire);
}
$query="select distinct vdu_mois from vendu_corsica_mois where vdu_mois >=812 and vdu_mois<=812 order by vdu_mois";
$sth=$dbh->prepare($query);
$sth->execute();
while (($mois)=$sth->fetchrow_array)
{
	push (@mois,$mois);
}

print "<h3>Parfumerie Ibs</h3><br>";
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
	$totalvm=$totalam=$totalqm=0;
	foreach $mois (@mois) {
		$totalv=0;
		$totala=0;
		$totalq=0;
		$query="select pr_four,pr_cd_pr,pr_desi,sum(vdu_qte),sum(vdu_vte),sum(vdu_prac)/sum(vdu_qte) from vendu_corsica_mois,produit where vdu_mois='$mois' and vdu_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and vdu_navire='$navire' and pr_sup!=5 and pr_sup!=6 group by pr_cd_pr order by pr_four";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_four,$pr_cd_pr,$pr_desi,$qte,$vendu,$achat)=$sth->fetchrow_array)
		{
			if ($vendu==0){next;}
			$nep=0;
			$pr_prac=&prac($pr_cd_pr);
			if ($pr_prac==0){$pr_prac=$achat;$nep=1;}
			$achat=$qte*$pr_prac;
			if ($achat==0){next;}  
			$marge=int(($vendu-$achat)*10000/$vendu)/100;
			$vendu=int($vendu);
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
			$totalq+=$qte;
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>$totalv<br>$marge%<br>$totalq<br>$totala</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totalqm+=$totalq;

		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;
	print "<th align=right>$totalvm<br>$marge%<br>$totalam<br>$totalqm</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>$totv{$mois}<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>$totalvg<br>$marge%</th>";
print "</tr></table>";

### Parfum paul

print "<h3>Parfumerie Paul</h3><table border=1 cellspacing=0><tr><td>&nbsp;</td>";
foreach $mois (@mois) {
	print "<th>$mois</th>";
	$totv{$mois}=0;
	$tota{$mois}=0;
}
print "<th>Total</th></tr>";
$totalvg=$totalag=0;
foreach $navire (@navire) {
	print "<tr><td>$navire</td>";
	$totalvm=$totalam=0;
	foreach $mois (@mois) {
		$totalv=0;
		$totala=0;
		$query="select pr_four,pr_cd_pr,pr_desi,sum(vdu_qte),sum(vdu_vte),sum(vdu_prac)/sum(vdu_qte) from vendu_corsica_mois,produit where vdu_mois='$mois' and vdu_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and vdu_navire='$navire' and pr_sup=5 group by pr_cd_pr order by pr_four";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_four,$pr_cd_pr,$pr_desi,$qte,$vendu,$achat)=$sth->fetchrow_array)
		{
			if ($vendu==0){next;}
			$nep=0;
			$pr_prac=&prac($pr_cd_pr);
			if ($pr_prac==0){$pr_prac=$achat;$nep=1;}
			$achat=$qte*$pr_prac;
			if ($achat==0){next;}  
			$marge=int(($vendu-$achat)*10000/$vendu)/100;
			$vendu=int($vendu);
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>$totalv<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	if ($totalvm!=0){
		$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;
	}
	else {$marge=0;}
	print "<th align=right>$totalvm<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	if ($totv{$mois}!=0){
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	}
	else {$marge=0;}
	print "<th align=right>$totv{$mois}<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
if ($totalvg!=0){
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;}
print "<th align=right>$totalvg<br>$marge%</th>";
print "</tr></table>";


print "<h3>Hors parfumerie</h3>";
print "<table border=1 cellspacing=0><tr><td>&nbsp;</td>";
foreach $mois (@mois) {
	print "<th>$mois</th>";
	$totv{$mois}=0;
	$tota{$mois}=0;
}
print "<th>Total </th></tr>";
$totalvg=$totalag=0;
foreach $navire (@navire) {
	print "<tr><td>$navire</td>";
	$totalvm=$totalam=0;
	foreach $mois (@mois) {
		$totalv=0;
		$totala=0;
		$query="select pr_four,pr_cd_pr,pr_desi,sum(vdu_qte),sum(vdu_vte),sum(vdu_prac)/sum(vdu_qte) from vendu_corsica_mois,produit where vdu_mois='$mois' and vdu_cd_pr=pr_cd_pr and vdu_navire='$navire' and pr_type!=5 and pr_type!=1 group by pr_cd_pr order by pr_four";
# 		print "$query<bR>";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_four,$pr_cd_pr,$pr_desi,$qte,$vendu,$achat)=$sth->fetchrow_array)
		{
			if ($vendu==0){next;}
			$nep=0;
			$pr_prac=&prac($pr_cd_pr);
			if ($pr_prac==0){$pr_prac=$achat;$nep=1;}
			$achat=$qte*$pr_prac;
			if ($achat==0){next;}  
			print "$pr_cd_pr;$vendu;$achat <br>";
			$marge=int(($vendu-$achat)*10000/$vendu)/100;
			$vendu=int($vendu);
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>$totalv<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;
	print "<th align=right>$totalvm<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>$totv{$mois}<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>$totalvg<br>$marge%</th>";
print "</tr></table>";

print "<h3>Total</h3>";
print "<table border=1 cellspacing=0><tr><td>&nbsp;</td>";
foreach $mois (@mois) {
	print "<th>$mois</th>";
	$totv{$mois}=0;
	$tota{$mois}=0;
}
print "<th>Total </th></tr>";
$totalvg=$totalag=0;
foreach $navire (@navire) {
	print "<tr><td>$navire</td>";
	$totalvm=$totalam=0;
	foreach $mois (@mois) {
		$totalv=0;
		$totala=0;
		# 0.83
		$query="select pr_four,pr_cd_pr,pr_desi,sum(vdu_qte),sum(vdu_vte),sum(vdu_prac)/sum(vdu_qte) from vendu_corsica_mois,produit where vdu_mois='$mois' and vdu_cd_pr=pr_cd_pr and vdu_navire='$navire' group by pr_cd_pr order by pr_four";
#  		print "$query<bR>";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_four,$pr_cd_pr,$pr_desi,$qte,$vendu,$achat)=$sth->fetchrow_array)
		{
			if ($vendu==0){next;}
			$nep=0;
			$pr_prac=&prac($pr_cd_pr);
			if ($pr_prac==0){$pr_prac=$achat;$nep=1;}
			$achat=$qte*$pr_prac;
			if ($achat==0){next;}  
			$marge=int(($vendu-$achat)*10000/$vendu)/100;
			$vendu=int($vendu);
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>$totalv<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;
	print "<th align=right>$totalvm<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>$totv{$mois}<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>$totalvg $totalag<br>$marge%</th>";
print "</tr></table>";

print "<h3>CA exclu (prix achat à zero)</h3>";
print "<table border=1 cellspacing=0><tr><td>&nbsp;</td>";
foreach $mois (@mois) {
	print "<th>$mois</th>";
	$totv{$mois}=0;
	$tota{$mois}=0;
}
print "<th>Total </th></tr>";
$totalvg=$totalag=0;
foreach $navire (@navire) {
	print "<tr><td>$navire</td>";
	$totalvm=$totalam=0;
	foreach $mois (@mois) {
		$totalv=0;
		$totala=0;
		$query="select pr_four,pr_cd_pr,pr_desi,sum(vdu_qte),sum(vdu_vte),sum(vdu_prac)/sum(vdu_qte) from vendu_corsica_mois,produit where vdu_mois='$mois' and vdu_cd_pr=pr_cd_pr and vdu_navire='$navire' group by pr_cd_pr order by pr_four";
# 		print "$query<bR>";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_four,$pr_cd_pr,$pr_desi,$qte,$vendu,$achat)=$sth->fetchrow_array)
		{
			if ($vendu==0){next;}
			$nep=0;
			$pr_prac=&prac($pr_cd_pr);
			if ($pr_prac==0){$pr_prac=$achat;$nep=1;}
			$achat=$qte*$pr_prac;
			if ($achat!=0){next;}  
			$marge=int(($vendu-$achat)*10000/$vendu)/100;
			$vendu=int($vendu);
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>$totalv<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;
	print "<th align=right>$totalvm<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	if ($totv{$mois}!=0){ 
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;}
	print "<th align=right>$totv{$mois}<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>$totalvg<br>$marge%</th>";
print "</tr></table>";





