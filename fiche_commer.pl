#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print $html->header;
$action=$html->param("action");
$selection=$html->param("selection");
$date1=$html->param("date1");
$date2=$html->param("date2");
if($date1 eq ""){
	$date1 = '010102';
}

%client_idx = &get_index_num("client2",0);            
open(FILE3,"/home/var/spool/uucppublic/client2.txt");   
@client_dat = <FILE3>;
close (FILE3);
&tete("SUIVI DES MARGES","/home/var/spool/uucppublic/echecom.txt");
print "<br><br><br>";
if ($action eq "") {
	&html();
	exit;
} 

$compteur=0;
`cat /home/var/spool/uucppublic/infococ.txt /var/spool/uucppublic/inf-arc.txt /var/spool/uucppublic/archive/infococl-2001.txt >/var/spool/uucppublic/inftemp.txt`;

%infococl_idx = &get_index_num("inftemp",0);            
open(FILE2,"/home/var/spool/uucppublic/inftemp.txt");  # entete de commande
@infococl_dat=<FILE2>;
close(FILE2);

`cat /home/var/spool/uucppublic/echecom.txt /var/spool/uucppublic/archive/ec-2001.txt >/var/spool/uucppublic/ectemp.txt`;
open(FILE2,"/home/var/spool/uucppublic/ectemp.txt");  # echeancier
@echeancier_dat=<FILE2>;
close(FILE2);

%facdata_idx = &get_index_multiple("fac2002",0);            
open(FILE3,"/home/var/spool/uucppublic/fac2002.txt");   # facdata
@facdata_dat = <FILE3>;
close(FILE3);

%produit_idx = &get_index_num("produit",1);            
open(FILE3,"/home/var/spool/uucppublic/produit.txt");   
@produit_dat = <FILE3>;

if ($selection eq "john"){
	$titre="JOHN";
	$lettre="J";
	@part=(47.66,24.37,27.97,30.62,26.60,19.53);
}
if ($selection eq "chantal"){
	$titre="CHANTAL";
	$lettre="C";
	@part=(63.92,21.33,14.75,36.72,34.16,30.14);
}
if ($selection eq "emmanuelle"){
	$titre="EMMANUELLE";
	$lettre="E";
	@part=(44.40,13.03,42.57,31.91,31.22,24.64);
}
if ($selection eq "bernard"){
	$titre="BERNARD";
	$lettre="B";
	@part=(64.04,26.82,9.13,36.46,31,34.04);
}
if ($selection eq "maryline"){
	$titre="MARYLINE";
	$lettre="M";
	@part=(10.59,29.57,59.83,27.71,31.59,23.78);
}

if ($selection eq "nonaffecte"){
	$titre="NON AFFECTES";
	$lettre="S;SP;N";
	@part=(0,100,0,13.15,13.15,13.15);
}

if ($selection eq "tout"){
	$titre="TOUS LES COMMERCIAUX";
	$lettre="J;M;C;B;E";
	@part=(53.40,22.27,24.34,33.40,30.03,23.99);
}

$premiere='100150';
$derniere=0;


foreach (@echeancier_dat) {
	$compteur++;
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev,$bug)  = split(/;/,$_);
        if (&nbjour($ec_dt)<&nbjour(10102)){next;}
        
        if (&nbjour($ec_dt)<&nbjour($date1)){next;}
        if (&nbjour($ec_dt)>&nbjour($date2) && $date2 ne ""){next;}

        #if (&nbjour($ec_dt)<&nbjour($premiere)){next;}
        #if (&nbjour($ec_dt)>=&nbjour($deniere)){next;}

	if ($ec_no_fact < 0) {
		$vente_bois+=$ec_mont;
		next;
	}

	(@tab)=split(/;/,$client_dat[$client_idx{$ec_cd_cl}]);
	
	(@lettre)=split(/;/,$lettre);
	$ok=0;
	foreach (@lettre){
	if ($tab[7]=~/^$_/){$ok=1;}
	}
	if ($ok==0){next;}
	if (($ec_mont==0)&&($ec_reg==0)){next;}


	if (&nbjour($ec_dt)<&nbjour($premiere)){$premiere=$ec_dt;}
	if (&nbjour($ec_dt)>&nbjour($derniere)){$derniere=$ec_dt;}
	 #print "$premiere;$derniere;$ec_no_fact;$ec_dt<br>";	
	if ( grep /[a-z,A-Z,0-9]/,$bug){
		print "<center><br><font color=red>Erreur dans le fichier echeancier , merci de prevenir sylvain<br></font>";
		print "$ec_cd_cl $ec_no_fact *$bug*";
		exit;
	}
	
	$ec_no_fact+=0;
	$ec_mont+=0;
	$ec_reg+=0;
	$ec_cd_cl+=0;
	if ($ec_mont!=0){$cours=$ec_mont_dev/$ec_mont;}

	$total+=$ec_mont;
	$totalreg+=$ec_reg;
	&code_mini();
	$totald{$cl_mini}+=$ec_mont;

	$ec_no_fact+=10000000;

	# test si la facture est dans facdata (copie des factures informatiques)
	if ($facdata_idx{$ec_no_fact} eq ""){
		# $vente_manuel+=$ec_mont;
		# &affiche();
		push (@tabecart,"$ec_no_fact;$ec_mont;0");

		next;
	}
	    

	(@liste)=split(/;/,$facdata_idx{$ec_no_fact});
	$ecartmont=0;
	foreach $element (@liste){                                       # pour chaque produit
		$compteur++;
		($facd_no,$facd_no_cde,$facd_cd_cl,$facd_cd_pr,$facd_qte,$facd_puni,$facd_dev,$facd_rem,$facd_date,$facd_prev,$facd_promo)= split (/;/,$facdata_dat[$element]); 
		if ($facd_puni==0){next;}
           	$facd_cd_pr+=0;
        	$facd_cd_cl+=0;
        	$code=$facd_cd_pr%1000000;
  		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$produit_idx{$code}]);
		$compt++;
		if ($facd_prev==0){$facd_prev=$pr_prx_rev}; 
           	$facd_rem+=0;
           	$facd_promo+=0;
           	$facd_puni=$facd_puni/$cours;
        	if ($facd_prev >$facd_puni){$facd_prev/=6.55957;}
        	if ($infococl_idx{$facd_no_cde}eq""){
			#&affiche();
			# print "$facd_no_cde<br>";
			# $vente_manuel+=$ec_mont;
			next;
		}
		($icc_no,$icc_cd_cl,$icc_add,$icc_pdb,$icc_col,$icc_dev,$icc_sub,$icc_ind,$icc_in_pos,$icc_cd_liv,$icc_dt_recp,$icc_tarif,$icc_ex3,$icc_delai,$icc_modif,$icc_camion,$icc_prtr_cdfr,$icc_cd_fa,$icc_carte,$icc_val,$icc_fact,$icc_lib,$icc_prom,)=split(/;/,$infococl_dat[$infococl_idx{$facd_no_cde}]);
       
	        # prix speciaux
		if ($pr_cd_prod eq 232060){
			$produit{$facd_cd_cl}+=$facd_qte*$facd_puni;
		}

		if (($icc_tarif>=1)&&($icc_tarif<5)){
			$client_spec_vente{$facd_cd_cl}+=$facd_qte*$facd_puni;
    			$client_spec_achat{$facd_cd_cl}+=$facd_qte*$facd_prev;
   
			$vente_spec+=$facd_qte*$facd_puni;
         		$achat_spec+=$facd_qte*$facd_prev;
			$qte_spec{$pr_cd_prod}+=$facd_qte;
	      		$produit_spec_vente{$pr_cd_prod}+=$facd_qte*$facd_puni;
	      		$produit_spec_achat{$pr_cd_prod}+=$facd_qte*$facd_prev;
 			
 			$qte_tous{$pr_cd_prod}+=$facd_qte;
  			$ecartmont+=$facd_qte*$facd_puni;

	      		$produit_tous_vente{$pr_cd_prod}+=$facd_qte*$facd_puni;
	      		$produit_tous_achat{$pr_cd_prod}+=$facd_qte*$facd_prev;
			$client_tous_vente{$facd_cd_cl}+=$facd_qte*$facd_puni;
			$client_tous_achat{$facd_cd_cl}+=$facd_qte*$facd_prev;
			
			next;
		}
		


           	# PRIX REMISE 
           	
           	if (($facd_rem != 0) && ($facd_promo <= 0)){
         		$facd_puni=$facd_puni - ($facd_puni*$facd_rem/100);
	
         		$client_spec_vente{$facd_cd_cl}+=$facd_qte*$facd_puni;
    			$client_spec_achat{$facd_cd_cl}+=$facd_qte*$facd_prev;
   
        		$vente_remise+=$facd_qte*$facd_puni;
         		$achat_remise+=$facd_qte*$facd_prev;
			$qte_spec{$pr_cd_prod}+=$facd_qte;
	      		$produit_spec_vente{$pr_cd_prod}+=$facd_qte*$facd_puni;
	      		$produit_spec_achat{$pr_cd_prod}+=$facd_qte*$facd_prev;
 			
 			$qte_tous{$pr_cd_prod}+=$facd_qte;
  			$ecartmont+=$facd_qte*$facd_puni;

	      		$produit_tous_vente{$pr_cd_prod}+=$facd_qte*$facd_puni;
	      		$produit_tous_achat{$pr_cd_prod}+=$facd_qte*$facd_prev;
			$client_tous_vente{$facd_cd_cl}+=$facd_qte*$facd_puni;
			$client_tous_achat{$facd_cd_cl}+=$facd_qte*$facd_prev;

         		next;
         	}
      	
      	  
 	 # 	if ($facd_puni <$facd_prev){
        #		print "$facd_no ; $pr_cd_prod;$pr_desi;$facd_qte;$facd_puni;$facd_prev <br>";
        #		}
      
	
    		$diff=$facd_puni-$pr_prx_un;
	
	
		# PRIX PROMO
		
		if (($diff >1 )||($diff <-1)){
			$qte_promo{$pr_cd_prod}+=$facd_qte;
	      		$produit_promo_vente{$pr_cd_prod}+=$facd_qte*$facd_puni;
	      		$produit_promo_achat{$pr_cd_prod}+=$facd_qte*$facd_prev;
			
			$client_promo_vente{$facd_cd_cl}+=$facd_qte*$facd_puni;
    			$client_promo_achat{$facd_cd_cl}+=$facd_qte*$facd_prev;
   
	      		$vente_promo+=$facd_qte*$facd_puni;
    			$achat_promo+=$facd_qte*$facd_prev;
    		}
		
		# PRIX CATALOGUE 
		
    		else{
	      		$produit_cata_vente{$pr_cd_prod}+=$facd_qte*$facd_puni;
	      		$produit_cata_achat{$pr_cd_prod}+=$facd_qte*$facd_prev;

			$qte_cata{$pr_cd_prod}+=$facd_qte;
			$client_cata_vente{$facd_cd_cl}+=$facd_qte*$facd_puni;
    			$client_cata_achat{$facd_cd_cl}+=$facd_qte*$facd_prev;
   
   	      		$vente_cata+=$facd_qte*$facd_puni;
    			$achat_cata+=$facd_qte*$facd_prev;
     		}	
    		
    		$qte_tous{$pr_cd_prod}+=$facd_qte;
    		$ecartmont+=$facd_qte*$facd_puni;
	      	$produit_tous_vente{$pr_cd_prod}+=$facd_qte*$facd_puni;
	      	$produit_tous_achat{$pr_cd_prod}+=$facd_qte*$facd_prev;
		$client_tous_vente{$facd_cd_cl}+=$facd_qte*$facd_puni;
		$client_tous_achat{$facd_cd_cl}+=$facd_qte*$facd_prev;

	
	}

	if ((($ec_mont-$ecartmont)>0.1)||(($ec_mont-$ecartmont)<-0.1)){
		push (@tabecart,"$ec_no_fact;$ec_mont;$ecartmont;2");
	}
}
$totalprec=0;
foreach (@echeancier_dat) {
	$compteur++;
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev,$bug)  = split(/;/,$_);
	$ec_no_fact+=0;
	if ($ec_no_fact<0){next;}
        if (&nbjour($ec_dt)<(&nbjour($premiere)-365)){next;}
	if (&nbjour($ec_dt)>(&nbjour($derniere)-365)){next;}
	(@tab)=split(/;/,$client_dat[$client_idx{$ec_cd_cl}]);
	(@lettre)=split(/;/,$lettre);
	$ok=0;
	foreach (@lettre){
	if ($tab[7]=~/^$_/){$ok=1;}
	}
	if ($ok==0){next;}
	if ($ec_no_fact<0){next;}
	&code_mini();	
	$totalprecd{$cl_mini}+=$ec_mont;
	$totalprec+=$ec_mont;
}


if ($action eq "fiche") {
	&fiche();
	exit;
} 
if ($action eq "top20cata") {
	$titre="AU PRIX CATALOGUE";
	%total_achat=%produit_cata_achat;
	%total_vente=%produit_cata_vente;
	%qte=%qte_cata;
	&top20();
	exit;
} 
if ($action eq "ecart") {
	&ecart();
	exit;
} 

if ($action eq "top20cata_cl") {
	$titre="AU PRIX CATALOGUE";
	%total_achat=%client_cata_achat;
	%total_vente=%client_cata_vente;
	&top20_cl();
	exit;
}

if ($action eq "top20promo") {
	$titre="A DES PRIX PROMOTIONNELS";
	%total_achat=%produit_promo_achat;
	%total_vente=%produit_promo_vente;
	%qte=%qte_promo;

	&top20();
	exit;
} 
if ($action eq "top20promo_cl") {
	$titre="A DES PRIX PROMOTIONNELS";
	%total_achat=%client_promo_achat;
	%total_vente=%client_promo_vente;
	&top20_cl();
	exit;
}

if ($action eq "top20spec") {
	$titre="A DES PRIX SPECIAUX";
	%total_achat=%produit_spec_achat;
	%total_vente=%produit_spec_vente;
	%qte=%qte_spec;

	&top20();
	exit;
} 

if ($action eq "top20spec_cl") {
	$titre="A DES PRIX SPECIAUX";
	%total_achat=%client_spec_achat;
	%total_vente=%client_spec_vente;
	&top20_cl();
	exit;
}

if ($action eq "top20tous") {
	$titre=" TOUS LES COMMERCIAUX";
	%total_achat=%produit_tous_achat;
	%total_vente=%produit_tous_vente;
	%qte=%qte_tous;

	&top20();
	exit;
} 

if ($action eq "top20tous_cl") {
	$titre="";
	%total_achat=%client_tous_achat;
	%total_vente=%client_tous_vente;
	&top20_cl();
	exit;
}

if ($action eq "top20test") {
	$titre="test";
	&top20test();
	exit;
} 
if ($action eq "top20bad_cl") {
	$titre="TOP 25 DES CLIENTS AVEC UN CHIFFRE D'AFFAIRE EN BAISSE";
	&top20bad_cl();
	exit;
}

# FIN


sub fiche {
	print "<center><table border=1 width=70%>";
	print "<tr><td  colspan=6 align=center><b>$titre</td></tr>";
	print "<tr><td colspan=6 align=center>Période du ";
	print &date($premiere);
	print " au ";
	print &date($derniere);
	print "</td></tr>";
	print "<tr bgcolor=#efefef><td><b>Chiffre d'affaire</b></td><td><b>Montant €</td><td>Realisé en 2001<br>même période</td><td align=center><font color=red> Objectif</td><td align=center><b>Realisé</td></tr>";
	print "<tr><td>";
	print "realisé:</td><td align=right nowrap>";
	print &separateur($total);
	$total_sv=$total;
	print "<td align=right nowrap>";
	print &separateur($totalprec);
	print "</td>";
	print "<td align=right nowrap><font color=red>+ 17.53%";
	print "</td>";
	print "<td align=right nowrap>";
	if ($totalprec!=0){
	$enplus=(($total-$totalprec)*100/$totalprec);
	}
	else{
	$enplus=100;
	}
	if ($enplus<17.53){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print "<a href=fiche_commer?action=top20bad_cl&selection=$selection>";
	print &separateur($enplus);
	print " %</a></td></tr>";
	$vente_spec+=$vente_remise;
	$achat_spec+=$achat_remise;
	$vente_manuel=$total-$vente_promo-$vente_cata-$vente_spec;
	$achat_total=$achat_promo+$achat_cata+$achat_spec;
	print "<tr><td>";
	print "non enregistré informatiquement:</td><td align=right nowrap><a href=fiche_commer.pl?action=ecart&selection=$selection>";
	print &separateur($vente_manuel);
	print "</a></td></tr>";
	print "<tr bgcolor=#efefef><td>&nbsp;</td><td>&nbsp;</td><td align=center><b>Proportion </td><td align=center><font color=red> Objectif</td><td align=center><b>Marge</td><td align=center><font color=red>Objectif</td></tr>";
	$total-=$vente_manuel;
	print "<tr><td>";
	print "<a href=fiche_commer?action=top20tous_cl&selection=$selection>";
	print "realisé informatiquement:</a></td><td align=right nowrap>";
	print &separateur($total);
	print "</td><td>&nbsp;</td><td>&nbsp;</td><td align=right nowrap>";
	if ((($total-$achat_total)*100/$total)<$part[3]){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print "<a href=fiche_commer?action=top20tous&selection=$selection>";
	print "<b>";
	print &separateur(($total-$achat_total)*100/$total);
	$marge_sv=&separateur(($total-$achat_total)*100/$total);
	print " %</a></td><td align=right nowrap><font color=red>$part[3] %</td></tr>";
	print "<tr><td>";
	print "<a href=fiche_commer?action=top20cata_cl&selection=$selection>";
	print "realisé au prix catalogues:</a></td><td align=right nowrap>";
	print &separateur($vente_cata);
	print "</td><td align=right nowrap>";
	if (($vente_cata*100/$total)<$part[0]){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print &separateur($vente_cata*100/$total);
	print " %</td><td align=right nowrap><font color=red>au moins $part[0] %</td><td align=right nowrap>";
	if ((($vente_cata-$achat_cata)*100/$vente_cata)<39.09){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print "<a href=fiche_commer?action=top20cata&selection=$selection>";
	print &separateur(($vente_cata-$achat_cata)*100/$vente_cata);
	print " %</a></td><td align=right nowrap><font color=red>39.09 %</td></tr>";
	print "<tr><td>";
	print "<a href=fiche_commer?action=top20promo_cl&selection=$selection>";
	print "realisé à des prix promotionnels:</a>";
	print "</td><td align=right nowrap>";
	print &separateur($vente_promo);
	print "</td><td align=right nowrap>";
	if (($vente_promo*100/$total)>$part[1]){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print &separateur($vente_promo*100/$total);
	print " %</td><td align=right nowrap><font color=red>au maximum $part[1] %</td><td align=right nowrap>";
	if ((($vente_promo-$achat_promo)*100/$vente_promo)<$part[4]){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print "<a href=fiche_commer?action=top20promo&selection=$selection>";
	print &separateur(($vente_promo-$achat_promo)*100/$vente_promo);
	print " %</td><td align=right nowrap><font color=red>$part[4] %</td></tr>";
	print "<tr><td>";
	print "<a href=fiche_commer?action=top20spec_cl&selection=$selection>";
	print "realisé à des tarifs spéciaux:</a>";
	print "</td><td align=right nowrap>";
	print &separateur($vente_spec);
	print "</td><td align=right nowrap>";
	if (($vente_spec*100/$total)>$part[2]){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print &separateur($vente_spec*100/$total);
	print " %</td><td align=right nowrap><font color=red>au maximum $part[2] %</td><td align=right nowrap>";
	$vente_spec=1 if ($vente_spec==0);
	if ((($vente_spec-$achat_spec)*100/$vente_spec)<$part[5]){print "<img src=http://intranet.dom/poucedown.gif align=left>";}
	else {	print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	print "<a href=fiche_commer?action=top20spec&selection=$selection>";
	print &separateur(($vente_spec-$achat_spec)*100/$vente_spec);
	print " %</a></td><td align=right nowrap><font color=red>$part[5] %</td></tr>";
	print "</table>";
	# marge brut
	print "<br><center>Pourcentage d'impayé:";
	#print $total_sv;
	#print "<br>";
	#print $totalreg;
	#print "<br>";

	$impaye=($total_sv-$totalreg)*100/$total_sv;
	print &separateur($impaye),"%";
	
	print "<br><br><table border=1>";
	print "<tr><td>&nbsp;</td><td align=center><b>realisé</td><td align=center><font color=red><b>objectif</td><td align=center><b>ecart</td><td align=center><b>%</td></tr>";
	$marge_theo=$totalprec*1.1753*$part[3]/100;
	$marge_reel=$total*$marge_sv/100;
	
	print "<tr><td><b>Marge brute</td><td>";
	print &separateur($marge_reel);
	print "</td><td>";
	print &separateur($marge_theo);
	print "</td><td>";
	print &separateur($marge_reel-$marge_theo);
	print "</td><td><font color=red>";
	$marge_theo=1 if ($marge_theo==0);
	if (($marge_reel-$marge_theo)*100/$marge_theo>=0){print "<img src=http://intranet.dom/pouceup.gif align=left>";}
	else {	print "<img src=http://intranet.dom/poucedown.gif align=left>";}

	print &separateur(($marge_reel-$marge_theo)*100/$marge_theo);
	print " %</td></tr>";
	print "</table>";
	@temps=times;
	print "<br><font size=-2>$compteur enregistrements traités en ",$temps[0],"s</body></html>";

}

sub affiche{
	print "<font color=red>$ec_no_fact;$ec_cd_cl;";
	print &client($ec_cd_cl,"nom");
	print ";$ec_dt;$ec_mont;</font><br>";
}

########### PREMIERE PAGE #############
	


sub html
{
	print "<center><form name=commer action=fiche_commer.pl><input type=hidden name=action value=fiche>";
	print "<br>\n\n<br>\n\n";
	print "<center><table width=40% border=2 cellspacing=0 cellpadding=0 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod >";
	print "<tr>\n<td align=center>";
	print "JOHN <input type=radio name=selection value=john><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "CHANTAL<input type=radio name=selection value=chantal><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "BERNARD <input type=radio name=selection value=bernard><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "EMMANUELLE <input type=radio name=selection value=emmanuelle><br>\n";
       	print "</td></tr>";			    
       		print "<tr>\n<td align=center>";
	print "MARYLINE <input type=radio name=selection value=maryline><br>\n";
       	print "</td></tr>";			    

	print "<tr>\n<td align=center>";
	print "NON AFFECTES <input type=radio name=selection value=nonaffecte><br>\n";
       	print "</td></tr>";			    

	print "<tr>\n<td align=center>";
	print "TOUS LES COMMERCIAUX (sans les non-affectés) <input type=radio name=selection value=tout><br>\n";
        
	print "</td></tr>\n";
	print "</table><br>\n\n";
	print "1er date : <I>(jjmmaa)</I><input type=text name=date1><BR>\n";
	print "Denière date : <I>(jjmmaa)</I><input type=text name=date2><BR>\n";
	print "<center><Input type=submit value=valider></form>";
	
}
	
sub top20
{
	print "<center>";
	print "<h2>$selection<br>TOP 20 DES PRODUITS VENDUS $titre</h2><br>";
	print "<table><tr bgcolor=#efefef><td><b>code</td><td><b>produit</td><td><b>qte</td><td><b>prix de vente</td><td><b>prix d'achat</td><td><b>marge</td></tr>";
	@prod=keys(%total_vente);
	foreach (@prod){
		# print "$_ $qte{$_}<br>";
		push (@listeprod,"$total_vente{$_};$_;$total_achat{$_};$qte{$_};");
	}
	#print $#listeprod;
	@listeprod=sort tri_num (@listeprod);
	
	for ($i=$#listeprod;$i>($#listeprod-20);$i--){
  		($vente,$code,$achat,$qte)=split(/;/,$listeprod[$i]);
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev,)=split(/;/,$produit_dat[$produit_idx{$code}]);
	  	print "<tr><td>$pr_cd_prod</td><td>$pr_desi</td><td align=right nowrap>";
	  	print &separateur($qte);
	 	print "</td><td align=right nowrap>";
	  	print &separateur($vente/$qte);
	  	$total_vente+=$vente;
	  	print "</td><td align=right nowrap>";
	  	print &separateur($achat/$qte);
	  	$total_achat+=$achat;
	  	print "</td><td align=right nowrap><font color=red>";
		$marge=($vente-$achat)*100/$vente;  	 
	  	print &separateur($marge);
		print "%</td></tr>";	
	}
	print "<tr bgcolor=#efefef><td><b>TOTAL</td><td>&nbsp;</td><td>&nbsp;</td><td align=right nowrap>";
	print &separateur($total_vente);
	print "</td><td align=right nowrap>";
	print &separateur($total_achat);
  	print "</td><td align=right nowrap><font color=red>";
	$marge=($total_vente-$total_achat)*100/$total_vente;  	 
	print &separateur($marge);
	print "%</td></tr>";	
	
print "</table>";
}

sub top20_cl
{
	print "<center>";
	print "<h2>$selection<br>TOP 20 CLIENTS DES PRODUITS VENDUS $titre</h2><br>";
	print "<table><tr bgcolor=#efefef><td><b>code</td><td><b>client</td><td><b>Chiffre d'affaire</td><td><b>marge</td>";
	if ($action eq "top20tous_cl") {
		print "<td><b>part catalogue</td><td><b>part promotion</td><td><b>part prix speciaux</td>";
		}
	print "</tr>";
	@client=keys(%total_vente);
	foreach (@client){
		#print "$_<br>";
		push (@listeclient,"$total_vente{$_};$_;$total_achat{$_};");
	}
	@listeclient=sort tri_num (@listeclient);
	
	for ($i=$#listeclient;$i>($#listeclient-20);$i--){
  		($vente,$code,$achat)=split(/;/,$listeclient[$i]);
		if ($vente==0){next};
  		# print "*$code*<br>";
		($cl_cd_cl,$cl_add,$cl_pays,$cl_cd_prx,$cl_sld,$cl_relance,$cl_ca)=split(/;/,$client_dat[$client_idx{$code}]);
	  	print "<tr><td>$cl_cd_cl</td><td>$cl_add</td><td align=right nowrap>";
	  	print &separateur($vente);
	  	$total_vente+=$vente;
	  	print "</td><td align=right nowrap><font color=red>";
		$total_achat+=$achat;
	  	$marge=($vente-$achat)*100/$vente;  	 
	  	print &separateur($marge);
		print " %</td>";

		if ($action eq "top20tous_cl") {
			print "<td align=right nowrap>";
			print &separateur($client_cata_vente{$cl_cd_cl}*100/$vente);
			$total_cata+=$client_cata_vente{$cl_cd_cl};
			print " %</td>";
			print "<td align=right nowrap>";
			print &separateur($client_promo_vente{$cl_cd_cl}*100/$vente);
			$total_promo+=$client_promo_vente{$cl_cd_cl};
			print " %</td>";
			print "<td align=right nowrap>";
			print &separateur($client_spec_vente{$cl_cd_cl}*100/$vente);
			$total_spec+=$client_spec_vente{$cl_cd_cl};
			print " %</td>";
			}
		print "</tr>";	
	}
	print "<tr bgcolor=#efefef><td><b>TOTAL</td><td>&nbsp;</td><td align=right nowrap>";
	print &separateur($total_vente);
  	print "</td><td align=right nowrap><font color=red>";
	$marge=($total_vente-$total_achat)*100/$total_vente;  	 
	print &separateur($marge);
	print " %</td>";
	if ($action eq "top20tous_cl") {
		print "<td align=right nowrap>";
		print &separateur($total_cata*100/$total_vente);
		print " %</td>";
		print "<td align=right nowrap>";
		print &separateur($total_promo*100/$total_vente);
		print " %</td>";
		print "<td align=right nowrap>";
		print &separateur($total_spec*100/$total_vente);
		print " %</td>";
		}

	print "</tr>";	
	
print "</table>";
}

sub top20test
{
	print "<center>";
	print "<h2>$selection<br>TOP 20 DES PRODUITS VENDUS $titre</h2><br>";
	print "<table><tr bgcolor=#efefef><td><b>code</td><td><b>produit</td><td><b>qte</td><td><b>prix de vente</td><td><b>prix d'achat</td><td><b>marge</td></tr>";
	@prod=keys(%produit);
	foreach (@prod){
		# print "$_ $qte{$_}<br>";
		push (@listeprod,"$produit{$_};$_;;");
	}
	#print $#listeprod;
	@listeprod=sort tri_num (@listeprod);
	
	for ($i=$#listeprod;$i>($#listeprod-20);$i--){
  		($ca,$code)=split(/;/,$listeprod[$i]);
		($cl_cd_cl,$cl_add,$cl_pays,$cl_cd_prx,$cl_sld,$cl_relance,$cl_ca)=split(/;/,$client_dat[$client_idx{$code}]);
}	
# a finir	
print "</table>";
}

sub ecart
{
	print "<center>";
	print "<h2>$selection<br>LISTE DES FACTURES AVEC UN ECART COMPTA-INFO</h2><br>";
	print "<table><tr bgcolor=#efefef><td><b>No de facture</td><td><b>Comptabilite</td><td><b>Informatique</td><td><b>Ecart</td></tr>";
	$total=0;
	foreach (@tabecart){
		($fact,$compt,$info)=split(/;/,$_);
	  	print "<tr><td>$fact</td><td align=right nowrap>";
	  	print &separateur($compt);
	 	print "</td><td align=right nowrap>";
	  	print &separateur($info);
	  	print "</td><td align=right nowrap>";
	  	print &separateur($compt -$info);
	  	$total+=$compt-$info;
	  	print " $code";
	  	print "</td></tr>";	
	}
	print "<tr bgcolor=#efefef><td><b>TOTAL</td><td>&nbsp;</td><td>&nbsp;</td><td align=right nowrap>";
	print &separateur($total);
	print "</td></tr>";	
print "</table>";
}

sub code_mini{
	$cl_mini=$ec_cd_cl;
	return();
	# permet de faire des regroupement par adresse
	$cl_mini=$ec_cd_cl%1000;
	if ( ($cl_mini <600) && ($ec_cd_cl <1800000) ){$cl_cour=substr($ec_cd_cl,0,4);}
	elsif (($cl_mini >699) && ($cl_mini <800) && ($ec_cd_cl <1800000)){$cl_cour=substr($ec_cd_cl,0,5);}
	else {$cl_cour=substr($ec_cd_cl,0,8);}
}
sub top20bad_cl
{
	print "<center>";
	print "<h2>$selection<br>$titre</h2><br>";
	print "<table><tr bgcolor=#efefef><td><b>code</td><td><b>client</td><td><b><font size=-2>commercial</td><td align=center><b>Chiffre d'affaire<br>2001</td><td align=center><b>Chiffre d'affaire<br>2002</td><td align=center><b>Ecart<br>2001</td><td align=center><font color=red><b>Ecart<br>Objectif</td>";
	print "</tr>";
	@table=();
	foreach $cle (keys(%totalprecd)){
		if ($totalprecd{$cle} > $totald{$cle}){
			$ecart=$totald{$cle}-$totalprecd{$cle};
			push(@table,"$ecart;$cle;$totalprecd{$cle};$totald{$cle};1");
		}
	}
	@table=sort tri_num (@table);
	$i=$totalecart=0;
	foreach (@table){
		if ($i++>25){last;}
		($ecart,$cle,$totalprec,$total)=split(/;/,$_);
		($cl_cd_cl,$cl_add,$cl_service,$null,$null,$null,$null,$commer)=split(/;/,$client_dat[$client_idx{$cle}]);
		print "<tr><td>$cl_cd_cl</td><td><font size=-2>$cl_add $cl_service</td><td align=center>$commer</td><td align=right nowrap nowrap>";
		print &separateur($totalprec,2);
		print "</td><td align=right nowrap>";
		print &separateur($total,2);
		print "</td><td align=right nowrap>";
		print &separateur($ecart,2);
		$totalecart+=$ecart;
		print "</td><td align=right nowrap><font color=red>";
		$ecart=$total-($totalprec+($totalprec*17.53/100));
		print &separateur($ecart,2);
		$totalobecart+=$ecart;
		print "</td></tr>";
	}
	print "<tr bgcolor=#efefef><td><b>TOTAL</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
	print "<td align=right nowrap>";
	print &separateur($totalecart);
	print "</td><td align=right nowrap>";
	print &separateur($totalobecart);
  	print "</td></tr>";
	print "</table>";
}

#                       total 			cata 			promo			special
# qte par produit     	$qte_tous{}		$qte_cata{}		$qte_promo{}		$qte_spec{}
# ca par produit	$produit_tous_vente{}	$produit_cata_vente{}	$produit_promo_vente{}	$produit_spec_vente{}
# achat par produit	$produit_tous_achat{}	$produit_cata_achat{}	$produit_promo_achat{}	$produit_spec_achat{}
# ca par client		$client_tous_vente{}	$client_cata_vente{}  	$client_promo_vente{}	$client_spec_vente{}
# achat par client 	$client_tous_achat{}	$client_cata_achat{}	$client_promo_achat{}	$client_spec_achat{}

# ca total		$vente_tous		$vente_cata		$vente_promo		$vente_spec
# achat total		$achat_tous		$achat_cata		$achat_promo		$achat_spec

    		


# -E fiche commerciale