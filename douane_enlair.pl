#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>en lair</title>";
require "./src/connect.src";
print "<h2>Qte hors entrepot au 21 Novembre</h2><br>";
print "<table border=1 cellspacing=0>";
$query="select distinct so_appro from sortie,produit where so_cd_pr=pr_cd_pr and (pr_ventil=6 or pr_ventil=15)";
$sth=$dbh->prepare($query);
$sth->execute();
$pr=120030;
while (($appro)=$sth->fetchrow_array){
	print "<tr><td>$appro </td><td>&nbsp;";
	$query="select pr_cd_pr,pr_desi,so_qte/100,pr_pdn from sortie,produit where so_cd_pr=pr_cd_pr and pr_ventil=15 and so_appro=$appro ";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$tab=0;
	while (($pr_cd_pr,$pr_desi,$pr_pdn,$so_qte)=$sth2->fetchrow_array)
	{
		print "$pr_cd_pr,$pr_desi,$so_qte,$pr_pdn<br>";
		$tab+=$so_qte*$pr_pdn;
	}
	print "</td><td>";
	$query="select pr_cd_pr,pr_desi,pr_pdn,pr_deg/100,so_qte/100 from sortie,produit where so_cd_pr=pr_cd_pr and pr_ventil=6 and so_appro=$appro";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$alc=0;
	$alcq=0;
	while (($pr_cd_pr,$pr_desi,$pr_pdn,$pr_deg,$so_qte)=$sth2->fetchrow_array)
	{
		print "$pr_cd_pr,$pr_desi,$so_qte,$pr_pdn,$pr_deg<br>";
		$alc+=$so_qte*$pr_pdn*$pr_deg/100000;
        	$alcq{$pr_cd_pr}+=$so_qte;
	
	}
	print "</td><td>tabac:$tab grs<br>alcool:$alc litre alcool pur</td></tr>";
	$totaltab+=$tab;
	$totalalc+=$alc;
}

require "./src/connect.src";

$query="select distinct v_code from vol where v_code='22578' or v_code='22579'";
$sth=$dbh2->prepare($query);
$sth->execute();
while (($appro)=$sth->fetchrow_array){
	print "<tr><td>$appro</td><td>&nbsp;";
	$query="select pr_cd_pr,pr_desi,ap_qte0/100,pr_pdn from appro,produit where ap_cd_pr=pr_cd_pr and pr_ventil=15 and ap_code=$appro";
	$sth2=$dbh2->prepare($query);
	$sth2->execute();
	$tab=0;
	while (($pr_cd_pr,$pr_desi,$pr_pdn,$so_qte)=$sth2->fetchrow_array)
	{
		print "$pr_cd_pr,$pr_desi,$so_qte,$pr_pdn<br>";
		$tab+=$so_qte*$pr_pdn;
	}
	print "</td><td>";
	$query="select pr_cd_pr,pr_desi,pr_pdn,pr_deg/100,ap_qte0/100 from appro,produit where ap_cd_pr=pr_cd_pr and pr_ventil=6 and ap_code=$appro";
	$sth2=$dbh2->prepare($query);
	$sth2->execute();
	$alc=0;
	$alcq=0;
	while (($pr_cd_pr,$pr_desi,$pr_pdn,$pr_deg,$so_qte)=$sth2->fetchrow_array)
	{
		print "$pr_cd_pr,$pr_desi,$so_qte,$pr_pdn,$pr_deg<br>";
		$alc+=$so_qte*$pr_pdn*$pr_deg/100000;
 	      	$alcq{$pr_cd_pr}+=$so_qte;

	}
	print "</td><td>tabac:$tab grs<br>alcool:$alc litre alcool pur</td></tr>";
	$totaltab+=$tab;
	$totalalc+=$alc;
}

print "</table>";
print "Total tabac:$totaltab grs<bR>";
print "Total alcool pur :$totalalc litre<bR>";
foreach $cle (keys(%alcq)){
	$query="select pr_desi,pr_deg,pr_pdn from produit where pr_cd_pr='$cle'";
	$sth2=$dbh2->prepare($query);
	$sth2->execute();
	($pr_desi,$pr_deg,$pr_pdn)=$sth2->fetchrow_array;
	print "$cle;$pr_desi;$pr_deg;$pr_pdn;$alcq{$cle}<br>";
}
