#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<body bgcolor=#efefef>";
require "./src/connect.src";
require "./src/connect.src";
$four=$html->param("four");

$requete1=$html->param("requete1");
$requete2=$html->param("requete2");
$base1=$html->param("base1");
$base2=$html->param("base2");

if ($requete1 eq ""){
	print "<form>";
	print "base <input type=texte name=base1 value=FLY> <textarea name=requete1 cols=80></textarea><br><br>";
	print "base <input type=texte name=base2 value=FLYDEV> <textarea name=requete2 cols=80 ></textarea><br><br>";
	print "<input type=submit></form>";
}
else
{
	if ($base1 eq "FLY") {$sth=$dbh->prepare($requete1);}
	else {$sth=$dbh2->prepare($requete1);}
	$sth->execute();
	while ((@tab)=$sth->fetchrow_array)
	{
		foreach $el (@tab) {
			print "$el "
		} 
		print "<br>";
	}
	print "<hr width=80%>";
	if ($requete2 ne "") {
		if ($base2 eq "FLY") {
		$sth=$dbh->prepare($requete2);}
		else {$sth=$dbh2->prepare($requete2);}
		$sth->execute();
		while ((@tab)=$sth->fetchrow_array)
		{
			foreach $el (@tab) {
				print "$el "
			} 
			print "<br>";
		}
	}
}
