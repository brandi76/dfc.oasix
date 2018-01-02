#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$mois--;
$max=$an*10000+$mois*100;
if ($jour>15){$max+=100;}
$max+=100;
print $max;

$today=&nb_jour($jour,$mois,$an);
$dateref=&nb_jour(1,$mois,$an);
$query="select es_cd_pr,es_no_do,es_dt,es_qte,es_qte_en,es_type from enso";
$sth3=$dbh->prepare($query);
$sth3->execute();
while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth3->fetchrow_array){
	$date_enso=$es_dt;
	if (($es_no_do >"10000")&&($es_qte>0)){
		$query="select v_date_jl from vol where v_code='$es_no_do' and v_rot=1";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$date=$sth2->fetchrow_array;
		$date_enso=&julian($date,"YYYYMMDD");
	}
	if ($date_enso>$max){next;}
	
	$query="update produit set pr_stanc=pr_stanc+($es_qte_en-$es_qte) where pr_cd_pr=$es_cd_pr";
	print "$query<br>";
	$sth2=$dbh->prepare($query);
 	$sth2->execute();
	$query="delete from enso where es_cd_pr='$es_cd_pr' and es_no_do='$es_no_do' and es_dt='$es_dt'";
	$sth2=$dbh->prepare($query);
 	$sth2->execute();
	print "$query<br>";
	print "<br>";
}
$somme=&get("select sum(pr_stanc) from produit");
# &save("update atad set dt_no=$somme where dt_cd_dt=50");
print "fin";
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
# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/mm/DD
# SORTIE : la date formatée

sub julian {
	my ($val)=$_[0];
	my ($option)=$_[1];
	$val=$val*60*60*24;
	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime($val);    
	$annee=substr($annee,1,2);
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);

	$option=lc($option);
	if (lc($option) eq "")
	{
		($option = "dd/mm/yyyy");
	}
	$option=~s/mm/$mois/;
	$option=~s/dd/$jour/;
	$option=~s/yyyy/20$annee/;
	$option=~s/yy/$annee/;
 	return($option);
}
