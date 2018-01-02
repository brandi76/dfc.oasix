#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
$html=new CGI;
print $html->header;
require "./src/connect.src";
print `date`;
print "<table border=1 cellspacing=0>";
print &ligne_tab("<b>","Produit","Désignation");
$query="select pr_cd_pr,pr_desi from produit  order by pr_cd_pr";
$sth = $dbh->prepare($query);
$sth->execute;
while (($pr_cd_pr,$pr_desi) = $sth->fetchrow_array) {
	
	print &ligne_tab("","$pr_cd_pr","$pr_desi");
}
print "</table>";

