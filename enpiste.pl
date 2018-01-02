#!/usr/bin/perl
use CGI;
use DBI();

# $html=new CGI;
require "../oasix/manip_table.lib";

# print $html->header;
require "./src/connect.src";
open (MAIL, ">/mnt/server-file/download/mailpiste.txt");   
print MAIL  "Content-type: text/html\n\n";
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
print MAIL "<body>";
print MAIL "Ceci est un mail automatique generé par le serveur <br>";
print MAIL "Merci de me retourner accusé de reception ainsi que toutes les remarques et suggestion<br>";
print MAIL "salutations s.Brandicourt<br>";
print MAIL "<center>\n";
$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
{
	$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
}
for ($i=1;$i<4;$i++){
	&table($today+$i);
}
print MAIL "</body>";

sub table{
	my $today=$_[0];
	print MAIL  "<h1>";
	print MAIL  &jour($today);
	print MAIL  " ";
	print MAIL  &julian($today,"");
	print MAIL  "</h1>\n";
	print MAIL  "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=yellow><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Tronçon</th></tr>";
	$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype from flyhead where fl_date=$today";
	$sth=$dbh->prepare($query);
	$sth->execute();

	while (($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype)=$sth->fetchrow_array){
		$query="select flb_tridep,flb_triret,flb_depart,flb_arrivee,flb_rot,flb_voltr,flb_datetr from flybody where flb_vol='$fl_vol' and flb_date=$fl_date order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		print MAIL  "<tr><td><b>";
		($cl_nom)=split(/;/,$client_dat{$fl_cd_cl});
		print MAIL  $cl_nom;
		print MAIL  "</td>";
		print MAIL  "<td align=center>$fl_vol</td><td align=center>$fl_troltype</td><td><table border=0 cellspacing=0 width=100%>";
		
		while (($flb_tridep,$flb_triret,$flb_depart,$flb_arrivee,$flb_rot,$flb_voltr,$flb_datetr)=$sth2->fetchrow_array){
			$query="select aero_type,aerd_desi from aeroport,aerodesi where aero_tri=aerd_trig and aero_tri='$flb_triret' and aero_tri!='CDG' and aero_tri!='ORY'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($aero_type,$aerd_desi)=$sth3->fetchrow_array;
			if ($flb_depart==0){$flb_depart="&nbsp;";}
			else {$flb_depart=&deci2($flb_depart/100);}
			if ($flb_arrivee==0){$flb_arrivee="&nbsp;";}
			else {$flb_arrivee=&deci2($flb_arrivee/100);}
			$datetr=&julian($flb_datetr);
			
			if (($flb_rot==11)&&($flb_datetr!=$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			if (($flb_rot!=11)&&($flb_datetr<$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			
			print MAIL "<tr><td>$flb_rot</td><td>$flb_voltr</td><td>$flb_tridep</td><td align=right><b>";
			print MAIL $flb_depart;
			print MAIL "</td><td>$flb_triret</td><td align=right><b>$flb_arrivee</td><td>$datetr</td><td>$aerd_desi</td><td>$aero_type</td></tr>";
		}
	
		print MAIL  "</table></td>";
		print MAIL  "</tr>\n";
	}
	print MAIL  "</table>\n";
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
	$var = "".$var;
	($ent,$dec) = split(/\./,$var);
	$deci = ("0.".$dec)+0;
	$deci = int($deci*100);
	
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	$var=int($var);
	$var=$var.".".$deci;
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

# -E Planning par mail
