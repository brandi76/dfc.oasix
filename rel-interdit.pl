#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require 'outils_perl.lib';
require 'manip_table.lib';

%pays_idx = &get_index_num("pays",0);
open(FILE2,"/home/var/spool/uucppublic/pays.txt");     
@pays_dat = <FILE2>;
close (FILE2);
%rappel1_idx = &get_index_num("relance-1bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-1bis.txt");     
@rappel1_dat = <FILE2>;
close (FILE2);
%rappel2_idx = &get_index_num("relance-2bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-2bis.txt");     
@rappel2_dat = <FILE2>;
close (FILE2);
%rappel3_idx = &get_index_num("relance-3bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-3bis.txt");     
@rappel3_dat = <FILE2>;
close (FILE2);
%rappel4_idx = &get_index_num("relance-4bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-4bis.txt");     
@rappel4_dat = <FILE2>;
close (FILE2);
%rappel5_idx = &get_index_num("relance-5bis",1);
open(FILE2,"/home/var/spool/uucppublic/relance-5bis.txt");     
@rappel5_dat = <FILE2>;
close (FILE2);

$date = `/bin/date '+%d%m%y'`;   
chop($date);  
$user = &user();
chop($user); 

print "<html><body>";
&tete("Relance interdite","/home/var/spool/uucppublic/rel-interditbis.txt",1); 

$action=$html->param("action");
$facture=$html->param("facture");
$client=$html->param("client");
if ($action eq ""){
	&choixfacture();
}
if ($action eq "motif"){
	&choixmotif();
}
if ($action eq "confirme"){
	&confirme();
	&choixmotif();

}

sub choixfacture {
	print "<center><br><br>";
	if ($erreur ==1){
		print "<font color=red>Facture $facture introuvable </font><br><br>";
		$erreur=0;
	}
	
	print"
	<form name=choix action=rel-interdit.pl>No de facture :<input type=text size=8 name=facture><br><br>
	<input type=hidden name=action value=motif>
	<input type=hidden name=facture value=$facture>
	<input type=submit value=go></form>
	</body></html>";
}

sub choixmotif {
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev) =&selecte("/home/var/spool/uucppublic/echeanc.txt",$facture,1);
	if ($ec_no_fact eq ""){
		$erreur=1;
		&choixfacture();
		exit;
		}	
	($cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville)=&selecte("/home/var/spool/uucppublic/client2.txt",$ec_cd_cl,0); 

	print "<center><br><br><table border=1><tr><td><font color=red>$ec_cd_cl</font></td><td colspan=13><font color=black>Client:<font color=red>$cl_add</td></tr>";
        print "<tr bgcolor=#e8e8e8><td><font>facture</td><td align=middle><font >Nom</td><td><font >Date de facture</td><td><font >Montant </td><td><font >montant reglé </td><td><font >date du reglement</td><td><font >Montant en devise</td><td><font >reste </td><td><font >reste en devise</td><td colspan=4><font >relance</td></tr>\n";
	print "<tr bgcolor=$gris><td align=right><font size=2 color=$couleur>$ec_no_fact</a></td>";
	print "<td align=middle><font size=2 color=$couleur>$ec_nom</td><td align=right><font size=2 color=$couleur>";
	print &date($ec_dt);
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_mont);
	print " EU";
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_reg);
	$ec_reg+=0;
	print " EU";
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
	print " EU";
	print "</td>"; 
	$reste_dev=0;
	if ($ec_mont!=0){$reste_dev=$reste*$ec_mont_dev/$ec_mont;}
	print "<td align=right><font size=2 color=$couleur>";
	print &separateur($reste_dev);
	print " $dev</td>"; 

	if ($rappel1_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel1_dat[$rappel1_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance1.gif border=0 align=top height=20><br><font >$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	if ($rappel2_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel2_dat[$rappel2_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance2.gif border=0 align=top height=20><br><font >$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	if ($rappel3_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel3_dat[$rappel3_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance3.gif border=0 align=top height=20><br><font >$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	if ($rappel4_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel4_dat[$rappel4_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance4.gif border=0 align=top height=20><br><font >$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}	
	if ($rappel5_idx{$ec_no_fact}ne""){
		($null,$null,$date_1)=split(/;/,$rappel5_dat[$rappel5_idx{$ec_no_fact}]);
		print "<td align=center><img src=http://intranet.dom/relance5.gif border=0 align=top height=20><br><font >$date_1</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	print "</tr></table><br><br>";
	%relancein_idx = &get_index_multiple("rel-interditbis",1);
	open(FILE2,"/home/var/spool/uucppublic/rel-interditbis.txt");     
	@relancein_dat = <FILE2>;
	close (FILE2);
	open(FILE2,"/home/var/spool/uucppublic/motif.txt");     
	@motif_dat = <FILE2>;
	close (FILE2);
	

	@liste=split(/;/,$relancein_idx{$facture});
	print "<table>";
	foreach (@liste) {
		(@ligne)=split(/;/,$relancein_dat[$_]);
		($motif)=split(/;/,$motif_dat[$ligne[4]]);
		print &ligne_tab("","le $ligne[2]","Blocage fait par $ligne[3]","Motif:<b>$motif</b>","Commentaire: <b>$ligne[5]</b>");
	} 
	print "</table>";
	print "<br><br>";
	print "<form action=rel-interdit.pl>";
	print "<input type=hidden name=facture value=$ec_no_fact>";
	print "<input type=hidden name=client value=$cl_cd_cl>";
	print "<input type=hidden name=action value=confirme>";
	print "Choisir un motif<br>";
	print "<select name=motif>";
	
	
	for ($i=0;$i<=$#motif_dat;$i++){
		($motif)=split(/;/,$motif_dat[$i]);
		print "<option value=$i>$motif</option>"; 
        	}
        print "</select>";
        print "<br>Autre<br><input type=text name=autre zize=30><br>Commentaire<br><input type=text name=comment size=60><br>"; 
        print "<br><input type=submit value=valider></form>";
        if ($html->param("niveau") ne ""){ # appel depuis relancebis
        	print "<a href=relancebis.pl?action=selection&code_client=$cl_cd_cl&niveau=",$html->param("niveau"),">retour au relance</a>";
        }
        print "</body></html>"; 

	
}

sub confirme {
	$motif=$html->param("motif");
	
	if ($html->param("autre") ne ""){
		$ligne=$html->param("autre").";".$user.";"."$date".";\n";
		open(FILE2,">>/home/var/spool/uucppublic/motif.txt");
		print FILE2 $ligne;     
		close (FILE2); 	
	}
	open(FILE2,"/home/var/spool/uucppublic/motif.txt");     
	@motif_dat=<FILE2>;
	close (FILE2); 	
	if ($html->param("autre") ne ""){$motif=$#motif_dat;	}
	$ligne=$client.";".$facture.";".$date.";".$user.";".$motif.";".$html->param("comment").";";
	&ajoute("/home/var/spool/uucppublic/rel-interditbis.txt",$ligne);     
	$ligne=$facture.";0;";
	&ajoute_n("/home/var/spool/uucppublic/relancebis.txt",$ligne,0);

}

# -E relance interdite