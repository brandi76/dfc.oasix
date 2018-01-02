#!/usr/bin/perl
use CGI; 
$html=new CGI;
require 'manip_table.lib';
require 'outils_perl.lib';
print $html->header; # impression des parametres obligatoires


$fich_catal = "/home/var/spool/uucppublic/cata20.txt";	# fichier catalogue


$page_premiere = $html->param('page_premiere');
$page_derniere = $html->param('page_derniere');

if ($page_premiere eq "")
{
	&html();
}
else
{
print "<html>\n";
print "<HEAD>\n";
print "<STYLE type=\"text/css\" >
H1 { page-break-after : right }          
span.police { font-family:\"Verdana\"}
span.taille1 {font-size=54px}
span.taille2 {font-size=18px}
span.taille3 {font-size=14px}
span.taille4 {font-size=12px}
span.taille5 {font-size=16px}

 </STYLE></head>";

print "<body bgcolor=white>\n";
&papier_entete();
print "<P>&nbsp;</P><P>&nbsp;</P>&nbsp;</P><P>&nbsp;</P>";
print "<p>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp<font color=\"#101646\">Dieppe, le \n";
print "<script>\n";
print "<!-- Affichage de la date du jour -->\n";
print "today = new Date\n";
print "jour = today.getDate();\n";
print "mois = today.getMonth();\n";
print "mois++;\n";
print "annee = today.getYear();\n";
print "document.write(jour+\"/\"+mois+\"/\"+annee)</script>\n";
print "<br><br><br><br>\n";
print "<table border=\"0\" width=\"650\" cellspacing=\"0\" cellpadding=\"0\">\n";
%produit_idx = &get_index_num("produit",1);
open(FILE1,"/home/var/spool/uucppublic/produit.txt");
@produit_dat = <FILE1>;
open(CATALOGUE,"< $fich_catal");
@FICHIER = <CATALOGUE>;
        foreach(@FICHIER){
	($code,$desi_cata,$page,$titre,$soustitre,$desi_prod)=split(/;/,$_); 
	($nul,$page2)=split(/ /,$page);
	if (($page2 >= $page_premiere) && ($page2 <= $page_derniere))
	{
	if ($titre ne $titre_ref){
		print "<tr><td colspan=2><b><br>$titre</b></td><td><br>$page</td><td align=right><br><font size=2>Degré</font></td><td align=right><br><font size=2>Litrage en Litre</td></tr>\n";
		$titre_ref=$titre;
	}
	if ($soustitre ne $soustitre_ref){
		if ($soustitre ne 0){print "<tr><td colspan=3><b>$soustitre</b></td></tr>\n";}
		$soustitre_ref=$soustitre;
	}
	print "<tr><td><font size=2>$code</font></td>";
	$desi_cata=substr($desi_cata,0,40);
	print "<td><font size=2>$desi_cata</font></td>";
	($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev)=split (/;/,@produit_dat[$produit_idx{$code}]);
        print "<td><font size=2 color=gray>$pr_desi</font></td>";
        
        printf ("<td align=right><font size=2><b>%10.2f </b></font></td>",$pr_deg);
        printf ("<td align=right><font size=2><b>%10.3f </b></font></td>",$pr_pdn/1000);

	print "</tr>";
	}
	       }      
	
close(CATALOGUE);
print "</table></body></html>\n";
}
# premiere page
		        	
sub html(){

&body();
&tete("LISTING DES DEGRES","/home/var/spool/uucppublic/produit.txt");
print <<"eof";
<center>
<form name=degre action=../cgi-bin/degre.pl>
<br>

<br><br><br><br>
Première page
<input type=text name=page_premiere value=11 size=3>
<br>
Dernière page
<input type=text name=page_derniere value=330 size=3>

<br><br><br><br>
<input type=submit value="Afficher">
<br>

</form>
Le document qui va être créé (patientez quelques minutes) peut être imprimé en utilisant le menu fichier->impression de votre navigateur<br>
</center>
<br><img src=http://intranet.dom/creation2000p.gif align=right border=0>
</body>
</html>
eof
}


sub papier_entete{
print "<span class=police>
	<span class=taille1>
		<IMG SRC='http://intranet.dom/bislogo.gif'>
	</span>
	<span class=taille3>
		<SPAN style=\"position: absolute; top: ",$page*27.7+3,"cm; left: 0cm;\">&nbsp;&nbsp;&nbsp;B.P. 106 -76203 DIEPPE Cedex</SPAN>
		<SPAN style	=\"position: absolute; top: ",$page*27.7+3.5,"cm; left: 0cm;\">&nbsp;&nbsp;&nbsp;Tél. 33 (0) 232 140 280 - Téléfax : 33 (0) 232 140 299</SPAN>
	</span>
</span>
";
}
# -E edition d'un listing avec les degrés


