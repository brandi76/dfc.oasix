#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

print $html->header;
open(FILE2,"/home/var/spool/uucppublic/enso.txt");
@enso_dat=<FILE2>;
close(FILE2);

%produit_idx = &get_index_num("produit",1);
open(FILE2,"/home/var/spool/uucppublic/produit.txt");
@produit_dat=<FILE2>;
close(FILE2);

open(FILE2,"/home/var/spool/uucppublic/type.txt");
@type=<FILE2>;
close(FILE2);

foreach (@type){
	($cle,$valeur)=split(/;/,$_);
	$type{$cle}=$valeur;
	}



$date = `/bin/date '+%y%m%'`;   
$mois = `/bin/date '+%m%'`;   
$date-=1;
$date-=88 if ($mois==1);
$mois-=1;
$mois=12 if ($mois==0);

# print "*$date*$mois*";
# ------------------------------- ENTREE ---------------------------------
foreach (@enso_dat){
	($es_cd_pr,$datee,$no_do,$es_qte,$es_qte_en,)=split(/;/,$_);
	if ($es_qte_en <= 0){ next;}
	$es_cd_pr+=0;
	if ($produit_idx{$es_cd_pr} ne ""){
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$produit_idx{$es_cd_pr}]);
		$pr_ndp_sh=substr($pr_ndp_sh,0,8);
	}

	$pr_famille+=0;
	$pays=int($pr_cd_fourn/100000);
	if (($pr_famille eq 2)&&($pr_cd_fourn >199999))
	{
		$unisup=0;
		$quant=$es_qte_en;
		$unisup=&calculsup();
		  print "entrée;$pays;$pr_cd_prod;$pr_desi;$pr_ndp_sh;$pr_prx_rev;$es_qte_en <br>";
		push (@table,"102;$pays;$pr_ndp_sh;$pr_cd_prod;$pr_desi;$pr_cd_fourn;$es_qte_en;$pr_prx_rev;$pr_pdn;$unisup;");
	}
}
print "<h2>ENTREE</h2>";
&affiche();

# ------------------------------- SORTIE ---------------------------------

@table=();
open(FILE2,"/home/var/spool/uucppublic/facdata.txt");
@facdata_dat=<FILE2>;
close(FILE2);
foreach (@facdata_dat){
	($facd_no,$facd_no_cde,$facd_cd_cl,$facd_cd_pr,$facd_qte,$facd_puni,$facd_dev,$facd_rem,$facd_date,$facd_prev,$facd_promo)= split (/;/,$_);  
	$facd_date=substr($facd_date,2,3);
	$facd_date+=0;
	# print "$facd_date,$date<br>";
	# last;
	if ($facd_date!=$date){next;}
 	$facd_cd_cl+=0;
 	if ($facd_cd_cl != 3001999){$france=substr($facd_cd_cl,3,1);}
 	# $france=0;
 	if (($facd_cd_cl > 2000000)&&($facd_cd_cl < 8000000)&&($france!=1)){
 		$facd_cd_pr=$facd_cd_pr%1000000;
 	#	print "$facd_cd_pr<br>";
 		$pr_famille=0;
 		if ($produit_idx{$facd_cd_pr} ne ""){
			($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$produit_idx{$facd_cd_pr}]);
			$pr_ndp_sh=substr($pr_ndp_sh,0,8);
				
		}
		if ($pr_prx_un<=0){next;}
	

		$pr_famille+=0;
		if ($pr_famille != 3)
		{
			if ($pr_ndp_sh!~/[0-9]/){
				print "<font color=red>Produit sans ndp:$pr_cd_prod $pr_desi<br></font>";
			next;
			}
		
			$unisup=0;
			$quant=$facd_qte;
			$unisup=&calculsup();
			$pays=int($facd_cd_cl/1000000);
			#if ($pays==3){print "<font color=red>$facd_no</font>";}
			push (@table,"$facd_date;$pays;$pr_ndp_sh;$pr_cd_prod;$pr_desi;$pr_cd_fourn;$facd_qte;$pr_prx_un;$pr_pdn;$unisup;");
 #		       print "sortie;$pays;$facd_cd_pr;$pr_desi;$pr_ndp_sh;$facd_no;$facd_qte<br>";

		}
	}
}	
print "<h2>SORTIE</h2>";

&affiche();
print "</body></html>";



sub affiche()
{
@table=sort(@table);
$ndp=$qte=$pdn=$valeur=0;
print "<table border=1><tr><td align=right>ndp</td><td align=right>qte</td><td align=right>valeur</td><td align=right>poids</td><td>unité sup</td></tr>";
print "<tr><td colspan=4><b>";
print &cal($mois);
print "</td></tr>";
$pays_cp=$qte=$qteuni=0;
	
foreach (@table)
{
	($facd_date,$pays,$pr_ndp_sh,$pr_cd_prod,$pr_desi,$pr_cd_fourn,$facd_qte,$prix,$pr_pdn,$unisup)=split(/;/,$_);
	if ($pays != $pays_cp){
		if ($qte >0){	
			&ligne();
			$ndp=$pr_ndp_sh;
			$qte=$pdn=$valeur=$qteuni=0;
			}
	
		$pays_desi=$pays;
		if ($pays==2){$pays_desi="BELGIQUE";}
		if ($pays==3){$pays_desi="PAYS BAS";}
		if ($pays==6){$pays_desi="ANGLETERRE";}
		if ($pays==7){$pays_desi="SUISSE";}
		
		print "<tr><td colspan=4><b>$pays_desi</td></tr>";
		$pays_cp=$pays;
		$ndp=$pr_ndp_sh;

		}

	if (($pr_ndp_sh != $ndp)&&($qte >0)){
		&ligne();
		$ndp=$pr_ndp_sh;
		$qte=$pdn=$valeur=$qteuni=0;
	}
	$qteuni+=$unisup;
	$qte+=$facd_qte;
	$pdn+=$facd_qte*$pr_pdn/1000;
	$valeur+=$facd_qte*$prix;
}

if ($qte >0){
		&ligne();
		
	}
print "<table><br><br>";
}



sub ligne {
		print "<tr><td align=right>$ndp </td><td align=right>$qte</td><td align=right>";
		print &separateur($valeur);
		print "</td><td align=right>";
		print &separateur($pdn);
		print "</td><td align=right>";
		print $qteuni;
		print "</td></tr>";
}

sub calculsup {
	#$pr_pac=$type{$pr_ndp_sh};
	if (($pr_pac <1)||($pr_pac >22)){
		# print "<font color=red>Produit sans code ventilation :$pr_ndp_sh $pr_cd_prod $pr_desi $pr_pac<br></font>";
		$unisup=-1;
		return ($unisup);
	}

	$pdn+=0;
	$pr_deg+=0;
	$quant+=0;
#	if ($pr_ndp_sh eq "22030001"){print "$pr_pac $quant $pr_pdn<br>";}
	if ((($pr_pac<6)||(($pr_pac >9) && ($pr_pac <15))||($pr_pac==18)||($pr_pac==19))&&(pr_famille==2)){
 		$unisup=$quant*$pr_pdn/1000;
	}
	if (($pr_pac>5)&&($pr_pac <10)){ # alcool
 		$unisup=$quant*($pr_pdn/1000)*($pr_deg/100);
	}
	if (($pr_pac==15)||($pr_pac==17)){  # cigarette et tabac
		$unisup=$quant*($pr_pdn/1000);
	}
	if ($pr_pac==16){  # cigares
		$unisup=$quant*($pr_qte_comp/1000);
	}
#	if ($pr_ndp_sh eq "22030001"){print "$unisup<br>";}
	
	return ($unisup);
}


# -E edition des deb
