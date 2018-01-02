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
</style><title>livraison</title></head><body>";


require "./src/connect.src";
# $dbh = DBI->connect("DBI:mysql:host=192.168.1.87:database=FLYDEV;","root","",{'RaiseError' => 1});

print "<table border=1 cellspacing=0><tr><th>Date</th><th>Type</th><th>Produit</th><th>Designation</th><th>qte</th><th>Nom</th>";
$query="select trace_jour.* from trace_jour,errdep where tjo_type=5 or (tjo_cd_pr=erdep_cd_pr and tjo_depart=erdep_depart) order by tjo_date desc limit 100";
$sth=$dbh->prepare($query);
$sth->execute();
while (($tjo_date,$tjo_type,$tjo_cd_pr,$tjo_qte,$tjo_nom,$tjo_justificatif)=$sth->fetchrow_array)
{
	$tjo_qte/=100;
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$tjo_cd_pr'");
	print "<tr><td>$tjo_date</td><td>$tjo_type</td><td>$tjo_cd_pr</td><td>$pr_desi</td><td>$tjo_qte</td><td>$tjo_nom</td><td>$tjo_justificatif</td>";
	print "</tr>";
}
print "</table>";