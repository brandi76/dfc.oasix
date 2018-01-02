#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';
print $html->header;    

# pour les ecarts fin d'annee
# courant janvier les ecarts et les casses sont saisie sur une commande puis sortie sur une note d'erreur
# on sort la drm comme d'habitude  et dans le fichier enso on recupere que le numero de douane avec excel et
# on modifie ce programme en remplacent enso par le fichier correspondant


%produit_idx = &get_index_num("douane/2003/produit030605",1);            
open(FILE2,"/home/var/spool/uucppublic/douane/2003/produit030605.txt");
@produit_dat = <FILE2>;
close(FILE2);


%mvt_idx = &get_index_multiple("douane/2003/enso030605",0);            
open(FILE2,"/home/var/spool/uucppublic/douane/2003/enso030605.txt");     # entree sortie 
@mvt_dat = <FILE2>;
close(FILE2);


%suspen_idx = &get_index_num("douane/2003/suspen030605",0);            
open(FILE2,"/home/var/spool/uucppublic/douane/2003/suspen030605.txt");     # stock des produits a declarer
@suspen_dat = <FILE2>;
close(FILE2);

open(COMPTA,">/home/var/spool/uucppublic/comptamatiere-accise.txt");     # mouvement des produits


print <<"eof";
<html>
<head>
<style type=\"text/css\">
<!--
BODY { background-color : white }
H1 { page-break-after : right }         
TH { text-align : center } 
-->
</style></head><body link=black vlink=black>
eof
			
		

foreach(@suspen_dat){ 
	# a partir du fichier genere par SUSPENSION avec l'aryx ona la liste des produit avec leur type
	# ici sus_qte correspond au stock ancien , par la suite il faudra tenier compte du stock nouveau
        # famille correspond au type d'entrepot et type au groupement ndp
	($sus_cd_pr,$sus_famille,$sus_type,$sus_qte,$sus_pdn,$sus_deg,$sus_nouveau)=split(/;/,$_);
	$sus_famille+=0;
	$sus_type+=0;
	# if ($sus_type==10){next;} # les bieres gestion à part

	$nb++;
	$qte_sortie=$qte_entree=0;
	$qte_sortie_tiers=0;
	$qte_entree_tiers=0;
		
	  
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
			}
		
			if (($sus_type<6)||(($sus_type >10) && ($sus_type <15))||($sus_type==18)||($sus_type==19)){
				$sortie2=$sortie*$pr_pdn;
				$entree2=$entree*$pr_pdn;
			}
			if (($sus_type>5)&&($sus_type <11)){  # alcool pur
				$sortie2=$sortie *($pr_pdn)*($pr_deg);
 				$entree2=$entree *($pr_pdn)*($pr_deg);
			
			}
			if (($sus_type==15)||($sus_type==17)){  # cigarette et tabac
				$sortie2=$sortie *$pr_pdn;
				$entree2=$entree *$pr_pdn;
			}
			if ($sus_type==16){  # nb par mille cigares
				$sortie2=$sortie*$pr_qte_comp;
				$entree2=$entree*$pr_qte_comp;

			}
			$date2=($date%100*10000)+(int(($date%10000)/100)*100)+int($date/10000);
			$sus_type+=0;
			print COMPTA "$date2;$sus_type;$douane;$sortie2;$entree2;$sortie;$entree;\n";
			
# --------------------- fin gestion des mouvements par type ----------------

		}
	}
	if (($sus_qte==0) && ($qte_sortie==0) && ($qte_entree==0) && ($sus_nouveau ==0)){next;}
	if (($sus_famille ==2)||($sus_famille ==3)) {
		push (@CEE,"$sus_type;$sus_cd_pr;$sus_qte;$qte_sortie;$qte_entree;$sus_nouveau;");
	}
	
}

$type_titre=$pass=$total_ent=$total_so=$total_ancien=$total_new=$total_ent_unite=$total_so_unite=$total_ancien_unite=$total_new_unite=0;
@tableau=();
print "<center>";
print "<h2><a href=#EFD>ENTREPOT ACCISES </a></h2>";
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

#                          subroutine 
	
sub detail{
foreach (@TABLE)
{
	($type,$code,$qte_ancien,$qte_sortie,$qte_entree,$qte_new)=split (/;/,$_);
	if ($type==10){next;}
	$qte_ancien+=0;
	$qte_sortie+=0;
	$qte_entree+=0;
	$qte_nouveau+=0;
	
	if ($type ne $type_titre){
		if ($pass ne 0){
			print "<tr><td><b>TOTAL</td><td><b>";
			print $total_ancien_unite;
			print "</td><td><b>";
			print $total_ancien;
			print "</td><td><b>";
			print $total_ancien_unite;
			print "</td><td><b>";
			print $total_ent;
			print "</td><td><b>";
			print $total_ent_unite;
			print "</td><td><b>";
			print $total_so;
			print "</td><td><b>";
			print $total_new_unite;
			print "</td><td><b>";
			print $total_new;
			$verif=$total_ent_unite-$total_so_unite-$total_new_unite+$total_ancien_unite;
			$verifn=$total_ent-$total_so-$total_new+$total_ancien;
			print "</td><td><b>";
			print &deci($verif,2);
			print "</td><td><b>";
			print $verifn;
			print "</td></tr>";
			print "</table><br>entrepot accise<h1>.</h1>";
			$tableau[$type_titre]="$total_ancien;$total_ent;$total_so;$total_new;";
			$total_ancien=$total_ent=$total_so=$total_new=0;
			
			
		}
		else {$pass=1;}
		print "<table border=1 width=100% cellspacing=0><COL span=1 ALIGN=left><col span=9 align=right><tr><td><b>$type ";
		if ($type == 1){print "Vins Tranquilles Autres ml";}
		if ($type == 2){print "Champagnes et mousseux ml";}
		if ($type == 3){print "ABV VDL ml";}
		if ($type == 4){print "VDN ml";}
		if ($type == 5){print "Cidres ml";}
		if ($type == 6){print "Alcools 9510 alcool pur";}
		if ($type == 7){print "Rhums francais (DOM) alcool pur";}
		if ($type == 8){print "Rhums autres alcool pur";}
		if ($type == 9){print "Cassis alcool pur";}
		if ($type == 10){print "Bieres ";}
		if ($type == 11){print "Bieres 5 ml";}
		if ($type == 12){print "Bieres 6 ml";}
		if ($type == 13){print "Bieres 7 ml";}
		if ($type == 14){print "Bieres X ml";}
		if ($type == 15){print "Cigarettes gr";}
		if ($type == 16){print "Cigares nb";}
		if ($type == 17){print "Tabacs gr";}
	        if ($type == 18){print "Champagnes ml";}
	        if ($type == 19){print "Vins ml";}
	        
	        $type_titre=$type;
	        print "</td><th colspan=2>ancien</td><th colspan=2>entree</td><th colspan=2>sortie</td><th colspan=2>nouveau</td><td>&nbsp;</td><td>&nbsp;</td></tr>";	
	}
	$pr_desi="";
	if ($produit_idx{$code}ne""){
		($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split(/;/,$produit_dat[$produit_idx{$code}]);
	}
	
	$qten_ancien=$qte_ancien;
	$qten_sortie=$qte_sortie;
	$qten_entree=$qte_entree;
	$qten_new=$qte_new;
	
	if (($type<6)||(($type >10) && ($type <15))||($type==18)||($type==19)){
	 	$qten_ancien=$qte_ancien*$pr_pdn;
		$qten_sortie=$qte_sortie*$pr_pdn;
		$qten_entree=$qte_entree*$pr_pdn;
		$qten_new=$qte_new*$pr_pdn;
		

	}
	if (($type>5)&&($type <11)){
		
	 	$qten_ancien=$qte_ancien*$pr_pdn*$pr_deg;
 		$qten_sortie=$qte_sortie *$pr_pdn*$pr_deg;
 		$qten_entree=$qte_entree *$pr_pdn*$pr_deg;
		$qten_new=$qte_new*$pr_pdn*$pr_deg;
 		
	}
	if (($type==15)||($type==17)){ 
		$qten_ancien=$qte_ancien *$pr_pdn;
		$qten_sortie=$qte_sortie *$pr_pdn;
		$qten_entree=$qte_entree *$pr_pdn;
		$qten_new=$qte_new *$pr_pdn;
		
	}
	if ($type==16){  
		$qten_ancien=$qte_ancien * $pr_qte_comp;
		$qten_sortie=$qte_sortie * $pr_qte_comp;
		$qten_entree=$qte_entree * $pr_qte_comp;
		$qten_new=$qte_new * $pr_qte_comp;
		
	}
	$color="black";
	
	print "<tr><td><font color=$color>$code $pr_desi </td><td>";
	print "<font size=-1>";
	print &deci($qte_ancien,2);
	print "</font></td><td >";
	print $qten_ancien;
	$total_ancien_unite+=$qte_ancien;
	$total_ancien+=$qten_ancien;
	print "</td><td align=right>";
	print "<font size=-1>";
	print &deci($qte_entree,2);
	print "</font></td><td>";
	print $qten_entree;
	$total_ent_unite+=$qte_entree;
	$total_ent+=$qten_entree;
	print "</td><td>";
	print "<font size=-1>";
	print &deci($qte_sortie,2);
	print "</font></td><td>";
	print $qten_sortie;
	$total_so_unite+=$qte_sortie;
	$total_so+=$qten_sortie;
	print "</td><td>";
	print "<font size=-1>";
	print &deci($qte_new,2);
	print "</font></td><td>";
	print $qten_new;
	$total_new_unite+=$qte_new;
	$total_new+=$qten_new;
	print "</td><td>";
	$verif=$qte_entree - $qte_sortie + $qte_ancien - $qte_new;
	print &deci($verif,2);
	print "</td><td>";
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
$tableau[$type_titre]="$total_ancien;$total_ent;$total_so;$total_new";
print "</td></tr>";
			
print "</table></center><h1>.</h1>";
}

sub recap
{
##################### DEBUT DE LA RECAP  ################

print "<table border=1 cellspacing=0 align=center>";
print "<tr><td>&nbsp;</td><td><b>Stock du mois<br>precedent</td><td><b>ENTREES</td><td><b>SORTIES</td><td><b>STOCK<br>THEORIQUE</td></tr>";
for ($type=1;$type<=19;$type++){
		if ($type==10){next;}
		if ($tableau[$type]ne""){
		print "<tr><td>";
		
		if ($type == 1){
			print "<b>VINS CIDRES ABV HL</td><td colspan=4>&nbsp;</td></tr><tr><td>$type ";
			print "Vins Tranquilles Autres";}
		if ($type == 2){print "$type Champagnes et mousseux";}
		if ($type == 3){print "$type ABV VDL";}
		if ($type == 4){print "$type VDN";}
		if ($type == 5){print "$type Cidres";}
		if ($type == 6){
			print "<b>SPIRITUEUX ALCOOLS HL ALCOOL PUR</td><td colspan=4>&nbsp;</td></tr><tr><td>";
			print "$type Alcools 9510";}
		if ($type == 7){print "$type Rhums francais (DOM)";}
		if ($type == 8){print "$type Rhums autres";}
		if ($type == 9){print "$type Cassis";}
		if ($type == 10){
			print "<b>BIERES HL ALCOOL PUR</td><td colspan=4>&nbsp;</td></tr><tr><td>";
			print "$type Bieres";}
		if ($type == 11){print "$type Bieres 5";}
		if ($type == 12){print "$type Bieres 6";}
		if ($type == 13){print "$type Bieres 7";}
		if ($type == 14){print "$type Bieres X";}
		if ($type == 15){
			print "<b>TABACS </td><td colspan=4>&nbsp;</td></tr><tr><td>";
			print "$type Cigarettes unités par 1000";}
		if ($type == 16){print "$type Cigares unités par 1000";}
		if ($type == 17){print "$type Tabacs poids pour 1000 grs";}
                if ($type == 18){
                		print "<b>CHAMPAGNES HL</td><td colspan=4>&nbsp;</td></tr><tr><td>";
		print "$type Champagnes";}
             
                if ($type == 19){
                		print "<b>VINS CIDRES ABV HL</td><td colspan=4>&nbsp;</td></tr><tr><td>";
		print "$type Vins";}
                
                ($ancien,$entree,$sortie,$stock)=split(/;/,$tableau[$type]);
                print "</td><td align=right>";
             
		if (($type<6)||(($type >10) && ($type <15))||($type==18)||($type==19)){
	 		$ancien/=100000;
	 		$sortie/=100000;
			$entree/=100000;
			$stock/=100000;
		  	print &deci($ancien,9);
                	print "</td><td align=right>";
                	print &deci($entree,9);
                	print "</td><td align=right>";
                	print &deci($sortie,9);
                	print "</td><td align=right>";
                	print &deci($stock,9);
        
		}
		if (($type>5)&&($type <11)){
	 		$ancien/=10000000;
	 		$sortie/=10000000;
			$entree/=10000000;
			$stock/=10000000;
		  	print &deci($ancien,9);
                	print "</td><td align=right>";
                	print &deci($entree,9);
                	print "</td><td align=right>";
                	print &deci($sortie,9);
                	print "</td><td align=right>";
                	print &deci($stock,9);
        
		}
	 	
		if (($type==15)||($type==17)){  
			$ancien/=1000;
	 		$sortie/=1000;
			$entree/=1000;
			$stock/=1000;
	        	print &deci($ancien,3);
                	print "</td><td align=right>";
                	print &deci($entree,3);
                	print "</td><td align=right>";
                	print &deci($sortie,3);
                	print "</td><td align=right>";
                	print &deci($stock,3);
        
		}
		if ($type==16){ 
			$ancien/=1000;
	 		$sortie/=1000;
			$entree/=1000;
			$stock/=1000;
		  	print &deci($ancien,3);
                	print "</td><td align=right>";
                	print &deci($entree,3);
                	print "</td><td align=right>";
                	print &deci($sortie,3);
                	print "</td><td align=right>";
                	print &deci($stock,3);
        
		}
	       
                print "</td>";
                print "</tr>";
                }
         	}
print "</table>";
}
# -E edition du tableau des suspensions de droits
	