#!/usr/bin/perl

use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
$no=$html->param("no");
$serial=$html->param("serial");
if ($no >0) {
 &save("replace into oasix_tpe values ('$no','$serial')");
}
print "<title>liste tpe</title>";
print "<table border=1><tr><th>Numero</th><th>No de serie</th></tr>";
$query="select oa_num,oa_serial from oasix_tpe order by oa_num";
# print $query;
$sth=$dbh->prepare($query);
$sth->execute();
while (($oa_num,$oa_serial)=$sth->fetchrow_array)
{
	print "<tr><td>$oa_num</td><td>$oa_serial</td></tr>";
}
print "<form><td><input type=text name=no></td><td><input type=text name=serial size=12></td></tr>";
print "</table>";
print "<input type=submit></form>";
