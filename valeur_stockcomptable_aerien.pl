#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";

	print $html->header;
	print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
	<!--
	#saut { page-break-after : right }
	-->
	</style></head><body>";

require "./src/connect.src";
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit,trolley where pr_prac>0 and pr_prac<30000 and pr_cd_pr=tr_cd_pr and tr_code=211 order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();

print "<table><tr><th>code</th><th>désignation</th><th>prix achat</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
{
		$pr_prac=&prac($pr_cd_pr);
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$pr_prac</td></tr>";
}
print "</table>";
