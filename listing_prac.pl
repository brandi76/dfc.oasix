#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>corsica</title>";
require "./src/connect.src";
$query="select pr_cd_pr,pr_desi from produit where  (pr_type=1 or pr_type=5) and pr_sup!=5 and pr_sup!=6 order by pr_four,pr_cd_pr";
print "<table>";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array)
{
	$pr_prac=&prac($pr_cd_pr);
	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$pr_prac</td></tr>";
}
print "</table>";
