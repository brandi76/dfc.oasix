#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
$html=new CGI;
print $html->header;
require "./src/connect.src";
print `date`;
print "<table border=1 cellspacing=0>";
print &ligne_tab("<b>","Produit","Désignation","Prix achat","Remise facture","Remise fin d'année","Prix final");
$query="select pr_cd_pr,pr_desi,pr_prac/100,pr_prx_rev from produit  order by pr_four";
$sth = $dbh->prepare($query);
$sth->execute;
while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_rem) = $sth->fetchrow_array) {
	
	$pr_remise2=&get("select pr_remise_com from produit_plus where pr_cd_pr='$pr_cd_pr'")+0;
	$prix=$pr_prac; 
	if ($pr_rem >0){$prix=$pr_prac-($pr_prac*$pr_rem/100);}
	if ($pr_remise2 >0){$prix=$prix-($prix*$pr_remise2/100);}
	$prix=int($prix*100)/100;
	print &ligne_tab("","$pr_cd_pr","$pr_desi","$pr_prac","$pr_rem%","$pr_remise2 %","$prix");
}
print "</table>";
print "*";
