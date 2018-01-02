#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';
print $html->header;    

$datecomp=`ls -tr /home/var/spool/uucppublic/douane/2003/suspen*|tail -1`;
$datecomp=~s/^.*suspen//;
$datecomp=~s/.txt//;
$a=substr($datecomp,0,2);
$m=substr($datecomp,2,2);
$j=substr($datecomp,4,2);
$datecomp="1$a$m$j";

%produit_idx = &get_index_num("produit",1);            
open(FILE2,"/home/var/spool/uucppublic/produit.txt");
@produit_dat = <FILE2>;
close(FILE2);

%mvt_idx = &get_index_multiple("enso",0);            
open(FILE2,"/home/var/spool/uucppublic/enso.txt");     # entree sortie 
@mvt_dat = <FILE2>;
close(FILE2);
%suspen_idx = &get_index_num("suspen",0);            
open(FILE2,"/home/var/spool/uucppublic/suspen.txt");     # stock des produits a declarer
@suspen_dat = <FILE2>;
close(FILE2);
 %double_idx = &get_index_num("douable",0);            
 open(FILE2,"/home/var/spool/uucppublic/douable.txt");     # cwgestion double entrepot 
@double_dat = <FILE2>;
close(FILE2);

open(COMPTA,">/home/var/spool/uucppublic/comptamatierebiere.txt");     # mouvement des produits


print <<"eof";
<html>
<head>
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
</style></head><body>
eof
			
		

foreach(@suspen_dat){ 
	# a partir du fichier genere par SUSPENSION avec l'aryx ona la liste des produit avec leur type
	# ici sus_qte correspond au stock ancien , par la suite il faudra tenier compte du stock nouveau
        # famille correspond au type d'entrepot et type au groupement ndp
	$qte_sortie_tiers=0;
	$qte_entree_tiers=0;

	($sus_cd_pr,$sus_famille,$sus_type,$sus_qte,$sus_pdn,$sus_deg,$sus_nouveau)=split(/;/,$_);
	$sus_deg+=0;
	$sus_famille+=0;
	$sus_type+=0;
	if ($sus_type!=10){next;}
	# A MODIFIER REPRENDRE LES LITRAGE A PARTIR DU FICHIER SUSPEN

	if ($produit_idx{$sus_cd_pr} ne ""){
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split(/;/,$produit_dat[$produit_idx{$sus_cd_pr}]);
		$pr_deg+=0;
	}
	$sus_type=$pr_deg;
	$nb++;
	$qte_sortie=$qte_entree=0;
	 
	  
	if ($mvt_idx{$sus_cd_pr} ne ""){ # si des mouvements sont enregistres pour ce produit
		@liste=split(/;/,$mvt_idx{$sus_cd_pr});
		foreach (@liste){
			($code,$date,$douane,$sortie,$entree,$flag)=split (/;/,$mvt_dat[$_]);
	                $sortie+=0;
	                $entree+=0;
	                if ($entree <0){
	                	$sortie=0-$entree;
	                	$entree=0;}
	                if ($sortie <0){
	                	$entree=0-$sortie;
	                	$sortie=0;
	                }
	                
			$qte_sortie+=$sortie;
			$qte_entree+=$entree;
			if (($flag==1)&&($douane<740000)){
				$qte_sortie_tiers-=$sortie;
				$qte_entree_tiers-=$entree;
			}

# --------------------- gestion des mouvements par type ----------------
			if ($produit_idx{$sus_cd_pr} ne ""){
			($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split(/;/,$produit_dat[$produit_idx{$sus_cd_pr}]);
			$pr_deg+=0;
			}
		
			 # alcool pur
	 			#$sortie2=$sortie *($pr_pdn/1000)*($pr_deg/10000);
 				#$entree2=$entree *($pr_pdn/1000)*($pr_deg/10000);
				$sortie2=$sortie *($pr_pdn)*($pr_deg);
 				$entree2=$entree *($pr_pdn)*($pr_deg);
			
			$date2=($date%100*10000)+(int(($date%10000)/100)*100)+int($date/10000);
			$sus_type+=0;
			print COMPTA "$date2;$sus_type;$douane;$sortie2;$entree2;$sortie;$entree;\n";
			
# --------------------- fin gestion des mouvements par type ----------------

		}
}
if (($sus_qte==0) && ($qte_sortie==0) && ($qte_entree==0) && ($sus_nouveau ==0)){next;}
	if (($sus_famille == 3)||($qte_sortie_tiers!=0)||($qte_entree_tiers!=0)){ 
		$qte_sortie+=$qte_sortie_tiers;
		$qte_entree+=$qte_entree_tiers;
		$sus_nouveau+=$qte_entree_tiers;
		$sus_nouveau-=$qte_sortie_tiers;
		if ($double_idx{$sus_cd_pr} ne ""){
               		($null,$dou_qte,$null,$dou_date)=split (/;/,$double_dat[$double_idx{$sus_cd_pr}]);
               		if ($dou_date<$datecomp){$sus_qte=$dou_qte;}
       		}
	     
		push (@TIERS,"$sus_type;$sus_cd_pr;$sus_qte;$qte_sortie;$qte_entree;$sus_nouveau;");
		}
		if (($sus_famille ==2)||($sus_famille ==3)) {
		#if ($sus_famille ==2) {
	
			push (@CEE,"$sus_type;$sus_cd_pr;$sus_qte;$qte_sortie;$qte_entree;$sus_nouveau;");
	
		}
		if ($sus_famille ==4){
			push (@VIN,"$sus_type;$sus_cd_pr;$sus_qte;$qte_sortie;$qte_entree;$sus_nouveau;");
	
		}
}

# a la sortie de la boucle on a 2 tableau tiers et cee
$type_titre=$pass=$total_ent=$total_so=$total_ancien=$total_new=0;
%tableau=();
print "<center>";
print "<h2><a href=#ED>ENTREPOT DOUANIER</a></h2>";
print "<br>";
print "<table border=1 width=100%>";
@TIERS=sort(@TIERS);
@TABLE=@TIERS;
$tiers=1;
 &detail();
print "BIS FRANCE<br>";
print "<center><h2>DECLARATION MENSUEL EN SUSPENSION DE DROITS</h2><br></center>";
print "Mois de:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Numero Entrepositaire agréé:C 116 016 FR<br>";
print "<font size=+1><b><a name=ED>Entrepot Douanier</a></b></font><br>";
&recap();
print "<h1>.</h1>";


$type_titre=$pass=$total_ent=$total_so=$total_new=$total_ancien=0;
%tableau=();
print "<center>";
print "<h2><a href=#EFD>ENTREPOT FISCAL </a></h2>";
print "<br>";
print "<table border=1 width=100%>";
@CEE=sort(@CEE);
@TABLE=@CEE;
$tiers=2;
 &detail();
print "BIS FRANCE<br>";
print "<center><h2>DECLARATION MENSUEL EN SUSPENSION DE DROITS</h2><br></center>";
print "Mois de:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N° Entrepositaire agréé:FR 01 116 S 0072<br>";
print "<font size=+1><b><a name=EFD>Entrepot d'accises</a></b></font><br>";
&recap();
print "<br><table border=1 width=80%><tr><td>";
print "Dieppe le</td><td>Etat recapitulatif N° d'empreinte<br><br><br>Premier numéro du mois<br><br>Dernier numéro du mois<br><br></td></tr></table>";
 print "<h1>.</h1>";


print "</body></html>";
close (BUG);
	
sub detail{
$type_titre=-1;
foreach (@TABLE)
{
	($type,$code,$qte_ancien,$qte_sortie,$qte_entree,$qte_new)=split (/;/,$_);
	$qte_ancien+=0;
	$qte_sortie+=0;
	$qte_entree+=0;
	$qte_nouveau+=0;
	
	if ($type ne $type_titre){
		if ($pass ne 0){
			print "<tr><td><b>TOTAL</td><td align=right>";
			print $total_ancien;
			print "</td><td align=right>";
			print $total_ent;
			print "</td><td align=right>";
			print $total_so;
			print "</td><td align=right>";
			print $total_new;
			$verif=$total_ent-$total_so-$total_new+$total_ancien;
			print "</td><td align=right>";
			print $verif;
			print "</td></tr>";
			print "</table>";
			$tableau{$type_titre}="$total_ancien;$total_ent;$total_so;$total_new;";
			$total_ancien=$total_ent=$total_so=$total_new=0;
			
			
		}
		else {$pass=1;}
		print "<table border=1 width=100%><tr><td><b>";
		print "Bieres $type degrée";
	        
	        $type_titre=$type;
	        print "</td><td><b>ancien</td><td><b>entree</td><td><b>sortie</td><td><b>nouveau</td></tr>";	
	}
	$pr_desi="";
	if ($produit_idx{$code}ne""){
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split(/;/,$produit_dat[$produit_idx{$code}]);
		$pr_deg+=0;
	}
	
	$qten_ancien=$qte_ancien;
	$qten_sortie=$qte_sortie;
	$qten_entree=$qte_entree;
	$qten_new=$qte_new;
	
 		
	 	$qten_ancien=$qte_ancien*$pr_pdn*$pr_deg;
 		$qten_sortie=$qte_sortie *$pr_pdn*$pr_deg;
 		$qten_entree=$qte_entree *$pr_pdn*$pr_deg;
		$qten_new=$qte_new*$pr_pdn*$pr_deg;
 		
	
	$color="black";
	
	print "<tr><td><font color=$color>$code $pr_desi </td><td align=right>";
	print "<font size=-1>";
	print &deci($qte_ancien,2);
	print "</font> !";
	print $qten_ancien;
	$total_ancien+=$qten_ancien;
	print "</td><td align=right>";
	print "<font size=-1>";
	print &deci($qte_entree,2);
	print "</font> ";
	print $qten_entree;
	$total_ent+=$qten_entree;
	print "</td><td align=right>";
	print "<font size=-1>";
	print &deci($qte_sortie,2);
	print "</font> ";
	print $qten_sortie;
	$total_so+=$qten_sortie;
	print "</td><td align=right>";
	print "<font size=-1>";
	print &deci($qte_new,2);
	print "</font> ";
	print $qten_new;
	$total_new+=$qten_new;
	print "</td><td align=right>";
	$verifn=$qten_entree - $qten_sortie + $qten_ancien - $qten_new;
	print &deci($verifn,3);
	print "</td></tr>";

}
print "<tr><td><b>TOTAL</td><td align=right>";
print $total_ancien;
print "</td><td align=right>";
print $total_ent;
print "</td><td align=right>";
print $total_so;
print "</td><td align=right>";
print $total_new;
$tableau{$type_titre}="$total_ancien;$total_ent;$total_so;$total_new";
print "</td></tr>";
			
print "</table></center><h1>.</h1>";
}

sub recap
{
##################### DEBUT DE LA RECAP  ################

print "<table border=1>";
print "<tr><td>&nbsp;</td><td><b>Stock du mois<br>precedent</td><td><b>ENTREES</td><td><b>SORTIES</td><td><b>STOCK<br>THEORIQUE</td></tr>";
foreach $type (keys(%tableau)){
		if ($tableau{$type} eq ""){next;}
		print "<tr><td>";
		
		
		print "<b>BIERES $type° HL ALCOOL PUR</td>";
	        ($ancien,$entree,$sortie,$stock)=split(/;/,$tableau{$type});
                print "<td align=right>";
             
	 		 $ancien/=10000000;
	 		 $sortie/=10000000;
			 $entree/=10000000;
			 $stock/=10000000;
	       
                print &deci($ancien,7);
                print "</td><td align=right>";
                print &deci($entree,7);
                print "</td><td align=right>";
                print &deci($sortie,7);
                print "</td><td align=right>";
                print &deci($stock,7);
                print "</td>";
                print "</tr>";
       }
print "</table>";
}
# -E edition du tableau des suspensions de droits
	