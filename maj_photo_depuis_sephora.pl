#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$query="select pr_cd_pr,pr_acquit from corsica.produit where pr_acquit>100";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_acquit)=$sth->fetchrow_array){
	$check=&get("select image_s from produit_mag where code='$pr_cd_pr'");
	if ($check ne ""){next;}
	($code,$ref)=&get("select code,ref from sephora_ref where ref='$pr_acquit'");
	$img=$code."_".$ref.".jpg";
	$code_dfa=&get("select code from dutyfreeambassade.produit_info where code_barre='$pr_cd_pr'");
	print "$pr_cd_pr <img src=/images_produits/$img width=30px> $code_dfa<br>";
}
