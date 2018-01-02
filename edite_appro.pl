#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
# require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
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
if ($lot eq ""){
	print "Reedition d'un bon d'appro<br>Numero d'appro<form><input type=text name=lot size=6> <input type=submit></form>";
}
else
{
	
	
print "<body>";
print "<div style=\"font-family:Courrier; font-size:11pt\"><pre>";



require "./src/connect.src";



$devise_id=&get("select dt_no from atadsql where dt_cd_dt=20");
$devise_tri=&get("select trigramme from devise where id='$devise_id'");
$query="select geslot.* from geslot where gsl_apcode=$lot";
$sth=$dbh->prepare($query);
$sth->execute();

$jour=&taillefixe($jour,2);
$mois=&taillefixe($mois,2);
$an=&taillefixe($an,4);

$br="<br>";

($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array;
	if ($gsl_nolot eq ""){
		# le lot a ete reutiliser
		&save("update geslot set gsl_apcode='$lot' where gsl_nolot=1000");
		# lot generique
		$query="select geslot.* from geslot where gsl_apcode=$lot";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array;
	}	
	$query="select cl_nom,cl_trilot from client where cl_cd_cl=floor($gsl_troltype/1000)";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($cl_nom,$cl_trilot)=$sth2->fetchrow_array;
	$cl_nom=&taillefixe($cl_nom,24);
	$nolot=$gsl_nolot%1000;
	$nolot=&taillefixe($nolot,3);
	$query="select vol.* from vol where v_code='$gsl_apcode' order by v_rot";
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
		$at_type=&get("select at_type from etatap where at_code='$gsl_apcode'");
		# edition des bon d'appro
		&bon_appro();
		&saut_de_page();
		&bon_appro();
		&saut_de_page();
		&mise_a_bord();
		&mise_a_bord();
		&saut_de_page();
		&fiche_de_caisse();
		&remise_de_caisse();
		&saut_de_page();
		&fiche_de_caisse();
		&remise_de_caisse();
		&saut_de_page();
	
# 		&bon_appro();
# 		&mise_a_bord();
# 		&fiche_de_caisse();
# 		&remise_de_caisse();
# 		&saut_de_page();
# 		&bon_appro();
# 		&mise_a_bord();
# 		&fiche_de_caisse();
# 		&remise_de_caisse();
# 		&saut_de_page();
	}
}
sub saut_de_page(){
	if ($printer==11){print "\f";}else {print "<div id=saut></div>";}
}

sub daa{
print "******************************************************************************
*$cl_nom CERTIFICAT DE SURETE No $gsl_apcode du $jour/$mois/$an       *
*                                                                            *";
print "
*----------------------------------------------------------------------------*
*   Lot No    !           No VOL     DESTINATION        DATE      HEURE CHARG*
*   $cl_trilot $nolot   ! rot no:$v_rot :$v_vol$v_dest";
print &julian($v_date_jl,"DD/MM/YY");
print "    10.00 *
*----------------------------------------------------------------------------*";
print "
*groupement de biens et de produits destines a etre utilises a bord          *
*des aeonefs                                                                 *
*$gsl_nb_cont contenants :$gsl_desi   $gsl_nbpb scelles *";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$var="gsl_pb".$i;
			print "${$var}","*"
		}
		for (;$i<=7;$i++){
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

($aero)=split(/\//,$v_dest);
if ($aero eq "CDG"){ $aero="ROISSY CHARLE DE GAULLE";}
if ($aero eq "ORY"){ $aero="PARIS ORLY";}

print "<pre>
COMMUNAUTE EUROPEENNE          Document Commercial d'Accompagnement pour la 
                               circulation des produits soumis à accises en 
                               régime de suspension
                                                                
------------------------------------------------------------------------------- 
(1) Expéditeur                 (2) No accices: FR00116S0031 (3) Reference:$v_code
Ibs France
ZI Rouxmenils Bouteille
76204 Dieppe
------------------------------------------------------------------------------- 
(7) Destinataire                (10) Garantie:No05/92RR ROUEN 
$cl_nom  
(7a) $aero
(8) Autorite competente: Douanes de Dieppe
(11) Moyen de transport
camion n 717RX76,9227XT76,1942XY76,8653WH76  (17) 2h30
(18.1) nombre  !(18.2)contenance!(18.5) marques            !(22)  !qte retour!
------------------------------------------------------------------------------- 
";
$query="select ap_qte0,pr_desi,pr_pdn from appro,produit where ap_code='$v_code' and ap_cd_pr=pr_cd_pr and ap_qte0>0 and pr_type=3 order by ap_ordre";
$sth4=$dbh->prepare($query);
$sth4->execute();
# boucle sur appro
while (($ap_qte0,$pr_desi,$pr_pdn)=$sth4->fetchrow_array)
{
	$poids=&taillefixen($ap_qte0*$pr_pdn/100,4);
	$pr_desi=&taillefixen($pr_desi,25);
	$ap_qte0=&taillefixen($ap_qte0/100,3);
	print "$ap_qte0 cartouches ! $pr_pdn cigarettes !$pr_desi!$poids g!          !
";
}
print "-------------------------------------------------------------------------------
";
print "(18.1) nombre  !(18.2)cont. (18.3)%vol (18.5) marques (20)alc. pur!qte retour!
";
print "-------------------------------------------------------------------------------
";

$query="select ap_qte0,pr_desi,pr_pdn/10,pr_deg/100 from appro,produit where ap_code='$v_code' and ap_cd_pr=pr_cd_pr and pr_type=2 and ap_qte0>0  order by ap_ordre";
$sth4=$dbh->prepare($query);
$sth4->execute();
# boucle sur appro
while (($ap_qte0,$pr_desi,$pr_pdn,$pr_deg)=$sth4->fetchrow_array)
{
	$pdn=&taillefixen(int($pr_pdn),5);
	$alcpur=&taillefixen($ap_qte0*$pr_pdn/100*$pr_deg/100,6);
	$pr_desi=&taillefixen($pr_desi,25);
	$ap_qte0=&taillefixen($ap_qte0/100,3);
	print "$ap_qte0 bouteilles ! ${pdn}cl! ${pr_deg}%!$pr_desi!${alcpur}cl!          !
";
}
$val=&get("select sum(ap_qte0*ap_prix)/10000 from appro,produit where ap_code='$v_code' and ap_cd_pr=pr_cd_pr and (pr_type=5 ||pr_type=4 || pr_type=1)");
$ap_qte0=&get("select sum(ap_qte0)/100 from appro,produit where ap_code='$v_code' and ap_cd_pr=pr_cd_pr and pr_type!=2 and pr_type!=3 and ap_qte0>0  order by ap_ordre");

print "------------------------------------------------------------------------------- 
$ap_qte0 parfums et cosmetiques  

Valeur des produits uniquement soumis à la tva:
Depart:$val   Retour:
(23) Attestations et observations


------------------------------------------------------------------------------- 
VISA AER. DEPART !VISA AER. RETOUR ! VISA RETOUR !        VISA DEPART          ! 
                 !                 !             !(16) date expedition:";
print &julian($v_date_jl,"DD/MM/YY");
print "
                 !                 !             !                             !
                 !                 !             !                             !
                 !                 !             !                             !
                 !                 !             !                             ! 
                 !                 !             !                             !
                 !                 !             !                             !
                 !                 !             !                             !
                 !                 !             !                             !  
------------------------------------------------------------------------------- 
";
&saut_de_page();
}
############### BON APPRO ########################
sub bon_appro{
	&cartouche_appro();

		$query="select appro.*,pr_desi,pr_type,tr_tiroir,pr_pdb from appro,produit,trolley where ap_code='$gsl_apcode' and ap_cd_pr=pr_cd_pr and tr_code='$v_troltype' and ap_cd_pr=tr_cd_pr order by tr_tiroir,ap_ordre";
		# print $query;
		$sth4=$dbh->prepare($query);
		$sth4->execute();
		# boucle sur appro
		$val=0;
		$total=0;
		$poids=690;
		while (($ap_code,$ap_ordre,$ap_cd_pr,$ap_prix,$ap_qte0,$ap_cd_pos,$ap_cd_cl,$pr_desi,$pr_type,$tr_tiroir,$pr_pdb)=$sth4->fetchrow_array)
		{
			if ($tr_tiroir != $tiroir){
			 	if ($total!=0){print " -->Nombre de Produit tiroir $tiroir :$total $br";}
			 	$total=0;
			 	$poids=690;
			 	$tiroir=$tr_tiroir;
				#if ($tr_tiroir==4){
				#	&saut_de_page();
				#	&cartouche_appro();
				#}
				
			}
			 
			$pr_desi=&taillefixen($pr_desi,25);
			$ap_qte0=$ap_qte0-$tr_qte;
			$total+=int($ap_qte0/100);
			$poids+=int($ap_qte0/100)*$pr_pdb;
			$ap_qte0=&taillefixen($ap_qte0/100,3);
			$ap_prix=&taillefixen($ap_prix/100,5);
			print "$pr_desi!";
			if ($v_rot==1){print $ap_qte0;}else {print"___";}
			$val=$val+$ap_prix*$ap_qte0;
			print "!___! - !___! = !____ *$ap_prix  = ______! !______!$br";
		} # fin boucle appro
 		if ($total!=0){print " -->Nombre  de Produit tiroir $tiroir :$total$br";}

print "
                                        TOTAL VENTES      :  _______ $devise_tri
valeur du bon d'appro:$val


------------------------------------------------------------------------------
No Plombs            Visa DOUANE
Depart   !Escale 1 ! Escale 2 ! Escale 3 ! Escale 4 ! Arrivée DLA ! camair/DFC     
";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$var="gsl_pb".$i;
			print "${$var}     !         !          !          !          !             !$br";
		}

}


sub cartouche_appro {
	if (($v_rot==1)&&(grep /CDG/,$v_dest)){$v_dest="DLA/CDG               ";}
print "

******************************************************************************
*$cl_nom CONTROLE QUALITE            No $gsl_apcode du $jour/$mois/$an*
*             NE PAS DEBARQUER L EXEMPLAIRE BLANC DU BON                     *";
print "
*----------------------------------------------------------------------------*
*   Lot No    !           No VOL     DESTINATION        DATE      HEURE CHARG*
*   $cl_trilot $nolot   ! rot no:$v_rot :$v_vol$v_dest";
print &julian($v_date_jl,"DD/MM/YY");
print " $at_type $depart*
*----------------------------------------------------------------------------*";
print "
! C/C:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
! PNC:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
------------------------------------------------------------------------------
Designation             stock check   stock   vendus  prix   montant!  Stock
                        depart  PNC    retour                        !CAMAIR/DFC
------------------------------------------------------------------------------
";
}


sub mise_a_bord {
#	print "$br$br";
#	print "$br$br";
#	print "$br$br";
#	print "$br$br";
#	print "$br$br";
	print "$br$br";
print "                                BON DE MISE A BORD ";
print "
*----------------------------------------------------------------------------*
*   Lot No    !           No VOL     DESTINATION        DATE      HEURE CHARG*
*   $cl_trilot $nolot   ! rot no:$v_rot :$v_vol$v_dest";
print &julian($v_date_jl,"DD/MM/YY");
print " $at_type $depart*
*----------------------------------------------------------------------------*$br";
print "1ER EXEMPLAIRE POUR DFC / 2E EX C/C CAMAIR  
------------------------------------------------------------------------------- 
VISA CAMAIR DEP  !VISA DFC DEPART  VISA RETOUR DFC   VISA CAMAIR  RET  ! 
                 !                     !                   !                   !
                 !                     !                   !                   !
                 !                     !                   !                   !
                 !                     !                   !                   !
                 !                     !                   !                   !  

ECARTS OU SUGGESTION DEPART ";
}

sub fiche_de_caisse {

print "
------------------------------------------------------------------------------

$cl_cd_cl $cl_nom     FICHE DE CAISSE    bon d'appro No:$gsl_apcode

ROT No  $v_rot :$v_vol      $v_dest   ";
print &julian($v_date_jl,"DD/MM/YY");
print " C/C:
------------------------------------------------------------------------------
! C/C:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
! PNC:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
------------------------------------------------------------------------------

Le premier exemplaire dans l'enveloppe de caisse, le deuxième pour le C/C

Nb    XOF    Total  Nb    XAF    Total  Nb    USD    Total  Nb     EUR   Total
------------------  ------------------  ------------------  ------------------

!  !10000 XOF!      !  !10000 XAF!      !  ! 50 USD !    !  !    ! 100€ !    !
------------------  ------------------  ------------------  -------------------		
!  ! 5000 XOF!      !  ! 5000 XAF!      !  ! 20 USD !    !  !    !  50€ !    !
------------------  ------------------  ------------------  -------------------		
!  ! 2000 XOF!      !  ! 2000 XAF!      !  ! 10 USD !    !  !    !  20€ !    !
------------------  ------------------  ------------------  -------------------		
!  ! 1000 XOF!      !  ! 1000 XAF!      !  !  2 USD !    !  !    !   5€ !    !
------------------                      ------------------  -------------------		
!  !  500 XOF!                          !  !  1 USD !    !  !    !   1€ !    !      
-----------------   ------------------  ------------------  -------------------
     TOTAL XOF           TOTAL XAF         TOTAL USD            TOTAL EUR
 
			 
 Nombre de carte bancaire:____ Total:_____
  
                                         MONTANT CAISSE    :";
print "

                                         TOTAL VENTES      :

                                         DIFFERENCE        :____________
ENVELOPPE DE CAISSE No:
SIGNATURE DU CHEF DE CABINE:
";
}

sub remise_de_caisse {
print "
BON DE REMISE DE CAISSE DE CAISSE

Num d.enve  Num appro  date des vols  NOM+TRIGRAM C/C  CAMAIR NOM AGENT DCF               
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 


Date  de la remise  $br$br$br$br$br$br";
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

# FONCTION : taillefixen
# affichage en taille fixe
sub taillefixen {
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

# -E avis de depart
# mise en page (pied de page à 5)



# <table width=100%>
# <tr><td><font size=+5>Business<br>Galley 1 POS 125</td><td><font size=+5>VAB<br>Galley 2 POS 174</td></tr> 
# <tr><td><font size=+5>Vins et bieres<br>Galley 6 POS 626</td><td><font size=+5>Vins et bieres<br>Galley 6 POS 676</td></td></tr> 
# </table>
