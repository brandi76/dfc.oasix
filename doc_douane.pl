#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;


# -----------------------------------------------------------------------------------------------------------
#        						CREATION DES DCA
#		les informations contenu dans le fichier sont classe par bloc, un bloc correspond a une adresse de 
#		livraisons . Bloc par bloc les informations sont stocke dans le fichier TETE et CORPS puis
# 		affcher à l'ecran, TETE et CORPS se vide a chaque nouvelle adresse de livraison
#		Chaque adresse de livraison est former du meme document en plusieurs exemplaires. Les exemplaires
#		sont differencie par une image differentes dans le cadre d'entete.
# 		Attention une addresse de livraison peut avoir un dca sur plusieurs pages
#                         			EXEMPLE EN FIN DE FICHIER
# -----------------------------------------------------------------------------------------------------------


open(FILE,"</home/var/spool/uucppublic/douane.txt");
@LINES=<FILE>;
$nb_ligne_fichier = @LINES;
$bool_10 = 0;
$bool_15 = 0;
$bool_20 = 0;
$bool_25 = 0;
$bool_30 = 0;
$bool_35 = 0;
$bool_40 = 0;
$bool_45 = 0;
$total_val=0; # cumul des valeurs
$bool_entete = 0;
$colisage = 0;
$bool_finpage = 0;
$nb_ligne = 0;
$nb_article = 0;
$max_ligne = 30;
$TITRE= "DOCUMENT COMMERCIAL D'ACCOMPAGNEMENT POUR LA CIRCULATION DES PRODUITS SOUMIS A ACCISES";
# $TITRE= "TRANSFERT ENTRE ENTREPOT D'EXPORTATION Procédure No:1632";

print "<HTML>\n";
print "<HEAD>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1252\">\n";
print "<TITLE>Douane</TITLE>\n";
print "</HEAD>\n";
print "<BODY topmargin=0 bgcolor=white>\n";
					
foreach(@LINES){
	
	($cl_add,$cl_cd_cl,$type,$dca_ref1,$dca_ref2,$dca_qte,$dca_valeur,$dca_desi,$ndp,$volume,$poids,$degre,$alcool_pur) = split(/;/,$_);

	# ------------------------------------------------------
	#                 Type 0 et 1 informations pour TETE autre information pour CORPS
	#                 dca_ref1: no de commande,code produit,code franchise
	#                 dca_ref2: code client de la franchise     
	# --------------------------------------------------------------------------------
	
	if($type == 0){ # debut de bloc d'une adresse de livraison   
		
		@TETE = ();
		@CORP = ();
		$bool_10 = 0;      	# permet de savoir si la ligne d'entete famille 10 à été creée
		$bool_20 = 0;		# permet de savoir si la ligne d'entete famille 20 à été creée
		$bool_30 = 0;		# permet de savoir si la ligne d'entete famille 30 à été creée
		$bool_40 = 0;		# permet de savoir si la ligne d'entete famille 40 à été creée
		$colisage = 0;
		$nb_ligne = 0;
		$le_corp = 0;
		$nombre_page=0;						
	}
        if($type == 0 || $type ==1){
		push(@TETE,$_);
	}
	elsif($type == 999){  
		
		# --------------------------------------------
		#      FIN DE BLOC EDITION DES EXEMPLAIRES 
		# --------------------------------------------
	
		for($i=1;$i<=4;$i++){
			
			$IMG_EXEMPLAIRE = "http://intranet.dom/douane/verticale$i.jpg";     
			# pour chaque exemplaire l'image sur le cote change    ^^^^
			
			$nombre_page = 1;

			if ($nb_ligne != 0){
			 &tete;
			 &corp;
			 }
			$le_corp=0;
		}
	}
	
print "\n";

	
        # ------------------------------------	
	# Creation des ligne entete de famille
	# ------------------------------------
	
	if($type == 10 && $bool_10 == 0){

#		print "\nProduits Alimentaires<br>\n";
		push(@CORP,";;;;;;;<b>Produits Alimentaires</b>;space;;;space");
		$nb_ligne++;
		$bool_10 = 1;
	}	

	if($type == 20 && $bool_20 == 0){

#		print "\nAlcool<br>\n";
		push(@CORP,";;;;;;;<b>Alcool</b>;space;;;space");
		$nb_ligne++;		
		$bool_20 = 1;
	}
	if($type == 30 && $bool_30 == 0){
#		print "\nCigarettes<br>\n";
		push(@CORP,";;;;;;;<b>Cigarettes</b>;space;;;space");
		$nb_ligne++;		
		$bool_30 = 1;
	}	
	if($type == 40 && $bool_40 == 0){
#		print "\nCigares<br>\n";
		push(@CORP,";;;;;;;<b>Cigares</b>;space;;;space");
		$nb_ligne++;		
	$bool_40 = 1;
	}	

	# ------------------------------------	
	# Totaux par famille 
	# ------------------------------------
	
	# P-A
	if($type == 11 ){
		$nb_ligne++;		
		push(@CORP,";;;;;;$total_val;<b>Totaux : </b>;space;;;space;;<b>;</b>");
		$total_val=0;
        }

        # ALCOOL volume,qte,valeur,alcool-pur
	if($type == 21 ){
		$nb_ligne++;
		$nb_ligne++;		
		push(@CORP,";;;;;;$total_val;<b>Totaux : </b>;space;$total_vol;;space;$total_pur;<b>;</b>");
		$total_vol*=0.0084;
		$total_vol+=$total_pur*95;
		push(@CORP,";;;;;;$total_vol;<b>Droit de douane 8.40 + 95 frs</b></FONT>;space;;;space;;<b>;</b>");
		$total_val=0;
		$total_vol=0;
		$total_pur=0;
        }

        # TABAC  valeur et poids
	if($type== 31 || $type==41){
		$nb_ligne++;	
		$nb_ligne++;	
		push(@CORP,";;;;;;$total_val;<b>Totaux : </b>;space;;$total_poids;space;;<b>;</b>");

	# ------------------------------------	
	# Droit et taxes 
	# ------------------------------------
	
	if ($type==31){
		$total_val=$total_poids*677;	
		push(@CORP,";;;;;;;<b>Droits et taxes 677 frs par 1000</b>;space;;;space;;<b>;</b>;$total_val");
        }
	else {
		$total_val=$total_qte*14;	
		push(@CORP,";;;;;;;<b>Droits et taxes 14 frs boite</b>;space;;;space;;<b>;</b>;$total_val");
	}
        
        $total_qte=0;
	$total_val=0;
	$total_poids=0;
	}
	
	# ------------------------------------	
	# Franchise 
	# ------------------------------------

	# P-A  valeur
	if($type == 15){
		$nb_ligne++;
	        push(@CORP,";;;;;;$dca_qte;<b>Franchise :</b> $dca_ref1;space;;;space;;<b>;</b>");
        
        }

        # ALCOOL  alcool pur
	if($type == 25){
		$nb_ligne++;
        	push(@CORP,";;;;;;;<b>Franchise :</b> $dca_ref1;space;;;space;$dca_qte;<b>;</b>");
        }
        
        # TABAC poids
	if($type == 35 || $type == 45){
		$nb_ligne++;
        	push(@CORP,";;;;;;;<b>Franchise :</b> $dca_ref1;space;;$dca_qte;space;;<b>;</b>");
      	}

        
        # ------------------------------------	
	# Ligne produits 
	# ------------------------------------
	

	if($type != 999 && $type != 11 && $type != 21 && $type != 31 && $type != 41 && $type != 15 && $type != 25 && $type != 35 && $type != 45 && $type != 0 && $type != 1){
		$nb_ligne++;
		if ($type == 40){
			$total_qte+=$dca_qte;
			}
	        $total_val+=$dca_valeur;
	        $total_vol+=$volume;
	        $total_poids+=$poids;
	        $total_pur+=$alcool_pur;
		push(@CORP,$_);
	}
	

}

print "</body></HTML>\n";


#   ---------------------------------------------------------------------------
#					SUBROUTINE
#   ---------------------------------------------------------------------------

sub tete {
		#   --------------------------------------------
		#    PREMIER CADRE EN DEBUT DE PAGE
		#   --------------------------------------------

foreach(@TETE){
 	($cl_add,$cl_cd_cl,$type,$dca_ref1,$dca_ref2,$dca_qte,$dca_valeur,$dca_desi) = split(/;/,$_);
 	($addr1,$addr2,$addr3) = split(/\*/,$cl_add);
 	if($type == 0){
		($colisage,$nul) = split(/\./,$dca_qte);
		
	                           #  ----------------
	                           #      HTML 
	                           #  ----------------
print <<"eof";
<Table border=1 bordercolor=#949494 bordercolorlight=#94949A bordercolordark=#94949A cellpadding=0 cellspacing=0 width=740 >


<tr valign=top>
<!--- Ligne 1 ------>
   
 	<td align=center width=20><font size=2 face="arial narrow" size=+1><b>$i</b></font></td>
                                                   <!-- Numero de l exemplaire ^ -->
 	<td colspan=8 align=left height=22 valign=bottom ><font size=2 face="*Arial Narrow" size=2>
 	<b>$TITRE</b></font></td>
         <!-- ^variable predefine au depart -->

</tr><tr>
<!---- Ligne 2 ------>

 	<td rowspan=3 align=center valign=bottom width=25 ><font size=2 face=arial narrow size=-5>
 	<img src=$IMG_EXEMPLAIRE></td>
 	<!-- cette image ^ change a chaque exemplaire -->
 	
 	<!-- case 1 ligne 1 -->

 	<td align=left valign=top width=227 height=60><font size=2 face="Arial Narrow">01 
			Expéditeur<br>
			BIS FRANCE<br>
			ZI ROUXMENILS BOUTEILLE<br>
			76204 DIEPPE<br>
 	</font></td>

	<!-- case 2 ligne 1 -->
	
 	<td colspan=4 align=left valign=top width=227><font size=2 face="Arial Narrow">02
 	Numero d'accise de l'expéditeur FR96341e0052</font></td>
 
 	<!-- case 3 ligne 1 -->
 	
 	<td align=left valign=top width=227><font size=2 face="Arial Narrow">03 Numéro de référence<br>
 	Article: $nombre_page /
eof
 print int($nb_ligne / $max_ligne)+1;
 print <<"eof";
 	</font></td>

</tr><tr>
<!------ Ligne 3 ----->
 	
 	<!-- case 1 ligne 2 -->
 	
 	<td align="left" valign="top" height=70><font size=2 face="Arial Narrow">04 Destinataire<br>
 	$addr1<br>$addr2<br>$addr3</font></td>
 
 	<!-- case 2 ligne 2 et 3 -->
        <td colspan=4 rowspan=2 align=left valign=top><font size=2 face="Arial Narrow">05 Numéros de commandes:<br>

eof
		}
		else{
		        # si type est 0 (debut de client on affiche le cadre sinon type =1 et on affiche les numeros de commandes
			print "$dca_ref1 ";
		}
# Fin de la boucle sur TETE
}
$date=`date '+%x'`; 
# suite du premier cadre
print <<"eof";
	</font></td>

	<!-- case 3 ligne 2 et 3 -->
	
	<td colspan=3 rowspan=2 align=left valign=top><font size=2 face="Arial Narrow">06 Autorité compétentes
   		<br>CRD de Dieppe 1, Rue Descroisilles
   		<br>76202 DIEPPE BP 222<br>
   		<br>Compagnie générale de garantie
   		<br>ETOILE CAUTION
   	</font></td>

</tr><tr>
<!------ Ligne 4 ----->
	
	<!-- case 1 ligne 3 -->
	
	<td align=left valign=top height=56><font size=2 face="Arial Narrow">07 Transporteur:<br>
	BIS FRANCE ZI ROUXMENILS BOUTEILLE<br>76204 DIEPPE<br>Route 8376 RF 76</font></td>

</tr><tr valign=bottom>
<!----- Ligne 5 ----->

	<!-- numero de l exemplaire -->
	<td align=center><font size=2 face="Arial Narrow" size=+1><b>$i</b></font></td>
	
	<!-- case 1 ligne 3 -->
	<td align=left height=22><font size=2 face="Arial Narrow">08 Date d'exp&eacute;dition:$date</font></td>
	<!-- case 2 ligne 3 -->
	<td colspan=4 align=left><font size=2 face="Arial Narrow">09 Nb de colis:Liste jointe</font></td>
	<!-- case 3 ligne 3 -->
	<td colspan=3 align=left><font size=2 face="Arial Narrow">10</font></td>
</tr>
</table>
eof
		#   --------------------------------------------
		#    DEUXIEME CADRE MILIEU DE PAGE
		#   --------------------------------------------
print <<"eof";


<br>

<Table border=1 bordercolor=#949494 bordercolorlight=#94949A bordercolordark=#94949A cellpadding=1 cellspacing=0 width=740>
<TR VALIGN=bottom>

<td align=left width=250 height=20 ><font size=2 face="Arial Narrow">&nbsp;Description des marchandises</font></td>
<td align=left width=71 ><font size=2 face="Arial Narrow">&nbsp;code NC</font></td>
<td align=left width=53 ><font size=2 face="Arial Narrow">&nbsp;Qte</font></td>
<td align=left width=56 ><font size=2 face="Arial Narrow">&nbsp;Valeur</font></td>
<td align=left width=56 ><font size=2 face="Arial Narrow">&nbsp;Caution</font></td>
<td align=left width=49 ><font size=2 face="Arial Narrow">&nbsp;volume</font></td>
<td align=left width=53 ><font size=2 face="Arial Narrow">&nbsp;poids</font></td>
<td align=left width=71 ><font size=2 face="Arial Narrow">&nbsp;degree</font></td>
<td align=left width=71 ><font size=2 face="Arial Narrow">&nbsp;alcool pur</font></td>
</TR>

eof

}	





sub corp {
		#   --------------------------------------------
		#    DEUXIEME CADRE LISTE DES PRODUITS
		#   --------------------------------------------

	$j=0;
	# le_corps est initialise a zero a chaquedebut de bloc
	for($le_corp;$le_corp<$nb_ligne;$le_corp++){
		$j++;
		($cl_add,$cl_cd_cl,$type,$dca_ref1,$dca_ref2,$dca_qte,$dca_valeur,$dca_desi,$ndp,$volume,$poids,$degre,$alcool_pur,$cl_add4,$cl_add5,$cl_add6) = split(/;/,@CORP[$le_corp]);
                if ($ndp eq "space"){$ndp="&nbsp;";}
                if ($degre eq "space"){$degre="&nbsp;";}
		print "<tr valign=bottom>\n";

		# ------------
		# colonne 1 designation
		# ------------
		print "<td align=left height=20><font size=2 face=\"Arial Narrow\">$dca_desi</font></td>\n"; 

		# ------------
		# colonne 2 code ndp
		# ------------
		print "<td align=right><font size=2 face=\"Arial Narrow\">$ndp</font></td>\n"; 

		# ------------
		# colonne 3 quantite
		# ------------
		print "<td align=right><FONT size=2 FACE=\"Arial Narrow\">";
		if ( $dca_qte > 0){
		 	 print "$cl_add4"; # gras
			 printf ("%.2f",$dca_qte);
			 print "$cl_add5"; # fin gras
			}
		else {print "&nbsp;";}
		print "</font></td>\n"; 

		# ------------
		# colonne 4 valeur
		# ------------
		print "<td align=right><font size=2 face=\"Arial Narrow\">";
		
		if ( $dca_valeur > 0){
		 	 print "$cl_add4"; # gras
			 printf ("%.2f",$dca_valeur);
			 print "$cl_add5"; # fin gras
			 }
		else {print "&nbsp;";}
		print "</font></td>\n"; 
		
		# ------------
		# colonne 5 droit et taxe
		# ------------
		print "<td align=right><font size=2 face=\"Arial Narrow\">";
		if ( $cl_add6 > 0){
		 	 print "<b>"; # gras
			 printf ("%.2f",$cl_add6);
			 print "</b>"; # fin gras
			 
			}
		else {print "&nbsp;";}
		print "</font></td>\n"; 
		
		# ------------
		# colonne 6 volume
		# ------------
		print "<td align=right><font size=2 face=\"Arial Narrow\">";
		if ( $volume > 0){
		 	 print "$cl_add4"; # gras
			 printf ("%.0f",$volume);
			 print "$cl_add5"; # fin gras
			}
		else {print "&nbsp;";}
		print "</font></td>\n"; 
		
		# ------------
		# colonne 7 poids
		# ------------
		print "<td align=right><font size=2 face=\"Arial Narrow\">";	
		if ( $poids > 0){
		 	 print "$cl_add4"; # gras
			 printf ("%.3f",$poids);
			 print "$cl_add5"; # fin gras
			}
		else {print "&nbsp;";}
		print "</font></td>\n"; 
		
		# ------------
		# colonne 8 degree
		# ------------
		print "<td align=right><font size=2 face=\"Arial Narrow\">";
		if ( $degre > 0){
		 	 printf ("%.2f",$degre);
			}
		else {print "&nbsp;";}
		print "</font></td>\n"; 
				
		# ------------
		# colonne 9 alcool_pur
		# ------------
		print "<td align=right><font size=2 face=\"Arial Narrow\">";
		if ( $alcool_pur > 0){
			 print "$cl_add4"; # gras
			 printf ("%.3f",$alcool_pur);
			 print "$cl_add5"; # fin gras
			}
		else {print "&nbsp;";}
		print "</font></td>\n"; 
		 
	        print "</tr>\n";
		
		# -------------------------------
		#  Saut de page si la limite est depasse 
		# -------------------------------
		
		if($j >= $max_ligne){
			$nombre_page += 1;
			&pied;
			&tete;
			
			$j=0;
		}
	}
&pied;
}

sub pied {
		#   --------------------------------------------
		#    FIN DE PAGE CADRE POUR LES SIGNATAIRES 
		#   --------------------------------------------

$reste = $max_ligne - $j;


for($var=0;$var <= $reste ;$var++){
print "<TR VALIGN=\"bottom\">\n";
print "<TD ALIGN=\"right\" height=20><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "<TD ALIGN=\"right\" ><FONT size=2 FACE=\"Arial Narrow\">&nbsp;</FONT></TD>\n";
print "</TR>\n";
	
}



print "</table><br>\n";
print "<table border=1 cellspacing=0 cellpadding=0 width=740 height=117>\n";
print "<tr>\n";
print "<td valign=top width=50%>\n";
print "<font face=\"Arial Narrow\" size=2>Contr&#244les</font>\n";
print "</td>\n";
print "<td valign=top width=50%>\n";
print "<font face=\"Arial Narrow\" size=2 >Signataire ou tampon officiel<br><br>\n";
print "\n";
print "nom (obligatoire):<br><br>\n";
print "\n";
print "signature (obligatoire):<br><br>\n";
print "</font></td>\n";
print "</TR>\n";
print "</Table><br><br>\n";	
	
}

# TETE DE BLOC

# COL 1  	ADRESSE
# COL 2  	CODE CLIENT SU 4 CHIFFRES
# COL 3 	TYPE=0
# COL 4 	NON UTILISE 
# COL 5 	NON UTILISE
# COL 6 	NB DE COLIS
# COL 7 	No de DCA
# COL 8 	NON UTILISE
# COL 9 	NON UTILISE
# COL 10 	NON UTILISE
# COL 11 	NON UTILISE
# COL 12 	NON UTILISE
# COL 13 	NON UTILISE

# ENTETE DE BLOC
# COL 1  	ADRESSE
# COL 2  	CODE CLIENT SU 4 CHIFFRES
# COL 3 	TYPE=1
# COL 4 	No DE COMMAMDE
# COL 5 	NON UTILISE
# COL 6 	NON UTILISE
# COL 7 	No de DCA
# COL 8 	NON UTILISE
# COL 9 	NON UTILISE
# COL 10 	NON UTILISE
# COL 11 	NON UTILISE
# COL 12 	NON UTILISE
# COL 13 	NON UTILISE

# LIGNE PRODUIT
# COL 1  	ADRESSE
# COL 2  	CODE CLIENT SU 4 CHIFFRES
# COL 3 	TYPE=10 ou 20 ou 30 ou 40
# COL 4  	CODE PRODUIT
# COL 5 	NON UTILISE 
# COL 6 	QTE
# COL 7 	PRIX
# COL 8 	DESIGNATION
# COL 9 	NO DE NDP
# COL 10 	LITRAGE
# COL 11 	POIDS
# COL 12 	DEGREE
# COL 13 	ALCOOL PUR

# FIN PRODUIT
# COL 1  	ADRESSE
# COL 2  	CODE CLIENT SU 4 CHIFFRES
# COL 3 	TYPE=11 ou 21 ou 31 ou 41
# COL 4 	NON UTILISE
# COL 5 	NON UTILISE
# COL 6 	NON UTILISE
# COL 7 	NON UTILISE
# COL 8 	NON UTILISE
# COL 9 	NON UTILISE
# COL 10 	NON UTILISE
# COL 11	NON UTILISE
# COL 12	NON UTILISE
# COL 13	NON UTILISE

# FRANCHISE
# COL 1  	ADRESSE
# COL 2  	CODE CLIENT SU 4 CHIFFRES
# COL 3 	TYPE=15 ou 25 ou 35 
# COL 4 	No de FRANCHISE
# COL 5 	CODE CLIENT DE LA FRANCHISE
# COL 6 	IMPUTATION
# COL 7 	NON UTILISE
# COL 8 	NON UTILISE
# COL 9 	NON UTILISE
# COL 10 	NON UTILISE
# COL 11	NON UTILISE
# COL 12	NON UTILISE
# COL 13	NON UTILISE


# FIN DE BLOC 
# COL 1  	ADRESSE
# COL 2  	CODE CLIENT SU 4 CHIFFRES
# COL 3 	TYPE=999
# COL 4 	NON UTILISE
# COL 5 	NON UTILISE
# COL 6 	NON UTILISE
# COL 7 	NON UTILISE
# COL 8 	NON UTILISE
# COL 9 	NON UTILISE
# COL 10 	NON UTILISE
# COL 11	NON UTILISE
# COL 12	NON UTILISE
# COL 13	NON UTILISE


# EXEMPLE


    #$cl_add            $cl_cd_cl            $type        $dca_ref1     $dca_ref2   $dca_qte   $dca_valeur              $dca_desi                $ndp   $volume  $poids  $degre   $alcool_pur
    #ADRESSE     CODE CLIENT 4 CHIFFRES        0                                   NB COLIS      NO DCA
    #ADRESSE     CODE CLIENT 4 CHIFFRES        1       No DE COMMANDE                            NO DCA
    #ADRESSE     CODE CLIENT 4 CHIFFRES   10/20/30/40   code produit                  qte         prix                 designation               ndp    volume   poids   degre    alcol pur
    #ADRESSE     CODE CLIENT 4 CHIFFRES   11/21/31/41
    #ADRESSE     CODE CLIENT 4 CHIFFRES    15/25/35    code franchise code client imputation
    #ADRESSE     CODE CLIENT 4 CHIFFRES       999
#
  #AMB.SENEGAL            1297                 0             0             0           6          2.64
  #AMB.SENEGAL            1297                 1          10016001         0           1          2.64
  #AMB.SENEGAL            1297                 1          10019565         0           5          2.64
  #AMB.SENEGAL            1297                 1          10019568         0           6          2.64
  #AMB.SENEGAL            1297                10           358440          0           1          320         910YSL Baby Doll ParisEDTvp100  33030090
  #AMB.SENEGAL            1297                11             0             0           1          320
  #AMB.SENEGAL            1297                15            438         1297002       320          0
  #AMB.SENEGAL            1297                20           220652          0           5         347.5                J & B 100 cl.           22083052    500              43        2.15
  #AMB.SENEGAL            1297                20           221643          0           2           81               Gin Gilbey's 1L00         22085011    200             47.5       0.95
  #AMB.SENEGAL            1297                21             0             0           4          188
  #AMB.SENEGAL            1297                25            437         1297002      9.55          0
  #AMB.SENEGAL            1297                30           232238          0          10          2400        Chesterf.KSF Originals p.1000   24022090             10
  #AMB.SENEGAL            1297                31             0             0          10          4500
  #AMB.SENEGAL            1297                35            437         1297002       24           0
  #AMB.SENEGAL            1297                999            0             0           6          2.64


# -E creation des DCA
