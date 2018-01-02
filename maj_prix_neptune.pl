#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";


$query="select tva_neptune,floor(tva_prac*100) from corsica_tva where tva_date>'2008-01-01' order by tva_date";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nep_cd_pr,$nep_prac)=$sth->fetchrow_array)
{
	$query="update neptune set nep_prac='$nep_prac' where nep_cd_pr='$nep_cd_pr'";
	print "$query<br>";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
}
