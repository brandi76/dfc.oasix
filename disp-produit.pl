#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;

$le_code = $html->param("code");
$la_devise = $html->param("devise");
if($la_devise eq ""){
		$la_devise = "EU";
}

# traitement via une recherche

if (! grep /[0-9]/,$le_code)
{ 
	 exec("/home/intranet/cgi-bin/chercheproduit.pl produit $le_code http://ibs.oasix.fr/cgi-bin/disp-produit.pl?code= 9");
}
require 'manip_table.lib';
require 'outils_perl.lib';

%ibs_idx = &get_index_multiple("BIS/stockibs",0);            
open(FILE2,"/home/var/spool/uucppublic/BIS/stockibs.txt");     # STOCK IBS
@ibs_dat = <FILE2>;


print "<html>\n";
print "<title>D I S P&nbsp;&nbsp;-&nbsp;&nbsp; P R O D U I T&nbsp;&nbsp;&nbsp;&nbsp;&copy;</title>\n"; 


open(DATE," /usr/local/bin/datemod.sh /home/var/spool/uucppublic/stre.txt |");
$ladate = <DATE>;
@ladate = split(/ /,$ladate);
close(DATE);
$code_produit_stre =0;
$stock_stre=0;
$prix_revien_stre=0;
$pr_ta_1=0;
$pr_ta_2=0;
$pr_ta_3=0;
$pr_ta_4 = 0;
$courf_gb=0;
$courf_ch=0;
$pr_prx_un=0;
$pr_desi="Produit inconnu";
$pr_cd_prod=$le_code;

if ($le_code != 0) { # permet d'accelerer le premier access
	%stre_idx= &get_index_num("stre",0); 
	open(FILE,"/home/var/spool/uucppublic/stre.txt"); 
	@stre_dat = <FILE>; 
        close (FILE);
        %produit_idx= &get_index_num("produit",1); 
	open(FILE,"/home/var/spool/uucppublic/produit.txt"); 
	@produit_dat = <FILE>; 
        close (FILE);
        %pays_idx= &get_index_num("pays",0);
        open(FILE,"/home/var/spool/uucppublic/pays.txt"); 
	@pays_dat = <FILE>; 
        close (FILE);
	
}
if ($produit_idx{$le_code}ne ""){ # si le produit existe on va recupere le stock et le prix de revient dans stre
	($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) =split (/;/,@produit_dat[$produit_idx{$le_code}]);
	$leparam = $pr_cd_nat*1000000 + $pr_cd_prod;
	$code_produit_stre,$stock_stre,$prix_revien_stre = 0;
	if($stre_idx{$leparam}ne""){
		($code_produit_stre,$stock_stre,$prix_revien_stre)=split (/;/,@stre_dat[$stre_idx{$leparam}]); 
	}
	$stock_ibs=0;
	if($ibs_idx{$le_code}ne""){
		($code,$stock_ibs)=split (/;/,@ibs_dat[$ibs_idx{$le_code}]); 
	}
	
	($nul,$nul,$nul,$nul,$cour_gb)=split (/;/,@pays_dat[$pays_idx{"6"}]); # on recupere le cour facuration
        ($nul,$nul,$nul,$nul,$cour_ch)=split (/;/,@pays_dat[$pays_idx{"39"}]);
}
print "<script language=javascript>\n";
print "prta1 = $pr_ta_1;\n";
print "prta2 = $pr_ta_2;\n";
print "prta3 = $pr_ta_3;\n";
print "prta4 = $pr_ta_4;\n";
print "prix_rev = $prix_revien_stre;\n";

# ------------- RECALCUL --------------------

print "function recalcul(dev){\n";
print "if(dev != 0){document.infoprod.devise.value = dev;\n";
print "}\n";
print "document.code_produit.devise.value = document.infoprod.devise.value;\n";
print "document.code_produit.devise.value = \"EU\";\n";
print "if(document.infoprod.devise.value == \"FF\"){\n";
print "cour = 0.15244;\n";
print "courc = 0.15244;\n";
print "document.infoprod.devise.SelectedIndex=1;";     
print "document.code_produit.devise.value = \"FF\";\n";
print "}\n";
print "if(document.infoprod.devise.value == \"EU\"){\n";
print "cour = 1;\n";
print "courc = 1;\n";
print "document.infoprod.devise.SelectedIndex=0;";     
print "}\n";
print "if(document.infoprod.devise.value == \"�\"){\n";
print "cour = ",$cour_gb/1000,";\n";
print "courc = 1.44;\n";   # ATTENTION COUR CATALOGUE A CHANGER CHAQUE ANNEE
print "document.infoprod.devise.SelectedIndex=3;";
print "document.code_produit.devise.value = \"�\";\n";
print "}\n";
print "if(document.infoprod.devise.value == \"CHF\"){\n";
print "cour = ",$cour_ch/1000,";\n";
print "courc = 0.60;\n";
print "document.infoprod.devise.SelectedIndex=2;";     
print "document.code_produit.devise.value = \"CHF\";\n";
print "}\n";
# print "alert(\"test\");";
print "monnai = \" \" + document.infoprod.devise.value;\n";
print "document.infoprod.prix_unitaire.value = Math.round($pr_prx_un / courc * 100) / 100 + monnai;\n";
print "document.infoprod.tarifA.value = Math.round((prix_rev * prta1) /10 / cour) / 100 + monnai;\n";
print "document.infoprod.tarifB.value = Math.round((prix_rev * prta2) /10 / cour) / 100 + monnai;\n";
print "document.infoprod.tarifC.value = Math.round((prix_rev * prta3) /10 / cour) / 100 + monnai;\n";
print "document.infoprod.tarifD.value = Math.round((prix_rev * prta4) /10 / cour) / 100 + monnai;\n";
print "}\n";
print "</script>\n";

print "<LINK rel=\"stylesheet\" href=\"/intranet.css\" type=\"text/css\">\n";	
print "<body bgcolor=\"white\" link=darkgoldenrod vlink=darkgoldenrod alink=darkgoldenrod topmargin=5 onload='recalcul(\"",$html->param('devise'),"\");document.code_produit.code.focus()'>\n";
&tete("DISP-PRODUIT ","/home/var/spool/uucppublic/stre.txt");
print "<form name=infoprod>\n";
# print $pr_prx_un;
# print $cour_gb;
print "<table width=100% border=0><tr><td>";  
if (-e "../../site-ibs/public_html/cata2000/photo/$pr_cd_prod.jpg"){
		print "<img src=http://site-ibs.dom/cata2000/photo/$pr_cd_prod.jpg align=left border=0>\n";
	
	}

# formulaire dans lequel se trouve les informations sur le produit
print "</td><td align=center>";
print "<strong><font size=4>\n";



print "<input type=hidden name=produit value=$pr_cd_prod><h3>$pr_cd_prod , $pr_desi &nbsp;&nbsp;&nbsp;&nbsp;<i><font color=gray size=-1>Page $pr_page</i></font></h3></td>\n";

print "</tr></table>";
print "<table border=0 width=100%><tr>\n";
	print "<td align = center><font color=green><b>Prix Unitaire</b></font></td>\n";
	print "<td align = center><i><u>TARIF A</td>\n";
	print "<td align = center><i><u>TARIF B</td>\n";
	print "<td align = center><i><u>TARIF C</td>\n";
	print "<td align = center><i><u>TARIF D</td></tr>\n";
	
	print "<tr>\n<td align = center><input type=text name=prix_unitaire size=9></td>\n";
	print "<td align = center><input type=text name=tarifA size=9></td>\n";
	print "<td align = center><input type=text name=tarifB size=9></td>\n";
	print "<td align = center><input type=text name=tarifC size=9></td>\n";
	print "<td align = center><input type=text name=tarifD size=9></td>\n";
	print "</tr></table>\n";
	print "<p align=center>\n";
	print "<table border=0 width=75%><tr>\n";
	print "<td align=center>Prix de revient : <b>$prix_revien_stre EU</b></td>\n";
	print "<td align=center><font color=blue>Stock : <b>$stock_stre</b></font></td>";
	print "<font color=green><b> Stock Ibs:$stock_ibs</b></td><td><font size=-1><a href=disp-command.pl?produit=$pr_cd_prod>Commande fournisseur en cours</a></font></td>\n";
	print "<td valign=middle align=center>\n";
	# on recalcul et on met a jour les tarifs si la devise change
	print "<br><select name=\"devise\" onChange=recalcul(0);>\n";
        print "<option ";
        if($la_devise eq "FF"){ print "selected "; }
        print "value=\"FF\">Francs Fran�ais</option>\n";
        print "<option ";
        if($la_devise eq "EU"){ print "selected "; }
        print "value=\"EU\">Euro</option>\n";
        print "<option ";
        if($la_devise eq "�"){ print "selected "; }
        print "value=\"�\">Livre Sterling</option>\n";
        print "<option ";
        if($la_devise eq "CHF"){ print "selected "; }
        print "value=\"CHF\">Francs Suisse</option>\n";
        print "</select></p>\n";
	print "</tr></table>\n";
print "</font></strong></form><hr width=25%>";
print "<form name=code_produit method=post action=../cgi-bin/disp-produit.pl>\n";
print "<input type=hidden value='disp-produit.pl' name=lien><br>";
print "\n<input type=hidden name=ok value='yes'>\n";



# formulaire de la requete contenent le code produit

print "<center><input name=\"devise\" type=hidden value=\"$la_devise\"><b>Code du produit ou d�signation : </b><input type=text name=code ";
	print" onBlur=document.infoprod.devise.focus()>\n";
	print "</form>\n";


		
	



print "</body></html>\n";
# -E info produit
# -B 06/11/2000  sylvain ajout de l'entete standard 