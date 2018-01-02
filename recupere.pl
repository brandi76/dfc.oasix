#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
require "./src/connect.src";
$query="select pr_cd_pr from produit where pr_desi='2'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr)=$sth->fetchrow_array)
{
	$query="select pr_desi from produit where pr_cd_pr='$pr_cd_pr'";
	$sth2=$dbhdev->prepare($query);
	$sth2->execute();
	while (($pr_desi)=$sth2->fetchrow_array)
	{
		&save("update produit set pr_desi='$pr_desi',pr_sup=2 where pr_cd_pr='$pr_cd_pr'","aff");
	}
}
