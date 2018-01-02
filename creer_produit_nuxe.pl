#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});

$query="select * from produit_master where code_fournisseur1=12660";
$sth=$dbh->prepare($query);
$sth->execute();
while (($inode,$designation1,$code_chapitre,$famille,$degree,$poids_net,$poids_brut,$conditionnement,$code_fournisseur1,$refour1,$litrage,$concentration,$marque,$gamme)=$sth->fetchrow_array){
	$code=&get("select max(code) from produit_inode where inode='$inode'");
	$query="select prac,prixv from produit_prac where inode='$inode'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($prac,$priv)=$sth2->fetchrow_array;
	$prac*=100;
	&save("insert ignore into corsica.produit (pr_cd_pr,pr_desi,pr_refour,pr_four,pr_prac,pr_prx_vte) values ('$code',\"$designation1\",\"$refour1\",'$code_fournisseur1','$prac','$priv')","aff");
	&save("insert ignore into cameshop.produit (pr_cd_pr,pr_desi,pr_refour,pr_four,pr_prac,pr_prx_vte) values ('$code',\"$designation1\",\"$refour1\",'$code_fournisseur1','$prac','$priv')","aff");
	&save("insert ignore into corsica.carton (car_cd_pr,car_carton) values ('$code','$conditionnement')","aff");
	&save("insert ignore into cameshop.carton (car_cd_pr,car_carton) values ('$code','$conditionnement')","aff");
	&save("insert ignore into corsica.produit_desi (code,marque) values ('$code','Nuxe')","aff");
	&save("insert ignore into cameshop.produit_desi (code,marque) values ('$code','Nuxe')","aff");
	&save("insert ignore into corsica.produit_plus (pr_cd_pr,pr_date_creation,pr_famille) values ('$code',curdate(),5)","aff");
	&save("insert ignore into cameshop.produit_plus (pr_cd_pr,pr_date_creation,pr_famille) values ('$code',curdate(),5)","aff");
	&save("update corsica.produit set pr_four=12661 where pr_cd_pr='$code'");
	&save("update cameshop.produit set pr_four=12661 where pr_cd_pr='$code'");
	

}
