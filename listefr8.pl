#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

$ventil=6;
$titre="Alcools";
print $html->header;
require "./src/connect.src";
$query="select pr_cd_pr,pr_desi,pr_pdn,pr_deg,pr_stre from produit where pr_ventil=$ventil and pr_stre>0 ";
$sth=$dbh->prepare($query);
$sth->execute();

print "<center><h1>$titre</h1><br><br>";
print "<table><caption><h2>Produit douanier</h2></caption><tr><th>produit</th><th>stock</th><th>Document entrée</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_pdn,$pr_deg,$pr_stre)=$sth->fetchrow_array)
{
	$pr_stre/=100;
	$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$pr_cd_pr'";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
	if (grep(/^IM/,$fr8_doc)){ 
		print "<tr><td>$pr_cd_pr $pr_desi</td><td>$pr_stre</td><td>$fr8_doc</td></tr>";
	}
}		
print "</table><br>";

$query="select pr_cd_pr,pr_desi,pr_pdn,pr_deg,pr_stre from produit where pr_ventil=$ventil and pr_stre>0";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table><caption><h2>Produit communautaire</h2></caption><tr><th>produit</th><th>stock</th><th>Document entrée</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_pdn,$pr_deg,$pr_stre)=$sth->fetchrow_array)
{
	$pr_stre/=100;
	$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$pr_cd_pr'";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
	if (! grep(/^IM/,$fr8_doc)&&($fr8_doc ne "")){ 
		print "<tr><td>$pr_cd_pr $pr_desi</td><td>$pr_stre</td><td>$fr8_doc</td></tr>";
	}
}		
print "</table><br>";


$query="select pr_cd_pr,pr_desi,pr_pdn,pr_deg,pr_stre from produit where pr_ventil=$ventil and pr_stre>0 and pr_cd_pr!=1222211 and pr_cd_pr!=1221490";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table><caption><h2>Produit indefinie</h2></caption><tr><th>produit</th><th>stock</th><th>Document entrée</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_pdn,$pr_deg,$pr_stre)=$sth->fetchrow_array)
{
	$pr_stre/=100;
	$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$pr_cd_pr'";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
	if ($fr8_doc eq ""){ 
		print "<tr><td>$pr_cd_pr $pr_desi</td><td>$pr_stre</td><td>$fr8_doc</td></tr>";
	}
}		
print "</table>";
