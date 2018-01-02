#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require 'outils_perl.lib';
require 'manip_table.lib';
# fichier:
# echeibs    --> echeancier
# relanceibs --> regroupements des factures
# client2 --> fichier bis des clients
# pays   --> fichier bis des devises
# fait   --> 1 rlance
# fait2 --> 2 relance
# archrelibs --> fichier bis des relances interdite
# archrelibs_li --> fichier linux ibs des relances interdites 
# produit --> fichier bis 
# facdidx --> fichier archive facture,et produit livre 

print "<html><head>
<style type=\"text/css\">
<!--
BODY { background-color : white }

.date {  position: relative;
         left: 6.8cm }

.madame {  position: relative;
         left: 2cm}
.facture {  position: relative;
         left: 2cm }
.adresse {  position: relative;
         left: 13cm }
.service {  position: relative;
         left: 11.4cm }
.tableau {  position: relative;
         left: 6cm }

.signature {  position: relative;
         left: 10cm} 
H1 { page-break-after : right }         

-->
</style></head>
";
&body();
&tete("RELANCE CLIENT","/home/var/spool/uucppublic/echeibs.txt");
print "<br>";

$code_client=$html->param("code_client");


if ($html->param("modification") eq "oui") {

	open(FILE2,"/home/var/spool/uucppublic/relanceibs.txt");     
	@relance_dat = <FILE2>;
	close (FILE2);
	open(relance,">/home/var/spool/uucppublic/relanceibs.txt");     

	foreach (@relance_dat){
		($facture,$lien)=split(/;/,$_);
		$facture+=0;
		if ($html->param($facture)ne""){
			print relance "$facture;",$html->param($facture),";\n";
		}
		else{
			print relance $_;
		} 
	}
	close (relance);
	open(FILE2,"/home/var/spool/uucppublic/relanceibs.txt");     
	@relance_dat = <FILE2>;
	close (FILE2);
}


# couleur de degradé
$coul0=black;
$coul1=red;
$coul2=blue;
$coul3=green;
$coul4=brown;
$coul5=orange;


%echeancier_idx = &get_index_multiple("echeibs",0);
open(FILE1,"/home/var/spool/uucppublic/echeibs.txt");
@echeancier_dat = <FILE1>;
close (FILE1);

%client_idx = &get_index_num("client2",0);
open(FILE2,"/home/var/spool/uucppublic/client2.txt");     
@client_dat = <FILE2>;
close (FILE2);

%relance_idx = &get_index_num("relanceibs",0);
open(FILE2,"/home/var/spool/uucppublic/relanceibs.txt");     
@relance_dat = <FILE2>;
close (FILE2);

%pays_idx = &get_index_num("pays",0);
open(FILE2,"/home/var/spool/uucppublic/pays.txt");     
@pays_dat = <FILE2>;
close (FILE2);

# relance interdite fichier arix
%archrel_idx = &get_index_multiple("archrelibs",0);
open(FILE2,"/home/var/spool/uucppublic/archrelbis.txt");     
@archrel_dat = <FILE2>;
close (FILE2);

# relance interdite fichier linux
%archrel_li_idx = &get_index_multiple("archrelibs_li",0);
open(FILE2,"/home/var/spool/uucppublic/archrelibs_li.txt");     
@archrel_li_dat = <FILE2>;
close (FILE2);


if ($code_client eq ""){
	&page_html();
	exit;}

if ($html->param("creation") eq "oui"){
	&crelettre();
	exit;}

################### chargement d'une table avec les pointeurs sur les  comptes à traiter ################
if ($echeancier_idx{$code_client}ne""){
	(@ECHEANCIER)=split(/;/,$echeancier_idx{$code_client});
    }

#############" edition de l'entete ####################        

if ($client_idx{$code_client} eq ""){
       	$cl_add="<font color=green>CLIENT INCONNU</font>";
       	$cl_service=$cl_ville=$cl_rue="";}
	else{($cl_cd_cl,$cl_add)=split(/;/,@client_dat[$client_idx{$code_client}]);}
	print "<table border=1><tr><td><font size=2><font color=red>$code_client</font></td><td colspan=9><font size=2><font color=black>Client:<font color=red>$cl_add</td></tr>";
        print "<tr bgcolor=#e8e8e8><td><font size=2>No de facture</td><td>regroupement</td><td align=middle><font size=2>Nom</td><td><font size=2>Date de facture</td><td><font size=2>Montant </td><td><font size=2>montant reglé </td><td><font size=2>date du reglement</td><td><font size=2>Montant en devise</td><td><font size=2>reste </td><td><font size=2>reste en devise</td></tr>\n";

##############" creation d'une table avec les comptes ################
$indice=-1;

foreach (@ECHEANCIER){
	$indice++;
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$echeancier_dat[$_]);
	$ec_cd_cl+=0;
	$lien=0;
	$ec_no_fact+=0;
	if ($relance_idx{$ec_no_fact} ne ""){
		($facture,$lien)=split(/;/,$relance_dat[$relance_idx{$ec_no_fact}]);
	}
		
	push (@tab,"$lien;$indice;$echeancier_dat[$_];");
}        		

				
################ trie de la table et affichage #####################
				
@tab=sort (@tab);
print "<form name=modif action=relanceibs.pl>";
print "<input type=hidden name=modification value=oui>";
print "<input type=hidden name=code_client value=$code_client>";
foreach (@tab){
	($lien,$indice,$ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
	$diff=$lien%6;
	if ($diff==0){$couleur=$coul0;}
	if ($diff==1){$couleur=$coul1;}
      	if ($diff==2){$couleur=$coul2;}
      	if ($diff==3){$couleur=$coul3;}
      	if ($diff==4){$couleur=$coul4;}
      	if ($diff==5){$couleur=$coul5;}
      	$gris="white";
      	if ($lien == 0){$gris="#efefef";}	
      	$ec_no_fact+=0;
	print "<tr bgcolor=$gris><td align=right><font size=2 color=$couleur><a href=rel-interditibs.pl?facture=$ec_no_fact&action=motif>$ec_no_fact</a></td>";

	print "<td align=middle><b><input type=text size=3 name=$ec_no_fact value=$lien></td>";

	print "<td align=middle><font size=2 color=$couleur>$ec_nom</td><td align=right><font size=2 color=$couleur>";
        $compt++;
	print &date($ec_dt);
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_mont);
	if (($ec_no_fact >100000) && ($ec_no_fact <9000000)){print " EU";}
	else {print " FF";}
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_reg);
	$ec_reg+=0;
		
	if (($ec_no_fact >100000) && ($ec_no_fact <9000000) && ($ec_reg ne 0)){print " EU";}
	elsif ($ec_reg ne 0) {print " FF";}
		
	print "</td><td align=right><font size=2 color=$couleur>";
	print &date($ec_dt_reg);
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_mont_dev);
	print " ";
	$dev=$ec_cd_dev;
	$ec_cd_dev=0+$ec_cd_dev;
		
	if ($pays_idx{$ec_cd_dev} ne ""){
		($nul,$nul,$nul,$nul,$nul,$nul,$dev)=split (/;/,@pays_dat[$pays_idx{$ec_cd_dev}]);
	}
	print "$dev</td>";
	$reste=$ec_mont-$ec_reg;
	print "<td align=right><font size=2 color=$couleur>";
	print  &separateur($reste);
	$reste+=0;
	
	if (($ec_no_fact >100000) && ($ec_no_fact <9000000) && ($reste ne 0)){
		print " EU";
		$totaleu+=$reste;}
	elsif ($reste ne 0) {
		print " FF";
		$totalff+=$reste;}
		
	print "</td>"; 
	$reste_dev=0;
	if ($ec_mont!=0){$reste_dev=$reste*$ec_mont_dev/$ec_mont;}
	print "<td align=right><font size=2 color=$couleur>";
	print &separateur($reste_dev);
	print "</td>"; 
	print "</tr>";
	
	# gestion des relances interdites fichier arix et fichier saisie sur linux
	
	
	if ($archrel_li_idx{$ec_cd_cl} ne ""){
			@liste=split(/;/,$archrel_li_idx{$ec_cd_cl});
			foreach (@liste){
				($code,$facture,$date,$etat,$desi)=split (/;/,$archrel_li_dat[$_]);
				if ($facture == $ec_no_fact){	
					print "<tr bgcolor=$gris><td colspan=9 align=center><font size=2 color=$couleur size=+2>ATTENTION RELANCE INTERDITE :<b>$desi</td></tr>";
					}
			}
			
	}
	elsif ($archrel_idx{$ec_cd_cl} ne ""){
			@liste=split(/;/,$archrel_idx{$ec_cd_cl});
			foreach (@liste){
				($code,$facture,$date,$etat,$desi)=split (/;/,$archrel_dat[$_]);
				if ($facture == $ec_no_fact){	
					print "<tr bgcolor=$gris><td colspan=9 align=center><font size=2 color=$couleur size=+2>ATTENTION RELANCE INTERDITE :<b>$desi</td></tr>";
					}
			}
			
	}

	
}

print "</table><br><center><input type=submit value=modifier></form>";
print "<br><form action=relanceibs.pl><center><input type=hidden name=mofication value=non>";
print "<input type=hidden name=creation value=oui>";
print "<input type=hidden name=code_client value=$code_client>";
print "<input type=submit value=\"creer les lettres\"></form>";


print "</body></html>";
close (relance);


################################### DATE ##########################
# formatage de la date
sub date {
	   my ($date)=@_;
	   if ($date == 0){
	   	$date="-";
	}
	else{
	   $date=substr($date,length($date)-6,2)."/".substr($date,length($date)-4,2)."/".substr ($date,length($date)-2,2);  
        }
        }
 
################################ SEPARATEUR ######################  
# separateur de miller     

sub separateur {
	      my ($var)=@_;
	      my ($couleur);
	      if ($var eq ""){$var=0;}
              if ($var == 0){$couleur="<font color=gray>";}
              if ($var < 0){$couleur="<font color=green>";}
	      if (($var <1000) && ($var >-1000)){
	        $virgule=$var*100%100;
	        if ($virgule<10){$virgule="0".$virgule;}
	        ($var,$nul)=split(/\./,$var);
	        $var=$var.".".$virgule;
	        }
	      
	      if (($var >=1000)&&($var <1000000) || (($var<-999)&&($var>-1000000))){
	        $virgule=$var*100%100;
	        if ($virgule<10){$virgule="0".$virgule;}
	        ($var,$nul)=split(/\./,$var);
	        
	        $groupe2=substr($var,0,length($var)-3);
	        $groupe1=substr($var,length($var)-3,3);
	        $var=$groupe2."&nbsp;".$groupe1.".".$virgule;
	        }
	      
	      if (($var >=1000000)|| ($var <= -1000000)){
	        $virgule=$var*100%100;
	        ($var,$nul)=split(/\./,$var);
	        $groupe3=substr($var,0,length($var)-6);
	        $groupe1=substr($var,length($var)-3,3);
	        $groupe2=substr($var,length($var)-6,3);
	        $var=$groupe3."&nbsp;".$groupe2."&nbsp;".$groupe1.".".$virgule; 
	}
	if ($var==0){$var="&nbsp;";}
        $var=$couleur.$var;
	return($var);
	
}

sub page_html {

%fait_idx = &get_index_num("fait",0);
open(FILE2,"/home/var/spool/uucppublic/fait.txt");     
@fait_dat = <FILE2>;
close (FILE2);
%fait2_idx = &get_index_num("fait2",0);
open(FILE2,"/home/var/spool/uucppublic/fait2.txt");     
@fait2_dat = <FILE2>;
close (FILE2);

@arelancer=();
foreach (@echeancier_dat){
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
	$aa=substr ($ec_dt,length($ec_dt)-2,2);
	#print "$aa<br>";
	if ($aa == 0) {
      		$reste = $ec_mont - $ec_reg;
      		if (($reste >2)&&(! grep /$ec_cd_cl/,@arelancer)){push (@arelancer,$ec_cd_cl);} # creation d'un tableau avec la liste des clients a relancer
	}
}
print "<table border=1 cellspacing=0><tr><td><b>client</b></td><td align=center><img src=http://intranet.dom/images/relance1.gif></td><td align=center><img src=http://intranet.dom/images/relance2.gif><td></tr>";
foreach (@arelancer){
	print "<tr><td><a href=relanceibs.pl?code_client=$_>$_</a>";
	if ($client_idx{$_} eq ""){
       	$cl_add="<font color=green>CLIENT INCONNU</font>";
       	$cl_service=$cl_ville=$cl_rue="";}
	else{($cl_cd_cl,$cl_add)=split(/;/,@client_dat[$client_idx{$_}]);}
	print " $cl_add</td>";
	if ($fait_idx{$_} ne ""){
		($code,$rel,$date)=split(/;/,@fait_dat[$fait_idx{$_}]);
		print "<td>";
		print &date($date);
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	if ($fait2_idx{$_} ne ""){
		($code,$date)=split(/;/,@fait2_dat[$fait2_idx{$_}]);
		print "<td>";
		print &date($date);
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	
	
	print "</tr>";
}
print "</table>";
	
}
sub crelettre {
	################### chargement d'une table avec les pointeurs sur les  comptes à traiter ################

$nb_el=$nb_tab=0;
%produit_idx = &get_index_num("produit",1);
open(FILE2,"/home/var/spool/uucppublic/produit.txt");     
@produit_dat = <FILE2>;
close (FILE2);

open(FILE1,"/home/var/spool/uucppublic/facdidx.txt");
%facture_idx = <FILE1>;
close (FILE1);

open(FILE2,">>/home/var/spool/uucppublic/fait.txt");
     
$date = `/bin/date '+%y%m%d'`;  
chop($date);
print FILE2 "$code_client;1;$date;\n";
close (FILE2);

if ($echeancier_idx{$code_client}ne""){
	(@ECHEANCIER)=split(/;/,$echeancier_idx{$code_client});
    }

#############" edition de l'entete ####################        

if ($client_idx{$code_client} eq ""){
       	$cl_add="<font color=green>CLIENT INCONNU</font>";
       	$cl_service=$cl_ville=$cl_rue="";}
	else{($cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville)=split(/;/,@client_dat[$client_idx{$code_client}]);}
        if ($cl_service eq $cl_add){$cl_service="";};
##############" creation d'une table avec les comptes ################

foreach (@ECHEANCIER){
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$echeancier_dat[$_]);
	$ec_cd_cl+=0;
	$lien=0;
	$ec_no_fact+=0;
	if ($relance_idx{$ec_no_fact} ne ""){
		($facture,$lien)=split(/;/,$relance_dat[$relance_idx{$ec_no_fact}]);
	}
	
	if ($lien != 0){push (@tab,"$lien;$echeancier_dat[$_];");}
}        		

				
################ trie de la table et affichage #####################
				
@tab=sort (@tab);
$group=-1;
$total=0;
%auto=();
# premier passage on ne retient que les positifs
foreach (@tab){
	($lien,$ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
   		
        if ($lien ne $group){
 		if ($total >20){
 			$auto{$group}="oui";  # on ne retient que les client avec un solde >20
        	}
        	$group=$lien;
        	$total=0;
        }
	$total+=$ec_mont-$ec_reg;
}        
if ($total > 0){$auto{$lien}="oui"};

# deuxieme passage on edite
$group=-1;
$total=$nom=0;
foreach (@tab){
	($lien,$ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
   	if ($auto{$lien} ne "oui"){next;} # on saute les comptes negatif	
        if ($lien ne $group){
        	if ($total != 0){
        		&pied_francais();
        		print "<h1>.</h1>";
        		$nb_el=$nb_tab=0;
        		&tete_francais();
        		$total=0;
               	}
        	else { &tete_francais();}
        	$group=$lien;
        	$nom=$ec_nom;
	}
	# edition de la ligne de facture
	print "Facture No:<b>$ec_no_fact</b> du ";
	print &date($ec_dt);
	print "<b>";
        print &separateur($ec_mont_dev);
	print "</b>";
	print " ";
	$dev=$ec_cd_dev;
	$ec_cd_dev=0+$ec_cd_dev;
	if ($pays_idx{$ec_cd_dev} ne ""){($nul,$nul,$nul,$nul,$nul,$nul,$dev)=split (/;/,@pays_dat[$pays_idx{$ec_cd_dev}]);}
	print "$dev";
        if ($ec_reg != 0){
        	print " montant reglé:";
        	print &separateur($ec_reg);
        	print " FF le ";
        	print &date($ec_dt_reg);
        	print "<b> solde:";
		$reste_dev=$ec_mont_dev-($ec_reg*($ec_mont_dev/$ec_mont));
		print &separateur($reste_dev);
		print "</b></font> $dev";
	        	
        	}
	print "<br>"; 
	
	$total+=$ec_mont;
	# edition des produits
	$ec_no_fact+=0;
	if ($ec_no_fact<1000000){$ec_no_fact+=10000000;}
	$cherche=$ec_no_fact."\n";
	if ($facture_idx{$cherche}ne""){
		(@liste)=split (/;/,$facture_idx{$cherche});
		$pass=0;
		print "Nous vous avions livré les produits ci-dessous:<br></span><center><table border=1 cellspacing=0><tr bgcolor=#efefef>";
		print "<td><font size=-1><b>Produits</b></font></td><td><font size=-1><b>Quantité</b></font></td></tr>";
		$nb_tab++;
		foreach ($j=0;$j<$#liste;$j++){
			if ($pass eq 0){
				$code=$liste[$j]%1000000;
				$pass=1;
				if ($produit_idx{$code}ne""){
					($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split (/;/,@produit_dat[$produit_idx{$code}]); 
					print "<tr><td><font size=-1>$pr_desi</font></td>";
					$nb_el++;
				}
			}
			
			else {
				print "<td><font size=-1>$liste[$j]</font></td></tr>";
				$pass=0;
				}
			}
		print "</table></center><span class=\"facture\"><br>\n";
		if (($nb_el >15)||($nb_tab >4)){ # saut de page
			$nb_el=$nb_tab=0;
			print "<h1>.</h1><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>";
				}
	}
	
	#if ($facture_idx{$ec_no_fact}ne""){
		#(@FACTURE)=split(/;/,$echeancier_idx{$ec_no_fact});
    	#}
	#foreach (@FACTURE){
		#print "$_<br>";
	#}
	
}	
if ($total != 0){&pied_francais};
print "</body></html>";
close (relance);

}

sub tete_francais {
	$date=`date +%d/%m/%y`;
	print <<"eof";
	<br><br><br><br><br><br><br><br><br><br><br><span class="adresse">
	<b>$ec_nom</b><br>$cl_add<br>
	</span>
	<span class="date">$date</span><span class="service">$cl_service<br></span>
	<span class="adresse">$cl_rue<br>$cl_ville
	</span>
	
	<span class="madame"><br><br><br><br><br>
	<b>RAPPEL DE FACTURE IMPAYÉE</b><br>réf client:$ec_cd_cl<br><br>
	Madame, Monsieur,<br><br>Votre compte présente un solde débiteur correspondant aux factures suivantes:<br>
	</span>
	<span class="facture">
eof
}

sub pied_francais {
	print <<"eof";
	Il existe sûrement une raison justifiant le non-paiement des sommes échues.<br>
	Dans l'affirmative, je vous invite à m'appeler aujourd'hui au numéro suivant :<b>02.32.14.02.88.</b><br><br>
	le cas écheant, nous vous demandons de régulariser cette omission en nous adressant le réglement.
	<br><br>
	<b>Cette relance est automatisée, seul un appel où un réglement permettront d'arrêter le processus<br>informatique de recouvrement.<br><br>
	</b>Nous vous prions d'agreer, Madame, Monsieur, l'expression de nos salutations distinguées.
	<br><br>
	<span class="signature">
	Service Comptabilité Clients<br>
	<br>
	</span></span> 
eof
}

# -E relance client ibs 
