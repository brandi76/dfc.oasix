#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';

$code_param = $html->param('code');
$type_code = $html->param('type_code');
$annee = $html->param('annee');
$premier = $html->param('premier');
$dernier = $html->param('dernier');

print $html->header;    
print "<HTML>\n";
&body();

if ($code_param !~ /[0-9]/){
		&html();
}
else
{
	
	 $facture=-1;
	 
	 if ($dernier eq ""){ $dernier = 9999999;}
	 if ($premier eq ""){ $premier = 000000;}
	 # Définition des variables en ca de besoin
	 if($type_code eq 'listeprod'){
	 		if($premier != 0){ 		
	 			$premier = '01'.$premier.'01';
	 			$dernier = '01'.$dernier.'31';
	 			$premier += 0;
	 			$dernier += 0;
	 		}else{
	 		 	$premier = '010101';
	 			$dernier = '011231';
	 			$premier += 0;
	 			$dernier += 0;
	
	 		}
	 }
	
	 &tete("Stat sur ventes $annee","","");
	
	 
	 #if (($code_param eq "")&&($type_code ne "client")&&($type_code ne "tous")){
	 if (($code_param eq "")&&($type_code ne "tous")){ 	
		print "<center><p><h3>Aucun code n'a été saisi !<br><br><a href='javascript:history.back();'><< Retour</a></p>";
	 }

	#############################################
	# AFFICHER LISTE PRODUIT par Client
	#############################################
	if($type_code eq "listeprod"){
	 %produit_idx = &get_index_num("produit",1);            
	 open(FILE2,"/home/var/spool/uucppublic/produit.txt");     # produit : info detaille des produits
	 @produit_dat = <FILE2>;
	 close(FILE2);

	#%facdata_idx = &get_index_multiple("facdata-$annee",2);
	 open(FILE3,"/home/var/spool/uucppublic/facdata-$annee.txt");     
	 @facdata_dat = <FILE3>;
	 close(FILE3);
	 
	 %client_idx = &get_index_num("client2",0);            
	 open(FILE3,"/home/var/spool/uucppublic/client2.txt");     
	 @client_dat = <FILE3>;
	 close(FILE3);

	
	
	
	#$premier = "01".$premier."01";
	#$dernier = "01".$dernier."31";
		 	#%produit_idx = &get_index_num("",1);            
		 	@tab = `sort -t';' +3 /home/var/spool/uucppublic/archive/facdata-2001.txt`;
		 	#@tab = @facdata_dat;
		 	#@tab = $facdata_dat[$facdata_idx{$code_param}];
		 	$code_prod = '';
		 	$line_prod='';
		 	$total = 0;
		 	@info_client = split(/;/,$client_dat[$client_idx{$code_param}]);
			print "<BR><BR><B><FONT SIZE='+1'>$info_client[0]</FONT><BR>$info_client[1]<BR>$info_client[2]<BR>$info_client[3]<BR>$info_client[4]<B><BR><BR>Du ".&date(&daten($premier))."<BR>au ".&date(&daten($dernier));
		 	print "<BR><BR><TABLE BORDER='1' CELLSPACING='0' CELLPADDING='5' WIDTH='600'>\n";
		 	print "<TR><TD><B><I>Code</B></I></TD><TD><B><I>Désignation</B></I></TD><TD><B><I>Degré</B></I></TD><TD><B></I>QTE</B></I></TD></TR>\n";
		 	foreach $ligne (@tab){
		 		@temp = split(/;/,$ligne);
		 		$temp[3] = $temp[3]%1000000;
		 		$temp[2] = $temp[2]%10000000;
		 		$temp[8]+=0;
		 		if($temp[2] == $code_param && $temp[8]>=$premier && $temp[8]<=$dernier){
		 		if($temp[3]!=$code_prod){
		 			print "$line_prod";
		 			$line_prod='';
		 			$code_prod = $temp[3];
		 			$total = 0;
		 		}
		 		if($temp[3]==$code_prod){
		 			$total = $total + $temp[4];
		 			@line_infoprod = split(/;/,$produit_dat[$produit_idx{$temp[3]}]);
		 			$line_prod = "<TR><TD>$temp[3]</TD><TD>$line_infoprod[9]</TD><TD>$line_infoprod[8]</TD><TD>$total</TD>";
		 		}
		 		}
		 		
			 }
			 print "</TABLE>\n";
		 
	 }
	 else{
	 	if ($type_code eq "client"){
	 %produit_idx = &get_index_num("produit",1);            
	 open(FILE2,"/home/var/spool/uucppublic/produit.txt");     # produit : info detaille des produits
	 @produit_dat = <FILE2>;
	 close(FILE2);

	#%facdata_idx = &get_index_multiple("facdata-$annee",2);
	 open(FILE3,"/home/var/spool/uucppublic/facdata-$annee.txt");     
	 @facdata_dat = <FILE3>;
	 close(FILE3);
	 
	 %client_idx = &get_index_num("client2",0);            
	 open(FILE3,"/home/var/spool/uucppublic/client2.txt");     
	 @client_dat = <FILE3>;
	 close(FILE3);

#	`cat /home/var/spool/uucppublic/infococ.txt /var/spool/uucppublic/archive/infococl-2001.txt /var/spool/uucppublic/archive/infococl-2000.txt>/var/spool/uucppublic/inftemp.txt`;

	%infococl_idx = &get_index_num("inftemp",0);            
	open(FILE2,"/home/var/spool/uucppublic/inftemp.txt");  # entete de commande
	@infococl_dat=<FILE2>;
	close(FILE2);
	 
	%infoarch_idx = &get_index_num("inf-arc",0);         
	open(FILE2,"/home/var/spool/uucppublic/inf-arc.txt"); 
	@infoarch_dat = <FILE2>; 


	                print "<br><b>Année $annee liste des clients selectionnés:</b><br><font size=-1>";
	 		#Modifier le 22/02/2002 par alex : Saisir 1 code client dans le champ 'code' et selectionner facture client
	 		#for ($i=$premier;$i<=$dernier;$i++){
			for ($i=$code_param;$i<=$code_param;$i++){ 			
	 			if ($client_idx{$i}ne""){
	 				($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville)=split(/;/,@client_dat[$client_idx{$i}]);
					print "$cl_cd_cl $cl_nom $cl_contact $cl_rue $cl_ville<br>";
				}
			}
			print "</font><br>";
	 	}
	 open(FILE3,"/home/var/spool/uucppublic/facdata-$annee.txt");     
	 @facdata_dat = <FILE3>;
	 close(FILE3);
	 	 %produit_idx = &get_index_num("produit",1);            
	 open(FILE2,"/home/var/spool/uucppublic/produit.txt");     # produit : info detaille des produits
	 @produit_dat = <FILE2>;
	 close(FILE2);

	 	foreach(@facdata_dat){                                       # pour chaque produit
	 		($facd_no,$facd_no_cde,$facd_cd_cl,$facd_cd_pr,$facd_qte,$facd_puni,$facd_dev,$facd_rem,$facd_date,$facd_prev,$facd_promo)= split (/;/,$_); 
	        	$code=$facd_cd_pr%1000000;
	        	$pr_page=1;
			($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split (/;/,@produit_dat[$produit_idx{$code}]);
			$facd_cd_cl += 0;
	
			if( &test() ){
				$mois = substr($facd_date,2,2);
				$mois = $mois + 0;
				if($mois == 1){$janvier{$code} = 0 + $janvier{$code} + $facd_qte;}
				if($mois == 2){$fevrier{$code} = 0 + $fevrier{$code} + $facd_qte;}
				if($mois == 3){$mars{$code} = 0 + $mars{$code} + $facd_qte;}
				if($mois == 4){$avril{$code} = 0 + $avril{$code} + $facd_qte;}
				if($mois == 5){$mai{$code} = 0 + $mai{$code} + $facd_qte;}
				if($mois == 6){$juin{$code} = 0 + $juin{$code} + $facd_qte;}
				if($mois == 7){$juillet{$code} = 0 + $juillet{$code} + $facd_qte;}
				if($mois == 8){$aout{$code} = 0 + $aout{$code} + $facd_qte;}
				if($mois == 9){$septembre{$code} = 0 + $septembre{$code} + $facd_qte;}
				if($mois == 10){$octobre{$code} = 0 + $octobre{$code} + $facd_qte;}
				if($mois == 11){$novembre{$code} = 0 + $novembre{$code} + $facd_qte;}
				if($mois == 12){$decembre{$code} = 0 + $decembre{$code} + $facd_qte;}
				if($mois >=1 && $mois <=12){$liste{$code} += 0 + $liste{$code} + $facd_qte;}
			}
	               
	               
	               ##########   EDITION PAR COMMANDES POUR UNE LISTE DE CLIENT #######################
	               #
	               $jour = substr($facd_date,4,2);
	               $mois = substr($facd_date,2,2);
	               $annee = int($facd_date / 10000);
	               #Modifier le 22/02/2002 par alex : Saisir 1 code client dans le champ 'code' et selectionner facture client
	               #if ( ($type_code eq "client") && (($facd_cd_cl>=$premier) && ($facd_cd_cl<=$dernier))) {
	               	if ( ($type_code eq "client") && ($facd_cd_cl==$code_param)) {
	               	if ($infococl_idx{$facd_no_cde} ne ""){ 
	                      ($icc_no,$icc_cd_cl,$icc_add,$icc_pdb,$icc_col,$icc_dev,$icc_sub,$icc_ind,$icc_in_pos,$icc_cd_liv,$icc_dt_recp,$icc_tarif,$icc_ex3,$icc_delai,$icc_modif,$icc_camion,$icc_prtr_cdfr,$icc_cd_fa,$icc_carte,$icc_val,$icc_fact,$icc_lib,$icc_prom) = split(/;/,$infococl_dat[$infococl_idx{$facd_no_cde}]); 
			}
	               
	                if ($infoarch_idx{$facd_no_cde} ne ""){ 
	                      ($icc_no,$icc_cd_cl,$icc_add,$icc_pdb,$icc_col,$icc_dev,$icc_sub,$icc_ind,$icc_in_pos,$icc_cd_liv,$icc_dt_recp,$icc_tarif,$icc_ex3,$icc_delai,$icc_modif,$icc_camion,$icc_prtr_cdfr,$icc_cd_fa,$icc_carte,$icc_val,$icc_fact,$icc_lib,$icc_prom) = split(/;/,$infoarch_dat[$infoarch_idx{$facd_no_cde}]); 
			}
	               	if ($facd_no ne $facture){
	               		($icc_add)=split(/\*/,$icc_add);
	               		if ($client_idx{$facd_cd_cl}ne""){
	 				($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville)=split(/;/,@client_dat[$client_idx{$facd_cd_cl}]);
				}
	                        if ($facture ne -1){print "</table><br>";}
	                        $facture = $facd_no;
	               		print "<table border=1 rules=none cellspacing='0' width=80%><tr><td width='30%'>No de Facture:$facd_no<br>No de Commande:$facd_no_cde</td>";
	               		print "<td width='30%'>Dieppe le:$jour/$mois/200$annee</td><td>$icc_cd_cl<br><b>$cl_nom</b><br>";
	               		if ($icc_add eq ""){print "->$icc_contact";}
	               		else{print "<b>$icc_add</b>";}
	               	        print "<br>$cl_rue $cl_ville</td></tr><tr><td><br><b>code</td><td><BR><b>désignation</td><td><BR><b>qte</td></tr>";
	               	}
	               	print "<tr><td>$pr_cd_prod</td><td>$pr_desi</td><td>";
	               	print &separateur($facd_qte);
	               	print "</td></tr>";
	               }
	               
	               ##########################
	  	}
	 }
	 if ($type_code eq "client"){print "</table><br>";}
	 if($type_code ne "client" && $type_code ne "listeprod"){

	 %produit_idx = &get_index_num("produit",1);            
	 open(FILE2,"/home/var/spool/uucppublic/produit.txt");     # produit : info detaille des produits
	 @produit_dat = <FILE2>;
	 close(FILE2);

	 	
	 @index = sort keys(%liste);
	
	
	 print "<table border=1 cellpadding=2 cellspacing=0 width=100%>\n";
	 print "<tr>\n";
	 print "<td align=center><font size=-1><b>Code</b></td>\n";
	 print "<td align=center width=100%><font size=-1><b>Désignation</b></td>\n";
	 print "<td align=center><font size=-1>Jan.</td>\n";
	 print "<td align=center><font size=-1>Fév.</td>\n";
	 print "<td align=center><font size=-1>Mar.</td>\n";
	 print "<td align=center><font size=-1>Avr.</td>\n";
	 print "<td align=center><font size=-1>Mai.</td>\n"; 
	 print "<td align=center><font size=-1>Jui.</td>\n";
	 print "<td align=center><font size=-1>Jul.</td>\n";
	 print "<td align=center><font size=-1>Aou.</td>\n";
	 print "<td align=center><font size=-1>Sep.</td>\n";
	 print "<td align=center><font size=-1>Oct.</td>\n";
	 print "<td align=center><font size=-1>Nov.</td>\n";
	 print "<td align=center><font size=-1>Déc.</td>\n";
	 print "<td align=center><font size=-1><b>Prix Unintaire</b></td>";
	 print "<td align=center><font size=-1><b>Qte Vendue Totale</b></td>";
	 print "<td align=center><font size=-1><b>CA annuel</b></td>";
	 print "</tr>\n";
	 open(TELE,"> ../public_html/statvente.csv");
	
	 foreach(@index){
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split (/;/,$produit_dat[$produit_idx{$_}]);
		print "<tr><td><font size=-1>$pr_cd_prod</td><td><font size=-1>$pr_desi</td><td align=right>";
		print TELE "$pr_cd_prod;$pr_desi;";
		if($janvier{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($janvier{$pr_cd_prod});
			print "</font>";
			print TELE "$janvier{$pr_cd_prod};";
		}
		else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($fevrier{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($fevrier{$pr_cd_prod});
			print "</font>";
			print TELE "$fevrier{$pr_cd_prod};";
		}
		else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($mars{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($mars{$pr_cd_prod});
			print "</font>";
			print TELE "$mars{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($avril{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($avril{$pr_cd_prod});
			print "</font>";
			print TELE "$avril{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($mai{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($mai{$pr_cd_prod});
			print "</font>";
			print TELE "$mai{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($juin{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($juin{$pr_cd_prod});
			print "</font>";
			print TELE "$juin{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($juillet{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($juillet{$pr_cd_prod});
			print "</font>";
			print TELE "$juillet{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($aout{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($aout{$pr_cd_prod});
			print "</font>";
			print TELE "$aout{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($septembre{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($septembre{$pr_cd_prod});
			print "</font>";
			print TELE "$septembre{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($octobre{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($octobre{$pr_cd_prod});
			print "</font>";
			print TELE "$octobre{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($novembre{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($novembre{$pr_cd_prod});
			print "</font>";
			print TELE "$novembre{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print "</td><td align=right>";
		if($decembre{$pr_cd_prod} ne ""){
			print "<font color=red size=-1>";
			print &separateur($decembre{$pr_cd_prod});
			print "</font>";
			print TELE "$decembre{$pr_cd_prod};";
		}else{
			print "0";
			print TELE "0;";
		}
		print TELE "\n";
		$code = $pr_cd_prod;
		$total2000 = 0;
		$total2000 = $janvier{$code}+$fevrier{$code}+$mars{$code}+$avril{$code}+$mai{$code}+$juin{$code}+$juillet{$code}+$aout{$code}+$septembre{$code}+$octobre{$code}+$novembre{$code}+$decembre{$code};
		$CA += $total2000*$pr_prx_un;
		$CAprod = $total2000*$pr_prx_un;
		print "</td><td><font color=green size=-1>$pr_prx_un</td><td><font color=green size=-1>$total2000</td><td><font color=green size=-1>$CAprod</td>";
		print "</tr>\n";
	
	 }
	 
	 close(TELE);
	 }
	 print "</table>";
	 
	 print "<br><br>";
	 if ($CA >0){
	 	print "<font color=green><b>Chiffre d'affaire pour cette page :</b> ",&separateur($CA),"€</font>\n";
	 	print "<p>&nbsp;</p>\n";
	 	print "<a href=../statvente.csv>Telecharger au Format Excel</a>\n";
	 }
}
@temps_prog = times();
print "<FONT COLOR=RED>$temps_prog[0]s</font>\n";
print "</body></html>";

	  

sub test(){
#  test si le produit est pris en compte 

$retour = 0;

if (($type_code eq "produit") && ($code_param eq $code)){$retour = 1;}
if (($type_code eq "fournisseur") && ($code_param eq $pr_cd_fourn)){$retour = 1;}
if ($type_code eq "tous") {$retour = 1;}

if ($facd_cd_cl < $premier || $facd_cd_cl > $dernier){$retour = 0;}
	
return $retour;
}


#########################################################
#                                                       #
#             		PAGE HTML                       #
#                                                       #
######################################################### 

sub html(){
&tete("Statistique sur les ventes","","");

print <<"eof";
<center>
<form method=post action=facdataalex.pl>

<table width=80% border=2 cellspacing=0 cellpadding=8 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod >
<tr>
<td bgcolor=#E0E0E0>
<b>Tapez ici le(s) code(s) recherché(e)</b>
</td>
<td bgcolor=#E0E0E0>
<b>Type du Code & année de recherche.</b>
</td>
<td bgcolor=#E0E0E0>
&nbsp;
</td>
</tr>
<tr>
<td align=center>
Code <input type=text size=15 name=code>
</td>
<td>
<input type=radio name=type_code value="fournisseur" CHECKED>Fournisseur<br>
<input type=radio name=type_code value="produit">Produit<br>
<input type=radio name=type_code value="client">Facture Client <font size='1px'><i>(Détaille facture pour un client)</I></font><br>
<input type=radio name=type_code value="listeprod">Produit par client <font size='1px'><i>(stat vente produit pour un client)</i></font><BR>
<input type=radio name=type_code value="tous">Tout les produits

</td>
<td bgcolor=#E0E0E0>
&nbsp;
</td>
</tr>
<tr>
<td align=center>
Premier : <input type=text size=10 name=premier><br>
Dernier : <input type=text size=10 name=dernier>
</td>
<td>
<input type=radio name=annee value=2001 checked> 2001<br>
<input type=radio name=annee value=2000> 2000<br>
<input type=radio name=annee value=1999> 1999<br>
<input type=radio name=annee value=1998> 1998<br>
<input type=radio name=annee value=1997> 1997<br>
</td>

<td>
<input type=reset value="Effacer"><br>
<input type=submit value="Valider">
</td>
</tr>

</form></BODY>
</HTML>

eof
}

# -E stat sur facdata  Par code fournisseur
