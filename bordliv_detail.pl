#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

print $html->header;
require "./src/connect.src";
$datedujour=`/bin/date`;
$jour=`/bin/date '+%d'`+0;
$mois=`/bin/date '+%m'`+0;
$an="20".`/bin/date '+%y'`+0;
$nodepart=$html->param("nodepart");
$choix=$html->param("choix");
$action=$html->param("action");
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$today=&nb_jour($jour,$mois,$an);

if ($choix eq ""){
print "<center><H1>Bodereau de travail<H2><br><form><table>
<tr><td>Bordereau de livraison  ORLY </td><td><input type=radio name=choix value=bl_ory></td></tr>
<tr><td>Bordereau de livraison  CDG </td><td><input type=radio name=choix value=bl_cdg></td></tr>
<tr><td>Bordereau de livraison  ESCALE </td><td><input type=radio name=choix value=bl_escale></td></tr>
</table><bR>
<table>
<tr><td>Bordereau enlevement  ORLY </td><td><input type=radio name=choix value=e_ory></td></tr>
<tr><td>Bordereau enlevement  CDG </td><td><input type=radio name=choix value=e_cdg></td></tr>
<tr><td>Bordereau enlevement  ESCALE </td><td><input type=radio name=choix value=e_escale></td></tr>
</table><br>
<table>
<tr><td>Document piste ORLY </td><td><input type=radio name=choix value=p_ory></td></tr>
<tr><td>Bordereau piste CDG </td><td><input type=radio name=choix value=p_cdg></td></tr>
<tr><td>Bordereau piste ESCALE </td><td><input type=radio name=choix value=p_escale></td></tr>
</table><br><input type=submit value=envoie><input type=hidden name=action value=subchoix></form>";
}
if ((($choix eq "bl_ory")||($choix eq "bl_cdg")||($choix eq "bl_escale"))&&($action eq "subchoix")){
	$query="select dt_no from atadsql where dt_cd_dt=100";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$nodepart=$sth->fetchrow_array;
	print "
	<html>
	<body bgcolor=white text=black alink=black vlink=black link=black>
	<center><h1>BORDEREAU DE LIVRAISON</h1>
	<form>No de depart:<input type=text name=nodepart value=$nodepart size=5>&nbsp;<input type=submit>";
	print "<input type=hidden name=action value=bl><input type=hidden name=choix value=$choix></form></body>";
	exit;
}
if ($action eq "subchoix"){
	print "<center><br><br><h1>Date</h1><br><form>";
	&select_date();
	print "<input type=hidden name=action value=pasbl><input type=hidden name=choix value=$choix><br><br>";
	print "<input type=submit value=go></form>";
	exit;
} 	
if ($action eq "pasbl"){
	print "<head><style type=\"text/css\">
	<!--
	H4 { page-break-after : right }         
	-->
	</style></head>";
	print "<body><center>";
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	if ($choix eq "e_ory"){&tableretour($today,"ORY");}
	if ($choix eq "e_cdg"){&tableretour($today,"CDG");}
	if ($choix eq "e_escale"){	
		&tableretour($today,"LYS");
		print "Fin de page";
		print "<h4>.</h4>";  # saut de page
		&tableretour($today,"MRS");
		print "Fin de page";
		print "</center>";
	}
	if ($choix eq "p_ory"){
		print "<h4>.</h4><center>Document Piste <b>ORLY</b>";  # saut de page
		&tablepiste($today,"ORY");
		print "Fin de page";
	}
	if ($choix eq "p_cdg"){
		print "<h4>.</h4><center>Document Piste <b>ROISSY</b>";  # saut de page
		&tablepiste($today,"CDG");
		print "Fin de page";
	}
	if ($choix eq "p_escale"){
		print "<h4>.</h4><center>Document Piste <b>Marseille </b>";  # saut de page
		&tablepiste($jour,"MRS");
		print "Fin de page";
		print "<h4>.</h4><center>Document Piste <b>Lyon</b>";  # saut de page
		&tablepiste($jour,"LYS");
		print "Fin de page";
	}
}

if ($action eq "bl"){
	print "<head><style type=\"text/css\">
	<!--
	H4 { page-break-after : right }         
	-->
	</style></head>";
	print "<body><center>";
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	if ($choix eq "bl_ory"){&table($today,"ORY");}
	if ($choix eq "bl_cdg"){&table($today,"CDG");}
	if ($choix eq "bl_escale"){
		&table($today,"LYS");
		print "Fin de page";
		print "</center>";
		print "<h4>.</h4>";  # saut de page
		&table($today,"MRS");
		print "Fin de page";
		print "</center>";
		print "<h4>.</h4>";  # saut de page
	}
}

sub select_date
{
 	$date=`/bin/date +%d';'%m';'%Y`;
  	(@dates)=split(/;/, $date, 3); 
  	$select_jour[$dates[0]]="selected"; 
  	$select_mois[$dates[1]]="selected"; 
  	$firstyear=$dates[2];
  	print "<select name=datejour>"; 
 	for($i=1;$i<=31;$i++) {print "<option value=\"$i\" $select_jour[$i]>$i</option>\n";} 
 	print "</select>"; 
  	@cal=("","Janvier","Février","mars","Avril","mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  	print "<select name=datemois>";
 	for($i=1;$i<=12;$i++) { print "<option value=\"$i\" $select_mois[$i]>$cal[$i]</option>\n"; } 
  	print "</select> <select name=datean>"; 
	for($i=$firstyear;$i<=($firstyear+1);$i++) { print "<option value=$i>$i</option> ";} 
 	print "</select>"; 
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
	print "<br>IMMATRICULATION DU VEHICULE:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CHAUFFEUR:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br><br> A L'ATTENTION DE L'ASSISTANT OBS  FAX <b>01 49 75 82 96</b><br><br>";
	print "Date d'edition:$datedujour";  
	print "<br>Date du depart et justificatif (si different):<br><br><center>";  
	$pass=0;
	print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#FFFF66><th>No du lot </th><th> No du vol</th><th>dest</th><th>conteneur </th><th>Date vol</th><th>charg</th><th>scelles</th><th width=200>Emargement</th></tr>";
	$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_nb_cont,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6 from geslot,etatap where at_depart>=$nodepart and gsl_apcode=at_code and gsl_ind<99 and (gsl_trajet like \"/$aero%\"or gsl_trajet like \"$aero%\")";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_nb_cont,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6)=$sth->fetchrow_array){
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

# bodereau de travail au detail