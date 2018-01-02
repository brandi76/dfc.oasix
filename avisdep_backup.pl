#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
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

require "./src/connect.src";
$action=$html->param('action');
$nodepart=$html->param('nodepart');
$printer=$html->param('printer');

print "<body>";

$nb_necessaire=&get("select count(*) from listevol,flyhead where liv_dep='$nodepart' and liv_nolot=0 and fl_date=liv_date and fl_vol=liv_vol");
$nb_dispo=&get("select count(*) from geslot where gsl_ind=0 and gsl_nolot<1000");
if ($nb_dispo <$nb_necessaire){
	print "<font color=red>lot necessaire:$nb_necessaire disponible:$nb_dispo <br>";
	$err=1;
}

if ($err){
	print "<br>AVIS DE DEPART IMPOSSIBLE</br>";
	exit;
}




# $query="select fl_troltype,liv_date,liv_vol,liv_nolot,liv_aprec,fl_cd_cl from listevol,flyhead where liv_dep='$nodepart' and fl_date=liv_date and fl_vol=liv_vol ";
# $sth=$dbh->prepare($query);
# $sth->execute();
# print $query;

# affectation des numeros d'appro et numero de lot , creation des bons d'appro
# boucle sur listevol
# while (($fl_troltype,$liv_date,$liv_vol,$liv_nolot,$liv_aprec,$fl_cd_cl)=$sth->fetchrow_array)

$query="select liv_vol,liv_date,liv_aprec,liv_nolot from listevol where liv_dep='$nodepart'";
$sth=$dbh->prepare($query);
$sth->execute();
$pass=0;
while (($liv_vol,$liv_date,$liv_aprec,$liv_nolot)=$sth->fetchrow_array)
{
	# pour chaque vol de listevol
	$query="select fl_troltype,fl_cd_cl from flyhead where fl_date='$liv_date' and fl_vol='$liv_vol' limit 1";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_troltype,$fl_cd_cl)=$sth2->fetchrow_array;
	# print "$liv_vol<br>";	
	$pastouche=0;
	#si un lot a été affecté soit il à déja été traiter ->next soit c'est un pas touché 
	if ($liv_nolot!=0){
		$query="select gsl_nolot,gsl_ind from geslot where gsl_nolot='$liv_nolot'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($gsl_nolot,$gsl_ind)=$sth2->fetchrow_array;
		if ($gsl_ind!=11) {next;} 
		#####################################
		# sortie pour les vols deja traites #
		#####################################	
		if ($liv_aprec eq ''){print "<font color=red>BUG PAS TOUCHE</font><br>";exit;}
		$no_lot=$gsl_nolot;
		$pastouche=1;
	}
	if ($pass==0){
		$pass=1;
		if (&lock("$0") == 0 ){
			print "Sécurité double click merci de réessayer dans 10 secondes";

			# securite double click
			exit;
		}
	}
	#  maj de atadsql
	$query="update atadsql set dt_desi=dt_desi+1 where dt_cd_dt=210";  # numero appro
	&execute();
	# recuperation du numero d'appro
	$query="select dt_desi from atadsql where dt_cd_dt=210";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($appro)=$sth2->fetchrow_array;
	
	# recuperation du numero de lot
	if ($pastouche==0){
		# if ($fl_troltype<10000){
			# dossier unifié
			$query="select gsl_nolot from geslot where gsl_nolot<300 and gsl_ind=0 order by gsl_nolot limit 1";
		# }
		# else
		# {	
			# dossier personnalisé
		# 	$query="select gsl_nolot from geslot where floor(gsl_nolot/100)=$fl_troltype and gsl_ind=0 order by gsl_nolot limit 1";
		# }
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($no_lot)=$sth2->fetchrow_array;
		if ($no_lot eq ""){print "$fl_troltype bug";exit;}
	}
	
	
	if ($pastouche==0){
		# recuperation des quantites alcool et tabac via les trolleys
		$query="select sum(tr_qte*pr_pdn) from trolley,produit where tr_code='$fl_troltype' and tr_cd_pr=pr_cd_pr and pr_type=3";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_cig)=$sth2->fetchrow_array;
		$query="select sum((tr_qte-ecr_qte)*pr_pdn) from trolley,produit,ecartrol where tr_code='$fl_troltype' and tr_cd_pr=pr_cd_pr and pr_type=3 and ecr_cd_pr=tr_cd_pr and ecr_cdtrol=tr_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_cig_ec)=$sth2->fetchrow_array;
		$qte_cig=($qte_cig-$qte_cig_ec)/1000;
		$query="select sum(tr_qte*pr_deg*pr_pdn) from trolley,produit where tr_code='$fl_troltype' and tr_cd_pr=pr_cd_pr and pr_type=2";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_alc)=$sth2->fetchrow_array;
		$query="select sum((tr_qte-ecr_qte)*pr_deg*pr_pdn) from trolley,produit,ecartrol where tr_code='$fl_troltype' and tr_cd_pr=pr_cd_pr and pr_type=2 and ecr_cd_pr=tr_cd_pr and ecr_cdtrol=tr_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_alc_ec)=$sth2->fetchrow_array;
		$qte_alc=($qte_alc-$qte_alc_ec)/10000000;
	}
	else{
		# recuperation des quantites alcool et tabac via le bon d'appro pas touche
		$query="select sum(ap_qte0*pr_pdn) from appro,produit where ap_code='$liv_aprec' and ap_cd_pr=pr_cd_pr and pr_type=3";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_cig)=$sth2->fetchrow_array;
		$qte_cig=($qte_cig/1000);
		$query="select sum(ap_qte0*pr_deg*pr_pdn) from appro,produit where ap_code='$liv_aprec' and ap_cd_pr=pr_cd_pr and pr_type=2";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_alc)=$sth2->fetchrow_array;
		$qte_alc=$qte_alc/10000000;
	
	}
	$query="select flb_arrivee,flb_datetr,flb_tridep,flb_triret from flybody where flb_vol='$liv_vol' and flb_date='$liv_date' order by flb_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$trajet="";
	# boucle sur flybody pour avoir le trajet
	while ((@flb)=$sth2->fetchrow_array){
		$flb_arrivee=$flb[0];
		$flb_datetr=$flb[1];
		$flb_tridep=$flb[2];
		$flb_triret=$flb[3];
		
		$trajet=$trajet.$flb_tridep."/";
		}
	$trajet=$trajet.$flb_triret;
	
	$query="select flb_datetr,flb_rot,flb_voltr from flybody where flb_vol='$liv_vol' and flb_date='$liv_date' and (flb_rot%10)=1 order by flb_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	# reboucle sur flybody pour les rotations
	while (($flb2_datetr,$flb2_rot,$flb2_voltr)=$sth2->fetchrow_array){
		$rot=int($flb2_rot/10);	
		# $cl_cd_cl=int($no_lot/1000);
		# $troltype=int($no_lot/100);
		$date=&julian($flb2_datetr,"DDMMYY");
		# maj de vol
		$query="replace into vol values ('$appro','$rot','$flb2_voltr','$date','','','','$trajet','$fl_cd_cl','','','','$fl_troltype','$flb2_datetr','')";
		&execute();
		# maj caisse
		$query="replace into caisse values ('$appro','$rot','0','0','0','0','0','0','0','0','','0','0','','')";
		&execute();
	}

	# maj de listevol
	$query="update listevol set liv_nolot='$no_lot' where liv_date='$liv_date' and liv_vol='$liv_vol' and liv_dep='$nodepart'";
	&execute();
	
	# maj de flyhead
	$query="update flyhead set fl_apcode='$appro',fl_nolot=$no_lot where fl_date='$liv_date' and fl_vol='$liv_vol'";
	# print "$query<br>";
	&execute();
	
	
	# new recuperation des infos trolley type
	$query="select lot_conteneur,lot_nbplomb,lot_nbcont from lot where lot_nolot='$fl_troltype'";
	$sth_n=$dbh->prepare($query);
	$sth_n->execute();
	($lot_conteneur,$lot_nbplomb,$lot_nbcont)=$sth_n->fetchrow_array;
	
	# maj de geslot
	$query="update geslot set gsl_apcode='$appro',gsl_ind=3,gsl_nodep='$nodepart',gsl_noret=0,gsl_novol='$liv_vol',gsl_dtvol='$liv_date',gsl_troltype='$fl_troltype',gsl_hrret='$flb_arrivee',gsl_dtret='$flb_datetr',gsl_triret='$flb_triret',gsl_trajet='$trajet',gsl_alc='$qte_alc',gsl_tab='$qte_cig',gsl_nb_cont='$lot_nbcont',gsl_desi='$lot_conteneur',gsl_nbpb='$lot_nbplomb' where gsl_nolot='$no_lot'";
	&execute();
	
	
	# maj etatap
	$troltype{$fl_troltype}++;
	$tiroir=$fl_troltype."_".$troltype{$fl_troltype};
	$query="replace into etatap values('$appro',2,'$datesimple',0,'','$tiroir','$nodepart','','$no_lot')";
	&execute();
	
	$query="select rat_no from radio_tiroir where rat_tiroir='$tiroir'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($rat_no)=$sth2->fetchrow_array){
		# sauvegarde de la radio
		&save("replace into radio_appro values ('$appro','$rat_no')");
	}		
	
	# maj apjour	
	$query="replace into apjour values('$datesimple','$appro')";
	&execute();
	$cree=0;
	if ($pastouche==0){
		$query="select tr_ordre,tr_cd_pr,tr_qte,tr_prix from trolley where tr_code='$fl_troltype' order by tr_ordre";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		# boucle sur trolley
		while (($tr_ordre,$tr_cd_pr,$tr_qte,$tr_prix)=$sth2->fetchrow_array){
			$query="select ecr_qte from ecartrol where ecr_cdtrol='$fl_troltype' and ecr_cd_pr='$tr_cd_pr'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($ecr_qte)=$sth3->fetchrow_array;
			if ($ecr_qte ne ''){$tr_qte=$ecr_qte;}
			# maj appro
			$query="replace into appro values('$appro','$tr_ordre','$tr_cd_pr','$tr_prix','$tr_qte','2','$fl_cd_cl')";
			&execute();
			$cree++;
			# maj produit
			$query="update produit set pr_stvol=pr_stvol+$tr_qte where pr_cd_pr='$tr_cd_pr'";
			&execute();
			# maj sortie
			$query="replace into sortie values('$tr_cd_pr','$appro','$tr_qte')";
			&execute();
			if (($tr_cd_pr==800201)&&($tr_qte!=0)){ # lunette
				# maj appro
				$query="replace into appro values('$appro','3605','230502','1500','1200','2','$fl_cd_cl')";
				&execute();
				# maj produit
				$query="update produit set pr_stvol=pr_stvol+1200 where pr_cd_pr='230502'";
				&execute();
				# maj sortie
				$query="replace into sortie values('230502','$appro','1200')";
				&execute();
			}
			if (($tr_cd_pr==800200)&&($tr_qte!=0)){ # bijoux
				$query="select * from pochon";
				$sth5=$dbh->prepare($query);
				$sth5->execute();
				while (($po_ordre,$po_cd_pr,$po_qte,$po_prix)=$sth5->fetchrow_array){
					# maj appro
					$query="replace into appro values('$appro','$po_ordre','$po_cd_pr','$po_prix','$po_qte','2','$fl_cd_cl')";
					&execute();
					# maj produit
					$query="update produit set pr_stvol=pr_stvol+$po_qte where pr_cd_pr='$po_cd_pr'";
					&execute();
					# maj sortie
					$query="replace into sortie values('$po_cd_pr','$appro','$po_qte')";
					&execute();
				}	
			}

		}
	}	
	else {
		# recuperation des quantitées du pas touché
		$query="select ap_ordre,ap_cd_pr,ap_qte0,ap_prix from appro where ap_code='$liv_aprec' order by ap_ordre";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		# boucle sur appro
		while (($ap_ordre,$ap_cd_pr,$ap_qte0,$ap_prix)=$sth2->fetchrow_array){
			# maj appro
			$query="replace into appro values('$appro','$ap_ordre','$ap_cd_pr','$ap_prix','$ap_qte0','2','$fl_cd_cl')";
			&execute();
			$cree++;
			# maj produit
			$query="update produit set pr_stvol=pr_stvol+$ap_qte0 where pr_cd_pr='$ap_cd_pr'";
			&execute();
			# maj sortie
			$query="replace into sortie values('$ap_cd_pr','$appro','$ap_qte0')";
			&execute();
	
		}
	}
	if ($cree==0){print "<font color=red> Attention bon d appro vierge : appro=$appro pastouche=$pastouche approprec=$liv_aprec trol_type=$tl_troltype</font><br>";}
	# maj pick	
	&maj_pick();
} # fin boucle sur listevol
########################
# MISE A JOUR DES PACK #
########################
%stock=&stock(130320);
$pr_stre=$stock{"stock"};
if ($pr_stre<0){
	$switch_p=(0-int($pr_stre/2))+$pr_stre%2;
	$switch_s=$switch_p*(-2);
	$switch_s*=100;
	$switch_p*=100;
	$query="update produit set pr_stre=pr_stre-($switch_s) where pr_cd_pr=130320;";
	&execute();
	$query="replace into enso values (130320,'$nodepart',curdate(),'$switch_s','0','24')";	
	&execute();
	$query="update produit set pr_stre=pr_stre-$switch_p where pr_cd_pr=130100;";
	&execute();
	$query="replace into enso values (130100,'$nodepart',curdate(),'$switch_p','0','24')";	
	&execute();
}
%stock=&stock(130120);
$pr_stre=$stock{"stock"};
if ($pr_stre<0){
	$switch_p=(0-int($pr_stre/2))+$pr_stre%2;
	$switch_s=$switch_p*(-2);
	$switch_s*=100;
	$switch_p*=100;
	$query="update produit set pr_stre=pr_stre-($switch_s) where pr_cd_pr=130120;";
	&execute();
	$query="replace into enso values (130120,'$nodepart',curdate(),'$switch_s','0','24')";	
	&execute();
	$query="update produit set pr_stre=pr_stre-$switch_p where pr_cd_pr=130105;";
	&execute();
	$query="replace into enso values (130105,'$nodepart',curdate(),'$switch_p','0','24')";	
	&execute();
}

if ($action eq "plombs"){
	&modifplombs();
}

# boucle sur geslot pour verifier si tous les plombs ont ete saisie
$query="select gsl_nolot,gsl_desi,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7 from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
$sth=$dbh->prepare($query);
$sth->execute();
$plombsok=1;
while(($gsl_nolot,$gsl_desi,$gsl_nbpb,@tabplombs)=$sth->fetchrow_array){
	for ($i=0;$i<$gsl_nbpb;$i++){
		if ($tabplombs[$i]+0==0){$plombsok=0;}
	}
}

if ($plombsok==0){
	&saiplombs();
}
else{
	&avisdep();
}

	
# mise a jour de typeair pour calculer le pic
# $query="delete from typeair where ta_date=$today";
# $sth=$dbh->prepare($query);
# $sth->execute();
# $query="select count(*),floor(gsl_nolot/100) from geslot where gsl_ind=3 group by floor(gsl_nolot/100)";  
# $sth=$dbh->prepare($query);
# $sth->execute();
# while (($nb,$troltype)=$sth->fetchrow_array)
# {
#	$query="replace into typeair value('$today','$troltype','$nb')";
#	$sth=$dbh->prepare($query);
#	$sth->execute();
# }
	





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
sub execute {
        # print "$query<br>";
	$dbh->do("insert into query values ('',QUOTE(\"$query\"),'$0','$ENV{'REMOTE_ADDR'}',now())");
	my($sth2)=$dbh->prepare($query);
	$sth2->execute();
}
# FONCTION : julian(secouonde,option)
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
			 
		$total+=int($tr_qte/100);

		$pr_desi=&taillefixen($pr_desi,25);
		$tr_qte=&taillefixen($tr_qte/100,3);
		$tr_prix=&taillefixen($tr_prix/100,5);
	
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


sub saiplombs(){
	# ***********saisie des plombs ********
	print "\n<script>";
	print "function auto(variable){\n";
	print "var j=1;\n";
	print "if (document.plomb.recopie.checked==false){return;}";
	print "	for (i=variable;i<document.plomb.elements.length-4;i++){";
	print "		document.plomb.elements[i].value=(parseInt(document.plomb.elements[i-1].value)+1);";
	print "		if (j++==9) break;";
	
	# print "alert(i+\" document.plomb.elements[i].value=(parseInt(document.plomb.elements[i-1].value)+1)\");";
	print "	}";
	print "}";
	print "</script>\n";
	
	$query="select gsl_nolot,gsl_desi,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7 from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print  "<form name=plomb method=POST><table border=1 cellspacing=0><tr bgcolor=yellow><th>Lot</th><th>Désignation</th><th>Plombs 1</th><th>Plombs 2</th><th>Plombs 3</th><th>Plombs 4</th><th>Plombs 5</th><th>Plombs 6</th><th>Plombs 7</th></tr>";
	$j=0;
	$ok=1;
	while(($gsl_nolot,$gsl_desi,$gsl_nbpb,@tabplombs)=$sth->fetchrow_array){
		print "<tr><td>$gsl_nolot</td><td>$gsl_desi</td>";
		for ($i=0;$i<$gsl_nbpb;$i++){
			$ref=$gsl_nolot.'_'.$i;
			$j++;
			print "\n<td><input type=text name=$ref value=$tabplombs[$i] Onchange=auto($j)></td>";
			$nbplombs++;
		}
		print "</tr>";
	}
	print "</table><br>Nombre de plombs necessaire:$nbplombs <br>recopie incrementé <input type=checkbox name=recopie checked><input type=hidden name=action value=plombs><input type=hidden name=nodepart value=$nodepart><input type=hidden name=printer value=$printer><input type=submit value=\"avis de depart et bon d\'appro\"></form>";
}


sub modifplombs {
	$query="select gsl_nolot,gsl_desi,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7 from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while(($gsl_nolot,$gsl_desi,$gsl_nbpb,@tabplombs)=$sth->fetchrow_array){
		
		$query="select * from geslot where gsl_nolot=$gsl_nolot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		(@table)=$sth2->fetchrow_array;
		for ($i=0;$i<$gsl_nbpb;$i++){
			$ref=$gsl_nolot.'_'.$i;
			$table[$i+6]=$html->param("$ref");
		}
  		$query="replace into geslot values(";
	 	for ($z=0;$z<=$#table;$z++)
		{
			$query.="'$table[$z]',";
		}
  		chop($query);
  		$query.=")";
	  	# print "$query<br>";;
		$sth2=$dbh->prepare($query);
		$sth2->execute();
	}
}

sub avisdep {
print "<div style=\"font-family:Courrier; font-size:11pt\"><pre>";
$query="select geslot.* from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
$sth=$dbh->prepare($query);
$sth->execute();

$jour=&taillefixen($jour,2);
$mois=&taillefixen($mois,2);
$an=&taillefixen($an,4);
$br="<br>";

# boucle sur listevol
while (($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array)
	{
	$query="select cl_nom,cl_trilot from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";

	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($cl_nom,$cl_trilot)=$sth2->fetchrow_array;
	$cl_nom=&taillefixen($cl_nom,24);
	$nolot=$gsl_nolot;
	$nolot=&taillefixen($nolot,3);
	$query="select vol.* from vol where v_code='$gsl_apcode' order by v_rot";
	$sth3=$dbh->prepare($query);
	$sth3->execute();

	########## BOUCLE SUR VOL #############

	while (($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_zatt)=$sth3->fetchrow_array)
	{
		if (($v_troltype <99)&& ($v_rot!=1)){next;} # economie de papier
		$v_vol=&taillefixen($v_vol,10);
		$v_dest=&taillefixen($v_dest,18);
		$gsl_desi=&taillefixen($gsl_desi,8);
		$query="select flb_depart from flybody,flyhead where fl_apcode='$gsl_apcode' and fl_vol=flb_vol and fl_date=flb_date and flb_rot=11";
		#print $query;
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($flb_depart)=$sth2->fetchrow_array;
		$flb_depart=&taillefixen($flb_depart,4);
		$depart=substr($flb_depart,0,2).'.'.substr($flb_depart,2,2);
		$at_type=&get("select at_type from etatap where at_code='$gsl_apcode'");
		# edition des bon d'appro
		if ($v_rot==1){
		############## BON d APPRO ################### 
		if ($v_rot==1){
print "******************************************************************************
*$cl_nom CONTROLE QUALITE            No $gsl_apcode du $jour/$mois/$an*
*                                                                            *";
}
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
Designation             stock check   stock   vendus  prix   montant!   ref
                       depart  PNC    retour                        !
------------------------------------------------------------------------------
";
		$query="select appro.*,pr_desi,pr_type,tr_tiroir,pr_pdb from appro,produit,trolley where ap_code='$gsl_apcode' and ap_cd_pr=pr_cd_pr and tr_code='$v_troltype' and ap_cd_pr=tr_cd_pr order by tr_tiroir,ap_ordre";
		$sth4=$dbh->prepare($query);
		$sth4->execute();
		# boucle sur appro
		$val=0;
		$total=0;
		$poids=690;
		while (($ap_code,$ap_ordre,$ap_cd_pr,$ap_prix,$ap_qte0,$ap_cd_pos,$ap_cd_cl,$pr_desi,$pr_type,$tr_tiroir,$pr_pdb)=$sth4->fetchrow_array)
		{
			# if ($tr_tiroir != $tiroir){
			# 	if ($total!=0){print " -->Nombre de Produit tiroir $tiroir :$total poids:$poids grs $br";}
			# 	$total=0;
			# 	$poids=690;
			# 	$tiroir=$tr_tiroir;
			# }
			 
			$pr_desi=&taillefixen($pr_desi,25);
			$ap_qte0=$ap_qte0-$tr_qte;
			$total+=int($ap_qte0/100);
			$poids+=int($ap_qte0/100)*$pr_pdb;
			$ap_qte0=&taillefixen($ap_qte0/100,3);
			$ap_prix=&taillefixen($ap_prix/100,5);
			print "$pr_desi!";
			if ($v_rot==1){print $ap_qte0;}else {print"___";}
			$val=$val+$ap_prix*$ap_qte0;
			print "!___! - !___! = !____ *$ap_prix E= ______! $ap_cd_pr$br";
		} # fin boucle appro
# 		if ($total!=0){print " -->Nombre  de Produit tiroir $tiroir ......:$total$br";}

print "
                                        TOTAL VENTES      :  _______ EU
valeur du bon d'appro:$val


------------------------------------------------------------------------------
No Plombs            Visa DOUANE
Depart   !Escale 1 ! Escale 2 ! Escale 3 ! Escale 4 ! Arrivée LFW ! asky/finaero     
";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$var="gsl_pb".$i;
			print "${$var}     !         !          !          !          !             !$br";
		}

		&saut_de_page();
		}
		######### FIN BON D'APPRO ***************


		########### DEBUT FICHE DE MISE A BORD ##############
		if ($v_rot==1){
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
		print "$br$br";
print "                                BON DE MISE A BORD ";
print "
*----------------------------------------------------------------------------*
*   Lot No    !           No VOL     DESTINATION        DATE      HEURE CHARG*
*   $cl_trilot $nolot   ! rot no:$v_rot :$v_vol$v_dest";
print &julian($v_date_jl,"DD/MM/YY");
print " $at_type $depart*
*----------------------------------------------------------------------------*$br";
print "1ER EXEMPLAIRE POUR FINAERO / 2E EX C/C ASKY  
------------------------------------------------------------------------------- 
VISA ASKY DEPART !VISA FINAERO DEPART   CONTROLE QUALITE  DEPART               ! 
                 !                     !          	                       ! 
                 !                     !                                       !
                 !                     !                                       !
                 !                     !                                       !
                 !                     !                                       !  

ECARTS OU SUGGESTION DEPART ";
		&saut_de_page();
		}


# ################### DEBUT FICHE DE CAISSE ###################

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
Le premier et le deuxieme exemplaire vont dans l'enveloppe de caisse.

      !PIECES  !   5e   ! 10e    !   20e  !   50e  !  100e !
      !-----------------------------------------------------
  NB  !XXXXXXXX!        !        !        !        !       !TOTAL EUROS
      !----------------------------------------------------------------------
 TOTAL!        !        !        !        !        !       !             EU !
      -----------------------------------------------------------------------


                     DEVISES           !  TAUX   ! NOMBRE  ! VALEUR EU !
                     ---------------------------------------------------
                   USD                     0.740 !_________!___________!
                   CFA XAF                 0.0015!_________!___________!
                   CFA XOF                 0.0015!_________!___________!
                                                                        
                                              TOTAL EUROS   ___________ EU


      !                                  ! CARTES BANCAIRES!
      !----------------------------------------------------!
  NB  !                                  !                 ! TOTAL EUROS :
 TOTAL!                                  !              EU !          EU !
      --------------------------------------------------------------------


                                         MONTANT CAISSE    :";
print "

                                         TOTAL VENTES      :

                                         DIFFERENCE        :____________
ENVELOPPE DE CAISSE No:
SIGNATURE DU CHEF DE CABINE:
";
print "






BON DE REMISE DE CAISSE DE CAISSE

Num d.enve  Num appro  date des vols  NOM + TRIGRAM C/C  ASKY NOM AGENT FINAERO               
           !          !             !                   !                     ! 
           !          !             !                   !                     ! 
           !          !             !                   !                     ! 
           !          !             !                   !                     ! 
           !          !             !                   !                     ! 


Date  de la remise  $br";
&saut_de_page();
	} # fin boucle vol
} # fin boucle listevol

print "</div></pre></body></html>";
}

sub maj_pick {
	my($troltype,$tr_cd_pr,$nb,$qte,$sth2,$sth3,$sth,$query);
	# suppression des valeurs pour aujourdui
	$query="delete from pick where pi_date=now()";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	# selection des trolleys en vol 
	$query="select gsl_troltype,count(*) from geslot where gsl_ind=3 group by gsl_troltype";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	# pour chaque trolley type en enregistre la quantité theorique dans pick
	while (($troltype,$nb)=$sth->fetchrow_array){
		$query="select tr_cd_pr,tr_qte/100 from trolley where tr_code='$troltype'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($tr_cd_pr,$qte)=$sth2->fetchrow_array){
			$qte*=$nb;
	 	 	$query="select pi_qte from pick where pi_date=now() and pi_cd_pr='$tr_cd_pr'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			$qte+=$sth3->fetchrow_array;
		 	$query="replace into pick values (now(),'$tr_cd_pr','$qte')";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
		}
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
Depart:$val euro  Retour:
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


# -E avis de depart
# mise en page (pied de page à 5)



# <table width=100%>
# <tr><td><font size=+5>Business<br>Galley 1 POS 125</td><td><font size=+5>VAB<br>Galley 2 POS 174</td></tr> 
# <tr><td><font size=+5>Vins et bieres<br>Galley 6 POS 626</td><td><font size=+5>Vins et bieres<br>Galley 6 POS 676</td></td></tr> 
# </table>
