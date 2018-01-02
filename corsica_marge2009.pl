#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>corsica</title>";
require "./src/connect.src";


&save("create temporary table journaux (jo_cd_pr bigint(20) NOT NULL,PRIMARY KEY (jo_cd_pr))");
&save("insert into journaux select distinct (tva_refour) from corsica_tva where tva_ssfamille like 'MAGAZ%' or tva_ssfamille like 'JOURN%' or tva_ssfamille like 'TAXE LOG%'");
print "<center>Marge Navire base vente neptune , prix achat dernier prix ibs (parfums) ou neptune du mois (autres)<br>";

print "<h1>Marge sans journaux</h1>";

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

# parfumerie ibs
print "<h3>Parfumerie Ibs</h3>";
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
		$query="select vdu_cd_pr,sum(vdu_qte),sum(vdu_vte) from vendu_corsica_mois where vdu_mois='$mois' and vdu_navire='$navire' group by vdu_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$qte,$vendu)=$sth->fetchrow_array)
		{
			$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
			if ($flag==0){next;} # produit non ibs
			$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
			if (($pr_type!=5)&&($pr_type!=1)){next;} # non parfums
			$pr_prac=&get("select prac from prix311208 where code='$pr_cd_pr'");
			$achat=$qte*$pr_prac;
			$marge=0;
			if ($vendu !=0){$marge=int(($vendu-$achat)*10000/$vendu)/100;}
#  			print $marge;
			$vendu=$vendu;
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
			$totalq+=$qte;
# 			print " *$totalv $totala*<br>";
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>".int($totalv)."<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totalqm+=$totalq;

		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=0;
	if ($totalvm!=0){$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;}
	print "<th align=right>".int($totalvm)."<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>".int($totv{$mois})."<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>".int($totalvg)."<br>$marge%</th>";
print "</tr></table>";


print "</td><td align=center>";


# parfumerie ibs prix corsica
print "<h3>Parfumerie Ibs prix corsica</h3>";
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
		$query="select vdu_cd_pr,sum(vdu_qte),sum(vdu_vte) from vendu_corsica_mois where vdu_mois='$mois' and vdu_navire='$navire' group by vdu_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$qte,$vendu)=$sth->fetchrow_array)
		{
			$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
			if ($flag==0){next;} # produit non ibs
			$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
			if (($pr_type!=5)&&($pr_type!=1)){next;} # non parfums
			$pr_prac=&get("select priv/2 from prix311208 where code='$pr_cd_pr'");
			$achat=$qte*$pr_prac;
			$marge=0;
			if ($vendu !=0){$marge=int(($vendu-$achat)*10000/$vendu)/100;}
#  			print $marge;
			$vendu=$vendu;
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
			$totalq+=$qte;
# 			print " *$totalv $totala*<br>";
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>".int($totalv)."<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totalqm+=$totalq;

		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=0;
	if ($totalvm!=0){$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;}
	print "<th align=right>".int($totalvm)."<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>".int($totv{$mois})."<br>$marge% </th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>".int($totalvg)."<br>$marge%</th></tr>";

print "<tr><th>Impact promo</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	$impact=int(10000*((100-2*$marge)/(200-2*$marge)))/100;
	print "<th align=right>$impact%</th>";
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
$impact=int(10000*((100-2*$marge)/(200-2*$marge)))/100;
print "<th align=right>$impact%</th>";


print "</tr></table>";

print "</td></tr>";
print "<tr><td align=center>";

# hors parfumerie ibs

print "<h3>Hors Parfumerie Ibs (hors journaux)</h3>";
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
		$query="select vdu_cd_pr,sum(vdu_qte),sum(vdu_vte) from vendu_corsica_mois where vdu_mois='$mois' and vdu_navire='$navire' group by vdu_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$qte,$vendu)=$sth->fetchrow_array)
		{
			$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
			if ($flag==0){next;} # produit non ibs
			$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
			if (($pr_type==5) || ($pr_type==1)){next;} # parfums
#  			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
#  			print "$pr_desi<br>";
			$pr_prac=&get("select prac from prix311208 where code='$pr_cd_pr'");
			$achat=$qte*$pr_prac;
			$marge=0;
			if ($vendu !=0){$marge=int(($vendu-$achat)*10000/$vendu)/100;}
#  			print $marge;
			$vendu=$vendu;
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
			$totalq+=$qte;
# 			print " *$totalv $totala*<br>";
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>".int($totalv)."<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totalqm+=$totalq;

		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=0;
	if ($totalvm!=0){$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;}
	print "<th align=right>".int($totalvm)."<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>".int($totv{$mois})."<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>".int($totalvg)."<br>$marge%</th>";
print "</tr></table>";
print "</td><td align=center>";
# hors parfumerie ibs prix corsica
print "<h3>Hors Parfumerie Ibs prix corsica (hors journaux)</h3>";
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
		$query="select vdu_cd_pr,sum(vdu_qte),sum(vdu_vte) from vendu_corsica_mois where vdu_mois='$mois' and vdu_navire='$navire' group by vdu_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$qte,$vendu)=$sth->fetchrow_array)
		{
			$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
			if ($flag==0){next;} # produit non ibs
			$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
			if (($pr_type==5) || ($pr_type==1)){next;} # parfums
# 			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
# 			print "$pr_desi<br>";
			$pr_prac=&get("select priv/2 from prix311208 where code='$pr_cd_pr'");
			$achat=$qte*$pr_prac;
			$marge=0;
			if ($vendu !=0){$marge=int(($vendu-$achat)*10000/$vendu)/100;}
#  			print $marge;
			$vendu=$vendu;
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
			$totalq+=$qte;
# 			print " *$totalv $totala*<br>";
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>".int($totalv)."<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totalqm+=$totalq;

		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=0;
	if ($totalvm!=0){$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;}
	print "<th align=right>".int($totalvm)."<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>".int($totv{$mois})."<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>".int($totalvg)."<br>$marge%</th>";
print "</tr></table>";
print "</td></tr></table>";



# <h3>Corsica</h3>

print "<h3>Produit corsica</h3>";
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
		$query="select vdu_cd_pr,sum(vdu_qte),sum(vdu_vte),sum(vdu_prac) from vendu_corsica_mois where vdu_mois='$mois' and vdu_navire='$navire' group by vdu_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$qte,$vendu,$achat)=$sth->fetchrow_array)
		{
			$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
			if ($flag!=0){next;} # produit ibs
 			$flag=&get("select count(*) from journaux where jo_cd_pr='$pr_cd_pr'")+0;
			if ($flag!=0){next;} # journaux
 			
 			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
#   			$flag=&get("select count(*) from corsica_tva where tva_refour='$pr_cd_pr' and tva_ssfamille like 'MAGAZ%' or tva_ssfamille like 'JOURN%' or tva_ssfamille like 'TAXE LOG%'")+0;
#    			if ($flag==0){next;} # pas des journaux
#   			print "$pr_cd_pr $pr_desi<br>";
			$marge=0;
			if ($vendu!=0){$marge=int(($vendu-$achat)*10000/$vendu)/100;}
			$vendu=$vendu;
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>".int($totalv)."<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=0;
	if ($marge!=0){$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;}
	print "<th align=right>".int($totalvm)."<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>".int($totv{$mois})."<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}

$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>".int($totalvg)."<br>$marge%</th>";
print "</tr></table>";

# total
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
		$query="select vdu_cd_pr,sum(vdu_qte),sum(vdu_vte),sum(vdu_prac) from vendu_corsica_mois where vdu_mois='$mois' and vdu_navire='$navire' group by vdu_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$qte,$vendu,$achat)=$sth->fetchrow_array)
		{
			$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
			if ($flag!=0){ # produit ibs
				$pr_prac=&get("select prac from prix311208 where code='$pr_cd_pr'");
				$achat=$qte*$pr_prac;
			}
			if ($vendu >0) {$marge=int(($vendu-$achat)*10000/$vendu)/100;}
			else {$marge=0;}
# 			$vendu=int($vendu);
			$totalv+=$vendu;	                     	
			$totala+=$achat;	                     	
		}
		if ($totalv==0){print "<td align=right>&nbsp;</td>";}
		else {
			$marge=int(($totalv-$totala)*10000/$totalv)/100;
			print "<td align=right>".int($totalv)."<br>$marge%</td>";
		}
		$totalvm+=$totalv;
		$totalam+=$totala;
		$totv{$mois}+=$totalv;
		$tota{$mois}+=$totala;

	}
	$marge=int(($totalvm-$totalam)*10000/$totalvm)/100;
	print "<th align=right>".int($totalvm)."<br>$marge%</th>";
	print "</tr>";
}
print "<tr><th>Total</th>";
foreach $mois (@mois) {
	$marge=int(($totv{$mois}-$tota{$mois})*10000/$totv{$mois})/100;
	print "<th align=right>".int($totv{$mois})."<br>$marge%</th>";
	$totalvg+=$totv{$mois};
	$totalag+=$tota{$mois};
}
$marge=int(($totalvg-$totalag)*10000/$totalvg)/100;
print "<th align=right>".int($totalvg)."<br>$marge%</th>";
print "</tr></table>";



