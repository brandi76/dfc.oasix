#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$action=$html->param('action');
if ($action ne "tpe"){
	print $html->header;
	print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
	<!--
	#saut { page-break-after : right }         
	-->
	</style></head><body>";
}
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$today=&nb_jour($jour,$mois,$an);
if ($today==-1){$today=$html->param('today');}
$nbjour=$html->param('nbjour');
$nodepart=$html->param('nodepart');
$pr_cd_pr=$html->param('produit');
$vol=$html->param('vol');
$date_vol=$html->param('date_vol');
# print "
# <h1>Message pour remi, carole pour axy il y a une nouvelle composition, il nous faut un trolley type 1/2 trolley + 1 armoire c'est pour des vols afriques ,( minimum de cigarette, produit spécial afrique) , merci de me donner les quantités que vous aurez misent, sylvain ";
# exit;



for ($i=0;$i<=6;$i++){
	$check=$html->param("check$i");
	if ($check eq "on"){
		push (@liste,$html->param("val$i"));
	}
}

require "./src/connect.src";
$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
{
	$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
}





#### ""  Premiere page
if ($action eq ""){
 	$date=`/bin/date +%d';'%m';'%Y`;
  	($jour,$mois,$an)=split(/;/, $date, 3); 
	$today=&nb_jour($jour,$mois,$an);
	# print "<font color=red><h2>Pour aujourd'hui mardi 29 mars -->mercredi, jeudi +escale depart 651 (départ déjà créée faire le relevé de marchandise, + commande corsica";
	# print " commande 7874 (deja créée faire bon de preparation) je passerai vers 15 heures, bon courage sylvain</h2></font>";
	print "<center><h1>Bordereau de livraison</h1>";
	$sth=$dbh->prepare("select dt_desi from atadsql where dt_cd_dt=300 ");
	$sth->execute();
	print "<br><br>";
	print "<form>";
 	print "<table border=0>";
	for($i=0;$i<=6;$i++) {
		$jour=$today+$i;
		$sth=$dbh->prepare("select count(*) from geslot where gsl_ind=3 and gsl_dtvol=$jour and gsl_trajet like 'CDG%'");
		$sth->execute();
		($nbvol)=$sth->fetchrow_array;
		if ($nbvol==0){next;}
		print "<tr><td><font size=+2>CDG ";
		print &jour($jour);
		print "</td><td align=right><font size=+2>";
		print &julian($jour,"");
		print "</td>";
		print "<td>Nb de vol:$nbvol</td>";
		print "<td><input type=hidden name=val$i value=$jour><input type=checkbox name=check$i style=\"width:40px; height:40px;\"></td>";
		print "</tr>\n";
		$sth=$dbh->prepare("select count(*) from geslot where gsl_ind=3 and gsl_dtvol=$jour and gsl_trajet like 'ORY%'");
		$sth->execute();
		($nbvol)=$sth->fetchrow_array;
		if ($nbvol==0){next;}
		print "<tr><td><font size=+2>ORY ";
		print &jour($jour);
		print "</td><td align=right><font size=+2>";
		print &julian($jour,"");
		print "</td>";
		print "<td>Nb de vol:$nbvol</td>";
		print "<td><input type=hidden name=val$i value=$jour><input type=checkbox name=check$i style=\"width:40px; height:40px;\"></td>";
		print "</tr>\n";
	
	}
	
	$jour=$today+6-($today%7);
	print "<tr><td><font size=+2>";
	print "escale";
	print "</td><td align=right><font size=+2>";
	print &julian($jour,"");
	print " au ";
	print &julian($jour+6,"");
	print "</td>";
	$sth=$dbh->prepare("select count(*) from flyhead,flybody where fl_date>=$jour and fl_date<$jour+7 and fl_apcode=0 and flb_tridep!='CDG' and flb_tridep!='ORY' and flb_rot=11 and fl_vol=flb_vol and flb_date=fl_date");
	$sth->execute();
	($nbvol)=$sth->fetchrow_array;
	print "<td>Nb de vol:$nbvol</td>";
	if ($nbvol>-1){print "<td><input type=hidden name=escale value=$jour><input type=checkbox name=checkescale style=\"width:40px; height:40px;\"></td>";}
	else {print "<td>&nbsp;</td>";}
	print "</tr>\n";

  	print "</table>";
	print "<input type=hidden name=action value=go>";
	print "<br><br><input type=submit value='Edition des documents'>";
	print "</form></body>";
}

###### -->go Gestion de listevol
if ($action eq "go"){&go();}




sub go{

		# attention bordereau de livraison -->cumule
	print  "</body>";
	foreach  (@CDG ){
		&table($_,"CDG");
		print "Fin de page";
		print "</center>";
		print "<h4>.</h4>";  # saut de page
	}
	foreach  (@ORY ){
		&table($_,"ORY");
		print "Fin de page";
		print "</center>";
		print "<h4>.</h4>";  # saut de page
	}

}


sub table{
	my $today=$_[0];
	my $aero=$_[1];
	print "<center><table border=1 cellspacing=0 cellpadding=10 width=80%><tr><td><font size=-1>Livraison pour <b>$aero</b><br>IBS FRANCE<br>DIEPPE</td><td><font size=-1>MARCHANDISES DETENUES ET CIRCULANT SOUS LE REGIME DE L'ENTREPOT TYPE E<br>REPRIS DANS LA CONVENTION B5779 (ARTICLE 528-2 D.A.C DU C.D.C)</td></tr></table></center>";
	print "<br>DEPART DE DIEPPE ";
	print "<br>IMMATRICULATION DU VEHICULE:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CHAUFFEUR:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br><br> A L'ATTENTION DE L'ASSISTANT OBS  FAX <b>01 49 75 82 96</b><br><br>";
	print "Date d'edition:$datedujour";  
	print "<br>Date du depart et justificatif (si different):<br><br><center>";  
	$pass=0;
	print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#FFFF66><th>No du lot </th><th> No du vol</th><th>dest</th><th>conteneur </th><th>Date vol</th><th>charg</th><th>scelles</th><th width=200>Emargement</th></tr>";
	$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_nb_cont,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_apcode from geslot where gsl_dtvol=$today and gsl_ind=3 and (gsl_trajet like \"/$aero%\"or gsl_trajet like \"$aero%\")";
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

# FONCTION : deci2(nombre)
# DESCRIPTION : retourne un chiffre avec2 chiffres apres la virgule 
# ENTREE : Un nombre 
# SORTIE : Un chaine
sub deci3 {
	my ($var)=@_[0];
	my ($chaine,$deci);
	$var = "".$var;
	($ENT,$DEC) = split(/\./,$var);
	#$deci = $var-int($var);
	$deci = ("0.".$DEC)+0;
	$deci = int($deci*100);
	
	#$deci=int(($var-int($var))*100);
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	$var=int($var);
	$chaine=$var.".".$deci;
	return($chaine);
}




