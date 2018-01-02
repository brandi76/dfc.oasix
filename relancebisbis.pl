#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table2.lib";
require "../oasix/outils_perl2.lib";
print $html->header;

%client_idx = &get_index_num("client2",0);
open(FILE2,"/home/var/spool/uucppublic/client2.txt.relance");
@client_dat=<FILE2>;
close(FILE2);

# client qui ne sont pas relance
%non_relance_idx = &get_index_num("non_relance",0);

# relance interdite fichier arix
%archrel_idx = &get_index_multiple("archrel",0);
open(FILE2,"/home/var/spool/uucppublic/archrel.txt.relance");     
@archrel_dat = <FILE2>;
close (FILE2);

# relance interdite fichier linux
%archrel_li_idx = &get_index_multiple("rel-interditbis",1);
open(FILE2,"/home/var/spool/uucppublic/rel-interditbis.txt.relance");     
@archrel_li_dat = <FILE2>;
close (FILE2);

%echeancier_idx = &get_index_multiple("echeanc",0);
open(FILE2,"/home/var/spool/uucppublic/echeanc.txt.relance");
@echeancier_dat=<FILE2>;
close(FILE2);

# fichier contenant les regroupements
%relance_idx = &get_index_num("relancebis",0);
open(FILE2,"/home/var/spool/uucppublic/relancebis.txt.relance");     
@relance_dat = <FILE2>;
close (FILE2);

%pays_idx = &get_index_num("pays",0);
open(FILE2,"/home/var/spool/uucppublic/pays.txt.relance");     
@pays_dat = <FILE2>;
close (FILE2);

$date = `/bin/date '+%d%m%y'`;   
chop($date);  

$code_client=$html->param("code_client");
$action=$html->param("action");  # action a faire modifier,ajouter, lettres etc..
$niveau=$html->param("niveau"); # niveau de relance 1 rappel , 2 rappel etc ..
# couleur de degradé
$coul0=black;
$coul1=red;
$coul2=blue;
$coul3=green;
$coul4=brown;
$coul5=orange;

if ($niveau eq "rappel1"){$ref=&nbjour($date)-22;}
if ($niveau eq "rappel2"){$ref=&nbjour($date)-36;}
if ($niveau eq "rappel3"){$ref=&nbjour($date)-43;}
if ($niveau eq "rappel4"){$ref=&nbjour($date)-57;}
if ($niveau eq "rappel5"){$ref=&nbjour($date)-71;}

print "<html><head><TITLE>Relance B.I.S.</TITLE>";
print "<STYLE type=\"text/css\" >
H1 { page-break-after : right }          
span.police { font-family:\"Time New Roman\"}
span.taille1 {font-size=54px}
span.taille2 {font-size=18px}
span.taille3 {font-size=14px}
span.taille4 {font-size=12px}
span.taille5 {font-size=16px}

 </STYLE></head>";
print "<body";
if (($action eq "rappel1")||($action eq "rappel2")||($action eq "rappel3")||($action eq "rappel4")||($action eq "rappel5")){
	print " link=red vlink=black";
}
print " topmargin='3'>";
# premiere page choix de la relance a faire
if ($action eq ""){&html();}

# creation des lettres
if ($action eq "creation"){&crelettre();}

# rappel telephonique
if ($action eq "telph") {
	# pour les factures du client qui ont ete cochées il y a une mise a jour du fichier de la relance correspondante 
	(*table,$code)=&selecte_n(*echeancier_dat,1,$code_client);
	foreach (@table){
		($client,$facture)=split(/;/,$_);
		$facture+=0;
		if ($html->param($facture) eq "on"){
			$ligne=$code_client.";".$facture.";".$date.";";
			&ajoute_n("/home/var/spool/uucppublic/relance-3bis.txt.relance",$ligne,1);
		}
	}
	$action="rappel3";
}

if (($action eq "rappel1")||($action eq "rappel2")||($action eq "rappel3")||($action eq "rappel4")||($action eq "rappel5")){
	# liste des clients à traiter
	&listedesclients();
	}

# modification du code regroupage
$user = &user();
if ($action eq "modification") {
	(*table,$code)=&selecte_n(*echeancier_dat,1,$code_client);
	foreach (@table){
		($client,$facture)=split(/;/,$_);
		$facture+=0;
		if ($html->param($facture)ne""){
			$ligne=$facture.";".$html->param($facture).";$user;";
			&ajoute_n("/home/var/spool/uucppublic/relancebis.txt.relance",$ligne,0);
		}
	}
	%relance_idx = &get_index_num("relancebis",0);
	open(FILE2,"/home/var/spool/uucppublic/relancebis.txt.relance");     
	@relance_dat = <FILE2>;
	close (FILE2);
	&selection();
}

if ($action eq "selection") { 
	&selection();
}

sub selection {
if ($niveau eq "rappel1"){&tete("Premier rappel","/home/var/spool/uucppublic/echeanc.txt.relance");}
if ($niveau eq "rappel2"){&tete("Deuxieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }
if ($niveau eq "rappel3"){&tete("Troisieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }
if ($niveau eq "rappel4"){&tete("Quatrieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }
if ($niveau eq "rappel5"){&tete("Cinquieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }

print "<br><br>";
%rappel1_idx = &get_index_num("relance-1bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-1bis.txt.relance");     
@rappel1_dat = <FILE2>;
close (FILE2);
%rappel2_idx = &get_index_num("relance-2bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-2bis.txt.relance");     
@rappel2_dat = <FILE2>;
close (FILE2);
%rappel3_idx = &get_index_num("relance-3bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-3bis.txt.relance");     
@rappel3_dat = <FILE2>;
close (FILE2);
%rappel4_idx = &get_index_num("relance-4bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-4bis.txt.relance");     
@rappel4_dat = <FILE2>;
close (FILE2);
%rappel5_idx = &get_index_num("relance-5bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-5bis.txt.relance");     
@rappel5_dat = <FILE2>;
close (FILE2);
open(FILE2,"/home/var/spool/uucppublic/motif.txt.relance");     
@motif_dat = <FILE2>;
close (FILE2);
	

################### chargement d'une table avec les pointeurs sur les  comptes à traiter ################
if ($echeancier_idx{$code_client}ne""){
	(@ECHEANCIER)=split(/;/,$echeancier_idx{$code_client});
    }

#############" edition de l'entete ####################        

if ($client_idx{$code_client} eq ""){
       	$cl_add="<font color=green>CLIENT INCONNU</font>";
       	$cl_service=$cl_ville=$cl_rue="";}

	else{($cl_cd_cl,$cl_add,$cl_contact,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,@client_dat[$client_idx{$code_client}]);}
	print "<center><table border=1><tr><td><font color=red>$code_client</font></td><td colspan=13><font color=black>Client:<font color=red>$cl_add</td></tr>";
        print "<tr bgcolor=#e8e8e8><td><font size=-2>facture</td><td><font size=-2>regroupement</td><td align=middle><font size=-2>Nom</td><td><font size=-2>Date de facture</td><td><font size=-2>Montant </td><td><font size=-2>montant reglé </td><td><font size=-2>date du reglement</td><td><font size=-2>Montant en devise</td><td><font size=-2>reste </td><td><font size=-2>reste en devise</td><td colspan=5><font size=-2>relance</td></tr>\n";

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
print "<form name=modif action=relancebisbis.pl>";
print "<input type=hidden name=action value=modification>";
print "<input type=hidden name=code_client value=$code_client>";
foreach (@tab){
	($lien,$indice,$ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
	$diff=$lien%6;
	$ec_no_fact+=0;
	if ($diff==0){$couleur=$coul0;}
	if ($diff==1){$couleur=$coul1;}
      	if ($diff==2){$couleur=$coul2;}
      	if ($diff==3){$couleur=$coul3;}
      	if ($diff==4){$couleur=$coul4;}
      	if ($diff==5){$couleur=$coul5;}
      	$gris="white";
      	if ($lien == 0){$gris="#efefef";}
      	$fluo="white";	
	if (&nbjour($ec_dt)==$ref){$fluo="#00FFCC";}
      	
	print "<tr bgcolor=$gris><td align=right><font size=2 color=$couleur><a href=rel-interdit.pl?facture=$ec_no_fact&action=motif&niveau=$niveau>$ec_no_fact</a></td>";

	print "<td align=middle><b><input type=text size=3 name=$ec_no_fact value=$lien></td>";

	print "<td align=middle bgcolor=$fluo><font size=2 color=$couleur>$ec_nom</td><td align=right><font size=2 color=$couleur>";
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
	print " $dev</td>"; 

	if ($rappel1_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel1_dat[$rappel1_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance1.gif border=0 align=top height=20><br><font size=-2>$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	if ($rappel2_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel2_dat[$rappel2_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance2.gif border=0 align=top height=20><br><font size=-2>$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	if ($rappel3_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel3_dat[$rappel3_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance3.gif border=0 align=top height=20><br><font size=-2>$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	if ($rappel4_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel4_dat[$rappel4_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance4.gif border=0 align=top height=20><br><font size=-2>$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}

	if ($rappel5_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel5_dat[$rappel5_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance5.gif border=0 align=top height=20><br><font size=-2>$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}	
	print "</tr>";
	
	# gestion des relances interdites fichier arix et fichier saisie sur linux
	
	@liste=split(/;/,$archrel_li_idx{$ec_no_fact});
	foreach (@liste) {
		(@ligne)=split(/;/,$archrel_li_dat[$_]);
		($motif)=split(/;/,$motif_dat[$ligne[4]]);
		print &ligne_tab("","le $ligne[2]","Blocage fait par $ligne[3]","Motif:<b>$motif</b>","Commentaire: <b>$ligne[5]</b>");
	} 
	if ($archrel_idx{$ec_cd_cl} ne ""){
		@liste=split(/;/,$archrel_idx{$ec_cd_cl});
		foreach (@liste){
			($code,$facture,$date3,$etat,$desi)=split (/;/,$archrel_dat[$_]);
			if ($facture == $ec_no_fact){	
				print "<tr bgcolor=$gris><td colspan=9 align=center><font size=2 color=$couleur size=+2>ATTENTION RELANCE INTERDITE :<b>$desi</td></tr>";
				}
		}
			
	}

	
}

print "</table><br><center>";
print "<input type=hidden name=niveau value=$niveau>";
print "<input type=submit value=modifier></form>";
	
if ($niveau eq "rappel1"){
	print "<br><form action=relancebisbis.pl><center>";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=niveau value=$niveau>";
	print "<input type=hidden name=code_client value=$code_client>";
	print "<input type=submit value=\"creer les lettres de premier rappel\"></form>";
}
if ($niveau eq "rappel2"){
	print "<br><form action=relancebisbis.pl><center>";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=niveau value=$niveau>";
	print "<input type=hidden name=code_client value=$code_client>";
	print "<input type=submit value=\"creer les lettres de deuxieme rappel\"></form>";
}
if ($niveau eq "rappel3"){
	print "<br><form action=relancebisbis.pl><center>";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=niveau value=$niveau>";
	print "<input type=hidden name=code_client value=$code_client>";
	print "<input type=submit value=\"creer la liste des appels telephoniques\"></form>";
}
if ($niveau eq "rappel4"){
	print "<br><form action=relancebisbis.pl><center>";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=niveau value=$niveau>";
	print "<input type=hidden name=code_client value=$code_client>";
	print "<input type=submit value=\"Creer les lettres de Quatrième Relance\"></form>";
}
if ($niveau eq "rappel5"){
	print "<br><form action=relancebisbis.pl><center>";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=niveau value=$niveau>";
	print "<input type=hidden name=code_client value=$code_client>";
	print "<input type=submit value=\"Creer les lettres de Quatrième Relance\"></form>";
}

print "</body></html>";
close (relance);
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

					# CRELETTRE #
sub crelettre {

# Recuperation de la table d'index de tous les comptes de l'ambassade
if ($echeancier_idx{$code_client}ne""){
	(@ECHEANCIER)=split(/;/,$echeancier_idx{$code_client});
    }

# Recuperation de l'adresse de l'ambassade        

if ($client_idx{$code_client} eq ""){
       	$cl_add="<font color=green>CLIENT INCONNU</font>";
       	$cl_service=$cl_ville=$cl_rue="";}
	else{($cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,@client_dat[$client_idx{$code_client}]);}
        if ($cl_service eq $cl_add){$cl_service="";};

# creation d'une table avec les comptes de l'ambassade possedant un numero de regroupement (tab)
# creation d'une table avec uniquement les regroupements dans lequel il y a une facture du jour a traitée (afaire) 
foreach (@ECHEANCIER){
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$echeancier_dat[$_]);
	$ec_cd_cl+=0;
	$lien=0;
	$ec_no_fact+=0;
	$ec_dt+=0;
	$ec_mont+=0;
	$ec_reg+=0;
	$reste=$ec_mont-$ec_reg;
	if ($reste<0){$reste*=-1;}
	if (($relance_idx{$ec_no_fact} ne "")&&($reste >2)){
		($facture,$lien)=split(/;/,$relance_dat[$relance_idx{$ec_no_fact}]);
	}

	if ($lien != 0){
		push (@tab,"$lien;$echeancier_dat[$_];");
		if (&nbjour($ec_dt)==$ref){
			$afaire{$lien}="$ec_nom"; 
		}
	}	
}        		

# edition des lettres par regroupement
		
if ($niveau eq "rappel1"){$file="/home/var/spool/uucppublic/relance-1bis.txt.relance";}
if ($niveau eq "rappel2"){$file="/home/var/spool/uucppublic/relance-2bis.txt.relance";}
if ($niveau eq "rappel3"){
	print "<form name=telph action=relancebisbis.pl>";
	print "<input type=hidden name=niveau value=rappel3>";
	print "<input type=hidden name=code_client value=$code_client>";
	print "<input type=hidden name=action value=telph>";
}
if ($niveau eq "rappel4"){$file="/home/var/spool/uucppublic/relance-4bis.txt.relance";}
if ($niveau eq "rappel4"){$file="/home/var/spool/uucppublic/relance-5bis.txt.relance";}
$saut=$lignea=0;
$page=-1;
$page2=-12;
foreach $cle (keys(%afaire)) {
	$page++;
	$ec_nom=$afaire{$cle};
	
	if ($niveau ne "rappel3"){
		&papier_entete();
	}
	
	#if ($saut==1){&sautepage();}
	if ($niveau eq "rappel1"){&tete1();}
	if ($niveau eq "rappel2"){&tete2();}
	if ($niveau eq "rappel3"){&tete3();}
	if ($niveau eq "rappel4"){&tete4();}
	if ($niveau eq "rappel5"){&tete5();}
	else {$lignea=0;}

	@table=();
	$total=0;
	$reg_flag="non";
	%total=();
	(*table,$code)=&selecte_n(*tab,1,$cle); 
	#Boule Affichage ligne differente facture . . .
	if($niveau ne "rappel5"){
	foreach (@table){
		($lien,$ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
   		print "
	        <SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left:1cm;\">$ec_no_fact</span>
	        <SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left:3cm;\">$ec_dt</span>";
		($nul,$nul,$nul,$nul,$nul,$nul,$dev)=&selecte("/home/var/spool/uucppublic/pays.txt.relance",$ec_cd_dev,0);
			
                print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left:5cm;\">$ec_mont € ";
                # Affiche le montant dans le devise de facturation . . .
                if ($ec_cd_dev != 12){
                	print "($ec_mont_dev $dev)";
                	$total{$dev}+=$ec_mont_dev;
	        }
        
                print "</span>";
		# Somme déjà régler . . .
	        if( $ec_reg !=0){
			$reg_flag="oui";
	               	print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left:10cm;\">**$ec_reg €</span>";
	        }
	     	$ec_mont-=$ec_reg;
	        print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left:13cm;\">";
	        print &separateur($ec_mont);
	        print " €</span>";
	        $ligne=$code_client.";".$ec_no_fact.";".$date.";";
		$total+=$ec_mont;
		&ajoute_n("$file",$ligne,1);
		if ($niveau eq "rappel3"){
			 print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left:16cm;\"><input type=checkbox name=$ec_no_fact></span>";
		}
 		$lignea+=0.5;
	       

} 
}
	if ($niveau eq "rappel1"){&pied1();}
	if ($niveau eq "rappel2"){&pied2();}
	if ($niveau eq "rappel4"){&pied4();}
	if ($niveau eq "rappel5"){&pied5();}
		

}
if ($niveau eq "rappel3"){
	print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left:1cm;\"><input type=submit value=\"enregistrer les factures qui ont été relancées\"></form></span>";
	}
close (FILE2);
}
# fin de crelettre

sub tete1 {
	$date2=`date +%d/%m/%y`;
	if (($cl_cd_cl <2000000)||(int($cl_cd_cl/1000)==6001)){
	@lang=("Premier rappel",
	"Réf. Client",
	"Madame, Monsieur,",
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nous avons eu récemment le plaisir de vous livrer nos produits et espérons que cette commande vous a apporté entière satisfaction.<BR><BR>Nous nous permettons de rappeler à votre aimable attention que toute facture est payable dès réception des marchandises.",
	"Facture",
	"Date",
	"Montant",
	"Réglé",
	"Reste dû",
	"Nous vous remercions de la confiance que vous nous accordez et dans l'attente d'un prompt règlement, nous vous prions d'agréer, Madame, Monsieur, l'expression de nos salutations distinguées.",
	"Le Directeur Financier",
	);
	}
	else{
	@lang=("ACCOUNT REMINDER",
	"customer ref",
	"Dear customer,",
	"Please find below the details of your outstanding account.",
	"Invoice",
	"Date",
	"Amount",
	"Paid",
	"Still due",
	"We remain yours faithfully,",
	"Accounts Department",
	);
	} 
	print "
	<span class=taille5>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 11cm;\">$cl_add</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5.5,"cm; left: 11cm;\"><b>$ec_nom</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6,"cm; left: 11cm;\">$cl_rue</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6.5,"cm; left: 11cm;\">$cl_ville</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 5cm;\">Dieppe le $date2</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7,"cm; left: 1cm;\"><b>$lang[0]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7.5,"cm; left: 1cm;\">$lang[1] : $ec_cd_cl</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+9,"cm; left: 1cm;\">$lang[2]</span><BR>
	
	<DIV align=justify style=\"position:absolute;width:16cm;height:200px;top:",$page*27.7+10,"cm;left:1cm;border-style:solid;border-width:0px;border-color:#FFCC66;background-Color:#FFFFFF\">$lang[3]</DIV>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13,"cm; left: 1cm;\"><U>RELEVE DE COMPTE</U></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 1cm;\"><b>$lang[4]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 3cm;\"><b>$lang[5]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 5cm;\"><b>$lang[6]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 10cm;\"><b>$lang[7]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 13cm;\"><b>$lang[8]</b></span>
	"

}
sub pied1 {
	print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left: 13cm;\"><b>";
	print &separateur($total);
	print " €";
	if ($reg_flag eq "non"){ # si aucun reglement n'a ete fait on affiche le total en devise
		foreach $cle (keys(%total)){
			print &separateur($total{$cle});
			print " $dev ";
		}
	}
		
	print "</b></span>";
	print "
	
	<DIV align=justify style=\"position:absolute;width:16cm;height:200px;top:",$page*27.7+15+$lignea,"cm;left:1cm;border-style:solid;border-width:0px;border-color:#FFCC66;background-Color:#FFFFFF\">$lang[9]</DIV>
	<SPAN style=\"position: absolute; top: ",$page*27.7+17.5+$lignea,"cm; left: 10cm;\">$lang[10]</span>
	</span>";
}

sub tete2 {
	$date2=`date +%d/%m/%y`;
	if (($cl_cd_cl <2000000)||(int($cl_cd_cl/1000)==6001)){
	@lang=("Deuxième Rappel",
	"Réf. Client",
	"Madame, Monsieur,",
	"Nous vous prions de trouver ci-dessous le relevé de votre compte arrêté à ce jour.",
	"Facture",
	"Date",
	"Montant",
	"Réglé",
	"Reste dû",
	"Cette(ces) livraison(s) n'ayant fait l'objet d'aucune réclamation, nous sommes très étonnés du délai apporté à votre règlement.<BR>Il s'agit très certainement d'un oubli de votre part auquel nous vous remercions de bien vouloir remédier très rapidement.<BR><BR>Faute d'un règlement dans les 8 jours suivant ce rappel, nous serons contraints de suspendre toute livraison à votre attention jusqu'à réception de ce paiement.<BR><BR>Nous espérons bien sûr ne pas en arriver à cette situation extrême et comptons sur un prompt règlement par retour de courrier.Nous saisissons cette occasion pour vous rappeler que les règlements par carte de crédit sont très faciles et appréciés de tous.<BR>Toutefois, si l'envoie de votre règlement a croisé ce rappel, nous vous demandons de ne pas tenir compte de ce courrier.<BR>Nous comptons sur votre compréhension et vous remerciant de la confiance que vous nous accordez. Nous vous prions de croire, Madame, Monsieur, en l'expression de nos respectueuses salutations.",
	"Le Directeur Financier",
	);
	}
	else{
	@lang=("SECOND REMINDER",
	"customer ref",
	"Dear customer,",
	"Please find below the details of your outstanding account.",
	"Invoice",
	"Date",
	"Amount",
	"Paid",
	"Still due",
	"Since you did not contest the delivery, we remain very surprised by the delay in settling your invoice(s) in spite",
	"of  a previous reminder.",
	"We presume this was an oversight on your part. However  your cheque in full settlement of your account within ",
	"the next 8 days following receipt of this letter is requested.",
        "If we do not receive payment, we regret to inform you that we shall stop any delivery until receipt of your ",
        "settlement. In addition we will ask you to pay in advance or on delivery from then on.",
        "Nevertheless we hope not to have to take such drastic measures.",
        "We look forward to receiving the above sum and to continuing business with you.",
	"We remain yours faithfully,",
	"",
	"",
	"",
	"",
	"Accountancy Department",
	);
	} 
	print "
	<span class=taille5>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 11cm;\">$cl_add</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5.5,"cm; left: 11cm;\"><b>$ec_nom</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6,"cm; left: 11cm;\">$cl_rue</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6.5,"cm; left: 11cm;\">$cl_ville</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 5cm;\">Dieppe le $date2</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7,"cm; left: 1cm;\"><b>$lang[0]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7.5,"cm; left: 1cm;\">$lang[1]:$ec_cd_cl</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+10,"cm; left: 1cm;\">$lang[2]</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+11.5,"cm; left: 1cm;\">$lang[3]<br><br></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13,"cm; left: 1cm;\"><b>$lang[4]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13,"cm; left: 3cm;\"><b>$lang[5]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13,"cm; left: 5cm;\"><b>$lang[6]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13,"cm; left: 10cm;\"><b>$lang[7]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13,"cm; left: 13cm;\"><b>$lang[8]</b></span>
	"

}

sub pied2 {
	print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left: 13cm;\"><b>";
	print &separateur($total);
	print " €";
	if ($reg_flag eq "non"){ # si aucun reglement n'a ete fait on affiche le total en devise
		foreach $cle (keys(%total)){
			print &separateur($total{$cle});
			print " $dev ";
		}
	}
	print "</b></span>";
	print "<SPAN class=taille3>
	<DIV align=justify style=\"position:absolute;width:16cm;height:200px;top:",$page*27.7+15.5+$ligna,"cm;left:1cm;border-style:solid;border-width:0px;border-color:#FFCC66;background-Color:#FFFFFF\">$lang[9]</DIV>	
	
	<SPAN style=\"position: absolute; top: ",$page*27.7+22.5+$lignea,"cm; left: 10cm;\">$lang[10]</span>

	</span>";

}
sub tete3 {
	$page2+=3+$lignea+9;
	$page=$page2/27.7;
	$lignea=-9;
	print "
	<span class=taille5>
	
	<SPAN style=\"position: absolute; top: ",$page*27.7+1,"cm; left: 1cm;\">$cl_add</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+1,"cm; left: 6cm;\"><b>$ec_nom</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+1.5,"cm; left: 1cm;\">$cl_rue</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+1.5,"cm; left: 10cm;\">$cl_ville</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+1.5,"cm; left: 15cm;\">$ec_cd_cl</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+2,"cm; left: 1cm;\"><b>Facture</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+2,"cm; left: 3cm;\"><b>Date</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+2,"cm; left: 5cm;\"><b>Montant</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+2,"cm; left: 10cm;\"><b>Réglé</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+2,"cm; left: 13cm;\"><b>Reste dû</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+2,"cm; left: 15cm;\"><a href=telephone.pl?client=$cl_cd_cl&action=ajout>Téléphone</a></span>

	"
}

sub tete4 {
	$date2=`date +%d/%m/%y`;
	if (($cl_cd_cl <2000000)||(int($cl_cd_cl/1000)==6001)){
	@lang=("Quatrième Rappel",
	"Réf. Client",
	"Madame, Monsieur,",
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nous regrettons de constater qu'à ce jour, la(les) facture(s) ci-dessous demeure(nt) impayée(s) et ce, malgré nos trois précédents rappels. Ces marchandises vous ont été livrées il y a maintenant deux mois.",
	"Facture",
	"Date",
	"Montant",
	"Réglé",
	"Reste dû",
	"Nous vous invitons, par conséquent, à régulariser votre situation par retour de courrier par tout moyen à votre convenance.<BR>Dans le cas contraire, nous serons contraints, tout d'abord, de vous demander un règlement à l'avance pour vos prochaines commandes et parallèlement, nous serons dans l'obligation d'envoyer un courrier à votre Chef de Mission.<BR>Nous espérons, bien sûr, ne pas en arriver à cette mesure extrême.<BR><BR>Dans l'attente de votre prompt règlement, nous vous prions de croire, Madame, Monsieur, l'expression de nos respectueuses salutations.",
	"Le Directeur Financier",
	);
	}
	else{
	@lang=("ACCOUNT REMINDER",
	"customer ref",
	"Dear customer,",
	"Please find below the details of your outstanding account.",
	"Invoice",
	"Date",
	"Amount",
	"Paid",
	"Still due",
	"We remain yours faithfully,",
	"Accounts Department",
	);
	} 
	print "
	<span class=taille5>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 11cm;\">$cl_add</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5.5,"cm; left: 11cm;\"><b>$ec_nom</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6,"cm; left: 11cm;\">$cl_rue</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6.5,"cm; left: 11cm;\">$cl_ville</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 5cm;\">Dieppe le $date2</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7,"cm; left: 1cm;\"><b>$lang[0]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7.5,"cm; left: 1cm;\">$lang[1] : $ec_cd_cl</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+9.5,"cm; left: 1cm;\">$lang[2]</span><BR>
	
	<DIV align=justify style=\"position:absolute;width:16.5cm;height:200px;top:",$page*27.7+11.5,"cm;left:1cm;border-style:solid;border-width:0px;border-color:#FFCC66;background-Color:#FFFFFF\">$lang[3]</DIV>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 1cm;\"><b>$lang[4]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 3cm;\"><b>$lang[5]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 5cm;\"><b>$lang[6]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 10cm;\"><b>$lang[7]</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+13.5,"cm; left: 13cm;\"><b>$lang[8]</b></span>
	"

}

sub pied4 {
	print "<SPAN style=\"position: absolute; top: ",$page*27.7+14+$lignea,"cm; left: 13cm;\"><b>";
	print &separateur($total);
	print " €";
	if ($reg_flag eq "non"){ # si aucun reglement n'a ete fait on affiche le total en devise
		foreach $cle (keys(%total)){
			print &separateur($total{$cle});
			print " $dev ";
		}
	}
	print "</b></span>";
	print "
<DIV align=justify style=\"position:absolute;width:16cm;height:200px;top:",$page*27.7+15+$lignea,"cm;left:1cm;border-style:solid;border-width:0px;border-color:#FFCC66;background-Color:#FFFFFF\">$lang[9]</DIV>
	<SPAN style=\"position: absolute; top: ",$page*27.7+20+$lignea,"cm; left: 10cm;\">$lang[10]</span>
	</span>";

}

sub tete5 {
	$date2=`date +%d/%m/%y`;
	if (($cl_cd_cl <2000000)||(int($cl_cd_cl/1000)==6001)){
	@lang=("Cinquième Rappel",
	"Réf. Client",
	"Monsieur l'Ambassadeur<BR>Monsieur Le Consul Général,",
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Le société BIS France vous présente ses compliments et profite de cette occasion pour porter à votre connaissance que malgré de nombreux rappels certains membres de votre Mission présentent un retard considérable dans le règlement de leurs factures (voir relevé ci-joint).<BR><BR>La Société BIS France sollicite de votre haute bienveillance votre intervention auprès des intéressés, persuadés qu'un simple rappel de leur Chef de Mission les amènera à régler leurs dettes envers nous dans les meilleurs délais.<BR><BR>Avec ses remerciements anticipés pour la suite que vous voudrez bien apporter à sa requête, la Société BIS France vous prie de croire, Monsieur Le Consul Général / Excellence, en l'expression de sa plus haute considération.",
	"John Lasnel<BR>Directeur Général",
	);
	}
	else{
	@lang=("ACCOUNT REMINDER",
	"customer ref",
	"Dear customer,",
	"Please find below the details of your outstanding account.",
	"Invoice",
	"Date",
	"Amount",
	"Paid",
	"Still due",
	"We remain yours faithfully,",
	"Accounts Department",
	);
	} 
	print "
	<span class=taille5>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 11cm;\">$cl_add</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5.5,"cm; left: 11cm;\"><b>Son Excel. / m. le Consul</b></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6,"cm; left: 11cm;\">$cl_rue</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+6.5,"cm; left: 11cm;\">$cl_ville</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+5,"cm; left: 5cm;\">Dieppe le $date2</span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7,"cm; left: 1cm;\"></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+7.5,"cm; left: 1cm;\"></span>
	<SPAN style=\"position: absolute; top: ",$page*27.7+9.5,"cm; left: 1cm;\">$lang[2]</span><BR>
	
	<DIV align=justify style=\"position:absolute;width:16.5cm;height:200px;top:",$page*27.7+11.5,"cm;left:1cm;border-style:solid;border-width:0px;border-color:#FFCC66;background-Color:#FFFFFF\">$lang[3]</DIV>
	"

}

sub pied5 {
	print "
	<SPAN style=\"position: absolute; top: ",$page*27.7+18.5+$lignea,"cm; left: 10cm;\">$lang[4]</span>
	</span>";

}

sub listedesclients {
	if ($action eq "rappel1"){&tete("Premier rappel","/home/var/spool/uucppublic/echeanc.txt.relance");}
	if ($action eq "rappel2"){&tete("Deuxieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }
	if ($action eq "rappel3"){&tete("Troisieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }
	if ($action eq "rappel4"){&tete("Quatrieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }
	if ($action eq "rappel5"){&tete("Cinquieme rappel ","/home/var/spool/uucppublic/echeanc.txt.relance"); }

	$total=$pass=0;
	foreach (@echeancier_dat) {
		($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev)  = split(/;/,$_);
		$ec_no_fact+=0;
		$ec_dt+=0;
		if ((&nbjour($ec_dt)==$ref)&&(&testsiauto() eq "oui")){
			$reste=$ec_mont -$ec_reg;
			if (($reste)<5){next;}

			if ($pass==0){
				print "<center><h2>Liste des impayées du ";
				print &jour($ref);
				print " $ec_dt</h2><br><br>\n";
				$pass=1;
			}
			
			if ($ec_cd_cl!=$cl_cd_cl){
				($cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,@client_dat[$client_idx{$ec_cd_cl}]);  
				print "</table><br><a href=relancebisbis.pl?code_client=$cl_cd_cl&action=selection&niveau=$niveau>";
				print "$cl_cd_cl $cl_add $cl_service $cl_rue $cl_ville <font color=blue>$code_lettre</font> </a><br><table><tr>\n";
				print "<td width=100><b>facture</td><td width=200><b>nom</td><td width=100>\n";
				print "<b>reste du</td></tr>\n";
			}
		
			print "<tr><td>$ec_no_fact</td><td>$ec_nom</td><td>";
			print &separateur($reste);
			print "</td></tr>";
			$total+=$reste;
			if ($action eq "rappel4"){
				$file="/home/var/spool/uucppublic/relance-4bis.txt.relance";
				$ligne=$ec_cd_cl.";".$ec_no_fact.";".$date.";";
				&ajoute_n("$file",$ligne,1);
			}
			if ($action eq "rappel5"){
				$file="/home/var/spool/uucppublic/relance-5bis.txt.relance";
				$ligne=$ec_cd_cl.";".$ec_no_fact.";".$date.";";
				&ajoute_n("$file",$ligne,1);
			}
		}
	}	

	print "</table><br>";
	if ($total ne 0){
		print "<b>TOTAL :";
		print &separateur($total);
		print " EU ";
	}
	else{
	print "<center> Il n'y a aucune relance pour cette journée";
	}
	
}

sub html {
        &tete("Relance ","/home/var/spool/uucppublic/echeanc.txt.relance"); 

	print <<"eof";
	<center><br><br><br><a href=relancebisbis.pl?action=rappel1&niveau=rappel1>1 rappel</a>&nbsp;&nbsp;<img src=http://intranet.dom/relance1.gif border=0 align=center>date de facture + 3 semaines<br></br>
	<a href=relancebisbis.pl?action=rappel2&niveau=rappel2>2 rappel</a>&nbsp;&nbsp;<img src=http://intranet.dom/relance2.gif border=0 align=center>date de facture + 5 semaines<br><br>
	<a href=relancebisbis.pl?action=rappel3&niveau=rappel3>3 rappel</a>&nbsp;&nbsp;<img src=http://intranet.dom/relance3.gif border=0 align=center>date de facture + 5 semaines<br><br>
	<a href=relancebisbis.pl?action=rappel4&niveau=rappel4>4 rappel</a>&nbsp;&nbsp;<img src=http://intranet.dom/relance4.gif border=0 align=center>date de facture + 6 semaines<br><br>
	<a href=relancebisbis.pl?action=rappel5&niveau=rappel5>5 rappel</a>&nbsp;&nbsp;<img src=http://intranet.dom/relance5.gif border=0 align=center>date de facture + 8 semaines<br>
	</center></html></body>
eof
}
sub sautepage{
	print "<h1>.</h1>";
	$saut=0;
	}
sub papier_entete{
print "<span class=police>
	<span class=taille1>
		<SPAN style=\"position: absolute; top: ",$page*27.7,"cm; left: 0cm;\">B.I.S. France</SPAN>
	</span>
	<span class=taille2>
		<SPAN style=\"position: absolute; top: ",$page*27.7+1.5,"cm; left: 0cm;\"><b>Diplomatic Corps Supplier</b></SPAN>
	</span>
	<span class=taille3>
		<SPAN style=\"position: absolute; top: ",$page*27.7+2.5,"cm; left: 0cm;\">B.P. 106 -76203 DIEPPE Cedex</SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+3,"cm; left: 0cm;\">Tél. 33 (0) 232 140 280 - Téléfax : 33 (0) 232 140 299</SPAN>
	</span>
	<span class=taille4>
		<SPAN style=\"position: absolute; top: ",$page*27.7+25.5,"cm; left: 0cm;\"><b>Siège Social</b></SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+26,"cm; left: 0cm;\">58, avenue de Wagram</SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+26.5,"cm; left: 0cm;\">75017 PARIS</SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+25.5,"cm; left: 13.5cm;\"><b>Administration Exploitation</b></SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+26,"cm; left: 13.5cm;\">B.P. 106</SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+26.5,"cm; left: 13.5cm;\">76203 DIEPPE cedex</SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+27,"cm; left: 2cm;\">Z.I. de Dieppe - Société Anonyme - Capital 54000 € -RCS Paris B 433 874 708 - TVA n°:FR.51433874708</SPAN>
	</span>
</span>
";
}


sub testsiauto {
	$auto="oui";
	if ($non_relance_idx{$ec_cd_cl} ne ""){$auto="non";}
	if ($archrel_li_idx{$ec_no_fact} ne ""){$auto="non";}
	if ($archrel_idx{$ec_cd_cl} ne ""){
		@liste=split(/;/,$archrel_idx{$ec_cd_cl});
		foreach (@liste){
			($code,$facture,$date3,$etat,$desi)=split (/;/,$archrel_dat[$_]);
			if ($facture == $ec_no_fact){	
				$auto="non";
				}
		}
			
	}
	return($auto);
}
# -E relance de bis
# -M 29/10 test si la facture est en relance interdite avnat laliste des factures à traiter
