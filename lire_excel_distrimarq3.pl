#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
# use Spreadsheet::XLS;
use Math::Round;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=aircotedivoire;","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";
@bases_client=("dfc","camairco","aircotedivoire","togo","tacv");
my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/distrimarq2.xls");
$nb_feuille=$book->[0]{sheets};
# print "*$nb_feuille*";
$i=1;
print "<table>";
for ($i=0;$i<=$nb_feuille-1;$i++){
	$nb_col=$book->[$i]{maxcol};
	$nb_ligne=$book->[$i]{maxrow};
	for ($l=1;$l<=$nb_ligne;$l++){
		for ($j=1;$j<12;$j++){
			print $ref=$book->[$i]{cell}[$j][$l].";";
		}
		print "<br>";	
	}	
}
print "</table>";