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
my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/distrimarq_avril_2017.xls");
$nb_feuille=$book->[0]{sheets};
print "*$nb_feuille*";
$i=1;
print "<table>";
for ($i=0;$i<=$nb_feuille-1;$i++){
	$nb_col=$book->[$i]{maxcol};
	$nb_ligne=$book->[$i]{maxrow};
	# print $i." ".$book->[$i]{label};
	$colone=6;
	$intitule=$book->[$i]{cell}[6][2];
	if ((grep /RRP/,$intitule)||(grep /Suggested/,$intitule)) {
		$intitule=$book->[$i]{cell}[5][2];
		$colone=5;
	}
	if ($i==13){
		$intitule=$book->[$i]{cell}[5][2];
		$colone=5;
	}
	# 	print $nb_ligne;
	# print $intitule;
	# print $book->[$i]{cell}[6][8];
	# print "\n";
	for ($l=1;$l<=$nb_ligne;$l++){
	
		# if ($book->[$i]{cell}[$colone][$l] eq ""){next};
		# if ($book->[$i]{cell}[0][$l] eq ""){next};
		$ref=$book->[$i]{cell}[2][$l];
		if ($ref eq "m"){$marque=$book->[$i]{cell}[3][$l];}
		$qte=$book->[$i]{cell}[9][$l]+0;
		$code=$book->[$i]{cell}[11][$l];
		
		# if ($qte<=0){next;}
		if (grep /[A-Z,0-9]/,$ref){
			$pr_prac=round($book->[$i]{cell}[$colone][$l]*100)/100;
			print "<tr><td>$ref</tD><td>";
			print "$code";
			print "</td>";
			print "<td>$marque</td><td>";
			print $ref=$book->[$i]{cell}[3][$l];
			print "</td><td>";
			print $ref=$book->[$i]{cell}[4][$l];
			print "</td>";
			print "<td>$qte</td>";
			print "<td>$pr_prac</td>";
			print "</tr>";
		}
		$pr_prac=round($book->[$i]{cell}[$colone][$l]*100,0);
		# $pr_cd_pr=&get("select pr_cd_pr from produit where pr_refour='$ref' and pr_four=1260","aff"); 
		# if ($pr_cd_pr ne ""){
			# print "$pr_cd_pr\n";
		# }	
	}	
}
print "</table>";