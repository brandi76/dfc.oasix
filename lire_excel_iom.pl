#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});

print "<style>";
print "tr:nth-child(even){background:lavender;}";
print "</style>";
# my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/GIVENCHY.xls");
my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/iom.xls");
# print $book->[1]{F13};
$nb_feuille=$book->[0]{sheets};
for ($i=1;$i<=$nb_feuille;$i++){
  $nb_col=$book->[$i]{maxcol};
  $nb_ligne=$book->[$i]{maxrow};
  print $i." ".$book->[$i]{label}."<br>";
  print "<table border=1;cellspacing=0,callpadding=0>";
  print "<tr bgcolor=orange>";
  for ($j=1;$j<=$nb_col;$j++){
    print "<th>";
    print $book->[$i]{cell}[$j][2]."</th>";
  }
  print "</tr>";
  for ($l=3;$l<=$nb_ligne;$l++){
    print "<tr>";
    for ($j=1;$j<=$nb_col;$j++){
      print "<td>";
      print $book->[$i]{cell}[$j][$l];
      if ($j==2){
	$ref=$book->[$i]{cell}[$j][$l];
	if (length($ref)>1){
	  $code=&get("select pr_cd_pr from produit where pr_refour='$ref' and pr_four=1290");
	  print "*";
	  if ($code ne ""){push(@liste,$code);}
	}
      }
      print "</td>";
     
    }  
    print "</tr>";
  }
  print "</table>";
}

foreach (@liste){
  $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$_'");
  print "$_ $pr_desi <br>";
}

;1