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
foreach $navire (@navire) {
	$totalv=0;
	$totalvv=0;
	$query="select tva_refour,tva_qte,tva_prixv,tva_type from corsica_tva where tva_date>='2009-03-01' and tva_date<='2009-03-31' and tva_nom='$navire' and tva_prixv!=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte,$vendu,$tva_type)=$sth->fetchrow_array)
	{
		$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
		if ($flag==0){next;} # produit non ibs
		$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
		if (($pr_type!=5)&&($pr_type!=1)){next;} # non parfums
		$venduv=0;
		if ($tva_type eq "PUBLIC"){$venduv=$vendu;}
		if ($tva_type eq "Remise 5%"){$venduv=$vendu/0.95;}
		if ($tva_type eq "EQUIPAGE"){$venduv=$vendu/0.80;}
		if ($tva_type eq "Remise 20%"){$venduv=$vendu/0.80;}
		if ($tva_type eq "Remise 50%"){$venduv=$vendu/0.50;}
		if ($tva_type eq "Remise 40%"){$venduv=$vendu/0.60;}
		if ($tva_type eq "Bon d Acha"){$venduv=$vendu+10;}
		if ($venduv==0){ print "erreur $tva_type $navire $pr_cd_pr<br>";exit;}
		$totalv+=$vendu;
		$totalvv+=$venduv;

	}
	
print "Mars $navire ca réalisé:$totalv remise accordée:";
print int($totalvv-$totalv);
print " ";
print int((100-($totalv*100/$totalvv))*100)/100;
print "%<br>";	
}
exit;
foreach $navire (@navire) {
	$totalv=0;
	$totalvv=0;
	$query="select tva_refour,tva_qte,tva_prixv,tva_type from corsica_tva where tva_date>='2009-02-01' and tva_date<='2009-02-31' and tva_nom='$navire' and tva_prixv!=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte,$vendu,$tva_type)=$sth->fetchrow_array)
	{
		$flag=&get("select flag from prix311208 where code='$pr_cd_pr'")+0;
		if ($flag==0){next;} # produit non ibs
		$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
		if (($pr_type!=5)&&($pr_type!=1)){next;} # non parfums
		$venduv=0;
		if ($tva_type eq "PUBLIC"){$venduv=$vendu;}
		if ($tva_type eq "Remise 5%"){$venduv=$vendu/0.95;}
		if ($tva_type eq "EQUIPAGE"){$venduv=$vendu/0.80;}
		if ($tva_type eq "Remise 20%"){$venduv=$vendu/0.80;}
		if ($tva_type eq "Remise 50%"){$venduv=$vendu/0.50;}
		if ($tva_type eq "Remise 40%"){$venduv=$vendu/0.60;}
		if ($tva_type eq "Bon d Acha"){$venduv=$vendu+10;}
		if ($venduv==0){ print "erreur $tva_type $navire $pr_cd_pr<br>";exit;}
		$totalv+=$vendu;
		$totalvv+=$venduv;

	}
	
print "fevrier $navire ca réalisé:$totalv remise accordée:";
print int($totalvv-$totalv);
print " ";
print int((100-($totalv*100/$totalvv))*100)/100;
print "%<br>";	
}