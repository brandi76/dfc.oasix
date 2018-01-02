#!/usr/bin/perl    
use CGI;    
$html=new CGI; 
require 'manip_table.lib';                           # librairie de procedure perl /usr/lib/perl5   
require 'outils_perl.lib';

open(FILE2,"/home/var/spool/uucppublic/client2.txt");
@client_dat = <FILE2>;
close(FILE2);
print $html->header;
print "<body>";
$action=$html->param("action");
if (($action ne "edition") && ($action ne "modifier") && ($action ne "valid_modif")) {&html();} 
elsif($action eq "modifier"){&modification();} 
elsif($action eq "valid_modif"){&valid_modif();} 
else{

$date=`date +%m`;
$date=12;
$lettre=$html->param("lettre");
%caclient1999_idx = &get_index_num("CAclient1999",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient1999.txt");  
@caclient1999_dat = <FILE1>;    
close(FILE1);
%objectif_idx = &get_index_num("objectif",0);                
open(FILE1,"/home/var/spool/uucppublic/objectif.txt");  
@objectif_dat = <FILE1>;    
close(FILE1);

%caclient2001_idx = &get_index_num("CAclient2001",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient2001.txt");  
@caclient2001_dat = <FILE1>;    
close(FILE1);

# open(SAUV,">/home/var/spool/uucppublic/test.txt");  


@total1999=@totalobjectif=@total2001="";
@cal1999_tot=@objectif_tot=@cal2001_tot="";
$premier=$html->param("premier");
$dernier=$html->param("dernier");

@adresse=();
$compt=0;
$total_cl=0;

# pour toutes les lettres existant dans le fichier clients on regarde si elle a ete choisie
foreach (@client_dat){
	($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,$_);
	while ($code_lettre=~s/ //g){}; # astuce
	if ($code_lettre eq ""){$code_lettre="*"};
	if ($html->param("$code_lettre")eq "on"){
		$table_lettre{$code_lettre}+=1;
	}
}

$premier_passage="on";		
	                
for($j=0;$j<=$#client_dat;$j++){
	($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,@client_dat[$j]);
	
	while ($code_lettre=~s/ //g){};
	if ($code_lettre eq ""){$code_lettre="*"};
	$cl_mini=$cl_cd_cl%1000;
	# pour tous les clients dont la lettre a ete choisie
	if (($table_lettre{$code_lettre} ne "")&& ($cl_cd_cl >= $premier) && ($cl_cd_cl <= $dernier)){  
	
		if ( ($cl_mini <600) && ($cl_cd_cl <1800000) ){$cl_cour=substr($cl_cd_cl,0,4);}
		elsif (($cl_mini >699) && ($cl_mini <800) && ($cl_cd_cl <1800000)){$cl_cour=substr($cl_cd_cl,0,5);}
		else {$cl_cour=substr($cl_cd_cl,0,8);}
		# un regroupement est fait en fonction des clients
		if ($premier_passage eq "on"){
			$cl_tampon=$cl_cour;
			$premier_passage="off";
			}
		if (($cl_cour != $cl_tampon)&&($#adresse >=0)) {   # affichage du tableau sur un changement de client
			&affiche_tableau();
		}
		
		@cal_1999=@objectif=@cal_2001="";
	        if ($caclient1999_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_1999)=split(/;/,$caclient1999_dat[$caclient1999_idx{$cl_cd_cl}]);
                }
                                             
                if ($caclient2001_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_2001)=split(/;/,$caclient2001_dat[$caclient2001_idx{$cl_cd_cl}]);
                }
                push (@adresse ,"$cl_cd_cl;$cl_nom;$cl_contact;$cl_rue;$cl_ville;$code_lettre");
                for ($i=0;$i<12;$i++){
                	@cal1999_tot[$i]+=@cal_1999[$i];
                	@cal2001_tot[$i]+=@cal_2001[$i];
                }

	} # fin du test fourchette client
}

if ($#adresse >=0) {   # affichage du tableau sur un fin de fichier
	&affiche_tableau();
}

print "</table><br>\n\n<table width=700 border=1 cellspacing=0>";
 ############### TABLEAU RECAPITULATIF ##################
print "<tr>\n<td nowrap>&nbsp;</td>";
for ($i=1;$i<13;$i++){
				print "<td nowrap><font size=-2><b>",&cal($i,"c"),"</td>";
				}
			
print "<tr>\n<td nowrap><b><font color=gray>1999</td>";
$total=0;
for ($i=0;$i<12;$i++){
	print "<td nowrap><font size=-2 color=gray>",&separateur($total1999[$i]),"</td>";
	$total+=$total1999[$i];
	
}
print "<td nowrap><font size=-2 color=gray><b>",&separateur($total),"</td></tr>";

print "<tr>\n<td nowrap><b>objectif</td>";
$total=0;
for ($i=0;$i<12;$i++){
	print "<td nowrap><font size=-2>",&separateur($totalobjectif[$i]),"</td>";
	$total+=$totalobjectif[$i];
}
print "<td nowrap><font size=-2><b>",&separateur($total),"</td></tr>";

print "<tr>\n<td nowrap><b>2001</td>";
$total=0;
for ($i=0;$i<12;$i++){
	print "<td nowrap><font size=-2>",&separateur($total2001[$i]),"</td>";
	$total+=$total2001[$i];
}
print "<td nowrap><font size=-2><b>",&separateur($total),"</td></tr>";

################# ECART GENERAL ###############
$total=0;
print "<tr>\n<td nowrap><b>Ecart</td>";
$total=0;
for ($i=0;$i<12;$i++){
	$diff=$total2001[$i]-$totalobjectif[$i];
	if ($i<($date-1)){
		print "<td nowrap><font size=-2>",&separateur($diff),"</td>";
		# $total+=$diff;
	}
	else {print "<td nowrap>&nbsp;</td>";}
}
print "<td nowrap><font size=-2><b>",&separateur($total),"</td></tr>";

  			
################ CUMUL GENERAL ###############
$total=0;
print "<tr>\n<td nowrap><b>Cumul</td>";
$total=0;
$cumul=0;
for ($i=0;$i<12;$i++){
	$cumul+=$total2001[$i]-$totalobjectif[$i];
	if ($i<($date-1)){
		print "<td nowrap><font size=-2>",&separateur($cumul),"</td>";
		# $total+=$cumul;
	}
	else {print "<td nowrap>&nbsp;</td>";}
}
print "<td nowrap><font size=-2><b>",&separateur($total),"</td></tr>";
	 	        
print "</table><br>\n\n";
print "<center><a href=suivi-commer.pl>Nouvelle requête</a></center>";
print "</body></html>";
# close (SAUV);
}
                                   ############## PROCEDURE ###################
                                   
                                   
############# AFFICHAGE DU TABLEAU ##############

sub affiche_tableau {
print "<br>\n\n<center><table border=1 width=100% frame=box rules=none bordercolor=BLACK>";

# liste des clients
$codetamp="null";
foreach (@adresse){
	($cl,$add,$contact,$rue,$ville,$code)=split(/;/,$_);
	print "<tr>\n<td nowrap><font size=-2>";
	if (($codetamp ne $code)&& ($codetamp ne "null")){
		print "<font color=red>ERREUR</font>";
		}
	else {$codetamp=$code;}
	if($code ne ""){
		print "$code";
	}else{
		print "*";
	}
	print "</td><td nowrap><font size=-2>$cl</td><td nowrap><font size=-2>$add</td><td nowrap><font size=-2>$contact</td><td nowrap><font size=-2>$rue</td><td nowrap><font size=-2>$ville</td></tr>\n";
}

print "<tr>\n<td colspan=6 align=center>";
print "<table border=1 width=90% cellspacing=0 cellpadding=0><tr>\n<td nowrap width=55>&nbsp;</td>";
# entete des mois
for ($i=1;$i<13;$i++){
	print "<td nowrap width=55><font size=-2><b>",&cal($i,"c"),"</td>";
}

print "<td nowrap width=60><font size=-2><b>Total en euro</td></tr>";

# ligne 1999

print "<tr>\n<td nowrap><font size=-2 color=gray><b>1999</td>";
$total_ligne="";

# print SAUV "$cl_tampon;";
for ($i=0;$i<12;$i++){
	if ($cal1999_tot[$i] eq ""){
		print "<td nowrap>&nbsp;</td>";
	}
	else{
	 	print "<td nowrap align=right><font size=-2 color=gray>",&separateur($cal1999_tot[$i]),"</td>";
	 	$total_ligne+=$cal1999_tot[$i];
	 	$total1999[$i]+=$cal1999_tot[$i];
                # print SAUV "$cal1999_tot[$i];";
	}
}
# print SAUV "\n";
print "<td nowrap align=right><font size=-2 color=gray><b>",&separateur($total_ligne),"</td>";
$bug=$total_ligne;
print "</tr>";

# ligne objectif

print "<tr>\n<td nowrap><font size=-2><b><a href=suivi-commer.pl?action=modifier&code=$cl_tampon>objectif</td>";
$total_ligne="";
@objectif=();
if ($objectif_idx{$cl_tampon} ne ""){
($cl2_cd_cl,@objectif)=split(/;/,$objectif_dat[$objectif_idx{$cl_tampon}]);
}

for ($i=0;$i<12;$i++){
	if ($objectif[$i] eq ""){
		print "<td nowrap>&nbsp;</td>";
	}
	else{
	 	print "<td nowrap align=right><font size=-2>";
	 	print &separateur($objectif[$i]),"</td>";
	 	$total_ligne+=$objectif[$i];
	 	$totalobjectif[$i]+=$objectif[$i];
        }
}
print "<td nowrap align=right><font size=-2><b>",&separateur($total_ligne);
# if ($bug ne $total_ligne) {print "<font color=red>WASAAAAAAAAA";}
print "</td>";
print "</tr>";

# ligne 2001

print "<tr>\n<td nowrap><font size=-2><b>2001</td>";
$total_ligne="";

for ($i=0;$i<12;$i++){
	if ($cal2001_tot[$i] eq ""){
		print "<td nowrap>&nbsp;</td>";
	}
	else{
	 	print "<td nowrap align=right><font size=-2>",&separateur($cal2001_tot[$i]),"</td>";
	 	$total_ligne+=$cal2001_tot[$i];
	 	$total2001[$i]+=$cal2001_tot[$i];
	}
}

print "<td nowrap align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
print "</tr>";
  			
  			################# ECART ###############
  			
print "<tr>\n<td nowrap><font size=-2><b>Ecart</td>";
$total_ligne="";

for ($i=0;$i<12;$i++){
	$diff=$cal2001_tot[$i]-$objectif[$i];
	if ($i<$date){
		print "<td nowrap align=right><font size=-2>",&separateur($diff),"</td>";
	 	#$total_ligne+=$diff;
	}
	else {print "<td nowrap>&nbsp;</td>";}
}

print "<td nowrap align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
print "</tr>";
			
			################# CUMUL ###############
  			
print "<tr>\n<td nowrap><font size=-2><b>Cumul</td>";
$total_ligne="";
$cumul=0;

for ($i=0;$i<12;$i++){
	$cumul+=$cal2001_tot[$i]-$objectif[$i];
	if ($i<($date-1)){
		print "<td nowrap align=right><font size=-2>",&separateur($cumul),"</td>";
	 	#$total_ligne+=$cumul;
	}
	else {print "<td nowrap>&nbsp;</td>";}
        		
}
print "<td nowrap align=right><font size=-2><b>",&separateur($total_ligne),"</td>";
print "</tr>";
print "</table></td>";
$cl_tampon=$cl_cour;
@cal1999_tot=@cal2001_tot=@objectif_tot="";
$total_cl=0;
@adresse=(); 	
print "</tr>";
}


					########### MODIFICATION ##############

sub modification
{
	&tete("SUIVI DES CHIFFRES D'AFFAIRE MODIFICATION","/home/var/spool/uucppublic/objectif.txt");

$date=`date +%m`;
$date=12;
%caclient1999_idx = &get_index_num("CAclient1999",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient1999.txt");  
@caclient1999_dat = <FILE1>;    
close(FILE1);
%objectif_idx = &get_index_num("objectif",0);                
open(FILE1,"/home/var/spool/uucppublic/objectif.txt");  
@objectif_dat = <FILE1>;    
close(FILE1);

%caclient2001_idx = &get_index_num("CAclient2001",0);                
open(FILE1,"/home/var/spool/uucppublic/CAclient2001.txt");  
@caclient2001_dat = <FILE1>;    
close(FILE1);


@total1999=@totalobjectif=@total2001="";
@cal1999_tot=@objectif_tot=@cal2001_tot="";
@adresse=();
$compt=0;
$total_cl=0;

$code=$html->param("code");

$premier_passage="on";		
	                
print "<form name=modif action=suivi-commer.pl>";
print "<input type=hidden name=action value=valid_modif>";	               
print "<input type=hidden name=code value=$code>";	               

for($j=0;$j<=$#client_dat;$j++){
	($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,@client_dat[$j]);
	$cl_mini=$cl_cd_cl%1000;
	if (($cl_mini <600)&&($cl_cd_cl <1800000)){$cl_cour=substr($cl_cd_cl,0,4);}
	else {$cl_cour=substr($cl_cd_cl,0,8);}
	if ($cl_cour eq $code){
		if ($premier_passage eq "on"){
			print "<input type=hidden name=code_cour value=$cl_cour>";	               
			$cl_tampon=$cl_cour;
			$premier_passage="off";
			}
		if (($cl_cour != $cl_tampon)&&($#adresse >=0)) {   # affichage du tableau sur un changement de client
			&affiche_tableau_m();
		}
		
		@cal_1999=@objectif=@cal_2001="";
	        if ($caclient1999_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_1999)=split(/;/,$caclient1999_dat[$caclient1999_idx{$cl_cd_cl}]);
                }
                                             
                if ($caclient2001_idx{$cl_cd_cl} ne ""){
			($cl2_cd_cl,@cal_2001)=split(/;/,$caclient2001_dat[$caclient2001_idx{$cl_cd_cl}]);
                }
                push (@adresse ,"$cl_cd_cl;$cl_nom;$cl_contact;$cl_rue;$cl_ville;$code_lettre");
                for ($i=0;$i<12;$i++){
                	@cal1999_tot[$i]+=@cal_1999[$i];
                	@cal2001_tot[$i]+=@cal_2001[$i];
                }

	} # fin du test fourchette client
}

if ($#adresse >=0) {   # affichage du tableau sur un fin de fichier
	&affiche_tableau_m();
}

print "</table>";
print "<center><br>\n\n<input type=submit value=valider></form><br>\n\n";

print "<center><a href=suivi-commer.pl>Nouvelle requête</a></center>";
print "</body></html>";
}

###################### TABLEAU POUR LA SAISIE DES OBJECTIFS ##############

sub affiche_tableau_m {
print "<br>\n\n<br>\n\n<br>\n\n<br>\n\n<center><table border=2 width=100% frame=box rules=none>";

# liste des clients

foreach (@adresse){
	($cl,$add,$contact,$rue,$ville,$code)=split(/;/,$_);
	print "<tr>\n<td nowrap><font size=-1>";
	if($code ne ""){
		print "$code";
	}else{
		print "*";
	}
	print "</td><td nowrap><font size=-1>$cl</td><td nowrap><font size=-1>$add</td><td nowrap><font size=-1>$contact</td><td nowrap><font size=-1>$rue</td><td nowrap><font size=-1>$ville</td></tr>\n";
}

print "<tr>\n<td colspan=5 align=center>";
print "<table border=1 width=90% height=100%><tr>\n<td nowrap>&nbsp;</td>";
# entete des mois
for ($i=1;$i<13;$i++){
	print "<td nowrap><font size=-1><b>",&cal($i,"c"),"</td>";
}

print "<td nowrap><font size=-1><b>Total en Euro</td></tr>";

# ligne 1999

print "<tr>\n<td nowrap><font size=-1 color=gray><b>1999</td>";
$total_ligne="";

for ($i=0;$i<12;$i++){
	if ($cal1999_tot[$i] eq ""){
		print "<td nowrap>&nbsp;</td>";
	}
	else{
	 	print "<td nowrap align=right><font size=-1 color=gray>",&separateur($cal1999_tot[$i]),"</td>";
	 	$total_ligne+=$cal1999_tot[$i];
	 	$total1999[$i]+=$cal1999_tot[$i];
	}
}
print "<td nowrap align=right><font size=-1 color=gray><b>",&separateur($total_ligne),"</td>";
print "</tr>";

# ligne objectif

print "<tr>\n<td nowrap><font size=-1><b>objectif</td>";
$total_ligne="";
($cl2_cd_cl,@objectif)=split(/;/,$objectif_dat[$objectif_idx{$cl_tampon}]);


for ($i=0;$i<12;$i++){
	
	 	print "<td nowrap align=right><font size=-1>";
	 	print "<input type=text size=8 name=mois$i value=$objectif[$i]></td>";
	 	$total_ligne+=$objectif[$i];
	 	$totalobjectif[$i]+=$objectif[$i];
}
print "<td nowrap align=right><font size=-1><b>",&separateur($total_ligne),"</td>";
print "</tr>";

# ligne 2001

print "<tr>\n<td nowrap><font size=-1><b>2001</td>";
$total_ligne="";

for ($i=0;$i<12;$i++){
	if ($cal2001_tot[$i] eq ""){
		print "<td nowrap>&nbsp;</td>";
	}
	else{
	 	print "<td nowrap align=right><font size=-1>",&separateur($cal2001_tot[$i]),"</td>";
	 	$total_ligne+=$cal2001_tot[$i];
	 	$total2001[$i]+=$cal2001_tot[$i];
	}
}

print "<td nowrap align=right><font size=-1><b>",&separateur($total_ligne),"</td>";
print "</tr>";
  			
  			################# ECART ###############
  			
print "<tr>\n<td nowrap><font size=-1><b>Ecart</td>";
$total_ligne="";

for ($i=0;$i<12;$i++){
	$diff=$cal2001_tot[$i]-$objectif[$i];
	if ($i<$date){
		print "<td nowrap align=right><font size=-1>",&separateur($diff),"</td>";
	 	#$total_ligne+=$diff;
	}
	else {print "<td nowrap>&nbsp;</td>";}
}

print "<td nowrap align=right><font size=-1><b>",&separateur($total_ligne),"</td>";
print "</tr>";
			
			################# CUMUL ###############
  			
print "<tr>\n<td nowrap><font size=-1><b>Cumul</td>";
$total_ligne="";
$cumul=0;

for ($i=0;$i<12;$i++){
	$cumul+=$cal2001_tot[$i]-$objectif[$i];
	if ($i<($date-1)){
		print "<td nowrap align=right><font size=-1>",&separateur($cumul),"</td>";
	 	#$total_ligne+=$cumul;
	}
	else {print "<td nowrap>&nbsp;</td>";}
        		
}
print "<td nowrap align=right><font size=-1><b>",&separateur($total_ligne),"</td>";
print "</tr>";
print "</table></td>";
$cl_tampon=$cl_cour;
@cal1999_tot=@cal2001_tot=@objectif_tot="";
$total_cl=0;
@adresse=(); 	
print "</tr>";
}


########### PREMIERE PAGE #############
	


sub html
{
	&tete("SUIVI DES CHIFFRES D'AFFAIRE <a href=http://intranet.dom/cgi-bin/majCAclient2001.pl>init</a> ","/home/var/spool/uucppublic/CAclient2001.txt");
	print "<form name=commer action=suivi-commer.pl><input type=hidden name=action value=edition>";
	print "<br>\n\n<br>\n\n";
	print "<center>Premier client <input type=text size=8 name=premier value=0><br>\n\nDernier Client <input type=text size=8 name=dernier value=9999999><br>\n\n</center><br>\n\n";
	print "<table width=100% border=2 cellspacing=0 cellpadding=0 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod >";

	foreach (@client_dat){
		($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,$_);
		$code_lettre=~s/ +//g;
		if ($code_lettre eq ""){$code_lettre="*"};
		$table_lettre{$code_lettre}+=1;
	}
	@index = sort keys(%table_lettre); # astuce 
	open(FILE1,"/home/var/spool/uucppublic/commer.txt"); # permet de recuprer les noms des comemrciaux affecte a une lettre  
	@commer_dat = <FILE1>;
	close (FILE1);
	
	foreach (@commer_dat){
		($nom,@liste)=split(/;/,$_);
		print "<tr>\n<td align=center>$nom</td><td align=center>";
		foreach ($i=0;$i<$#liste;$i++){
			print "@liste[$i] <input type=checkbox name=@liste[$i]><br>\n\n";
			$liste_ok{@liste[$i]}="ok"; # je sauvegarde la liste des lettre sui ont etet affichee
       		}
       		print "</td></tr>";			    
        
        }
        print "<tr>\n<td align=center>AUTRES</td><td align=center>";
        
	foreach (@index)
	{
		# pour tous les elements de la listetrie qui n'a pas encore ete affichie on affiche
		if ($liste_ok{$_} eq ""){
			print "$_ <input type=checkbox name=$_>";
			# print "<font size=-2>$table_lettre{$_} clients</font>"
			print "<br>\n\n";
		}
	} 
	print "</td><tr>\n</table><br>\n\n<center><Input type=submit value=valider></form>";
	
}
	
########### SAUVEGARDE DES MODIFICATIONS #####################
sub valid_modif
{
$code=$html->param("code");
open(FILE1,"/home/var/spool/uucppublic/objectif.txt");  
@objectif_dat = <FILE1>;    
close(FILE1);
open(FILE1,">/home/var/spool/uucppublic/objectif.txt");  
foreach (@objectif_dat){
	($cl_cd_cl,@objectif)=split(/;/,$_);
	if ($cl_cd_cl eq $code){
		print FILE1 "$code;";
		for ($i=0;$i<12;$i++){
          
			print FILE1 $html->param("mois$i"),";";
		}
	}
	else {
		print FILE1 "$cl_cd_cl;";
		for ($i=0;$i<$#objectif;$i++){
			print FILE1 "$objectif[$i];";
		}
	}
	print FILE1 "\n";
}
close (FILE1);
print "<html><body><br>\n\n<br>\n\n<center><form action=suivi-commer.pl>Modification pris en compte <br>\n\n<input type=submit value=retour>";
print "<input type=hidden name=action value=modifier>";
print "<input type=hidden name=code value=$code>";
print "</form></body></html>";
#exec ("http://sylvain.dom/cgi-bin/suivi-commer.pl?action=modifier\&code=$code");
}
# -E suivi des chiffre d'affaire des commerciaux