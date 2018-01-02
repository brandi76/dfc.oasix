#!/usr/bin/perl
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
use DBI();
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
use CGI;
$html=new CGI;
print $html->header();
# print "<select name=base>";
foreach $client (@bases_client){
	 if ($client eq "dfc"){next;}
	&save("update $client.produit,dfc.produit set $client.produit.pr_douane=dfc.produit.pr_douane where $client.produit.pr_cd_pr=dfc.produit.pr_cd_pr","aff");
}	
