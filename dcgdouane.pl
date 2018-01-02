#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
print $html->header;
require "./src/connect.src";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$max=$an*10000+$mois*100;
if ($jour>15){$max+=100;}
$today=&nb_jour($jour,$mois,$an);
$dateref=&nb_jour(1,$mois,$an);
$action=$html->param("action");
$option=$html->param("option");

$code=$html->param("code");
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "<body>";
$option=$html->param("option");
&calcul();
&recap();


######################################
#     Boucle sur produit et enso  ####
######################################

sub calcul
{
	$query="delete from cumulven";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	if (($action eq "stre")||($action eq "stanc")||($action eq "casse")||($action eq "theo")||($action eq "ecart")||($action eq "nonsai")){&titre_ancien_nouveau();} 
	if (($action eq "entree")||($action eq "sortie")){&titre_entree_sortie();} 
	if ($action eq "air"){&titre_air();} 

	$query="select pr_cd_pr,pr_stanc,pr_stre,pr_desi,pr_qte_comp,pr_deg,pr_douane,pr_pdn,pr_ventil,pr_stvol,pr_casse,pr_diff from produit";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_stanc,$pr_stre,$pr_desi,$pr_qte_comp,$pr_deg,$pr_douane,$pr_pdn,$pr_ventil,$pr_stvol,$pr_casse,$pr_diff)=$sth->fetchrow_array){
		if ($pr_ventil<1){next;}
		if ($pr_ventil>=20){next;}
		if ($pr_ventil==10){next;}
		$query3 = "select sum(erdep_qte)  from  errdep where erdep_cd_pr=$pr_cd_pr";
		$sth3=$dbh->prepare($query3);
		$sth3->execute();
		$pr_ecart=$sth3->fetchrow*100;
		$query3 = "select sum(ret_retour)  from  non_sai,retoursql where ret_cd_pr=$pr_cd_pr and ns_code=ret_code";
		$sth3=$dbh->prepare($query3);
		$sth3->execute();
		$pr_nonsai=$sth3->fetchrow*100;
			
		# print "$pr_cd_pr $pr_ecart <br>";
		if (($pr_ventil==15)||($pr_ventil==17)){ # cigarettes +tabac
			$stanc=$pr_stanc*$pr_pdn;
			$stre=$pr_stre*$pr_pdn;
			$stvol=$pr_stvol*$pr_pdn;
			$stcasse=$pr_casse*$pr_pdn;
			$stecart=$pr_ecart*$pr_pdn;
			$stenonsai=$pr_nonsai*$pr_pdn;
	
		}
		if ($action eq "stre"){$stock_action=$pr_stre;}
		if ($action eq "stanc"){$stock_action=$pr_stanc;}
		if ($action eq "air"){$stock_action=$pr_stvol;}
		if ($action eq "casse"){$stock_action=$pr_casse;}
		if ($action eq "ecart"){$stock_action=$pr_ecart;}
		if ($action eq "nonsai"){$stock_action=$pr_nonsai;}
		if ($action eq "theo"){$stock_action=$pr_stre-$pr_casse-$pr_stvol+$pr_ecart+$pr_nonsai;}
	
		if (($pr_ventil==$code)&&(($action eq "stre")||($action eq "stanc")||($action eq "casse")||($action eq "theo")||($action eq "ecart")||($action eq "nonsai"))&&($stock_action!=0)){
			&detail_ancien_nouveau(); # edition du detail par produit
		}
		if (($pr_ventil==$code)&&($action eq "air")&&($stock_action!=0)){
			&detail_air(); # edition du detail stock en vol
		}
	
		if (($pr_ventil>=6)&&($pr_ventil<=9)){ # alcool
			$stanc=$pr_stanc*$pr_pdn*$pr_deg;
			$stre=$pr_stre*$pr_pdn*$pr_deg;
			$stvol=$pr_stvol*$pr_pdn*$pr_deg;
			$stcasse=$pr_casse*$pr_pdn*$pr_deg;
			$stecart=$pr_ecart*$pr_pdn*$pr_deg;
			$stenonsai=$pr_nonsai*$pr_pdn*$pr_deg;
		}
	
		if (($pr_ventil<6)||(($pr_ventil>=10)&&($pr_ventil<=19)&&($pr_ventil!=15)&&($pr_ventil!=17)&&($pr_ventil!=16))){ # vin
			$stanc=$pr_stanc*$pr_pdn;
			$stre=$pr_stre*$pr_pdn;
			$stvol=$pr_stvol*$pr_pdn;
			$stcasse=$pr_casse*$pr_pdn;
			$stecart=$pr_ecart*$pr_pdn;
			$stenonsai=$pr_nonsai*$pr_pdn;
		
		}
		if ($pr_ventil==16){
			$stanc=$pr_stanc*100*$pr_qte_comp;
			$stre=$pr_stre*100*$pr_qte_comp;
			$stvol=$pr_stvol*100*$pr_qte_comp;
			$stcasse=$pr_casse*100*$pr_qte_comp;
			$stecart=$pr_ecart*100*$pr_qte_comp;
			$stenonsai=$pr_nonsai*100*$pr_qte_comp;
		}
	
		$sortie=$entree=0;
		$query="select es_cd_pr,es_no_do,es_dt,es_qte,es_qte_en,es_type from enso where es_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth3->fetchrow_array){
	
			if (($es_no_do >"10000")&&($es_qte>0)){
				$query="select v_date_jl from vol where v_code='$es_no_do' and v_rot=1";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				$date=$sth2->fetchrow_array;
				$es_dt=&julian($date,"YYYYMMDD");
			}
			# if ($es_dt>$max){next;}
			# if ($ec_cd_pr==130321){ print "ok";}
			if (($pr_ventil==15)||($pr_ventil==17)){
				$sortie+=$es_qte*$pr_pdn;
				$entree+=$es_qte_en*$pr_pdn;
				}
		
			if (($pr_ventil>=6)&&($pr_ventil<=9)){
				$sortie+=$es_qte*$pr_pdn*$pr_deg;
				$entree+=$es_qte_en*$pr_pdn*$pr_deg;
				# if ($es_qte_en!=0){print "$es_no_do <br>";}
				}
		
			if (($pr_ventil<6)||(($pr_ventil>=10)&&($pr_ventil<=19)&&($pr_ventil!=15)&&($pr_ventil!=17))){
				$sortie+=$es_qte*$pr_pdn;
				$entree+=$es_qte_en*$pr_pdn;
				}
		
			if ($pr_ventil==16){
				print "BUGGGGGGG";
				exit;
			}
			if ($action eq "entree"){$stock_action=$es_qte_en;}
			if ($action eq "sortie"){$stock_action=$es_qte;}
			
			if (($pr_ventil==$code)&&(($action eq "entree")||($action eq "sortie"))&&($stock_action!=0)){
				&detail_entree_sortie(); # edition du detail par produit
			}
		
		}
		$query="select cmv_anc,cmv_ent,cmv_sor,cmv_new,cmv_air,cmv_casse,cmv_ecart,cmv_nonsai from cumulven where cmv_code='$pr_ventil'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($cmv_anc,$cmv_ent,$cmv_sor,$cmv_new,$cmv_air,$cmv_casse,$cmv_ecart,$cmv_nonsai)=$sth2->fetchrow_array;
		$cmv_anc+=$stanc;
		$cmv_ent+=$entree;
		$cmv_sor+=$sortie;
		$cmv_new+=$stre;
		$cmv_air+=$stvol;
		$cmv_casse+=$stcasse;
		$cmv_ecart+=$stecart;
		$cmv_nonsai+=$stenonsai;
		
		# print "$cmv_ecart<br>";		
		$query="replace into cumulven values ('$pr_ventil','$cmv_anc','$cmv_sor','$cmv_ent','$cmv_new','$cmv_air','$cmv_casse','$cmv_ecart','$cmv_nonsai')";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
	
	}
	if (($action eq "stre")||($action eq "stanc")||($action eq "entree")||($action eq "sortie")||($action eq "air")||($action eq "casse")||($action eq "theo")||($action eq "ecart")||($action eq "nonsai")){ print "<tr><th>Total</th><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=right>$total_comp</td></tr></table>";}	
}

######################################
#     Edition de la recap         ####
######################################

sub recap{
	print "<div id=saut></div>";
	$query="select cmv_code,cmv_anc,cmv_ent,cmv_sor,cmv_new,cmv_air,cmv_casse,cmv_ecart,cmv_nonsai from cumulven order by cmv_code ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<center><h3>IBS FRANCE ZI ROUXMENILS BOUTEILLE<br>COMPTABILITE MATIERE</h3>";
	print "Numero d'entrepositaire agree:FR00116S0031<br>";
	print "Edition du $jour ",&cal($mois)," $an<br>";
	
	print "<table border=1 cellspacing=0><tr><th>code</th><th>Stock du mois precedent</th><th>Entree</th><th>Sortie</th><th>Stock theorique</th><th>Stock en l'air</th><th>Casse</th><th>Ecart constaté</th><th>En cours de saisie</th><th>Stock entrepot</th></tr>";
	print "<tr><th>VINS CIDRES ABV VDL</th></tr>";
	while (($cmv_code,$cmv_anc,$cmv_ent,$cmv_sor,$cmv_new,$cmv_air,$cmv_casse,$cmv_ecart,$cmv_nonsai)=$sth->fetchrow_array){
		if (($cmv_code==15)||($cmv_code==17)){
			$cmv_anc/=100000;
			$cmv_ent/=100000;
			$cmv_sor/=100000;
			$cmv_new/=100000;
			$cmv_air/=100000;
			$cmv_casse/=100000;
			$cmv_ecart/=100000;
			$cmv_nonsai/=100000;
		
		}
		if (($cmv_code>=6)&&($cmv_code<=9)){
			$cmv_anc/=100000000000;
			$cmv_ent/=100000000000;
			$cmv_sor/=100000000000;
			$cmv_new/=100000000000;
			$cmv_air/=100000000000;
			$cmv_casse/=100000000000;
			$cmv_ecart/=100000000000;
			$cmv_nonsai/=100000000000;
		}
		if (($cmv_code<6)||(($cmv_code>=10)&&($cmv_code<=19)&&($cmv_code!=15)&&($cmv_code!=17))){ # vin
			$cmv_anc/=10000000;
			$cmv_ent/=10000000;
			$cmv_sor/=10000000;
			$cmv_new/=10000000;
			$cmv_air/=10000000;
			$cmv_casse/=10000000;
			$cmv_ecart/=10000000;
			$cmv_nonsai/=10000000;
		}
		$query="select type_desi from typedesi where type_code='$cmv_code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($type_desi)=$sth2->fetchrow_array;
		if ($cmv_code==6){print "<tr><th>SPIRITUEUX ALCOOLS HL ALCOOL PUR</th></tr>";}
		if ($cmv_code==15){print "<tr><th>TABACS</th></tr>";}
		$cmv_new=$cmv_anc+$cmv_ent-$cmv_sor;
		$physique=$cmv_new-$cmv_air-$cmv_casse+$cmv_ecart+$cmv_nonsai;
		print "<tr><td>$type_desi</td><td align=right><a href=?action=stanc&code=$cmv_code>$cmv_anc</a></td><td align=right><a href=?action=entree&code=$cmv_code>$cmv_ent</a></td><td align=right><a href=?action=sortie&code=$cmv_code>$cmv_sor</a></td><td align=right><a href=?action=stre&code=$cmv_code>$cmv_new</a></td><td align=right><a href=?action=air&code=$cmv_code>$cmv_air</a></td><td align=right><a href=?action=casse&code=$cmv_code>$cmv_casse</a></td><td align=right><a href=?action=ecart&code=$cmv_code>$cmv_ecart</a></td><td align=right><a href=?action=nonsai&code=$cmv_code>$cmv_nonsai</a></td><td align=right><a href=?action=theo&code=$cmv_code>$physique</a></td></tr>";
	}	
	print "</table>";
	print "fin";
}

# FONCTION : cal(mois,option)
# DESCRIPTION : retourne le mois en clair soit au format cours ex janv(pas d'option) soit au format long (option=l)

sub cal {
	
	my ($mois)=$_[0];
	$mois+=0;
	if ($mois eq 0){$desi="Décembre";}
	if ($mois eq 1){$desi="Janvier";}
	if ($mois eq 2){$desi="Fevrier";}
	if ($mois eq 3){$desi="Mars";}
	if ($mois eq 4){$desi="Avril";}
	if ($mois eq 5){$desi="Mai";}
	if ($mois eq 6){$desi="Juin";}
	if ($mois eq 7){$desi="Juillet";}
	if ($mois eq 8){$desi="Aout";}
	if ($mois eq 9){$desi="Septembre";}
	if ($mois eq 10){$desi="Octobre";}
	if ($mois eq 11){$desi="Novembre";}
	if ($mois eq 12){$desi="Décembre";}
        return ($desi);
}


# -E Compta matiere	



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
sub stock{
	my ($prod)=$_[0];
	my($stock);
	my(%stock);
	my ($query) = "select * from produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	my($produit) = $sth->fetchrow_hashref;
	
	$query = "select sum(ret_retour)  from  non_sai,retoursql where ret_cd_pr=$prod and ns_code=ret_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	my($non_sai) =$sth->fetchrow*100;
	$stock{"nonsai"}=$non_sai/100;
	
	$query = "select sum(ap_qte0)  from  appro,geslot where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	my($pastouch) = $sth->fetchrow;
	
	$query = "select max(liv_dep)  from  geslot,listevol where gsl_nolot=liv_nolot and gsl_ind=11";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	my($max) = $sth->fetchrow;
	
	$query = "select sum(ap_qte0)  from  appro,listevol where ap_code=liv_aprec and ap_cd_pr=$prod and liv_dep='$max'";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	my($pastouch2) = $sth->fetchrow;  # pas touche des pas touche dans le depart
	
	
	$stock{"pastouch"}=$pastouch+$pastouch2;
	$query = "select sum(ret_retour) from retoursql,retjour,geslot,etatap where at_code=rj_appro and at_nolot=gsl_nolot and ret_cd_pr=$prod and rj_appro=ret_code and rj_date>='$today' and gsl_ind!=10 and gsl_ind!=11";
	$sth=$dbh->prepare($query);
	# print $query;
	$sth->execute();
	my($retourdujour) = $sth->fetchrow;
	$stock{"retourdujour"}=$retourdujour;

	# $query = "select sum(ap_qte0)  from  appro,geslot,retjour where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod and rj_appro=gsl_apcode and rj_date>=$today";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# $pastouchdujour = $sth->fetchrow;
	# $stock{"pastouchdujour"}=$pastouchdujour/100;

	$query = "select sum(erdep_qte)  from  errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	my($errdep) = $sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"vol"}=$produit->{'$pr_vol'}/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	
	
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100;

	return(%stock);
}

#################################################
#    TITRE STOCK ANCIEN/NOUVEAU                 #
#################################################

sub titre_ancien_nouveau(){
		print "$action<br><table border=1 cellspacing=0>";
		if ($code==15){ # cigarette
			print "<caption><h3>Cigarette</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb unité</th><th>Nb de cigarette par unité</th><th>Total cigarette en millier</th><th>Derniere entrée</th></tr>";
		}	
		if ($code==16){ # cigare
			print "<caption><h3>Cigare</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Boite</th><th>Nb de cigare par boite</th><th>Total cigare en millier</th><th>Derniere entrée</th></tr>";
		}	
		if ($code==1){ # Vin tranquille
			print "<caption><h3>Vin tranquille</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th><th>Derniere entrée</th></tr>";
		}	
		if ($code==3){ # ABV VDL
			print "<caption><h3>ABV VDL</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th><th>Derniere entrée</th></tr>";
		}	
		if ($code==4){ # VDN
			print "<caption><h3>VDN</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th><th>Derniere entrée</th></tr>";
		}	
		if ($code==6){ # ALCOOL
			print "<caption><h3>ALCOOL</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Pourcentage d\'alcool pur</th><th>Total Alcool pur en hectolitre</th><th>Derniere entrée</th></tr>";
		}	
		if ($code==8){ # RHUM
			print "<caption><h3>RHUM</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Pourcentage d\'alcool pur</th><th>Total Alcool pur en hectolitre</th><th>Derniere entrée</th></tr>";
		}	
		if ($code==17){ # TABAC
			print "<caption><h3>TABAC</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Paquet</th><th>Poids d\'un paquet en gramme</th><th>Poids Total en kg</th><th>Derniere entrée</th></tr>";
		}	

}	
#################################################
#    TITRE STOCK EN VOL                         #
#################################################

sub titre_air(){
		print "<br><b>liste des bons d'appros concernés</b><br>";
		$query3="select at_code from etatap where at_etat=2";
		$sth3=$dbh->prepare($query3);
		$sth3->execute();
		while (($at_code)=$sth3->fetchrow_array){
			print "$at_code,";
			if ($nbel++==15){print "<br>";$nbel=0;}
		}	
		print "<br><table border=1 cellspacing=0>";
		if ($code==15){ # cigarette
			print "<caption><h3>Cigarette</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb unité</th><th>Nb de cigarette par unité</th><th>Total cigarette en millier</th></tr>";
		}	
		if ($code==16){ # cigare
			print "<caption><h3>Cigare</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Boite</th><th>Nb de cigare par boite</th><th>Total cigare en millier</th></tr>";
		}	
		if ($code==1){ # Vin tranquille
			print "<caption><h3>Vin tranquille</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th></tr>";
		}	
		if ($code==3){ # ABV VDL
			print "<caption><h3>ABV VDL</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th></tr>";
		}	
		if ($code==4){ # VDN
			print "<caption><h3>VDN</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th></tr>";
		}	
		if ($code==6){ # ALCOOL
			print "<caption><h3>ALCOOL</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Pourcentage d\'alcool pur</th><th>Total Alcool pur en hectolitre</th></tr>";
		}	
		if ($code==8){ # RHUM
			print "<caption><h3>RHUM</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Pourcentage d\'alcool pur</th><th>Total Alcool pur en hectolitre</th></tr>";
		}	
		if ($code==17){ # TABAC
			print "<caption><h3>TABAC</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Paquet</th><th>Poids d\'un paquet en gramme</th><th>Poids Total en kg</th></tr>";
		}	

}	

#################################################
#    TITRE ENTREE/SORTIE                        #
################################################# 

sub titre_entree_sortie(){
		print "$action<br><table border=1 cellspacing=0>";
		if ($code==15){ # cigarette
			print "<caption><h3>Cigarette</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb unité</th><th>Nb de cigarette par unité</th><th>Total cigarette en millier</th><th>Reference douane</th></tr>";
		}	
		if ($code==16){ # cigare
			print "<caption><h3>Cigare</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Boite</th><th>Nb de cigare par boite</th><th>Total cigare en millier</th><th>Reference douane</th></tr>";
		}	
		if ($code==1){ # Vin tranquille
			print "<caption><h3>Vin tranquille</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th><th>Reference douane</th></tr>";
		}	
		if ($code==3){ # ABV VDL
			print "<caption><h3>ABV VDL</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th><th>Reference douane</th></tr>";
		}	
		if ($code==4){ # VDN
			print "<caption><h3>VDN</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Total en hectolitre</th><th>Reference douane</th></tr>";
		}	
		if ($code==6){ # ALCOOL
			print "<caption><h3>ALCOOL</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Pourcentage d\'alcool pur</th><th>Total Alcool pur en hectolitre</th><th>Reference douane</th></tr>";
		}	
		if ($code==8){ # RHUM
			print "<caption><h3>RHUM</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Bouteille</th><th>Litrage d\'une bouteille en cl</th><th>Pourcentage d\'alcool pur</th><th>Total Alcool pur en hectolitre</th><th>Reference douane</th></tr>";
		}	
		if ($code==17){ # TABAC
			print "<caption><h3>TABAC</h3></caption><tr><th>Code</th><th>Désignation</th><th>Nb Paquet</th><th>Poids d\'un paquet en gramme</th><th>Poids Total en kg</th><th>Reference douane</th></tr>";
		}	

}	


#################################################
#  DETAIL DES PRODUITS  STOCK EN L'air    #
#################################################


sub detail_air()
{
			if ($pr_ventil==15){ # cigarette
				$comp=$stock_action*$pr_pdn/100000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil==16){ # cigare
				$comp=$stock_action*$pr_qte_comp/100000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_qte_comp</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil<5){ # vin tranquille
				$comp=$stock_action*$pr_pdn/10000000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			if (($pr_ventil==6)||($pr_ventil==8)){ # alcool
				$stock_aff=$stock_action/100;
				$comp=$stock_action*$pr_pdn*$pr_deg/100000000000;
				$deg=$pr_deg/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>$deg</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil==17){ # tabac
				$stock_aff=$stock_action/100;
				$comp=$stock_action*$pr_pdn/100000;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			print "<td>";
			print "</tr>";
			$total_comp+=$comp;
}


#################################################
#  DETAIL DES PRODUITS  STOCK ANCIEN/NOUVEAU    #
#################################################


sub detail_ancien_nouveau()
{
			if ($pr_ventil==15){ # cigarette
				# if ($action eq "theo"){ # pour la gestion pack<->single
					#$query3 = "select sum(erdep_qte)  from  errdep where erdep_cd_pr=$pr_cd_pr";
					#$sth3=$dbh->prepare($query3);
					#$sth3->execute();
					# print $sth3->fetchrow*100;
				#	$stock_action+=($sth3->fetchrow*100);
				# }
				$comp=$stock_action*$pr_pdn/100000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil==16){ # cigare
				$comp=$stock_action*$pr_qte_comp/100000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_qte_comp</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil<5){ # vin tranquille
				$comp=$stock_action*$pr_pdn/10000000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			if (($pr_ventil==6)||($pr_ventil==8)){ # alcool
				$stock_aff=$stock_action/100;
				$comp=$stock_action*$pr_pdn*$pr_deg/100000000000;
				$deg=$pr_deg/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>$deg</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil==17){ # tabac
				$stock_aff=$stock_action/100;
				$comp=$stock_action*$pr_pdn/100000;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			print "<td>";
			$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$pr_cd_pr'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
			$info_entree="entree sous $fr8_doc le $fr8_date document precedent $fr8_info créé à $fr8_lieu";
			if ($fr8_doc eq ""){$info_entree="Information non disponible";}
			print "$info_entree</td>";
			print "</tr>";
			$total_comp+=$comp;
}

#################################################
#  DETAIL DES PRODUITS  ENTREE/SORTIE           #
#################################################


sub detail_entree_sortie()
{
			my($sth3);
			if ($pr_ventil==15){ # cigarette
				$comp=$stock_action*$pr_pdn/100000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil==16){ # cigare
				$comp=$stock_action*$pr_qte_comp/100000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_qte_comp</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil<5){ # vin tranquille
				$comp=$stock_action*$pr_pdn/10000000;
				$stock_aff=$stock_action/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			if (($pr_ventil==6)||($pr_ventil==8)){ # alcool
				$stock_aff=$stock_action/100;
				$comp=$stock_action*$pr_pdn*$pr_deg/100000000000;
				$deg=$pr_deg/100;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>$deg</td><td align=right>".$comp."</td>";
			}
			if ($pr_ventil==17){ # tabac
				$stock_aff=$stock_action/100;
				$comp=$stock_action*$pr_pdn/100000;
				print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock_aff</td><td align=right>$pr_pdn</td><td align=right>".$comp."</td>";
			}
			print "<td>$es_no_do</td>";
			print "</tr>";
			$total_comp+=$comp;
}