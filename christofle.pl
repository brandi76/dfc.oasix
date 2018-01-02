#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print $html->header;
%pourqui_idx = &get_index_num("pourqui",0);
open(FILE2,"/home/var/spool/uucppublic/pourqui.txt");
@pourqui_dat=<FILE2>;
close(FILE2);
%produit_idx = &get_index_num("produit",1);
open(FILE2,"/home/var/spool/uucppublic/produit.txt");
@produit_dat=<FILE2>;
close(FILE2);
%infococl_idx = &get_index_num("infococ",0);
open(FILE2,"/home/var/spool/uucppublic/infococ.txt");
@infococl_dat=<FILE2>;
close(FILE2);
%client_idx = &get_index_num("client2",0);
open(FILE2,"/home/var/spool/uucppublic/client2.txt");
@client_dat=<FILE2>;
close(FILE2);

%produitchri_idx = &get_index_multiple("produit",6);
open(FILE2,"/home/var/spool/uucppublic/produit.txt");
@produitchri_dat=<FILE2>;
close(FILE2);

%stockbis_idx = &get_index_num("stre",0);
open(FILE2,"/home/var/spool/uucppublic/stre.txt");
@stockbis_dat=<FILE2>;
close(FILE2);

%stock_idx = &get_index_num("BIS/stockibs",0);
open(FILE2,"/home/var/spool/uucppublic/BIS/stockibs.txt");
@stock_dat=<FILE2>;
close(FILE2);
&tete("CHRISTOFLE","/home/var/spool/uucppublic/pourqui.txt","non");
print "<br><br><br>";
print "<center><table border=1><tr><td colspan=8><b><font size=+1>PRODUIT EN COMMANDE</td></tr>";
print "<td><b>Code</td><td><b>Designation</td><td><b>Commande</td><td><b>Stock bis</td><td><b>Date de reception</td><td><b>Code client</td><td><b>Nom</td><td><b>Ambassade</td></tr>";
foreach (@pourqui_dat) {
	($po_cd_pr,$po_no_cde,)=split(/;/,$_);
	$po_cd_pr=$po_cd_pr%1000000;
	if ($produit_idx{$po_cd_pr}ne""){
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$produit_idx{$po_cd_pr}]);
		if ($pr_cd_fourn==110640){
			if ($color eq "#efefef"){$color="white";}
			# else{$color="#00FFCC";}
			else{$color="#efefef";}
			
			print "<tr bgcolor=$color><td>$pr_cd_prod</td><td>$pr_desi</td><td>$po_no_cde</td>";
			$codelong=$pr_cd_nat*1000000+$pr_cd_prod;
			$stock="&nbsp;";
			if ($stockbis_idx{$codelong}ne""){
				($code,$stock,$prix)=split(/;/,$stockbis_dat[$stockbis_idx{$codelong}]);
				}
			print "<td align=right>$stock</td>";
				
			if ($infococl_idx{$po_no_cde}ne""){
				($icc_no,$icc_cd_cl,$icc_add,$icc_pdb,$icc_col,$icc_dev,$icc_sub,$icc_ind,$icc_in_pos,$icc_cd_liv,$icc_dt_recp,$icc_tarif,$icc_ex3,$icc_delai,$icc_modif,$icc_camion,$icc_prtr_cdfr,$icc_cd_fa,$icc_carte,$icc_val,$icc_fact,$icc_lib,$icc_prom,)=split(/;/,$infococl_dat[$infococl_idx{$po_no_cde}]);
				#print $infococl_dat[$infococl_idx{$po_no_cde}];
				while ($icc_add=~s/\*//g){};
				print "<td>$icc_dt_recp</td><td>$icc_cd_cl</td><td>$icc_add</td>";
				if ($client_idx{$icc_cd_cl}){
					($cl_cd_cl,$cl_add,$cl_pays,$cl_cd_prx,$cl_sld,$cl_relance,$cl_ca,)=split(/;/,$client_dat[$client_idx{$icc_cd_cl}]);
					($ambassade)=split(/\*/,$cl_add);
					print "<td>$ambassade</td>";
				}
			}
			print "</tr>";
		} 
	}
}

print "</table><br><br>";
print "<center><table border=1><tr><td colspan=3><b><font size=+1>PRODUIT EN STOCK CHEZ IBS</td></tr><td><b>Code</td><td><b>Designation</td><td><b>stock</td></tr>";

if ($produitchri_idx{110640} ne""){
	@liste=split(/;/,$produitchri_idx{110640});
	foreach(@liste){
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$_]);
		if ($stock_idx{$pr_cd_prod}ne""){
			($code,$stock,$prix)=split(/;/,$stock_dat[$stock_idx{$pr_cd_prod}]);
			if ($stock>0){
				$codelong=$pr_cd_nat*1000000+$pr_cd_prod;
				if ($pourqui_idx{$codelong}ne""){
					print "<tr><td><b>$pr_cd_prod</td><td><b>$pr_desi</td><td><b>$stock</td></tr>";
				}
				else{
					print "<tr><td>$pr_cd_prod</td><td>$pr_desi</td><td>$stock</td></tr>";
				}
			}
		}
	}
}

print "</table></body></html>";
# -E permetde trouver les commandes christofle