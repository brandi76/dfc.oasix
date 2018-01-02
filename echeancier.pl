#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require 'outils_perl.lib';
require 'manip_table.lib';
 

# couleur de degradé
$coul0=black;
$coul1="#0000ff";
$coul2="#3e00cc";
$coul3="#930093";
$coul4="#bb0066";
$coul5="#ff0000";
$coul6="#ff0000";
$coul7="#ff0000";
$coul8="#ff0000";
$coul9="#ff0000";
############## recuperation des parametres ###############

$debut = $html->param("debut"); # premier client
$fin = $html->param("fin");     # dernier client
$code_client = $html->param("code_client"); # code client
$pays_francais = $html->param("pays_francais"); # client francais
$pays_anglais = $html->param("pays_anglais"); # client anglais
$pays_suisse= $html->param("pays_suisse");# client suisse
$pays_autres = $html->param("pays_autres");# client autres
$type_cd =$html->param("type_cd"); # corps diplomatique
$type_autres=$html->param("type_autres");#hors corps diploamtique 
$inconnu=$html->param("inconnu");# code client inconnu
$aff=$html->param("print");# affichage des comptes
$det=$html->param("detail");# affichage du detail
$calcul=$html->param("calcul");# calcul du reste du
$statistique=$html->param("statistique");# edition des statistique
$type_unesco=$html->param("type_unesco");# unesco 
$ibs=$html->param("ibs");
$bis=$html->param("bis");
$rel_interdit=$html->param("rel_interdit");
$regle=$html->param("regle");
$interdit=$html->param("interdit");
$queinterdit=$html->param("queinterdit");

# recupration des vraiables liées à la date (date dynamic)
@date_invalide="";
$annee=`date +%Y`;
for ($i=0;$i<5;$i++)
{
	$an=$annee-$i;
	if (($html->param("an_$an") ne "on")&&($html->param("toutes") ne "on")){push(@date_invalide,$an);}
	}
$i--;
$an=$annee-$i;
$date_mini=-1;


################ modofication des parametre en fonction des valeurs des autres parametres #############

if (($html->param("av_$an") ne "on")&&($html->param("toutes") ne "on")){$date_mini=$an;}


if ($html->param("tous") eq "on") {
$pays_francais = "on";
$pays_anglais = "on";
$pays_suisse= "on";
$pays_autres = "on";
}	

######## variables master ############

$compt=0;  # compteur de ligne
$max_ligne=3000; #Nombre de ligne maximum avant arret


# traitement via une recherche
if (($code_client ne "") && (! grep /[0-9]/,$code_client))
{ 
	
	 exec("/home/intranet/cgi-bin/choix-col.pl client $code_client http://intranet.dom/cgi-bin/echeancier.pl?tous=\"on&calcul=on&print=on&type_autres=on&type_cd=on&toutes=on&code_client=\" 2");

}

# premier passage ou parametre incorrect

if ( ( ($debut eq "") && ($code_client eq "") && ($inconnu ne "on")) || ( ($fin > 0) && ($fin < $debut)) )  {  
		&choix();
	}
else {
print "<html>\n";
print "<body bgcolor=white text=black topmargin=3>";

# traitement de la demande
	
if ($debut eq ""){$debut=$fin=$code_client;}



if ($fin eq ""){$fin=$debut;}
if ($inconnu eq "on"){$debut=0;$fin=999999999;}
	
if (($bis eq "on")&&($ibs ne "on")){
	open(FILE1,"/home/var/spool/uucppublic/echeanc.txt");
	@ECHEANCIER = <FILE1>;
}
if (($bis ne "on")&&($ibs eq "on")){
	open(FILE1,"/home/var/spool/uucppublic/echeibs.txt");
	@ECHEANCIER = <FILE1>;
}
if (($bis eq "on")&&($ibs eq "on")){
	@ECHEANCIER = `sort /home/var/spool/uucppublic/echeanc.txt /var/spool/uucppublic/echeibs.txt`;
}

%client_idx = &get_index("client2",0);            
open(FILE2,"/home/var/spool/uucppublic/client2.txt");     
@client_dat = <FILE2>;
close (FILE2);
%pays_idx = &get_index_num("pays",0);
open(FILE2,"/home/var/spool/uucppublic/pays.txt");     
@pays_dat = <FILE2>;
close (FILE2);

%archrel_idx = &get_index_multiple("archrel",1);
open(FILE2,"/home/var/spool/uucppublic/archrel.txt");     
@archrel_dat = <FILE2>;
close (FILE2);

%archrelibs_idx = &get_index_multiple("archrelibs_li",1);
open(FILE2,"/home/var/spool/uucppublic/archrelibs_li.txt");     
@archrelibs_dat = <FILE2>;
close (FILE2);


# relance interdite fichier linux
%archrel_li_idx = &get_index_multiple("rel-interditbis",1);
open(FILE2,"/home/var/spool/uucppublic/rel-interditbis.txt");     
@archrel_li_dat = <FILE2>;
close (FILE2);
open(FILE2,"/home/var/spool/uucppublic/motif.txt");     
@motif_dat = <FILE2>;
close (FILE2);

$date=`date`;
print "<div align=right><font size=2>$date</font></div><br>";

print "<table  border=1 cellspacing=0>";
$totalff=$totaleu=0;
$total_page=$total_euro=0;
foreach (@ECHEANCIER){
        
        ($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
	$ec_no_fact+=0;
	if ($ec_cd_dev == 36){$ec_cd_dev=39;} # bug sur les francs susse en 95
	if (($ec_cd_cl >= $debut) && ($ec_cd_cl <= $fin) && (fourchette($ec_cd_cl) eq "oui") && (&test_date($ec_dt) eq "oui") && (&test_interdit() eq "oui") && (&test_regle() eq "oui")){
		
		# ok celui la est à traiter
		
		if ($ec_cd_cl ne $client){ # entete client
		        
		        if (($totalff!=0)||($totaleu!=0)){ &fin_tableau(); }# total du client precedent
		      
		        if ($client_idx{$ec_cd_cl}eq""){$cl_add="<font color=green>CLIENT INCONNU</font>";
		        $cl_service=$cl_ville=$cl_rue="";}
		        else{($cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville)=split(/;/,@client_dat[$client_idx{$ec_cd_cl}]);}
        		&affiche( "<tr><td><font size=2><font color=red>$ec_cd_cl</font></td><td colspan=8><font size=2><font color=black>Client:<font color=red>$cl_add<font color=black> Service:<font color=red>$cl_service<font color=black> Adresse:<font color=red>$cl_rue $cl_ville</tr>");
        		&affiche( "<tr bgcolor=#e8e8e8><td><font size=2>No de facture</td><td align=middle><font size=2>Nom</td><td><font size=2>Date de facture</td><td><font size=2>Montant </td><td><font size=2>montant reglé </td><td><font size=2>date du reglement</td><td><font size=2>Montant en devise</td><td><font size=2>reste </td><td><font size=2>reste en devise</td></tr>\n");
        		$client=$ec_cd_cl;
      		}
      		
      		# ligne echeance
      		$aa=substr ($ec_dt,length($ec_dt)-2,2)+1900;
      		if ($aa<1980){
      			$aa=$aa+100;
      			}
      		$annee=`date +%Y`;
      		#($nul,$annee)=split(/CEST/,$date);
      		$diff=$annee-$aa;
      		$couleur="#000000";
      		
      		# selection de la couleur en fonction de l'annee 
      		
      		if ($diff==1){$couleur=$coul1;}
      		if ($diff==2){$couleur=$coul2;}
      		if ($diff==3){$couleur=$coul3;}
      		if ($diff==4){$couleur=$coul4;}
      		if ($diff==5){$couleur=$coul5;}
      		
		&affiched("<tr><td align=right><font size=2 color=$couleur>$ec_no_fact</td><td align=middle><font size=2 color=$couleur>$ec_nom</td><td align=right><font size=2 color=$couleur>");
                $compt++;
	        &affiched(&date($ec_dt));
		&affiched( "</td><td align=right><font size=2 color=$couleur>");
		&affiched($ec_mont,"num");
		if (($ec_no_fact >100000) && ($ec_no_fact <9000000)){&affiched(" EU");}
		else {&affiched(" FF");}
		&affiched("</td><td align=right><font size=2 color=$couleur>");
		&affiched( &separateur($ec_reg));
		$ec_reg+=0;
		
		if (($ec_no_fact >100000) && ($ec_no_fact <9000000) && ($ec_reg ne 0)){&affiched(" EU");}
		elsif ($ec_reg ne 0) {&affiched(" FF");}
		
		&affiched("</td><td align=right><font size=2 color=$couleur>");
		&affiched(&date($ec_dt_reg));
		&affiched("</td><td align=right><font size=2 color=$couleur>");
		&affiched( &separateur($ec_mont_dev));
		&affiched(" ");
		$dev=$ec_cd_dev;
		$ec_cd_dev=0+$ec_cd_dev;
		
		if ($pays_idx{$ec_cd_dev} ne ""){
			($nul,$nul,$nul,$nul,$nul,$nul,$dev)=split (/;/,@pays_dat[$pays_idx{$ec_cd_dev}]);
			}
		&affiched( "$dev</td>");
		$reste=$ec_mont-$ec_reg;
		&affiched( "<td align=right><font size=2 color=$couleur>");
		&affiched( &separateur($reste));
		$reste+=0;
		
		if (($ec_no_fact >100000) && ($ec_no_fact <9000000) && ($reste ne 0)){
			&affiched(" EU");
			$totaleu+=$reste;}
		elsif ($reste ne 0) {
			&affiched(" FF");
			$totalff+=$reste;}
		
		&affiched( "</td>"); 
		$reste_dev=0;
		if ($ec_mont!=0){$reste_dev=$reste*$ec_mont_dev/$ec_mont;}
		&affiched( "<td align=right><font size=2 color=$couleur>");
		&affiched( &separateur($reste_dev));
		&affiched( " $dev</td>"); 
		&affiched( "</tr>\n");
		
		if (($archrel_idx{$ec_no_fact} ne "")&&($rel_interdit eq "on")){
			($code,$facture,$date,$etat,$desi)=split (/;/,$archrel_dat[$archrel_idx{$ec_no_fact}]);
			&affiched("<tr><td colspan=9 align=center><font size=2>$desi</td></tr>");
		}
		if (($archrelibs_idx{$ec_no_fact} ne "")&&($rel_interdit eq "on")){
			($code,$facture,$date,$etat,$desi)=split (/;/,$archrelibs_dat[$archrelibs_idx{$ec_no_fact}]);
			&affiched("<tr><td colspan=9 align=center><font size=2>$desi</td></tr>");
		}
		if (($archrel_li_idx{$ec_no_fact} ne "")&&($rel_interdit eq "on")){
			@liste=split(/;/,$archrel_li_idx{$ec_no_fact});
			foreach (@liste) {
				(@ligne)=split(/;/,$archrel_li_dat[$_]);
				($motif)=split(/;/,$motif_dat[$ligne[4]]);
				&affiched("<tr><td colspan=9 align=center><font size=2>le $ligne[2] Blocage fait par $ligne[3] Motif:<b>$motif</b> Commentaire: <b>$ligne[5]</b></td></tr>");
			}
		}
		
		
		
		# $total+=$reste;
		
		# creation d'une  associative avec une chaine composer des info du client (pour les stats)
		$item=$aa.";".&fourchette2($ec_cd_cl).";".$ec_cd_dev;
		if ($reste_dev != 0){$stat{$item}+=$reste_dev;}
	}
	if ($ec_cd_cl >$fin){
			last;
		}
		
	}
if (($totalff!=0)||($totaleu!=0)){ &fin_tableau();} # total du client precedent
	
print "</table><br>";

# message en cas de de listing vide
if ($compt==0){
	if ($code_client ne ""){
		if ($client_idx{$code_client}eq""){
	 		print "<center><font color=red size=4>$code_client Code client inconnu</font></center><br>";
		}
		else{ 
        		@client_item=split(/;/,@client_dat[$client_idx{$code_client}]);
        		print "<center>@client_item<br><center><font color=red size=4>Ce client n'a aucune facture un cours</font></center";
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
	print "<br><br><center>Nombre de facture traitées:$compt<br>";
	print "<font size=3 color=black><b><center>TOTAL RESTE DU EN EU: <font color=blue>";
        print &separateur($total_page);
        
        print "</font></center></b>";
}
print "<br><center><a href=echeancier.pl>nouvelle requête</a></center>";
print <<"eof";
<br><br>
<font size=1 color=gray>
Requete: 
debut:$debut 
fin:$fin 
code client:$code_client 
pays francais:$pays_francais 
pays anglais:$pays_anglais 
pays suisse:$pays_suisse 
pays autres:$pays_autres 
corps diplomatique:$type_cd 
grossiste:$type_autres 
inconnu:$inconnu 
date invalide :@date_invalide 
date_mini:$date_mini
statistique:$statistique
</font><br> 
eof


# print $ENV{"REQUEST_URI"};
print "</body></html>";

close (FILE1);
}

################################### STAT ##########################
# edition des statistiques
sub stat{


# recuperation des libelle de  devise
%pays_idx= &get_index_num("pays",0); 
open(FILE,"/home/var/spool/uucppublic/pays.txt");  
@pays_dat = <FILE>;  
close (FILE);
         foreach $cle (keys(%stat)) {
         	#print $cle,"-->",$stat{$cle},"<br>";
         	($aa,$pays,$type,$dev)=split(/;/,$cle);
         	#astuce
		if (! grep /$dev/,@{"A".$aa}){push (@{"A".$aa},$dev);} # pour une annee on a toute les devises
         	if (! grep /$aa/,@annee){push (@annee,$aa);} # on a la liste des annees 
         	if (! grep /$pays/,@{"P".$aa}){push (@{"P".$aa},$pays);} # on a la liste des pays
         	if (! grep /$type/,@{"T".$aa}){push (@{"T".$aa},$type);} # on a la liste des type (corps diplo ou autres)
        @annee=sort(@annee);
        foreach(@annee){
        	@{"P".$_}=sort(@{"P".$_});
        	@{"A".$_}=sort(@{"A".$_});
        	@{"T".$_}=sort(@{"T".$_});
        	}
        $date=`date +%Y`;        	        	}
        foreach $annee (@annee){ # pour chaque annee on a un tableau
                %total="";
                print "<br><center>\n<table border=1 cellspacing=0 ";
                #print "bordercolor=";
                $c=$date-$annee;
                #print ${"coul".$c};
                print " width=80%>"; 
                
        	print "<tr bgcolor=";
        	print ${"coul".$c};
        	print "><td colspan=";
        	print $#{"A".$annee}+2;
        	print " align=center><font color=white><b>",$annee,"</td></tr><tr><td>&nbsp;</td>";
        	foreach $dev (@{"A".$annee}){ # ligne des devises , une par colonne
        		 

			($nul,$nul,$nul,$nul,$nul,$lib_dev)=split (/;/,@pays_dat[$pays_idx{$dev}]); # on recupere le cour facuration 
        		 print "<td align=center><font size=2><b>",$lib_dev,"</font></td>";        	
        	}
        	print "</tr>\n";
        	foreach $type (@{"T".$annee}){ # 2 groupe corps diplo et autres
        		if ($type ==1){ # corps diplo
        			foreach $pays (@{"P".$annee}){ # ligne des clients un par ligne
        				if ($pays==1){$lib_pays="France";}
        				if ($pays==6){$lib_pays="Angleterre";}
        				if ($pays==7){$lib_pays="Suisse";}
        				if ($pays==2){$lib_pays="Autre";}
        		
        				print "<tr><td>",$lib_pays,"</td>";
        				foreach $dev (@{"A".$annee}){ # valeur des reste du , un par colonne-devise
        					print "<td align=right>";
        					print &separateur($stat{$annee.";".$pays.";"."1".";".$dev});
        					$total{$dev}+=$stat{$annee.";".$pays.";"."1".";".$dev};
        					print "</td>";

        				}
        				print "</tr>";
        			}
        		print "<tr bgcolor=#e8e8e8><td><b>Total</td>";
                        foreach $dev (@{"A".$annee}){ # total corps diplo un par colonne-devise
        					print "<td align=right><b>";
        					print &separateur($total{$dev});
        					print "</td>";
        				}
                        %total="";
                        print "</tr>";
                        
                        }
                        if ($type==2){ # autres grossistes
                                print "<tr><td>Clients Non Corps Diplomatique</td>";
        			foreach $dev (@{"A".$annee}){ # valeur des reste du , un par colonne-devise
        				print "<td align=right>";
        				print &separateur($stat{$annee.";"."1".";"."2".";".$dev});
        				     				
					$total{$dev}+=$stat{$annee.";"."1".";"."2".";".$dev};
        				print "</td>";

        			}
        			print "</tr>";
        			print "<tr bgcolor=#e8e8e8><td><b>Total</td>";
                        	foreach $dev (@{"A".$annee}){ # total corps diplo un par colonne-devise
        					print "<td align=right><b>";
        					print &separateur($total{$dev});
        					print "</td>";
        				}
                                 
        		}
        	}
        	
        print "</table>";
        }
        
        # print @annee,@1999;
         
        # print "1995 francais franc francais corps diplo:";
        # print "1996 francais franc francais corps diplo:";
        # print $stat{"1996;1;1;1"};
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
 

########################## FIN TABLEAU ########################
# fin du client affichage du total

sub fin_tableau {
  	&affiche( "<tr><td colspan=7 align=right><font size=2><b>TOTAL</td><td align=right><font size=2><b> ");
  	                        if ($totaleu ne 0){
  	                        	&affiche( &separateur($totaleu));
  	                        	&affiche("  EU");
  	                		$total_page+=$totaleu;
  	                        }
  	                        if ($totalff ne 0){
  	                        	&affiche("<br>");
  	                        	&affiche( &separateur($totalff));
  	                        	&affiche("  FF");
  	                        	$total_page+=$totalff/6.55957;
  	                        
  	                        }
		        	&affiche("</td><td>&nbsp;</td></tr>");
		        	$total_euro+=$totaleu;
		        	$totalff=$totaleu=0;
	&affiche("</table><br><table width=100% border=1 cellspacing=0>");
}
####################    TEST FOURCHETTE ##################
# verification des criteres client
sub fourchette { 
	my ($var)=@_;
	my ($autorise)="oui";
	if (($pays_francais ne "on") && ($var < 2000000)){$autorise="non";}
	if (($pays_anglais ne "on") && ( ($var >= 6000000) && ($var < 7000000) )) {$autorise="non";}
	if (($pays_suisse ne "on") && ( ($var >= 7000000) && ($var < 8000000) )) {$autorise="non";}
	if ( ($pays_autres ne "on")   &&   (  ($var >= 8000000) || ( ($var >= 2000000)&&($var <6000000) ) ) ) {$autorise="non";}
        if ( ($type_autres ne "on")   &&   (  ($var < 1010000) || ( ($var >= 1900000)&&($var <2000000) ) ) ) {$autorise="non";}
        if ( ($type_cd ne "on")   &&   (  ($var >= 2000000) || ( ($var >= 1010000)&&($var <1900000) ) ) ) {$autorise="non";}
        $der3=$var%1000;
        if ($type_unesco eq "on"){
        	if (($der3 >= 700) && ($der3 <=703) && ($var <2000000)){
        	$autorise="oui";
        	}
        	else{ 
        	$autorise="non";}
        	}
        	
        return($autorise);                                                	
		
	}
	
################### TEST FOURCHETTE 2 ############
# retourne le type de client

sub fourchette2 {
my ($var)=@_;
	my ($pays,$type);
	$type=2;
	$pays=1;
	if ($var < 2000000){$pays=1};
	if ( ($var >= 6000000) && ($var < 7000000) ) {$pays=6;}
	if ( ($var >= 7000000) && ($var < 8000000) ) {$pays=7;}
	if ( ($var >= 8000000) || ( ($var >= 2000000)&&($var <6000000) ) )  {$pays=2;}
	if ( ($var < 1010000) || ( ($var >= 1900000)&&($var <2000000) ) )  {$type=2;}
        else {$type=1;}
        return($pays.";".$type);
        } 
####################    TEST DATE ##################
# verification des criteres date
sub test_date { 
	my ($var)=@_;
	my ($autorise)="oui";
        my ($annee)=substr ($ec_dt,length($ec_dt)-2,2)+1900;
       
        if ($annee<1980){$annee=$annee+100;}
	if (grep /$annee/,@date_invalide){$autorise="non";}
	if ($annee<$date_mini){$autorise="non";}
	return($autorise);                                                	
		
	}	
####################    TEST INTERDIT ##################
# verification des criteres relance interdite
sub test_interdit { 
	my ($autorise)="oui";
    if ($interdit eq "on"){
		if (($archrel_idx{$ec_no_fact} ne "")||($archrelibs_idx{$ec_no_fact} ne "")||($archrel_li_idx{$ec_no_fact} ne "")){
			$autorise="non";
		}
    }
    if ($queinterdit eq "on"){
		if (($archrel_idx{$ec_no_fact} eq "")&&($archrelibs_idx{$ec_no_fact} eq "")&&($archrel_li_idx{$ec_no_fact} eq "")){
    		$autorise="non";}
	}
	
	return($autorise);                                                	
	
}	
	
####################    TEST REGLE ##################
# verification des criteres facture reglée
sub test_regle { 
	my ($autorise)="oui";
    	if (($regle ne "on")&&(($ec_mont-$ec_reg)==0)){$autorise="non";}
    	return($autorise);                                                	
}	

	
#################### AFFICHE ##################
# permet d'afficher ou nom le tableau

sub affiche {
	my ($var)=@_;
	if ( $aff eq "on"){
		if ($compt>$max_ligne){
			print "</table><center><font size=5 color=red>STOP VOTRE REQUETE A GENERE TROP DE LIGNE</font>";
			print "<br>merci de limiter votre choix ou de ne faire que le caclul</br>";
			&pied();
			
			exit;
		}
	print $var;
	}
}		

sub affiched {
	my ($var)=@_[0];
	my ($type_var)=@_[1];
	if (($det eq "on") && ($aff eq "on")){
		if ($compt>$max_ligne){
			print "</table><center><font size=5 color=red>STOP VOTRE REQUETE A GENERE TROP DE LIGNE</font>";
			print "<br>merci de limiter votre choix ou de ne faire que le caclul</br>";
			&pied();
			
			exit;
		}
	if($type_var eq "num"){
		printf "%10.2f",$var;
	}else{
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

	if (param=="fo2"){document.choix.inconnu.checked=false;
		}
}
function modif2c(param)
{       
	if (param=="p"){
		document.choix.tous.checked=false;
		if ((document.choix.pays_francais.checked==false)&&(document.choix.pays_anglais.checked==false)&&(document.choix.pays_suisse.checked==false)&&(document.choix.pays_autres.checked==false)){
			document.choix.tous.checked=true;
			}	
		}
	if (param=="t"){
		document.choix.pays_francais.checked=false;
		document.choix.pays_anglais.checked=false;
		document.choix.pays_suisse.checked=false;
		document.choix.pays_autres.checked=false;
	
	}
        
	
}

function modif2cb(param)
{       
	if (param=="a"){document.choix.toutes.checked=false;
		
	}
	if (param=="t"){
eof

for ($i=0;$i<5;$i++)
{
	print "document.choix.an_",$annee-$i,".checked=false;\n";
}
$i--;
print "document.choix.av_",$annee-$i,".checked=false;\n";

print <<"eof";
			
	}
}      
pos=2; 
function keydown(){
	if (pos=="vrai"){
	k = window.event.keyCode;
	if (k == 13) {
		eval('document.choix.fin.focus()');
		document.choix.inconnu.checked=false;
		return false;}
	}	
	}

document.onkeydown = keydown;
 
</script>
<body bgcolor=white text=black>
eof
&tete("ECHEANCIER","/home/var/spool/uucppublic/echeanc.txt","oui");
print <<"eof";
<form action=echeancier.pl name=choix>

<center><table width=100% border=2 width=100% cellspacing=0 cellpadding=0 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod >

<tr bgcolor=e8e8e8><td align= middle><b>Choix du client ou de la fourchette de client</td><td align=middle><b>Options</td><td align=middle><b>Requête</tr>
<tr>
<td align=middle>Code client ou Pays:<input type=text name=code_client size=8 Onchange=modif1c("fo2") ></td>
<td align=right rowspan=2>
Français <input type=checkbox name=pays_francais Onclick=modif2c("p")><br>
Tous<input type=checkbox name=tous checked Onclick=modif2c("t")>&nbsp;&nbsp;&nbsp;&nbsp; Anglais <input type=checkbox name=pays_anglais Onclick=modif2c("p")><br>
Suisse <input type=checkbox name=pays_suisse Onclick=modif2c("p")><br>
Autres <input type=checkbox name=pays_autres Onclick=modif2c("p")><br>
<br>
Corps diplomatique <input type=checkbox name=type_cd checked><br>

Autres<input type=checkbox name=type_autres checked>
<br><br>
eof


for ($i=0;$i<5;$i++)
{
	if ($i == 2){print "Toutes<input type=checkbox name=toutes checked onclick=modif2cb(\"t\")>&nbsp;&nbsp;&nbsp;&nbsp;";}
	print "année ",$annee-$i," <input type=checkbox name=an_",$annee-$i," onclick=modif2cb(\"a\")><br>";
}
$i--;

print "avant ",$annee-$i," <input type=checkbox name=av_",$annee-$i," onclick=modif2cb(\"a\")>";

print <<"eof";
<br>
</td>

<!-- colonne 3 ->

<td align=middle rowspan=2>
<b>EDITION <input type=checkbox name=print checked>
<b>DETAIL <input type=checkbox name=detail checked>
<br>CALCUL <input type=checkbox name=calcul checked><br>
STATISTIQUE</b><input type=checkbox name=statistique><br><br><br>
<input type=submit value=go></td>

</tr><tr>

<!-- colonne 1 ->

<td align=middle>
Premier Client : <input type=text name=debut size=8 onfocus="pos='vrai';" onblur="pos='false';"><br>
Dernier Client : <input type=text name=fin size=8 Onchange=modif1c("fo2")><br>
<br><br>Unesco <input type=checkbox name=type_unesco >&nbsp;Inconnu <input type=checkbox name=inconnu checked OnClick=modif1c("inc")>
<br><br>BIS <input type=checkbox name=bis checked>&nbsp;IBS <input type=checkbox name=ibs>
<br>Factures soldées<input type=checkbox name=regle> 
<br>Libellé des relances interdites <input type=checkbox name=rel_interdit> <font size=-2>maj 
eof
# &datemod("/home/var/spool/uucppublic/archrel.txt");
print <<"eof";
<br></font>Enlever les factures en relances interdites<input type=checkbox name=interdit> <br>
Que les factures en relances interdites<input type=checkbox name=queinterdit> 
</td></tr></table></form>
<br><img src=http://intranet.dom/creation2000p.gif align=right border=0>
eof


print "</HTML>";
print "</BODY>";
		}


# -E echeancier client 
# -B 13/12/00 sylvain ajout du focus sur code client et tous cocher si aucun pays n'est selectionné
# -B 16/01/01 sylvain ajout de la selection unesco 
