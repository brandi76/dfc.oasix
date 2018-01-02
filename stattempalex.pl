#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$date = `/bin/date '+%d%m%y'`;   
chop($date);  
print $html->header;

$premiercl=$html->param("premier");
$derniercl=$html->param("dernier");
$premiere=$html->param("premieredt");
$derniere=$html->param("dernieredt");
$detail=$html->param("detail");
open(FILE2,"/home/var/spool/uucppublic/echecom.txt");
@echeancier_dat=<FILE2>;
close(FILE2);
%client_idx = &get_index("client2",0);            
open(FILE2,"/home/var/spool/uucppublic/client2.txt");     
@client_dat = <FILE2>;
close (FILE2);
%archrel_li_idx = &get_index_multiple("rel-interditbis",1);
open(FILE2,"/home/var/spool/uucppublic/rel-interditbis.txt");     
@archrel_li_dat = <FILE2>;
close (FILE2);
%archrel_idx = &get_index_multiple("archrel",1);
open(FILE2,"/home/var/spool/uucppublic/archrel.txt");     
@archrel_dat = <FILE2>;
close (FILE2);


# pour toutes les lettres existant dans le fichier clients on regarde si elle a ete choisie
foreach (@client_dat){
	($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,$_);
	while ($code_lettre=~s/ //g){}; # astuce
	$code_lettre=&filtre($code_lettre);
	if ($code_lettre eq ""){$code_lettre="*"};
	if ($html->param("$code_lettre")eq "on"){
		$table_lettre{$code_lettre}+=1;
	}
}

$total=$pass=$nb=$ok=0;

print "<HTML>\n<BODY>\n";
print "<center><b>Statistique du chiffre d'affaire du ";
print &date($premiere);
print " au ";
print &date($derniere);
print "<br>";
print "Premier client:";
print $premiercl;
@tabcl=&selecte("/home/var/spool/uucppublic/client2.txt",$premiercl,0);
print " $tabcl[1] $tabcl[2]";

print "<br>Dernier client:";
print $derniercl;
@tabcl=&selecte("/home/var/spool/uucppublic/client2.txt",$derniercl,0);
print " $tabcl[1] $tabcl[2]";
print "<br><br>";


foreach $cle (keys(%table_lettre)){
	if ($cle eq "B"){print "BERNARD,";next;}
	if ($cle eq "J"){print "JOHN,";next;}
	if ($cle eq "JO"){print "JOHN OCDE,";next;}
	if ($cle eq "C"){print "CHANTAL,";next;}
	if ($cle eq "CU"){print "CHANTAL UNESCO,";next;}
	if ($cle eq "CO"){print "CHANTAL OCDE,";next;}
	if ($cle eq "E"){print "EMMANUELLE,";next;}
	if ($cle eq "PRO"){print "PROVINCE,";next;}
	print "$cle ";
	}
if ($detail==8){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 0 A 1 SEMAINE<br>";}
if ($detail==29){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 2 A 4 SEMAINES<br>";}
if ($detail==57){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 4 A 8 SEMAINES<br>";}
if ($detail==85){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 8 A 12 SEMAINES<br>";}
if ($detail==100){print "<br>FACTURES IMPAYEES DANS UN DELAI AU DELA DE 12 SEMAINES<br>";}

print "<br></b><br><br><table border=1><tr><td><b>Facture</td><td><b>nom</td><td><b>Montant</td><td><b>Date</td><td><B>Relance Interndite</B></td></tr>";

foreach (@echeancier_dat) {
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev,$bug)  = split(/;/,$_);
	if ( grep /[a-z,A-Z,0-9]/,$bug){
		print "<center><br><font color=red>Erreur dans le fichier echeancier , merci de prevenir sylvain<br></font>";
		print "$ec_cd_cl $ec_no_fact *$bug*";
		#`echo "stat echeancier erreur" | mail sylvain`;
		exit;
		}
	$ec_mont+=0;
	$ec_reg+=0;
	if (($ec_mont==0)&&($ec_reg==0)){next;}
	($cl_cd_cl,$cl_nom,$cl_contact,$cl_rue,$cl_ville,$nul,$nul,$code_lettre)=split(/;/,$client_dat[$client_idx{$ec_cd_cl}]);
	$ec_cd_cl+=0;
	$ec_dt+=0;
	if($ec_cd_cl == 0){next;}
	while ($code_lettre=~s/ //g){};
	$code_lettre=&filtre($code_lettre);
	if ($code_lettre eq ""){$code_lettre="*"};
	
	if (&testsiauto eq "non"){next;}
	
	$ec_no_fact+=0;
	$ec_dt+=0;
	$ec_dt_reg+=0;
	$reste=$ec_mont -$ec_reg;
	$mois=(($ec_dt/100)%100);

	if ($ec_mont<0 ){ # avoir
		$avoir+=1;
		$aca+=$ec_mont;
		
		if ($ec_dt_reg == 0){
			$anonregle+=1;
			$acano+=$ec_mont;
			$aduno+=$reste;
			$areno+=$ec_reg;
			next;
		}
	
		if (($reste<15)&&($reste>-15)){
			$asolde+=1;
			$acasol+=$ec_mont;
			$aresol+=$ec_reg;
			$adusol+=$reste;
			
			next;
		}
		if ($ec_reg < $ec_mont){
			$atroppercu+=1;
			$acatr+=$ec_mont;
			$aretr+=$ec_reg;
			$adutr+=$reste;
			next;
		}
		$apartiel+=1;
		$acapa+=$ec_mont;
		$arepa+=$ec_reg;
		$adupa+=$reste;
		next;
	}
	$facture+=1;
	$ca+=$ec_mont;
		
	if ($ec_dt_reg == 0){
		$nonregle+=1;
		$duno+=$reste;
		$reno+=$ec_reg;
		$cano+=$ec_mont;
		$delai=&nbjour($date)-&nbjour($ec_dt);
		if ($delai <8){
			$nonreg8+=1;	
			$duno8+=$reste;
			if ($detail==8){&compta();}
			next;
		}
		if ($delai <29){
			$nonreg29+=1;	
			$duno29+=$reste;
			if ($detail==29){&compta();}
			next;
		}
		if ($delai <57){
			$nonreg57+=1;	
			$duno57+=$reste;
			if ($detail==57){&compta();}
			next;
		}
		if ($delai <85){
			$nonreg85+=1;	
			$duno85+=$reste;
			if ($detail==85){&compta();}
			next;
		}
		$nonreg100+=1;	
		$duno100+=$reste;
		if ($detail==100){&compta();}
		next;
	}
	
	if (($reste<15)&&($reste>-15)){
	
		$solde+=1;
		$casol+=$ec_mont;
 		$dusol+=$reste;
 		$resol+=$ec_reg;
 		$delai=&nbjour($ec_dt_reg)-&nbjour($ec_dt);
		if ($delai <8){
			$solde8+=1;	
			$casol8+=$ec_reg;
			next;
		}
		if ($delai <29){
			$solde29+=1;	
			$casol29+=$ec_reg;
			next;
		}
		if ($delai <57){
			$solde57+=1;	
			$casol57+=$ec_reg;
			next;
		}
		if ($delai <85){
			$solde85+=1;	
			$casol85+=$ec_reg;
			next;
		}
		$solde100+=1;	
		$casol100+=$ec_reg;
			
		next;
	}
	if ($ec_reg > $ec_mont){
		$troppercu+=1;
		$catr+=$ec_mont;
		$retr+=$ec_reg;
		$dutr+=$reste;
		#&ligne("trop perçu");
		next;
	}
	$partiel+=1;
	$capa+=$ec_mont;
	$repa+=$ec_reg;
	$dupa+=$reste;


}
print "</table><center><br><br><b>";
print "$nbfact factures pour un total de ";
print &separateur($total);
print " €<br>";
print "<br>edition du ";
print &date($date);
print "</body></html>";

sub testsiauto{
	$retour="non";
	if (($table_lettre{$code_lettre} ne "")&& ($cl_cd_cl >= $premiercl) && ($cl_cd_cl <= $derniercl) && (&nbjour($ec_dt) >= &nbjour($premiere)) && (&nbjour($ec_dt) <= &nbjour($derniere))){
		$retour="oui";
		}
	
	return ($retour);
}

sub separateurs{
return(&separateur(@_));
#return(@_);

}

	
sub filtre{
	$retour=$code_lettre;
	if (
(	$retour 	eq 	"AN"	)||
(	$retour 	eq 	"BA"	)||
(	$retour 	eq 	"BAS"	)||
(	$retour 	eq 	"BE"	)||
(	$retour 	eq 	"BO"	)||
(	$retour 	eq 	"CA"	)||
(	$retour 	eq 	"CF"	)||
(	$retour 	eq 	"CL"	)||
(	$retour 	eq 	"DI"	)||
(	$retour 	eq 	"ET"	)||
(	$retour 	eq 	"GR"	)||
(	$retour 	eq 	"LI"	)||
(	$retour 	eq 	"LY"	)||
(	$retour 	eq 	"MA"	)||
(	$retour 	eq 	"ME"	)||
(	$retour 	eq 	"MO"	)||
(	$retour 	eq 	"MU"	)||
(	$retour 	eq 	"NA"	)||
(	$retour 	eq 	"NAY"	)||
(	$retour 	eq 	"NI"	)||
(	$retour 	eq 	"NIM"	)||
(	$retour 	eq 	"OR"	)||
(	$retour 	eq 	"PA"	)||
(	$retour 	eq 	"PAU"	)||
(	$retour 	eq 	"PE"	)||
(	$retour 	eq 	"RE"	)||
(	$retour 	eq 	"RO"	)||
(	$retour 	eq 	"ST"	)||
(	$retour 	eq 	"TA"	)||
(	$retour 	eq 	"TO"	)||
(	$retour 	eq 	"TOU"	)||
(	$retour 	eq 	"VIL"	)){
	$retour="PRO";
}
return ($retour);
}

sub compta{
	if ($ec_cd_cl != $ec_tampon){
		@tabcl=&selecte("/home/var/spool/uucppublic/client2.txt",$ec_cd_cl,0);
		print "<tr><td colspan=5><b>$ec_cd_cl $tabcl[1] -->$tabcl[7]</b></td></tr>";
		$ec_tampon=$ec_cd_cl;
	}
	print "<tr><td>$ec_no_fact</td><td><font color=red>$ec_nom";
	print "</td><td align=right>";
	print &separateur($ec_mont);
	print "</td><td align=right>$ec_dt</td>";
		if($archrel_li_idx{$ec_no_fact} ne ""){
			@rel_split = split(/;/,$archrel_li_dat[$archrel_li_idx{$ec_no_fact}]);
			#print "<TD>$rel_split[5]</TD>";
			print "<TD><FONT COLOR='RED\'><B>Relance Interdite</B></FONT></TD>";
		}
		if($archrel_idx{$ec_no_fact} ne ""){
			@rel_split = split(/;/,$archrel_li_dat[$archrel_li_idx{$ec_no_fact}]);
			#print "<TD>$rel_split[5]</TD>";
			print "<TD><FONT COLOR='RED\'><B>Relance Interdite</B></FONT></TD>";
		}
	print "</tr>";
	$total+=$ec_mont;
	$nbfact++;
}
# -E stat de du client