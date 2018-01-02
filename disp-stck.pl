#!/usr/bin/perl
use CGI;
use DBI();
# $html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "../oasix/simple.lib";
$html=new CGI;

$produit=$html->param("produit");
$desi=$html->param("desi");
$action=$html->param("action");

print $html->header;
require "./src/connect.src";

if ($action eq ""){
print "<table>";
$query="select pr_cd_pr,pr_desi from ordre,produit where ord_cd_pr=pr_cd_pr order by ord_ordre";
$sth=$dbh->prepare($query);
$sth->execute();
while (@res=$sth->fetchrow_array)
{
		print  "<tr><td><a href=disp-stck.pl?action=stock&produit=$res[0]>$res[0]</a></td><td>$res[1]</td></tr>";
}

print "</table>";
}
else
{
$query="select pr_cd_pr,pr_desi,pr_stre,pr_diff,pr_stvol from produit where pr_cd_pr=$produit";
$sth=$dbh->prepare($query);
$sth->execute();
($pr_cd_pr,$pr_desi,$pr_stre,$pr_diff,$pr_stvol)=$sth->fetchrow_array;
$pr_stre/=100;
$pr_diff/=100;
$pr_stvol/=100;

print "<center><p>$pr_cd_pr $pr_desi</p><br>";
print "Stock:$pr_stre<br>";
print "Diff:$pr_diff<br>";
print "Stock vol:$pr_stvol<br>";
print "Stock entrepot:",$pr_stre+$pr_diff-$pr_stvol,"<br>";

 }
