#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";
$client2="aircotedivoire";
$client="cameshop";
$query="select pr_cd_pr,pr_desi,pr_prac,pr_stre from $client.produit";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$prac,$pr_stre)=$sth->fetchrow_array){
	$prac/=100;
	$pr_stre/=100;
	$dernier_prix=&get("select livb_prix from dfc.livraison_b,dfc.livraison_h,$client.enthead where enh_document=livh_id and livb_id=livh_id and livb_code='$pr_cd_pr' and livh_base='$client' order by livh_id desc limit 1")+0;
	# if ($dernier_prix==0){
		# $dernier_prix=&get("select livb_prix from dfc.livraison_b,dfc.livraison_h,$client2.enthead where enh_document=livh_id and livb_id=livh_id and livb_code='$pr_cd_pr' and livh_base='$client2' order by livh_id desc limit 1")+0;
	# }
	
	if ($dernier_prix==0){next;}
	if ($dernier_prix!=$prac){
		print "$pr_cd_pr $pr_desi $prac $dernier_prix";
		$bl=&get("select livb_id from dfc.livraison_b,dfc.livraison_h,$client.enthead where enh_document=livh_id and livb_id=livh_id and livb_code='$pr_cd_pr' and livh_base='$client' order by livh_id desc limit 1");
		print " bl:$bl";
		$tot=($dernier_prix-$prac)*$pr_stre;
		print " $tot";
		$val+=($dernier_prix-$prac)*$pr_stre;
		&save("update $client.produit set pr_prac=$dernier_prix*100 where pr_cd_pr='$pr_cd_pr'");
		print "<br>";
	
	}
	
}
print $val;
=pod
$query="select togo.produit.pr_cd_pr,togo.produit.pr_prac,aircotedivoire.produit.pr_prac from aircotedivoire.produit,togo.produit where togo.produit.pr_cd_pr=aircotedivoire.produit.pr_cd_pr and aircotedivoire.produit.pr_prac!=togo.produit.pr_prac";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$togo_pr_prac,$aircotedivoire_pr_prac)=$sth->fetchrow_array){
if ($aircotedivoire_pr_prac>$togo_pr_prac){
	&save("update togo.produit set pr_prac=$aircotedivoire_pr_prac where pr_cd_pr=$pr_cd_pr","aff");
}
else{
	&save("update aircotedivoire.produit set pr_prac=$togo_pr_prac where pr_cd_pr=$pr_cd_pr","aff");
}	
}

