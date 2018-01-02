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
my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/olga.xls");
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
      print "</td>";
    }
    $ref=$book->[$i]{cell}[1][$l];
    if (length($ref)>1){
      $code=&get("select pr_cd_pr from produit where pr_refour='$ref' and pr_four=1260");
      if ($code ne ""){push(@liste,$code);}
      else {
	$ref=$book->[$i]{cell}[2][$l];
	if (length($ref)>1){
	$code=&get("select pr_cd_pr from produit where pr_refour='$ref' and pr_four=1260");
	if ($code ne ""){push(@liste,$code);}
	}
      }
    }
    
    print "</tr>";
  }
  print "</table>";
}
@bases_client=("camairco","aircotedivoire","togo");
$query="select pr_cd_pr,pr_desi,pr_refour from produit where pr_four=1260 and pr_cd_pr<900000 order by pr_desi";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_refour)=$sth->fetchrow_array){
  if (grep /$pr_cd_pr/,@liste){next;}
  $check=0;
  foreach $client (@bases_client) {
    if ($client eq "dfc"){next;}
    $check+=&get($query="select count(*) from $client.trolley,$client.lot where tr_code=lot_nolot and tr_cd_pr='$pr_cd_pr' and lot_flag=1","af")+0;
  }
  if ($check==0){next;}
  print "$pr_cd_pr $pr_desi $pr_refour :$check<br>";
  $nb++;
}  
print "<br>$nb";

# foreach (@liste){
#   $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$_'");
#   print "$_ $pr_desi <br>";
# }

;1