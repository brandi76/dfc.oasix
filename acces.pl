#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>control acces</title>";
require "./src/connect.src";

print "<center><table border=1 cellspacing=0><tr><th>date</th><th>programme</th><th>nom</th><th>ip</th></tr>";
$query="select * from traceur order by trac_date desc limit 1000";
$sth=$dbh->prepare($query);
$sth->execute();
	while (($date,$prg,$nom,$ip)=$sth->fetchrow_array)
	{
		$prg=~s/\/cgi-bin\///;
		$prg=substr($prg,0,50);
		print "<tr><td>$date</td><td>$prg</td><td>$nom</td><td>$ip</td></tr>";
	}
	print "</table>";

