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
		print  "<tr><td><a href=ventjpj.pl?action=vente&produit=$res[0]>$res[0]</a></td><td>$res[1]</td></tr>";
}

print "</table>";
}
else
{
$query="select pr_desi from produit where pr_cd_pr=$produit";
$sth=$dbh->prepare($query);
$sth->execute();
$desi=$sth->fetchrow_array;
$premiere=&nb_jour(1,1,2004);
$derniere=&nb_jour(31,03,2004);
$total=0;


 print "<center><table width=60%><caption><b>$produit $desi $premiere  $derniere<tr>";
 $query="select * from vtsjour where vtsj_cd_pr=$produit and vtsj_jour>=$premiere and vtsj_jour<=$derniere order by vtsj_jour";
 $sth=$dbh->prepare($query);
 $sth->execute();
 while (@res=$sth->fetchrow_array)
 {
 		print  "<tr><td>$res[1] ",&julian($res[1]),"</td><td>",$res[2]/100,"</td></tr>";
 	$total+=$res[2]/100;
 }

 print "</table>";
 print "<b>total:$total<br>";

 }
