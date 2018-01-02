#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
 `/home/intranet/cgi-bin/radio_1.3.pl`;
$query="select * from radio order by rad_no";
$sth=$dbh->prepare($query);
$sth->execute;
while ($rad_no= $sth->fetchrow_array) {
 	print "$rad_no ";
        print &get("select pr_desi from produit,radio_produit where pr_cd_pr=rap_cd_pr and rap_no='$rad_no'");
        print "<br>";
	$i++;
}
print $i;


