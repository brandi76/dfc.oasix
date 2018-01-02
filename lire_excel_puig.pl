#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
# use Spreadsheet::XLS;
use Math::Round;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=cameshop;","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";

my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/puig.xls");
$nb_feuille=$book->[0]{sheets};
print "*$nb_feuille*";
for ($i=1;$i<=$nb_feuille;$i++){
	$nb_col=$book->[$i]{maxcol};
	$nb_ligne=$book->[$i]{maxrow};
	for ($l=7;$l<=$nb_ligne;$l++){
		$ref_four=$book->[$i]{cell}[5][$l];
		$prix=$book->[$i]{cell}[9][$l];
		if ($ref_four eq ""){next;}
		$prix=round($prix*100);
		$pr_cd_pr=&get("select pr_cd_pr from corsica.produit where pr_refour='$ref_four'");
		
		if ($pr_cd_pr ne ""){
			&save("update corsica.produit set pr_prac=$prix where pr_cd_pr='$pr_cd_pr'","aff");
		}
		# print "$ref_four $pr_desi $prix<br>";
	}	
}
