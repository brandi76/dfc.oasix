#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
$action=$html->param("action");
print $html->header;
require "./src/connect.src";
$query="select pr_cd_pr,pr_desi from ordre,produit where pr_cd_pr=ord_cd_pr order by ord_ordre";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1>";

while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array)
{
 print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>";
 print "$stock";
 print "</td></tr>";
}
print "</table>";
print "</body>";