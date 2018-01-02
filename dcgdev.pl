#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
print $html->header;
require "./src/connect.src";
$date=`/bin/date +%d';'%m';'%Y`;
$date="09;10;2009 ";
($jour,$mois,$an)=split(/;/, $date, 3); 
# $mois+=1;
chop($an);
$max=$an*10000+$mois*100;
if ($jour>18){$max+=100;}
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
print "<title>recap mensuel</title><body>";
print $max;
$option=$html->param("option");
if ($option ne "non"){&bon_en_retard();}
&calcul();
&recap();

#########################
#     bon en retard  ####
#########################

sub bon_en_retard
{
	if ($option eq "non"){return;}
	$query="select v_code,v_date,v_troltype,v_dest from vol,etatap where v_date_jl <$dateref and at_code=v_code and (at_etat=2 or at_etat=3) and v_rot=1";
	$sth=$dbh->prepare($query);
	if ($sth->execute()>0){
		print "<font color=red>Bon en retard<br>";
		while (($v_code,$v_date,$v_troltype,$v_dest)=$sth->fetchrow_array)
		{
			$query="select ns_code from non_sai where ns_code='$v_code'";
			$sth2=$dbh->prepare($query);
			if ($sth2->execute()>0){print "Rentré ";}
			print "$v_code,$v_date $v_troltype $v_dest<br>";
		}
		print "</font>";
	}
}

######################################
#     Boucle sur produit et enso  ####
######################################

sub calcul
{
	$query="delete from cumulven";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	if (($action eq "stre")||($action eq "stanc")){&titre_ancien_nouveau();} 
	if (($action eq "entree")||($action eq "sortie")){&titre_entree_sortie();} 

	$query="select pr_cd_pr,pr_stanc,pr_stre,pr_desi,pr_qte_comp,pr_deg,pr_douane,pr_pdn,pr_ventil,pr_acquit,pr_douane from produit where pr_acquit!=1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_stanc,$pr_stre,$pr_desi,$pr_qte_comp,$pr_deg,$pr_douane,$pr_pdn,$pr_ventil,$pr_acquit,$pr_douane)=$sth->fetchrow_array){
		
		if ($pr_ventil<1){next;}
		if ($pr_ventil>=20){next;}
		if ($pr_ventil==10){next;} # biere
		if ($pr_ventil==18){next;} # chamapgne
		
		if (($pr_ventil==15)||($pr_ventil==17)){ # cigarettes +tabac
			$stanc=$pr_stanc*$pr_pdn;
			$stre=$pr_stre*$pr_pdn;
		}
		# %stock=&stock($pr_cd_pr);

		if ($action eq "stre"){$stock_action=$pr_stanc;}
		if ($action eq "stanc"){$stock_action=$pr_stanc;}
	
		if (($pr_ventil>=6)&&($pr_ventil<=9)){ # alcool
			$stanc=$pr_stanc*$pr_pdn*$pr_deg;
			$stre=$pr_stre*$pr_pdn*$pr_deg;
		}
	
		if (($pr_ventil<6)||(($pr_ventil>=10)&&($pr_ventil<=19)&&($pr_ventil!=15)&&($pr_ventil!=17)&&($pr_ventil!=16))){ # vin
			$stanc=$pr_stanc*$pr_pdn;
			$stre=$pr_stre*$pr_pdn;
		}
		if ($pr_ventil==16){
			$stanc=$pr_stanc*100*$pr_qte_comp;
			$stre=$pr_stre*100*$pr_qte_comp;
		}
	
	
		$sortie=$entree=0;
		$query="select es_cd_pr,es_no_do,es_dt,es_qte,es_qte_en,es_type from enso where es_cd_pr='$pr_cd_pr' and es_type!=5 and es_type!=10 ";
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
			if ($es_dt>$max){next;}
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
			if ($action eq "stre"){$stock_action+=$es_qte_en;}

			if ($action eq "sortie"){$stock_action=$es_qte;}
			if ($action eq "stre"){$stock_action-=$es_qte;}
			
			if (($pr_ventil==$code)&&(($action eq "entree")||($action eq "sortie"))&&($stock_action!=0)){
				&detail_entree_sortie(); # edition du detail par produit
			}
		
		}
		if (($pr_ventil==$code)&&(($action eq "stre")||($action eq "stanc"))&&($stock_action!=0)){
			&detail_ancien_nouveau(); # edition du detail par produit
		}

		$query="select cmv_anc,cmv_ent,cmv_sor,cmv_new from cumulven where cmv_code='$pr_ventil'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($cmv_anc,$cmv_ent,$cmv_sor,$cmv_new)=$sth2->fetchrow_array;
		$cmv_anc+=$stanc;
		$cmv_ent+=$entree;
		$cmv_sor+=$sortie;
		$cmv_new+=$stre;
		$query="replace into cumulven values ('$pr_ventil','$cmv_anc','$cmv_sor','$cmv_ent','$cmv_new','','','','')";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
	
	}
	if (($action eq "stre")||($action eq "stanc")||($action eq "entree")||($action eq "sortie")){ print "<tr><th>Total</th><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=right>$total_comp</td></tr></table>";}	
}

######################################
#     Edition de la recap         ####
######################################

sub recap{
	print "<div id=saut></div>";
	$query="select cmv_code,cmv_anc,cmv_ent,cmv_sor,cmv_new from cumulven order by cmv_code ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<center><h3>IBS FRANCE ZI ROUXMENILS BOUTEILLE<br>COMPTABILITE MATIERE</h3>";
	print "Mois de ",&cal($mois-1)," Numero d'entrepositaire agree:FR00116S0031<br>";
	print "Edition du $jour ",&cal($mois)," $an<br>";
	
	print "<table border=1 cellspacing=0><tr><th>code</th><th>Stock du mois precedent</th><th>Entree</th><th>Sortie</th><th>Stock theorique</th></tr>";
	print "<tr>";
	while (($cmv_code,$cmv_anc,$cmv_ent,$cmv_sor,$cmv_new)=$sth->fetchrow_array){
		if ($cmv_anc==0 &&$cmv_ent==0&&$cmv_sort==0&&$cmv_new==0){next;}
		if (($cmv_code==15)||($cmv_code==17)){
			$cmv_anc/=100000;
			$cmv_ent/=100000;
			$cmv_sor/=100000;
			$cmv_new/=100000;
		}
		if (($cmv_code>=6)&&($cmv_code<=9)){
			$cmv_anc/=100000000000;
			$cmv_ent/=100000000000;
			$cmv_sor/=100000000000;
			$cmv_new/=100000000000;
		}
		if (($cmv_code<6)||(($cmv_code>=10)&&($cmv_code<=19)&&($cmv_code!=15)&&($cmv_code!=17))){ # vin
			$cmv_anc/=10000000;
			$cmv_ent/=10000000;
			$cmv_sor/=10000000;
			$cmv_new/=10000000;
		}
		$query="select type_desi from typedesi where type_code='$cmv_code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($type_desi)=$sth2->fetchrow_array;
		$cmv_new=$cmv_anc+$cmv_ent-$cmv_sor;
		print "<tr><td>$type_desi</td><td align=right><a href=?action=stanc&code=$cmv_code>$cmv_anc</a></td><td align=right><a href=?action=entree&code=$cmv_code>$cmv_ent</a></td><td align=right><a href=?action=sortie&code=$cmv_code>$cmv_sor</a></td><td align=right><a href=?action=stre&code=$cmv_code>$cmv_new</a></td></tr>";
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
#  DETAIL DES PRODUITS  STOCK ANCIEN/NOUVEAU    #
#################################################


sub detail_ancien_nouveau()
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
			$query="select fr8_doc,fr8_date,fr8_info,fr8_lieu from fr8 where fr8_cd_pr+1000000='$pr_cd_pr'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($fr8_doc,$fr8_date,$fr8_info,$fr8_lieu)=$sth3->fetchrow_array;
			$info_entree="entree sous $fr8_doc le $fr8_date document precedent $fr8_info créé à $fr8_lieu";
			if ($fr8_doc eq ""){$info_entree="Information non disponible";}
			print "$info_entree </td><td>$pr_douane</td>";
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