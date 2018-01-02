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

$query="select * from entbody where enb_cd_pr=3595200501138";
$sth=$dbh->prepare($query);
$sth->execute();
while (($enb_no,$enb_cdpr,$enb_quantite)=$sth->fetchrow_array)
{
        print "$enb_no,$enb_cdpr,$enb_quantite<br>";
}
