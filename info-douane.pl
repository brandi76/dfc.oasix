#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
%produit_idx= &get_index_num("produit",1); 
open(FILE,"/home/var/spool/uucppublic/produit.txt"); 
@produit_dat = <FILE>; 
close (FILE);
     
$code = $html->param("code");
&tete("INFORMATION DOUANIERE","/home/var/spool/uucppublic/produit.txt");
print "<center><br><br>";
if ($code ne ""){
	if ($produit_idx{$code} ne ""){ 
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) =split (/;/,@produit_dat[$produit_idx{$code}]);
		print "<br><br><b>$pr_cd_prod $pr_desi</b><br>";
		print "Code nature:$pr_cd_nat<br>";		
		print "Code franchise:$pr_cd_fr<br>";		
		print "Code ndp:$pr_ndp_sh<br>";		
		print "Code entrepot:$pr_famille<br>";		
		print "Code ventitaltion:$pr_pac<br>";		
		print "Code franchise:$pr_cd_fr<br>";
	}
	else{ print "<font color=red>code produit introuvable</font>";}		
}
print "<br><br><br><form action=info-douane.pl>Code produit: <input type =text name=code size=8><br><input type=submit value=go></font>";
print "</body></html>";

# -E info produit douane
