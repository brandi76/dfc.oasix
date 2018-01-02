#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

# print $html->header;
require "./src/connect.src";
$datedujour=`/bin/date`;
$jour=`/bin/date '+%d'`+0;
$mois=`/bin/date '+%m'`+0;
$an="20".`/bin/date '+%y'`+0;
print "Content-type: text/html\n\n";
$nodepart=$html->param("nodepart");
if ($nodepart eq ""){
$query="select dt_no from atadsql where dt_cd_dt=100";
$sth=$dbh->prepare($query);
$sth->execute();
$nodepart=$sth->fetchrow_array;
# $nodepart++;
print "
<html>
<body bgcolor=white text=black alink=black vlink=black link=black>
<center><h1>BORDEREAU DE LIVRAISON</h1>
<form>No de depart:<input type=text name=nodepart value=$nodepart size=5>&nbsp;<input type=submit></form>";
print "<br><a href=bordliv_detail.pl>edition au detail</a></body>";
}
else
{
# $query="update atadsql set dt_no=$nodepart,dt_date=now() where dt_cd_dt=100 and dt_date!=now()";
# $sth=$dbh->prepare($query);
# $sth->execute();
print "<head><style type=\"text/css\">
<!--
H4 { page-break-after : right }         
-->
</style></head>";
print "<body>";
$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
{
	$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
}

$today=&nb_jour($jour,$mois,$an);

$today--;
&table($today,"ORY");
print "Fin de page";
print "</center>";
print "<h4>.</h4>";  # saut de page

&table($today,"CDG");
print "Fin de page";
print "</center>";
print "<h4>.</h4>";  # saut de page

&tableretour($today+1,"ORY");
print "Fin de page";
print "</center>";
print "<h4>.</h4>";  # saut de page
&tableretour($today+1,"CDG");
print "Fin de page";
print "</center>";

$query="select count(*) from geslot,etatap where at_depart>=$nodepart and gsl_apcode=at_code and gsl_ind<99 and (gsl_trajet like \"LYS%\"or gsl_trajet like \"MRS%\")";
$sth=$dbh->prepare($query);
$sth->execute();
$escale=$sth->fetchrow_array;
# print "$ecale $query";

if ($escale>0){
	print "<h4>.</h4>";  # saut de page
	&table($today,"LYS");
	print "Fin de page";
	print "</center>";
	print "<h4>.</h4>";  # saut de page
	
	&table($today,"MRS");
	print "Fin de page";
	print "</center>";
	print "<h4>.</h4>";  # saut de page

	&tableretour($today+1,"LYS");
	print "Fin de page";
	print "</center>";
	print "<h4>.</h4>";  # saut de page

	&tableretour($today+1,"MRS");
	print "Fin de page";
	print "</center>";
}


 $query="select gsl_dtvol from geslot,etatap where at_depart>=$nodepart and gsl_apcode=at_code and gsl_ind<99 and gsl_triret!=\"LYS%\" and gsl_triret!=\"MRS%\" group by gsl_dtvol order by gsl_dtvol";
 $sth3=$dbh->prepare($query);
 $sth3->execute();
 while (($jour)=$sth3->fetchrow_array){
	print "<h4>.</h4><center>Document Piste Orly exemplaire pour <b>ORLY</b>";  # saut de page
	&tablepiste($jour,"ORY");
	print "Fin de page";
	print "<h4>.</h4><center>Document Piste CDG exemplaire pour <b>ORLY</b>";  # saut de page
	&tablepiste($jour,"CDG");
	print "Fin de page";
	print "<h4>.</h4><center>Document Piste CDG exemplaire pour <b>CDG</b>";  # saut de page
	&tablepiste($jour,"CDG");
	print "Fin de page";

}
if ($escale>0){
	 $query="select gsl_dtvol from geslot,etatap where at_depart>=$nodepart and gsl_apcode=at_code and gsl_ind<99 and (gsl_triret!=\"LYS%\" or gsl_triret!=\"MRS%\") group by gsl_dtvol order by gsl_dtvol";
	 $sth3=$dbh->prepare($query);
	 $sth3->execute();
	 while (($jour)=$sth3->fetchrow_array){
		print "<h4>.</h4><center>Document Piste <b>Marseille </b>";  # saut de page
		&tablepiste($jour,"MRS");
		print "Fin de page";
		print "<h4>.</h4><center>Document Piste <b>Lyon</b>";  # saut de page
		&tablepiste($jour,"LYS");
		print "Fin de page";
	}
}
for ($i=0;$i<4;$i++){
	print "<h4>.</h4><center>Planning previsionnel</b>";  
	&table_prev($today+$i);
}

print "</body>";
}
sub table{
my $today=$_[0];
my $aero=$_[1];

print "<center><table border=1 cellspacing=0 cellpadding=10 width=80%><tr><td><font size=-1>Livraison pour <b>$aero</b><br>IBS FRANCE<br>DIEPPE</td><td><font size=-1>MARCHANDISES DETENUES ET CIRCULANT SOUS LE REGIME DE L'ENTREPOT TYPE E<br>REPRIS DANS LA CONVENTION B5779 (ARTICLE 528-2 D.A.C DU C.D.C)</td></tr></table></center>";
print "<br>DEPART DE DIEPPE No:";
$query="select at_depart from etatap where at_depart>=$nodepart group by at_depart";
$sth=$dbh->prepare($query);
$sth->execute();
while ($no=$sth->fetchrow_array){print "<b>$no </b>";}
print "<br>* IMMATRICULATION DU VEHICULE:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CHAUFFEUR:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br><br> A L'ATTENTION DE L'ASSISTANT OBS  FAX <b>01 49 75 82 96</b><br><br>";
print "Date d'edition:$datedujour";  
print "<br>Date du depart et justificatif (si different):<br><br><center>";  
$pass=0;
print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#FFFF66><th>No du lot </th><th> No du vol</th><th>dest</th><th>conteneur </th><th>Date vol</th><th>charg</th><th>scelles</th><th width=200>Emargement</th></tr>";
$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_nb_cont,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_apcode from geslot,etatap where at_depart>=$nodepart and gsl_apcode=at_code and gsl_ind<99 and (gsl_trajet like \"/$aero%\"or gsl_trajet like \"$aero%\")";
$sth=$dbh->prepare($query);
$sth->execute();
while (($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_nb_cont,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_apcode)=$sth->fetchrow_array){
	$query="select flb_depart from flybody where flb_date=$gsl_dtvol and flb_vol like \"$gsl_vol\" and flb_rot=11";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($flb_depart)=$sth2->fetchrow_array;
	@plomb=($gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6);
	$nbcont+=$gsl_nb_cont;
	
	# $client=int($gsl_nolot/1000);
	$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";
	$sth_n=$dbh->prepare($query);
	$sth_n->execute();
	($client)=$sth_n->fetchrow_array;

	($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
	$gsl_nolot%=1000;
	$flb_depart/=100;
	$gsl_hrret/=100;
	
	print "<tr>";
	print "<td>$cl_trilot $gsl_nolot</td>";
	print "<td>$gsl_vol</td>";
	print "<td>$gsl_trajet</td>";
	print "<td align=middle>$gsl_desi</td><td>";
	print &julian($gsl_dtvol,"");
	print "</td><td align=center>";
	print &deci2(flb_depart);
	print "</td><td>";
	foreach (@plomb) {if ($_!=0){print "$_<br>";}}
	print "</td><td>&nbsp;</td>";
	
	print "</tr>\n";
	$pass=1
}
print "</table>\n";
if ($pass==0){print "-------------------NIL-----------------------<br>";}
print "Nombre de conteneur:$nbcont<br>";
}
sub tableretour{
my $today=$_[0];
my $aero=$_[1];
print "<center><table border=1 cellspacing=0 cellpadding=10 width=80%><tr><td><font size=-1>Enlevement de <b>$aero</b><br>IBS FRANCE<br>DIEPPE</td><td><font size=-1>MARCHANDISES DETENUES ET CIRCULANT SOUS LE REGIME DE L'ENTREPOT TYPE E<br>REPRIS DANS LA CONVENTION B5779 (ARTICLE 528-2 D.A.C DU C.D.C)</td></tr></table></center>";
print "<br>RETOUR DU:<b>";
print &julian($today,"");
print "</b><br>Date d'edition:$datedujour";  
print "<br><br><center>";  
$pass=0;
print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#FFCC33><th>No du lot </th><th> No du vol</th><th>dest</th><th>conteneur </th><th>Date retour</th><th>dechargement</th><th>scelles</th><th width=200>Emargement</th></tr>";
$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_apcode from geslot where gsl_dtret<=$today and gsl_ind=3 and gsl_triret=\"$aero\"";
$sth=$dbh->prepare($query);
$sth->execute();
while (($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_apcode)=$sth->fetchrow_array){
	$query="select flb_depart from flybody where flb_date=$gsl_dtvol and flb_vol like \"$gsl_vol\" and flb_rot=11";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($flb_depart)=$sth2->fetchrow_array;
	@plomb=($gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6);
	
	$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";
	$sth_n=$dbh->prepare($query);
	$sth_n->execute();
	($client)=$sth_n->fetchrow_array;

	# $client=int($gsl_nolot/1000);
	($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
	$gsl_nolot%=1000;
	$flb_depart/=100;
	$gsl_hrret/=100;
	
	print "<tr>";
	print "<td>$cl_trilot $gsl_nolot</td>";
	print "<td>$gsl_vol</td>";
	print "<td>$gsl_trajet</td>";
	print "<td align=middle>$gsl_desi</td><td>";
	print &julian($gsl_dtret,"");
	print "</td><td align=center>";
	print &deci2(gsl_hrret);
	print "</td><td>&nbsp;</td>";
	print "</td><td>&nbsp;</td>";
	print "</tr>\n";
	$pass=1;
}
print "</table>\n";
if ($pass==0){print "-------------------NIL-----------------------<br>";}

}

# PISTE 
sub tablepiste{
my $today=$_[0];
my $aero=$_[1];

print "<center><br><table border=1 cellspacing=0 width=80%><tr><td>                                                         
IBS FRANCE AGREMENT SURETE (numero en cours d'etablissement)<br>LISTE D'EMARGEMENT SURETE DU ";                    
print &julian($today,"");
print " Pour <b>$aero</b></td></tr></table><br><h2>";
print &jour($today);
print " ";
print &julian($today,"");
print "</h2></center></center>\n";
print "<br>Avant d'apposer votre visa dans la case emargement :</br>verifier la coherence des elements portes sur l'etiquette avec le document a signer</br>verifier le nombre et les numeros de plombs des contenants avec le document a signer</br>";
print "<b>Nom du Chauffeur:</b><br><br><center>";
$pass=0;  
print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=pink><th><font size=-1>Compagnie</th><th>Trajet</th><th>No de lot</th><th>vol</th><th><font size=-2>Conteneur</th><th>Heure <br>(local)</th><th>Plombs</th><th><font size=-1>Controle sureté chargeur</th><th><font size=-1>Controle sureté compagnie</th><th>Immat</th><th>Parking</th></tr>";
@liste=();
$query="select gsl_nolot,flb_depart from geslot,flybody where gsl_dtvol=$today and flb_date=gsl_dtvol and flb_vol=gsl_novol and flb_rot=11 and (gsl_trajet like \"/$aero%\" or gsl_trajet like \"$aero%\")";
$sth=$dbh->prepare($query);
$sth->execute();
while (($lot,$heure)=$sth->fetchrow_array){
	push (@liste,"$heure;$lot;depart");
}
$query="select gsl_nolot,gsl_hrret from geslot where gsl_dtret=$today and gsl_triret=\"$aero\"";
$sth=$dbh->prepare($query);
$sth->execute();
while (($lot,$heure)=$sth->fetchrow_array){
	push (@liste,"$heure;$lot;retour");
}
@liste=sort{ $a <=> $b}(@liste);
foreach (@liste){
	($heure,$lot,$sens)=(split/;/,$_);
	$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_nb_cont,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_apcode from geslot where gsl_nolot=$lot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_nb_cont,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_apcode)=$sth->fetchrow_array;
	$query="select flb_depart from flybody where flb_date=$gsl_dtvol and flb_vol like \"$gsl_vol\" and flb_rot=11";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($flb_depart)=$sth2->fetchrow_array;
	@plomb=($gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6);

	# $client=int($gsl_nolot/1000);
	
	$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";
	$sth_n=$dbh->prepare($query);
	$sth_n->execute();
	($client)=$sth_n->fetchrow_array;

	print "<tr><td><font size=-2><b>";
	($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
	print $cl_nom;
	print "</td>";
	print "<td><font size=-2>$gsl_trajet</td>";
	$gsl_nolot%=1000;
	print "<td>$cl_trilot $gsl_nolot</td><td>$gsl_vol</td><td align=center>$gsl_desi</td>";
	 $flb_depart=$flb_depart/100;
	if ($sens eq "depart"){
		print "<td align=center>";
		print "<b>";
		print &deci2(flb_depart);
		print "</td><td>";
		foreach (@plomb) {if ($_!=0){print "$_<br>";}}
		print "&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
	}
	else {
		print "<td align=center>";
		print "<b>";
		$gsl_hrret/=100;
		print &deci2(gsl_hrret);
		print "</td>";
		print "<td>&nbsp;<br>Retour<br>&nbsp;</td>";
		print "<td>&nbsp;</td><td>&nbsp;</td>\n";

	}
	print "<td>&nbsp;</td><td>&nbsp;</td></tr>\n";
	$pass=1;
}
print "<tr><td>&nbsp;<br>&nbsp;<br>&nbsp;<br></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
print "<tr><td>&nbsp;<br>&nbsp;<br>&nbsp;<br></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
print "</table>\n";
if ($pass==0){print "-------------------NIL-----------------------";}
}

sub table_prev{
	my $today=$_[0];
	print  "<h1>";
	print  &jour($today);
	print  " ";
	print  &julian($today,"");
	print  "</h1></div>\n";
	print  "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=yellow><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Tronçon</th><th>Validation</th></tr>";
	$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype from flyhead where fl_date=$today";
	$sth=$dbh->prepare($query);
	$sth->execute();

	while (($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype)=$sth->fetchrow_array){
		$query="select flb_tridep,flb_triret,flb_depart,flb_arrivee,flb_rot,flb_voltr,flb_datetr from flybody where flb_vol='$fl_vol' and flb_date=$fl_date order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		print  "<tr><td><div class=ombre><b>";
		($cl_nom)=split(/;/,$client_dat{$fl_cd_cl});
		print  $cl_nom;
		print  "</td>";
		print  "<td align=center><div class=ombre>$fl_vol</td><td align=center><div class=ombre>$fl_troltype</td><td><div class=ombre><table border=0 cellspacing=0 width=100%>";
		print "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td><font size=-1>Charg LT</td><td><font size=-1>depart LT</td><td><font size=-1>depart UT</td>";
		print "<td>&nbsp;</td><td><font size=-1>Arr LT</td><td><font size=-1>Arr UT</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
		
		
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
			
			print "<tr><td>$flb_rot</td><td>$flb_voltr</td><td>$flb_tridep</td><td align=right><b>";
			print $flb_depart;
			print "<td align=right>".&cal_heure($flb_depart,+1)."</td>";
			print "<td align=right><font color=lightgreen>".&cal_heure($flb_depart,$decalage-1)."</td>";
			print "</td><td align=right>$flb_triret</td><td align=right><b>$flb_arrivee</td>";
			print "<td align=right><font color=lightgreen>".&cal_heure($flb_arrivee,0-$decalage)."</td>";
			print "<td>$datetr</td><td>$aerd_desi</td><td>$aero_type</td></tr>";
		}
	
		print  "</table></td><td></div><a href=?action=modif&vol=$fl_vol&date=$fl_date&nbjour=$nbjour&datejour=$jour&datemois=$mois&datean=$an>Modif</a><div class=ombre></td>";
		print  "</tr>\n";
	}
	($datejour,$datemois,$datean)=split(/\//,&julian($today,""));
	print "<tr></div></tr>";
	print  "</table>\n";
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