#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
use Math::Round;
$html=new CGI;
print $html->header();
@bases_client=("dfc","camairco","aircotedivoire","togo","tacv");
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$option=$html->param("option");
print "<style>";
print "tr:nth-child(even){background:lavender;}";
print "</style>";
# my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/GIVENCHY.xls");
my $book  = ReadData ("/var/www/cgi-bin/dfc.oasix/olga.xls");
# print $book->[1]{F13};
$nb_feuille=$book->[0]{sheets};
for ($i=1;$i<=$nb_feuille;$i++){
  $pass=0;
  $nb_col=$book->[$i]{maxcol};
  $nb_ligne=$book->[$i]{maxrow};
  for ($l=3;$l<=$nb_ligne;$l++){
     $ok=0;
    $ref=$book->[$i]{cell}[1][$l];
    if (length($ref)>1){
      $match=0;
      $code=&get("select pr_cd_pr from produit where pr_refour='$ref' and pr_four=1260");
      if ($code ne ""){$ok=1;$match=1;}
      else {
	$ref=$book->[$i]{cell}[2][$l];
	if (length($ref)>1){
	$code=&get("select pr_cd_pr from produit where pr_refour='$ref' and pr_four=1260");
	if ($code ne ""){$ok=1;$match=2;}
	}
      }
    }
    if ($ok==1){
      if ($pass==0){
	$prepack=0;
        print $i." ".$book->[$i]{label}."<br>";
	print "<table border=1;cellspacing=0,callpadding=0>";
	print "<tr bgcolor=orange>";
	$barre=0;
	for ($j=1;$j<=$nb_col;$j++){
	  print "<th>";
	  $desi_col=$book->[$i]{cell}[$j][2];
	  print "$desi_col</th>";
	  if (grep /Pack/,$desi_col){$prepack=1;}
  	  if (grep /pack/,$desi_col){$prepack=1;}
	  if (grep /EAN CODE/,$desi_col){$barre=$j;}

	}
	print "</tr>";
	$pass=1;
      }
      if ($option eq "maj_refour"){
	$ref_four=$book->[$i]{cell}[2][$l];
	foreach $client (@bases_client) {
	  &save ("update $client.produit set pr_refour='$ref_four' where pr_cd_pr='$code'","aff");
	}  
      } 
      print "<tr>";
      $prix_vente=0;
      $prix_public=0;
      $code_barre="";
      for ($j=1;$j<=$nb_col;$j++){
	print "<td>";
	$aff=$book->[$i]{cell}[$j][$l];
	if (($prepack)&&($j==6)){
	  $prix_vente=$book->[$i]{cell}[$j][$l];
	  $prix_vente=round($prix_vente*100)/100;
	  $aff=$prix_vente;
	}
	if (($prepack)&&($j==7)){
	  $prix_public=$book->[$i]{cell}[$j][$l];
	  $prix_public=round($prix_public*100)/100;
	  $aff=$prix_public;
	}
	if ((! $prepack)&&($j==5)){
	  $prix_vente=$book->[$i]{cell}[$j][$l];
	  $prix_vente=round($prix_vente*100)/100;
	  $aff=$prix_vente;
	}
	if ((! $prepack)&&($j==6)){
	  $prix_public=$book->[$i]{cell}[$j][$l];
	  $prix_public=round($prix_public*100)/100;
	  $aff=$prix_public;
	}
	if (($j==$barre)&&($barre>4)){
	  $code_barre=$book->[$i]{cell}[$j][$l];
	}
	
# 	if ($match==$j){print " *";}
	print "$aff</td>";
      }
#       $prix_vente=0;
#       if ($prepack){$prix_vente=$book->[$i]{cell}[6][$l];}else{$prix_vente=$book->[$i]{cell}[5][$l];}
      $query="select pr_desi,pr_pdn,pr_prac/100 from produit where pr_cd_pr='$code'";
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($pr_desi,$pr_pdn,$pr_prac)=$sth->fetchrow_array;
      $query="select car_carton,car_pal from carton where car_cd_pr='$code'";
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($car_carton,$car_pal)=$sth->fetchrow_array;
      $color="white";
      if ($prepack){
 	$pack=$book->[$i]{cell}[5][$l];
      }
      $cont=$book->[$i]{cell}[4][$l];
      if ($prepack) {
	if ($cont+0!=$pr_pdn+0){
	  $color="red";
	  $lock=&get("select pr_remplace from produit_plus where pr_cd_pr='$pr_cd_pr'");
	  if ($lock eq "loc"){$color="green";}
	  else {
	    if ($option eq "maj_pdn"){
	      foreach $client (@bases_client) {
		&save ("update $client.produit set pr_pdn='$cont' where pr_cd_pr='$code'","aff");
	      }  
	    }
	  }
	}
      }
      $ecart=$pr_prac-$prix_vente;
#       if ((($ecart >3)||($ecart<-3))&&($pr_prac>0)){$color="red";}

      print "<tr bgcolor=$color><td>$col_prix &nbsp;</td><td>$code</td><td>$pr_desi</td><td>$pr_pdn</td>";
      if ($prepack){ 
	print "<td>$car_carton</td>";
	if ($option eq "maj_carton"){
	  foreach $client (@bases_client) {
	    &save ("update $client.carton set car_carton='$pack' where car_cd_pr='$code'","aff");
	  }  
	}	
      }
      $pr_prac+=0;
      print "<td>$pr_prac</td>";
      if ($option eq "maj_prac"){
	$new_prix=int($prix_vente*100);
      	foreach $client (@bases_client) {
	  &save ("update $client.produit set pr_prac='$new_prix' where pr_cd_pr='$code'","aff");
	}  
      }
      if ($option eq "maj_codebarre"){
      	foreach $client (@bases_client) {
	  &save ("update $client.produit set pr_codebarre='$code_barre' where pr_cd_pr='$code'","aff");
	}  
      }
      print "<td>ecart:$ecart</td></tr>";
      $nb++;
    }
  }
  if ($pass==1){print "</table>";}
}
print "<br>$nb fin";
