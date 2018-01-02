#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

$datesimple="1".substr($an,2,2).$mois.$jour;
print $html->header;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";

$lot=$html->param("lot");
$action=$html->param("action");

if ($action eq ""){
	print "<a href=?action=appro&lot=234001>Appro Axy</a><br>";
	print "<a href=preparation.pl?action=etiquette&appro='18794'>Etiquette Axy</a><br>";
	print "<a href=?action=tpe&lot=234001>Tpe Axy</a><br>";
	print "<br><br><a href=?action=appro&lot=345002>Appro blue</a><br>";
	print "<a href=preparation.pl?action=etiquette&appro='18899'>Etiquette blue</a><br>";
	print "<a href=?action=tpe&lot=345002>Tpe blue</a><br>";
	18899
}
else
{
print "<body>";
print "<pre><div style=\"font-family:Courrier; font-size:11pt\">";

require "./src/connect.src";



$query="select geslot.* from geslot where gsl_nolot=$lot";
$sth=$dbh->prepare($query);
$sth->execute();

$jour=&taillefixe($jour,2);
$mois=&taillefixe($mois,2);
$an=&taillefixe($an,4);


# boucle sur listevol
while (($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array)
	{
	# print "$gsl_nolot",'###########';
	$query="select cl_nom,cl_trilot from client where cl_cd_cl=floor($gsl_nolot/1000)";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($cl_nom,$cl_trilot)=$sth2->fetchrow_array;
	$cl_nom=&taillefixe($cl_nom,24);
	$nolot=$gsl_nolot%1000;
	$nolot=&taillefixe($nolot,3);
	$query="select vol.* from vol where v_code='$gsl_apcode' and v_rot=1";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	# boucle sur vol

	while (($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_zatt)=$sth3->fetchrow_array)
	{
	$v_vol=&taillefixe($v_vol,10);
	$v_dest=&taillefixe($v_dest,18);
	$gsl_desi=&taillefixe($gsl_desi,8);
	$query="select flb_depart from flybody,flyhead where fl_apcode='$gsl_apcode' and fl_vol=flb_vol and fl_date=flb_date and flb_rot=11";
	#print $query;
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($flb_depart)=$sth2->fetchrow_array;
	$flb_depart=&taillefixe($flb_depart,4);
	$depart=substr($flb_depart,0,2).'.'.substr($flb_depart,2,2);
	# edition des bon d'appro

print "<div id=saut></div>";
if ($v_rot==1){
print "_ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ . _ .";
}
print "
Pdd Dieppe Crd EXPORT B5779     bon d'appro no:$gsl_apcode

";
if ($v_rot==1){
print "******************************************************************************
*$cl_nom CERTIFICAT DE SURETE No $gsl_apcode du $jour/$mois/$an       *
*                          AGREMENT en cours                                 *";
}
print "
*----------------------------------------------------------------------------*
*   Lot No    !           No VOL     DESTINATION        DATE      HEURE CHARG*
*   $cl_trilot $nolot   ! rot no:$v_rot :$v_vol$v_dest";
print &julian($v_date_jl,"DD/MM/YY");
print "     $depart   *
*----------------------------------------------------------------------------*";
if ($v_rot==1){
print "
*groupement de biens destine a etre utilise a bord des aeronefs              *
*                                                                            *
*$gsl_nb_cont contenants :$gsl_desi   $gsl_nbpb scelles *";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$var="gsl_pb".$i;
			print "${$var}","*"
		}
		for (;$i<=6;$i++){
			print "******";
		}
print "****";
print "
******************************************************************************
*  EMARGEMENT COMPAGNIE   *    CONTROLE QUALITE    *     CONTROLE SURETE     *
*                         *                        *                         *
*                         *                        *                         *
*                         *                        *                         *
******************************************************************************";
}
print "
! C/C:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
! PNC:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
------------------------------------------------------------------------------
UNE FOIS LES DOCUMENTS REMPLIS:
-------------------------------
3 exemplaires du B.A 2 blancs 1 jaune doivent
imperativement rester dans le dossier
Les autres exemplaires pour la cie et ou le PNC

En cas d'erreur de calcul c'est la colonne stock retour qui sera prise en compte
enfermer les documents dans le trolley a l'issu du vol Merci
------------------------------------------------------------------------------
Designation             stock check   stock   vendus  prix   montant!   ref
                       depart  PNC    retour                        !
------------------------------------------------------------------------------
";
	$query="select appro.*,pr_desi,pr_type from appro,produit where ap_code='$gsl_apcode' and ap_cd_pr=pr_cd_pr order by ap_ordre";
	$sth4=$dbh->prepare($query);
	$sth4->execute();
	# boucle sur appro
	$val=0;
	$total=0;
	while (($ap_code,$ap_ordre,$ap_cd_pr,$ap_prix,$ap_qte0,$ap_cd_pos,$ap_cd_cl,$pr_desi,$pr_type)=$sth4->fetchrow_array)
	{
		if (($pr_type != $pr_typetampon)||($ap_cd_pr==180620)){
			if (($ap_cd_pr==180620)&&($total!=0)){print " -->Nombre  de Parfum Femme .......:$total<br>";$total=0;}
			if (($pr_typetampon==1)&&($total!=0)){print " -->Nombre  de Parfum Homme .......:$total<br>";}
			if (($pr_typetampon==2)&&($total!=0)){print " -->Nombre  de Bouteille    .......:$total<br>";}
			if (($pr_typetampon==3)&&($total!=0)){print " -->Nombre  de Cigarette    .......:$total<br>";}
			if (($pr_typetampon==4)&&($total!=0)){print " -->Nombre  de Boutique     .......:$total<br>";}
			if (($pr_typetampon==5)&&($total!=0)){print " -->Nombre  de Cosmetique   .......:$total<br>";}
			$total=0;
			$pr_typetampon=$pr_type;
		}
			 
		$pr_desi=&taillefixe($pr_desi,25);
		# trolley de reserve
		if (($v_troltype==1230)||($v_troltype==1230)){
			$query="select tr_qte from trolley where tr_cd_pr=$ap_cd_pr and tr_code=$v_troltype+9";
			$sth5=$dbh->prepare($query);
			$sth5->execute();
			($tr_qte)=$sth5->fetchrow_array;
		}
		$ap_qte0=$ap_qte0-$tr_qte;
		$ap_qte0=&taillefixe($ap_qte0/100,3);
		$ap_prix=&taillefixe($ap_prix/100,5);
		$total+=$ap_qte0;

		print "$pr_desi!";
		if ($v_rot==1){print $ap_qte0;}else {print"___";}
		$val=$val+$ap_prix*$ap_qte0;
		print "!___! - !___! = !____ *$ap_prix E= ______! $ap_cd_pr<br>";

	} # fin boucle appro
	if (($pr_typetampon==1)&&($total!=0)){print " -->Nombre  de Parfum Homme .......:$total<br>";}
	if (($pr_typetampon==2)&&($total!=0)){print " -->Nombre  de Bouteille    .......:$total<br>";}
	if (($pr_typetampon==3)&&($total!=0)){print " -->Nombre  de Cigarette    .......:$total<br>";}
	if (($pr_typetampon==4)&&($total!=0)){print " -->Nombre  de Boutique     .......:$total<br>";}
	if (($pr_typetampon==5)&&($total!=0)){print " -->Nombre  de Cosmetique   .......:$total<br>";}
	# trolley de reserve
	if (($v_troltype==1230)||($v_troltype==1230)){&trolsecours();}

print "
                                        TOTAL VENTES      :  _______ EU
valeur du bon d'appro:$val
------------------------------------------------------------------------------
OBSERVATIONS OU SUGGESTIONS DU C/C
------------------------------------------------------------------------------




------------------------------------------------------------------------------

A remplir obligatoirement
Nombre d enveloppe de caisse remise dans le trolley:
(si aucune mettre 0 merci)
Num. d enveloppe ! Num. de vol ! Date du vol ! Signature C/C ! Contre-signature
_________________!_____________!_____________!_______________!________________

_________________!_____________!_____________!_______________!________________

------------------------------------------------------------------------------
No Plombs            Visa DOUANE
Depart             Escale No  1      Escale  No 2      Retour
";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$var="gsl_pb".$i;
			print "***${$var} ***  $i               !                 !               !<br>";
		}
# fiche de caisse
print "<div id=saut></div>
------------------------------------------------------------------------------

$cl_cd_cl $cl_nom     FICHE DE CAISSE    bon d'appro No:$gsl_apcode

ROT No  $v_rot :$v_vol      $v_dest   ";
print &julian($v_date_jl,"DD/MM/YY");
print " C/C:
------------------------------------------------------------------------------
! C/C:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
! PNC:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
------------------------------------------------------------------------------

UNE FOIS LE DOCUMENT REMPLIS:
-------------------------------
Le premier et le deuxieme exemplaires va dans l'enveloppe de caisse.
Le troisieme est pour la comptabilite de votre compagnie.
Le quatrieme est pour le chef de cabine.
Le reste doit obligatoirement etre remis dans le dossier.
      !PIECES  !   5e   ! 10e    !   20e  !   50e  !  100e !
      !-----------------------------------------------------
  NB  !XXXXXXXX!        !        !        !        !       !TOTAL EUROS
      !----------------------------------------------------------------------
 TOTAL!        !        !        !        !        !       !             EU !
      -----------------------------------------------------------------------


                     DEVISES           !  TAUX   ! NOMBRE  ! VALEUR EU !
                     ---------------------------------------------------
                   USD                     0.7751!_________!___________!
                   GBP                     1.5350!_________!___________!
                   CHF                     0.6650!_________!___________!
                   CFP                     0.0084!_________!___________!
                   AUD                     0.5350!_________!___________!
                   CFA                     0.0015!_________!___________!

                                              TOTAL EUROS   ___________ EU


      !     CHEQUES     !  TRAVELLERS    ! CARTES BANCAIRES!
      !----------------------------------------------------!
  NB  !                 !                !                 ! TOTAL EUROS :
 TOTAL!              EU !             EU !              EU !          EU !
      --------------------------------------------------------------------


                                         MONTANT CAISSE    :

                                         TOTAL VENTES      :

                                         DIFFERENCE        :____________
ENVELOPPE DE CAISSE No:
SIGNATURE DU CHEF DE CABINE:
";
	} # fin boucle vol
} # fin boucle listevol
print "</div></pre></body></html>";
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
# FONCTION : taillefixe(???)
# affichage en taille fixe
sub taillefixe {
		my ($char)=$_[0];
		my ($len)=$_[1];
		my ($i)=0;
		my ($chaine)="";
		$_=$char;
		if (! /[a-z,A-Z]/) # astuce test si numerique
		{ # numerique
			while ($char=~s/ //g){};
			for ($i=($len-length($char));$i>0;$i--){
				$chaine=$chaine." ";
			}
			$chaine=$chaine.$char;
			
		}
		else
		{ # non numerique
			for ($i=0;$i<=$len;$i++){
				$car=substr($char,$i,1);
				if ($car eq " "){$car=" ";}
				if ($car eq ""){$car=" ";}
				$chaine=$chaine.$car;
			}
		}
		return($chaine);
}

sub trolsecours{
		print "
             *************  TROLLEY DE RESERVE  *************
EN CAS DE VENTE IMPORTANTE UN TROLLEY SUPLEMENTAIRE EST A VOTRE DISPOSITION
merci de l'ouvrir que s'il vous est necessaire

";
		$query="select trolley.*,pr_desi,pr_type from trolley,produit where tr_code=$v_troltype+9 and tr_cd_pr=pr_cd_pr order by tr_ordre";
		$sth4=$dbh->prepare($query);
		$sth4->execute();
		# boucle sur le trolley de secours
		$total=0;
		while (($tr_code,$tr_ordre,$tr_cd_pr,$tr_qte,$tr_prix,$null,$null,$pr_desi,$pr_type)=$sth4->fetchrow_array)
		{
		if (($pr_type != $pr_typetampon)||($ap_cd_pr==180620)){
			if (($tr_cd_pr==180620)&&($total!=0)){print " -->Nombre  de Parfum Femme .......:$total<br>";$total=0;}
			if (($pr_typetampon==1)&&($total!=0)){print " -->Nombre  de Parfum Homme .......:$total<br>";}
			if (($pr_typetampon==2)&&($total!=0)){print " -->Nombre  de Bouteille    .......:$total<br>";}
			if (($pr_typetampon==3)&&($total!=0)){print " -->Nombre  de Cigarette    .......:$total<br>";}
			if (($pr_typetampon==4)&&($total!=0)){print " -->Nombre  de Boutique     .......:$total<br>";}
			if (($pr_typetampon==5)&&($total!=0)){print " -->Nombre  de Cosmetique   .......:$total<br>";}
			$total=0;
			$pr_typetampon=$pr_type;
		}
			 
		$pr_desi=&taillefixe($pr_desi,25);
		$tr_qte=&taillefixe($tr_qte/100,3);
		$tr_prix=&taillefixe($tr_prix/100,5);
		$total+=$tr_qte;

		print "$pr_desi!";
		if ($v_rot==1){print $tr_qte;}else {print"___";}
		$val=$val+$tr_prix*$tr_qte;
		print "!___! - !___! = !____ *$tr_prix E= ______! $tr_cd_pr<br>";

		} # fin boucle trolley de secours
		if (($pr_typetampon==1)&&($total!=0)){print " -->Nombre  de Parfum Homme .......:$total<br>";}
		if (($pr_typetampon==2)&&($total!=0)){print " -->Nombre  de Bouteille    .......:$total<br>";}
		if (($pr_typetampon==3)&&($total!=0)){print " -->Nombre  de Cigarette    .......:$total<br>";}
		if (($pr_typetampon==4)&&($total!=0)){print " -->Nombre  de Boutique     .......:$total<br>";}
		if (($pr_typetampon==5)&&($total!=0)){print " -->Nombre  de Cosmetique   .......:$total<br>";}
		
}	

sub stock {
	$prod=$_[0];
	my($stock);
	my(%stock);
	$query = "select * from produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$produit= $sth->fetchrow_hashref;
	
	$query = "select sum(ret_retour)  from  non_sai,retoursql where ret_cd_pr=$prod and ns_code=ret_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$non_sai =$sth->fetchrow*100;
	$stock{"nonsai"}=$non_sai/100;
	
	$query = "select sum(ap_qte0)  from  appro,geslot where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$pastouch = $sth->fetchrow;
	
	$query = "select max(liv_dep)  from  geslot,listevol where gsl_nolot=liv_nolot and gsl_ind=11";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	$max = $sth->fetchrow;
	
	$query = "select sum(ap_qte0)  from  appro,listevol where ap_code=liv_aprec and ap_cd_pr=$prod and liv_dep='$max'";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	$pastouch2 = $sth->fetchrow;  # pas touche des pas touche dans le depart
	
	
	$stock{"pastouch"}=$pastouch+$pastouch2;
	$query = "select sum(ret_retour) from retoursql,retjour,geslot,etatap where at_code=rj_appro and at_nolot=gsl_nolot and ret_cd_pr=$prod and rj_appro=ret_code and rj_date>='$today' and gsl_ind!=10 and gsl_ind!=11";
	$sth=$dbh->prepare($query);
	# print $query;
	$sth->execute();
	$retourdujour = $sth->fetchrow;
	$stock{"retourdujour"}=$retourdujour;

	# $query = "select sum(ap_qte0)  from  appro,geslot,retjour where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod and rj_appro=gsl_apcode and rj_date>=$today";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# $pastouchdujour = $sth->fetchrow;
	# $stock{"pastouchdujour"}=$pastouchdujour/100;

	$query = "select sum(erdep_qte)  from  errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	$errdep = $sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"vol"}=$produit->{'$pr_vol'}/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	
	
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100;

	return(%stock);
}

# -E avis de depart
# mise en page (pied de page à 5)



# <table width=100%>
# <tr><td><font size=+5>Business<br>Galley 1 POS 125</td><td><font size=+5>VAB<br>Galley 2 POS 174</td></tr> 
# <tr><td><font size=+5>Vins et bieres<br>Galley 6 POS 626</td><td><font size=+5>Vins et bieres<br>Galley 6 POS 676</td></td></tr> 
# </table>