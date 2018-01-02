#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print $html->header;
%vent_idx = &get_index_unique("categorie-douane");
%produit_idx = &get_index_num("produit",1);
open(FILE2,"/home/var/spool/uucppublic/produit.txt");
@produit_dat=<FILE2>;
close(FILE2);

%stock_idx = &get_index_num("stre",0);
open(FILE2,"/home/var/spool/uucppublic/stre.txt");
@stock_dat=<FILE2>;
close(FILE2);
 open(FILE,">/home/sylvain/abrandi");
#open(SAUV,">/home/var/spool/uucppublic/ventilation-douane.txt");

&printcle(%vent_idx);

print "<h1>Liste des produits sans code de ventilation</h1>";
foreach (@produit_dat) {
	($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$_);
	$pr_stan+=0;
	$pr_stre+=0;
	$pr_cd_fr+=0;
	# if ($pr_stre==0){next;}
	# if ($pr_cd_prod<229315){next;} # produit alimentaire
	# if ($pr_famille ==1){next;}			# entrepot epicierie
	# if ($pr_cd_prod>700000){next;} # produit menager
	# if (($pr_cd_fr==4)||($pr_cd_fr==0)){next;} 	# produit alimentaire
	if (($pr_stan==0)&&($pr_stre==0)){next;}	   	# stock vide	
	# if ($pr_famille<2){next;}	
	$pr_pac+=0;
	# if ($pr_cd_nat > 2) {next;}			# epicerie
	# print "$pr_cd_prod $pr_pac<br>";
	if (($pr_pac > 0)&& ($pr_pac <40)){		# code ventilation existante
		$ventilation{$pr_ndp_sh}=$pr_pac;
	}
	else{
		push (@produit,"$pr_ndp_sh;$pr_cd_prod");			# produit en erreur
	}		
}
print "<table><tr><td><b>Code</td><td><b>Désignation</td><td><b>stock ancien</td><td><b>Stock</td><td><b>Entrepot</b></td><td><b>Ndp</td></tr>";
@produit=sort (@produit);
foreach (@produit){
	($ndp,$code)=split(/;/,$_);
	($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$produit_idx{$code}]);
	print "<tr><td>$pr_cd_nat $pr_cd_prod</td><td>$pr_desi</td><td>$pr_stan</td><td>$pr_stre</td><td>$pr_famille</td><td>$ndp";	
	print FILE "$pr_cd_prod\n";
	if ($ventilation{$pr_ndp_sh}ne""){
		print "<font color=red>";
		print $ventilation{$pr_ndp_sh};
	#	print " ";
	#	print $vent_idx{$ventilation{$pr_ndp_sh}};
	#	print "</font>";
	}
	else{
		print "&nbsp;";
		}
		
	print "</td></tr>";
}
print "</table>";
# -E verification des codes produits en fontion de la douane
