#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";

open (FILE,">/mnt/windows_bocal/perl/tampon/tpecorsica.txt");
print FILE "Z;1000;\r\n";
require "./src/connect.src";
$query="select * from produit where pr_cd_pr>100000000";
$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
while (($pr_cd_pr,$pr_desi,$pr_prx_vte)=$sth->fetchrow_array)
{
	$pr_desi=substr($pr_desi,0,16);
	print FILE "$i++;$pr_cd_pr;$pr_desi;$pr_prx_vte;;;;;;;;;;0;0;0;0\r\n";
}
print FILE "V;1;CORSICA;;0;0;1;0;0.00\r\n";
print FILE "E;0;CORSICA BOUTIQUE;;;;;MERCI DE VOTRE VISITE;A BIENTOT;;0\r\n";
print FILE "END;\r\n";
close(FILE);