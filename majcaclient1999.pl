#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';

%produit_idx = &get_index_num("produit",1);            
open(FILE2,"/home/var/spool/uucppublic/produit.txt");     # produit : info detaille des produits
@produit_dat = <FILE2>;
close(FILE2);

@facdata_dat = `sort -t';' +2 /home/var/spool/uucppublic/fac1999.txt`;

foreach(@facdata_dat){                                       # pour chaque produit
	  ($facd_no,$facd_no_cde,$facd_cd_cl,$facd_cd_pr,$facd_qte,$facd_puni,$facd_dev,$facd_rem,$facd_date,$facd_prev,$facd_promo)= split (/;/,$_); 
	$code = $facd_cd_pr % 1000000;
        $pr_page=1;
	($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split (/;/,@produit_dat[$produit_idx{$code}]);
	$facd_cd_cl += 0;
	
	$mois = substr($facd_date,2,2);
	$mois = $mois + 0;
	# if ($facd_dev == 6){
	#	$moisref=199700+$mois;
	#	$cour=10;
	#	if ($gbp_idx{$moisref}ne""){
	#		($month,$cour)=split(/;/,$gbp_dat[$gbp_idx{$moisref}]);
	#	}
	#	$facd_puni*=$cour/6.55957;
	#}
        
        if ($facd_dev == 1){$facd_puni*=1/6.55957};
        if ($facd_dev == 2){$facd_puni*=0.16/6.55957};
        if ($facd_dev == 4){$facd_puni*=3.35/6.55957};
	if ($facd_dev == 400){$facd_puni*=7/6.55957};
        if ($facd_dev == 6){$facd_puni*=10/6.55957};
        if ($facd_dev == 17){$facd_puni*=0.16/6.55957};
        if ($facd_dev == 39){$facd_puni*=3.80/6.55957};
        if (($facd_rem != 0) && ($facd_promo == 0)){$facd_puni=$facd_puni - ($facd_puni*$facd_rem/100);}
        $mont=$facd_puni*$facd_qte;
	if($mois == 1){
		$janvier{$facd_cd_cl} = 0 + $janvier{$facd_cd_cl} + $mont;
	}
	if($mois == 2){
		$fevrier{$facd_cd_cl} = 0 + $fevrier{$facd_cd_cl} + $mont;
	}
	if($mois == 3){
		$mars{$facd_cd_cl} = 0 + $mars{$facd_cd_cl} + $mont;
	}
	if($mois == 4){
		$avril{$facd_cd_cl} = 0 + $avril{$facd_cd_cl} + $mont;
	}
	if($mois == 5){
		$mai{$facd_cd_cl} = 0 + $mai{$facd_cd_cl} + $mont;
	}
	if($mois == 6){
		$juin{$facd_cd_cl} = 0 + $juin{$facd_cd_cl} + $mont;
	}
	if($mois == 7){
		$juillet{$facd_cd_cl} = 0 + $juillet{$facd_cd_cl} + $mont;
	}
	if($mois == 8){
		$aout{$facd_cd_cl} = 0 + $aout{$facd_cd_cl} + $mont;
	}
	if($mois == 9){
		$septembre{$facd_cd_cl} = 0 + $septembre{$facd_cd_cl} + $mont;
	}
	if($mois == 10){
		$octobre{$facd_cd_cl} = 0 + $octobre{$facd_cd_cl} + $mont;
	}
	if($mois == 11){
		$novembre{$facd_cd_cl} = 0 + $novembre{$facd_cd_cl} + $mont;
	}
	if($mois == 12){
		$decembre{$facd_cd_cl} = 0 + $decembre{$facd_cd_cl} + $mont;
	}
	if($mois >=1 && $mois <=12){
		$liste{$facd_cd_cl} += 0 + $liste{$facd_cd_cl} + $mont;
	}

}

@index = sort keys(%liste);

open(FILE,"> /home/var/spool/uucppublic/CAclient1999.txt");
foreach(@index){
	$janvier{$_}=int($janvier{$_}*100)/100;
	$fevrier{$_}=int($fevrier{$_}*100)/100;
	$mars{$_}=int($mars{$_}*100)/100;
	$avril{$_}=int($avril{$_}*100)/100;
	$mai{$_}=int($mai{$_}*100)/100;
	$juin{$_}=int($juin{$_}*100)/100;
	$juillet{$_}=int($juillet{$_}*100)/100;
	$aout{$_}=int($aout{$_}*100)/100;
	$septembre{$_}=int($septembre{$_}*100)/100;
	$octobre{$_}=int($octobre{$_}*100)/100;
	$novembre{$_}=int($novembre{$_}*100)/100;
	$decembre{$_}=int($decembre{$_}*100)/100;
	
	print FILE "$_;$janvier{$_};$fevrier{$_};$mars{$_};$avril{$_};$mai{$_};$juin{$_};$juillet{$_};$aout{$_};$septembre{$_};$octobre{$_};$novembre{$_};$decembre{$_};\n";
}
close(FILE);
exec("/home/intranet/cgi-bin/suivi-commer.pl");

# -E programme pour generer les fichiers CAclient
# creer le fichier fac01.txt avec L-FACDATA sur l'aryx
# mettre le fichier dans uucppublic
# lancer ce programme pour generer CAclient2001.txt
# utiliser les programmes qui si refere ex:baton2.pl