#!/usr/bin/perl
use CGI; 
$html=new CGI;
require 'manip_table.lib';
require 'outils_perl.lib';

print $html->header; # impression des parametres obligatoires

$var = $html->param('produit'); # la variable test contient le code produit
print "<html><body>";
&tete("DISP-COMMANDE ","/home/var/spool/uucppublic/command.txt");
print "<br><br><br>";
if ($var eq ""){&html();}
else{

%commande_idx = &get_index_multiple("command",2);
open(FILE2,"/home/var/spool/uucppublic/command.txt");
@commande_dat=<FILE2>;
close(FILE2);

%fournisseur_idx = &get_index_num("fournisseur",0);
open(FILE2,"/home/var/spool/uucppublic/fournisseur.txt");
@fournisseur_dat=<FILE2>;
close(FILE2);

%produit_idx = &get_index_num("produit",1);
open(FILE2,"/home/var/spool/uucppublic/produit.txt");
@produit_dat=<FILE2>;
close(FILE2);

if ($produit_idx{$var} ne ""){
	($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$produit_idx{$var}]);
}
if ($commande_idx{$var} ne ""){
	(@element)=split(/;/,$commande_idx{$var});
	foreach(@element){
		($co_cd_fo,$co_no_co,$co_cd_prod,$co_ref_fo,$co_qte,$co_prac,$co_devac,$co_rem,$co_date,$co_cd_liv,$co_in,)=split(/;/,$commande_dat[$_]);
		$fo_cd_fo=$fo_desi="";
		if ($fournisseur_idx{$co_cd_fo} ne ""){
			($fo_cd_fo,$fo_add,$fo_pays,$fo_sld,$fo_cu,$fo_telph,$fo_tlx,$fo_mini,$fo_delai,$fo_natcont,$fo_flag,$fo_fax,)=split(/;/,$fournisseur_dat[$fournisseur_idx{$co_cd_fo}]);
		}
	push (@table,"$fo_cd_fo;$co_no_co;$fo_add;$co_date;$co_qte;");
	}
}
if ($#table >= 0){
	print "<center><table border=1><tr bgcolor=gold><td colspan=4><b>$var $pr_desi</td></tr>";
	print "<tr><td><b>fournisseur</td><td><b>No de commande</td><td><b>date</td><td><b>qte</td></tr>";
	
	foreach (@table){
		($fo_cd_fo,$co_no_co,$fo_add,$co_date,$co_qte)=split(/;/,$_);
		print "<tr><td>$fo_cd_fo $fo_add</td><td>$co_no_co</td><td>$co_date</td><td>$co_qte</td></tr>";
		}
print "</table>";
}
else
{
	print "<center>le produit \"$var $pr_desi\" n'a aucune commande en cours";
}
print "<br><br><a href=\"javascript:history.go(-1)\">retour</a> </body></html>";
}
sub html(){
	print "<center><form action=disp-command.pl>code produit <input type=texte name=produit zize=6> <input type=submit value=go></form></body></html>";
	}