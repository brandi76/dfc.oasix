#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;

require "./src/connect.src";

=pod
$query="show tables";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table>";
while (($table)=$sth->fetchrow_array)
{
		$qte=&get("select count(*) from $table");
		if ($qte >50000){
			print "<tr><td align=right>$qte</td><td>$table</td></tr>";
	}
}
print "</table>";

=cut

$query="select * from navire2 where nav_date<'2006-01-01'";
$sth=$dbh->prepare($query);
$sth->execute();
while ((@tab)=$sth->fetchrow_array)
{
		$query="replace into navire2_2005 values (";
		foreach (@tab) {
			$query.="'".$_."',";
		}
		chop($query);
		$query.=")";
		print "$query<br>";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
}
