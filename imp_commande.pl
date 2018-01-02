#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;

# print $html->header;
require "./src/connect.src";
print $html->header();
$query="select dt_no from atadsql where dt_cd_dt=205";
$sth=$dbh->prepare($query);
$sth->execute();
($commande)=$sth->fetchrow_array;
	$commande+=1;
	$query="update atadsql set dt_no=$commande where dt_cd_dt=205";
	$sth=$dbh->prepare($query);
	$sth->execute();
$date=`/bin/date +%d/%m/%y`;
$datesimple="10".`/bin/date +%y%m%d`;
open(FILE,"retour_navire.csv");
@file=<FILE>;
foreach (@file){
	($produit,$qte)=split(/;/,$_);

	$query="select pr_cd_pr,pr_desi,pr_refour,pr_prac/100,pr_type,pr_prx_rev from produit where pr_cd_pr='$produit'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_cd_pr,$pr_desi,$pr_refour,$pr_prac,$pr_type,$remise)=$sth->fetchrow_array;
	$qte*=100;
	$query="replace into commande values ('$commande','500','$pr_cd_pr','$qte','$pr_prac','','$datesimple','')";
	print "$query<br>";
	$sth2=$dbh->prepare($query);
	$sth2->execute();

}

# FONCTION : nb_jour(jour,mois,annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : le jour mois annee (yyyy)
# SORTIE : le nombre de seconde

sub nb_jour{
	my ($jour)=$_[0];
	my ($mois)=$_[1];
	my ($annee)=$_[2];

	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}
sub nb_jour_an
{
	my ($annee)=$_[0];
	my ($n)=0;
	for (my($i)=1970; $i<$annee; $i++) {
		$n += 365; 
		if (&bissextile($i)){$n++;}
	}
	return($n);
}

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
}


# -E Creation d'une commande fournisseur a partie d'un fichier csv (desarmement navire)
