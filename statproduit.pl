#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require 'outils_perl.lib';
require 'manip_table.lib';
# fourchette des produits hors taxes 
@f_ht=("30510;Alcool_Fly",     # fourchette des produits hors taxes
"30860;Tabac_Fly",
"213454;Alimentation",
"225987;Alcool",
"226249;Vin",
"228970;Biere",
"229851;Soda",
"242622;Cigarette",
"247300;Cigare",
"248482;Tabac",
"330220;Produit_menager",
"359999;Parfum",
"480042;Cadeaux",
"880528;Autres");

@f_tt=("226598;Champagne",     # fourchette des produits hors taxes
"228599;Vin",
"510301;Bieres",
"510820;Soda",
"513952;Produit_alimentaire",
"514950;Produit_menager",
"529590;Cosmetique",
"529999;Cadeaux",
"530051;Promotion",
"549026;Cadeaux;non",
"551761;Produit_alimentaire;non",
"552348;Produit_menager;non",
"555280;Page_de_pub",
"560654;Cadeaux;non",
"999999;autres");



############## recuperation des parametres ###############

$debut = $html->param("debut"); # premier produit
$fin = $html->param("fin");     # dernier produit
$code_produit = $html->param("code_produit"); # code produit
$inconnu =$html->param("inconnu"); # selection automatique
$aff= $html->param("print"); # affichage oui non
$cata=$html->param("type_cat");
$non_cata=$html->param("type_noncat");
$calcul=$html->param("calcul");# calcul
$statistique=$html->param("statistique");# edition des statistique
$stock_null=$html->param("stock_null");# avec  les stocks à zero
$stock_nonnull=$html->param("stock_nonnull");# sans  les stocks à zero
$ecart=$html->param("ecart");# avec  les produit +-
$sans_ecart=$html->param("sans_ecart");# avec les produit sans +-
$enso=$html->param("enso");# avec  les produit present dans le fichier enso
$sans_enso=$html->param("sans_enso");# sans les les produit present dans enso
$type_col=$html->param("col");# colonne a afficher

$dispo=$html->param("dispo");# avec les produits dispo
$sans_dispo=$html->param("sans_dispo");# sans les produits dispo
$tiers=$html->param("tiers"); # avec les produits tiers
$cee=$html->param("cee"); # avec les produits cee
$stock_mini=$html->param("stock_mini"); # avec un stock minimum

$CODE_ERREUR=0;

foreach(@f_ht){
	($produit,$famille)=split(/;/,$_);
        if (($html->param("fa_$famille") eq "on") || ($html->param("tous") eq on)){
        	push(@famille_auto,$famille." ");
        }
}
foreach(@f_tt){
	($produit,$famille)=split(/;/,$_);
        if (($html->param("fat_$famille") eq "on") || ($html->param("toust") eq on)){
        	push(@famillet_auto,$famille." ");
        }
}       



######## variables master ############

$compt=0;  # compteur de ligne
$max_ligne=500; #Nombre de ligne maximum avant arret   -> 3000 modification alex


# traitement via une recherche
if (($code_produit ne "") && (! grep /[0-9]/,$code_produit))
{ 
	
	 exec("/home/intranet/cgi-bin/choix-col.pl produit $code_produit http://intranet.dom/cgi-bin/statproduit.pl?tous=\"on&calcul=on&print=on&type_autres=on&type_cd=on&toutes=on&code_produit=\" 2");

}

# premier passage ou parametre incorrect

if ( ( ($debut eq "") && ($code_produit eq "") && ($inconnu ne "on")) || ( ($fin > 0) && ($fin < $debut) ) )  {  
		&choix();
	}
else {
print "<html>\n";

print "<head><style type=\"text/css\">TD {font-size: 0.80em;}</style></head><body>";

# traitement de la demande
	
if ($debut eq ""){$debut=$fin=$code_produit;}



if ($fin eq ""){$fin=$debut;}
if ($inconnu eq "on"){$debut=0;$fin=999999999;}
	

%produit_idx = &get_index_num("produit",1);            
open(FILE1,"/var/spool/uucppublic/produit.txt");     
@produit_dat = <FILE1>;
close (FILE1);

%fournisseur_idx = &get_index_num("fournisseur",0);            
open(FILE1,"/var/spool/uucppublic/fournisseur.txt");     
@fournisseur_dat = <FILE1>;
close (FILE1);

open(FILE2,"/var/spool/uucppublic/stre.txt");     
@stre_dat = <FILE2>;
close (FILE2);

open(SAUV,">../public_html/statproduit.csv");


$date=`date`;
print "<div align=right><font size=2>$date</font></div><br>";


$total=0;
$total_plus=0;
$total_moins=0;
$total_page=0;
&affiche("<table width=100% border=1 cellspacing=0 cellpadding=0>");
&affiche( "<tr bgcolor=#e8e8e8><td>Code Produit</td><td>Designation</td><td>Famille</td><td>Code fournisseur</td><td>fournisseur</td>");

if ($type_col eq "1") {
	&affiche("<td>Stock disponible</td><td>Prix de revient</td><td>Valeur du stock</td></tr>\n");        
}else {
	&affiche("<td>Prix de revient</td><td>Prix catalogue</td><td>Coefficient</td></tr>\n");        
}
if ($type_col eq "1") {
	print SAUV "Code Produit;Designation;Famille;Code fournisseur;fournisseur;Stock disponible;Prix de revient;Valeur du stock;\n";        
}else{
	print SAUV "Code Produit;Designation;Famille;Code fournisseur;fournisseur;Prix de revient;Prix catalogue;coéfficient;\n";        
}	
print "<font color=red> $fin </font>";	
foreach (@stre_dat){
        ($stre_cd_pr,$stre_stock,$stre_prev,$stre_res,$stre_diff)=split(/;/,$_);
        # $stre_stock+=$stre_res-$stre_diff;  valeur comptable
        $stre_cd_pr=$stre_cd_pr%1000000;
	$pr_desi="inconnu";
       # print "$_<BR>";
        if ($produit_idx{$stre_cd_pr} ne ""){
			($pr_cd_nat,$pr_cd_prod,$pr_famille,$pr_niveau,$pr_manq,$pr_cde_mini,$pr_cd_fourn,$pr_co,$pr_deg,$pr_desi,$pr_dte_en,$pr_orig,$pr_pdb,$pr_pdn,$pr_prx_rev,$pr_prx_un,$pr_qte_comp,$pr_qte_ven,$pr_stal,$pr_stan,$pr_stre,$pr_ta_1,$pr_ta_2,$pr_ta_3,$pr_ta_4,$pr_prev_ent,$pr_freq,$pr_secu,$pr_diff,$pr_cde_limite,$pr_cd_fr,$pr_ndp_sh,$pr_pac,$pr_maj_sh,$pr_in_sup,$pr_nv_prix,$pr_nv_dev,$pr_dt_nvp,$pr_prac,$pr_conge,$pr_prfs,$pr_prls,$pr_prusd,$pr_qte_cde,$pr_qte_uncde,$pr_remcde,$pr_devac,$pr_condach,$pr_nom,$pr_dt_dcp,$pr_nv_rem,$pr_page,$pr_transport,$pr_coef_puni,$pr_coef2_prev) = split(/;/,$produit_dat[$produit_idx{$stre_cd_pr}]);
	}
# else
# {
#	print "<tr><td>$stre_cd_pr</td></tr>";
#	}
        if ($fournisseur_idx{$pr_cd_fourn} ne ""){ 
                         ($fo_cd_fo,$fo_add)=split(/;/,@fournisseur_dat[$fournisseur_idx{$pr_cd_fourn}]); 
			($fo_nom)=split(/\*/,$fo_add); 
        } 
 

        $pr_famille="";
        
	if ($pr_cd_nat==1){
        	foreach(@f_ht){
        		($produit,$famille)=split(/;/,$_);
        		if ($pr_cd_prod <= $produit){
        			$pr_famille=$famille." ";
        			last;
       	 		}
        	}
	}
	else {
		
		foreach(@f_tt){
        		($produit,$famille)=split(/;/,$_);
        		if ($pr_cd_prod <= $produit){
        			$pr_famille=$famille." ";
         #print "<h5>$pr_famille</h5>";
        			last;
       	 		}
        	}

        }
       
 

        if ($stre_prev eq "") {$stre_prev=0;}
	if ($stre_stock eq "") {$stre_stock=0;}
        #print "$pr_cd_prod<BR>";
        if (($pr_cd_prod >= $debut) && ($pr_cd_prod <= $fin) && (fourchette($pr_cd_prod) eq "oui")&& ($pr_in_sup!=4)) {
		# ok celui la est à traiter
		
     		&affiche( "<tr><td><font color=red>$pr_cd_prod</font></td><td><font size=2><font color=red>$pr_desi</font></td><td align=center><font color=red>$pr_famille </td>");
                
                &affiche("<td align=center>$pr_cd_fourn</td><td>$fo_nom</td>");
      		&affiche("<td align=right>");
     		
     		
		# 2 denière colone (alex)
		if ($type_col eq "1") {
     			&affiche(&separateur($stre_stock));
			&affiche("</td><td align=right> ");
			&affiche(&separateur($stre_prev));
                	&affiche("</td><td align=right> ");
			&affiche(&separateur($stre_stock*$stre_prev));
		}
      		else {
      			&affiche(&separateur($stre_prev));
			&affiche("</td><td align=right> ");
			&affiche(&separateur($pr_prx_un));
                	&affiche("</td><td align=right> ");
                        $coef=0;
                	if ($stre_prev != 0){$coef=($pr_prx_un/$stre_prev);}
             		&affiche(&separateur($coef));
		}
		
		&affiche("</td><td align=right>");
		&affiche( "</tr>\n");
		$val=$stre_stock*$stre_prev;
		$total+=$val;
		$compt++;
		
		# creation d'une  table associative avec une chaine composer des info du produit (pour les stats)
		$item=$pr_cd_nat.";".$famille.";".$pr_page;
		
		($val_anc,$valm_anc,$valp_anc)=split(/;/,$stat{$item});
		$val_anc+=$val;
		# $valm_anc+=$valm; ncienne version avec des stats qte neg et pos
		# $valp_anc+=$valp;
		$stat{$item}=$val_anc.";".$valm_anc.";".$valp_anc;
		if ($type_col eq "1") {
     			print  SAUV "$pr_cd_prod;$pr_desi;$famille;$pr_cd_fourn;$fo_nom;$stre_stock;$stre_prev;\n"; # creation d'une table en vue d'une sauvegarde
		}
		else{
			print  SAUV "$pr_cd_prod;$pr_desi;$famille;$pr_cd_fourn;$fo_nom;$stre_prev;$pr_prx_un;$coef;\n"; # creation d'une table en vue d'une sauvegarde
		}
	}
	if ($pr_cd_prod >$fin){
			last;
		}
		
}

&affiche ("</table><br>\n");
# message en cas de de listing vide
if ($compt==0){
	if ($code_produit ne ""){
		if ($produit_idx{$code_produit}eq""){
	 		print "<center><font color=red size=4>$code_produit Code produit inconnu</font></center><br>";
		}
		else{ 
        		@produit_item=split(/;/,@produit_dat[$produit_idx{$code_produit}]);
        		print "<center>@produit_item<br><center><font color=red size=4>Ce produit n'existe pas</font></center";
		}
	}
	else{
		print "<center><font color=red size=4>Votre requête n'a généré aucun enregisrement</font></center><br>"
	}
}

        			
&pied();

}

############# PIED DE PAGE ######################
sub pied{
if ($statistique eq "on"){&stat();}
if ($calcul eq "on"){
	
	print "<br><br><center>Nombre de produits traitées:$compt<br>";
	&fin_tableau();
        print "</center></b>";
}
print "<br><center><a href=statproduit.pl>nouvelle requête</a></center>";

print <<"eof";
<br><br>
<font size=1 color=gray>
Requete: 
debut:$debut 
fin:$fin 
code produit:$code_produit 
eof
print "<font size=1>@famille_auto;$#famille_auto:$#famillet_auto</font>";
#for ($i=0;$i<=$#f_ht;$i++){
#	
	#($produit,$famille)=split(/;/,$f_ht[$i]);	
#	
        #print $famille," :",${"fa_".$famille}; 
#}
print <<"eof";
cata:$cata
noncata:$non_cata
inconnu:$inconnu 
statistique:$statistique
</font><br> 
eof
close (SAUV);
print "<br><center><a href=http://intranet.dom/statproduit.csv>Telecharger au Format Excel</a>\n";
print "</body></html>";

close (FILE1);
}

################################### STAT ##########################
# edition des statistiques
sub stat{

         $total=0;
         $totalp=0;
         $totalm=0;
         print "<center><table border=1 width=80%><tr><td><b>Famille</td><td><b>Sous-douane</td><td><b>Hors douane</td><td><b>Catalogue</td><td><b>Hors catalogue</td><td><b>Valeur </td></tr>";
         foreach $cle (keys(%stat)) {
         	#print $cle,"-->",$stat{$cle},"<br>";
         	
         	($douane,$famille,$cata)=split(/;/,$cle);
         	print "<tr><td>$famille</td>";
         	if ($douane == 1){print "<td align=center>X</td><td>&nbsp;</td>";}
         	else {print "<td>&nbsp;</td><td align=center>X</td>";}
         	if ($cata == 1){print "<td align=center>X</td><td>&nbsp;</td>";}
         	else {print "<td>&nbsp;</td><td align=center>X</td>";}
		($val,$valm,$valp)=split(/;/,$stat{$cle});
		print "<td align=right>";
		print &separateur($val);
		$total+=$val;
		print "</td></tr>";
         	         	
        	}
        print "<tr><td><b>TOTAL</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=right><b>";
        print &separateur($total);
        print "</td></tr></table>";
        }
        
         

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

########################## FIN TABLEAU ########################
# fin du produit affichage du total

sub fin_tableau {
  	&affiche( "<table border=0><tr><td><font size=2><b>VALEUR DU STOCK:</td><td align=right><b>");
  	                        &affiche( &separateur($total));
		        	&affiche( "</td></tr></table>");	        	
		        	$total_page+=$total;
		        	$total=0;
}
####################    TEST FOURCHETTE ##################
# verification des criteres produit
sub fourchette { 
	my ($var)=@_;
	my ($autorise)="oui";
	if (($#famille_auto == -1) && ($pr_cd_nat == 1)){$autorise="non";}
        if (($#famille_auto != -1) && ($pr_cd_nat == 1) && (! grep /$pr_famille/,@famille_auto)){$autorise="non";}
        if (($#famillet_auto == -1) && ($pr_cd_nat != 1)){$autorise="non";}
        if (($#famillet_auto != -1) && ($pr_cd_nat != 1) && (! grep /$pr_famille/,@famillet_auto)){$autorise="non";}
        if (($pr_page >= 1)&&($cata ne "on")){$autorise="non";}
        if (($pr_page != 0)&&($non_cata ne "on")){$autorise="non";}
        $st_null="vrai";
        
        if (($pr_stre!=0)||($pr_diff!=0)||($pr_prusd!=0)){$st_null="faux";}
        if (($st_null eq "faux")&&($stock_nonnull ne "on")){$autorise="non";}
        # if ($pr_cd_prod==226979){print "<font size=+5>$st_null:$stock_nonnull:$autorise</font>";}
        
        if (($st_null eq "vrai")&&($stock_null ne "on")){$autorise="non";}
        
        if (($ecart ne "on")&&($pr_diff!=0)){$autorise="non";}
        if (($sans_ecart ne "on")&&($pr_diff==0)){$autorise="non";}
        #if (! $enso_idx{$pr_cd_nat} eq ""){print "<tr><td>---------</td></tr>";}
        if (($enso ne "on")&&($enso_idx{$pr_cd_prod} ne "")){$autorise="non";}
        if (($sans_enso ne "on")&&($enso_idx{$pr_cd_prod} eq "")){$autorise="non";}
        
        if (($dispo ne "on")&&($stre_stock!=0)){$autorise="non";}
        if (($sans_dispo ne "on")&&($stre_stock == 0)){$autorise="non";}
        if (($tiers ne "on")&&($pr_orig > 21)){$autorise="non";}
        if (($cee ne "on")&&($pr_orig < 22)){$autorise="non";}
        if (($stock_mini > 0)&& ($pr_stre < $stock_mini)){$autorise="non";}
        
        return($autorise);                                                	
		
	}
	
	
	
#################### AFFICHE ##################
# permet d'afficher ou nom le tableau

sub affiche {
	my ($var)=@_;
	if ( $aff eq "on"){
		#if ($compt>$max_ligne && $CODE_ERREUR == 0){
#			print "</table><center><font size=5 color=red>STOP VOTRE REQUETE A GENERE TROP DE LIGNE</font>";
#			print "<br>merci de limiter votre choix ou de ne faire que le caclul</br>";
			#$CODE_ERREUR=1;
#			&pied();
#			$var = "";
#		}
	if($CODE_ERREUR == 0){
		print $var;
	}
	}
}		
######################### PAGE HTML  #############################
# premiere page
		        	
sub choix(){

print <<"eof";
<html>
<script>
function modif1c(param)
{       
	if ((param=="inc") &&(document.choix.inconnu.checked==true))
	{
	document.choix.debut.value="";
	document.choix.fin.value="";
	}
        if (param=="fo"){document.choix.inconnu.checked=false;}
	
}
function modif2c(param)
{       
	if (param=="p"){document.choix.tous.checked=false;}
	if (param=="t"){
eof
		
for ($i=0;$i<=$#f_ht;$i++){
	($produit,$famille)=split(/;/,$f_ht[$i]);	
	print "document.choix.fa_",$famille,".checked=false;\n";
}
print <<"eof";
	}
        
	
}
function modif3c(param)
{       
	if (param=="p"){document.choix.toust.checked=false;}
	if (param=="t"){
eof
		
for ($i=0;$i<=$#f_tt;$i++){
	($produit,$famille,$aff)=split(/;/,$f_tt[$i]);
	if ($aff ne "non"){	
		print "document.choix.fat_",$famille,".checked=false;\n";
	}
}
print <<"eof";
	}
        
	
}


</script>
<body bgcolor=white text=black>
eof
&tete("PRODUIT BIS","/var/spool/uucppublic/stre.txt","");
print <<"eof";
<form action=statproduit.pl name=choix>

<center><table width=100% border=2 width=100% cellspacing=0 cellpadding=0 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod >

<!-- ligne 1 -->
<tr bgcolor=e8e8e8><td align= middle><b>Choix du produit ou de la fourchette de produit</td><td align=middle><b>Options</td><td align=middle><b>Requête</td></tr>

<!-- ligne 2 -->
<tr>

<!-- colonne 1 -->

<td align=middle>Code produit ou Désignation:<input type=text name=code_produit size=8 Onchange=modif1c("fo")></td>

<!-- colonne 2 -->

<td align=middle>
eof

print "<b>Sous-Douane</b>&nbsp;&nbsp;&nbsp;Tous<input type=checkbox name=tous checked Onclick=modif2c(\"t\")> <br><br><table border=0><tr>";
for ($i=0;$i<=$#f_ht;$i++){
	if (($i==3)||($i==6)||($i==9)||($i==12)){print "</tr><tr>";}
	($produit,$famille)=split(/;/,$f_ht[$i]);	
	print "<td align=right>",$famille," <input type=checkbox name=fa_",$famille," Onclick=modif2c(\"p\")></td>\n";
}
print "</tr></table>";



print <<"eof";
</td>

<!-- colonne 3 -->

<td align=middle rowspan=3>
<font size=-1>stock , prix de revient, valeur<input type=radio name=col value=1 checked><br>
prix de revient ,prix catalogue , coéfficient<input type=radio name=col value=2></font><br><br>
Stock minimum:<input type=text name=stock_mini size=5><br><br><br><br>
<b>EDITION <input type=checkbox name=print checked>
 <input type=hidden name=calcul value=on><br>
STATISTIQUE</b><input type=checkbox name=statistique><br><br><br>
<input type=submit value=go></td>

</tr>

<!-- Ligne 3 -->

<tr>

<!-- colonne 1 -->

<td align=middle rowspan=2>
Premier Produit : <input type=text name=debut size=8 Onchange=modif1c("fo")><br>
Dernier Produit : <input type=text name=fin size=8 Onchange=modif1c("fo")><br>
<br><br>Inconnu <input type=checkbox name=inconnu checked OnClick=modif1c("inc")></td>

<!-- colonne 2 -->
<td align=middle>
eof

print "<b>Hors-Douane</b>&nbsp;&nbsp;&nbsp;Tous<input type=checkbox name=toust Onclick=modif3c(\"t\")> <br><br><table border=0><tr>";
$j=0;
for ($i=0;$i<=$#f_tt;$i++){
	if ($j==3){
		print "</tr><tr>";
		$j=0;
		}
	($produit,$famille,$aff)=split(/;/,$f_tt[$i]);
	if ($aff ne "non"){	
		$j++;
		print "<td align=right>",$famille," <input type=checkbox name=fat_",$famille," Onclick=modif3c(\"p\")></td>\n";
	}
}
print <<"eof";
</tr></table>
</td>
</tr>
<!-- ligne 4 -->

<tr>
<td align=center>
Catalogue <input type=checkbox name=type_cat checked><br>
Hors catalogue<input type=checkbox name=type_noncat checked><br>
Avec les stocks à zéro <input type=checkbox name=stock_null checked> Avec les stocks non null <input type=checkbox name=stock_nonnull checked><br>
Produits Tiers <input type=checkbox name=tiers checked> Produits Cee <input type=checkbox name=cee checked> <br>

<input type=hidden name=ecart value=on>
<input type=hidden name=sans_ecart value=on>
<input type=hidden name=enso value=on>
<input type=hidden name=sans_enso value=on>
<input type=hidden name=sans_dispo value=on>
<input type=hidden name=dispo value=on> 

</td>
</tr>
</table>
</form>
<br><img src=http://intranet.dom/creation2000p.gif align=right border=0>
eof


print "</HTML>";
print "</BODY>";
		}
# -E Stat sur les produits BIS
