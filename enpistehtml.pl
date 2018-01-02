#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

# print $html->header;
require "./src/connect.src";
print "Content-type: text/html\n\n";

$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
{
	$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
}

$jour=`/bin/date '+%d'`;
$mois=`/bin/date '+%m'`;
$an="20".`/bin/date '+%y'`;

$today=&nb_jour($jour,$mois,$an);
print "<body>";
print "Ceci est un automatique generé par le serveur <br>";
print "Merci de me retourner accusé de reception ainsi que toutes les remarques et suggestion<br>";
print "salutations s.Brandicourt<br>";
print "<center>\n";
&table($today-1);
&table($today);
# print "<br>planning provisoire<br>";
&table($today+1);
&table($today+2);
&table($today+3);
&table($today+4);
&table($today+5);
&table($today+6);

print "</body>";

sub table{
my $today=$_[0];
print "<h1>";
print &jour($today);
print " ";
print &julian($today,"");
print "</h1>\n";
print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=yellow><th>Compagnie</th><th>Trajet</th><th>No de lot</th><th>vol</th><th>Conteneur</th><th>Date de depart</th><th>Heure depart<br>(local)</th><th>Date retour</th><th>Heure retour<br>(local)</th></tr>";
$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_apcode from geslot where gsl_dtret=$today or gsl_dtvol=$today";
$sth=$dbh->prepare($query);
$sth->execute();
while (($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_apcode)=$sth->fetchrow_array){
	$query="select flb_depart from flybody where flb_date=$gsl_dtvol and flb_vol like \"$gsl_vol\" and flb_rot=11";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($flb_depart)=$sth2->fetchrow_array;

	$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";
	$sth_n=$dbh->prepare($query);
	$sth_n->execute();
	($client)=$sth_n->fetchrow_array;

	# $client=int($gsl_nolot/1000);
	print "<tr><td><b>";
	($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
	print $cl_nom;
	print "</td>";
	print "<td>$gsl_trajet</td>";
	$gsl_nolot%=1000;
	print "<td>$cl_trilot $gsl_nolot</td><td>$gsl_vol</td><td>$gsl_desi</td><td>";
	print "<b>" if ($gsl_dtvol==$today);
	print &julian($gsl_dtvol,"");
	 $flb_depart=$flb_depart/100;
	print "</td><td align=center>";
	print "<b>" if ($gsl_dtvol==$today);
	print &deci2(flb_depart);
	print "</td><td >";
	print "<b>" if ($gsl_dtret==$today);
	print &julian($gsl_dtret,"");
	 $gsl_hrret/=100;
	print "</td><td align=center>";
	print "<b>" if ($gsl_dtret==$today);
	print &deci2(gsl_hrret);
	print "</td>";
	print "</tr>\n";
}
print "</table>\n";
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
# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/MM/DD
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
# FONCTION : deci2(variable)
# DESCRIPTION : retourne un chiffre avec2 chiffres apres la virgule 
# ENTREE : le nom de la variable 
# SORTIE : 
sub deci2 {
	my ($var)=@_[0];
	my ($chaine,$deci,$ent,$dec);
	# ${$var}=${$var}/100 ;
	${$var} = "".${$var};
	($ent,$dec) = split(/\./,${$var});
	$deci = ("0.".$dec)+0;
	$deci = int($deci*100);
	
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	${$var}=int(${$var});
	${$var}=${$var}.".".$deci;
}
# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine)=(4,"Lundi",5,"Mardi",6,"Mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	return "$semaine{$var%7}";
}

# -E Liste des lots en l'air
