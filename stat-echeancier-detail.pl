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
$selection=$html->param("selection");
$periode=$html->param("periode");

open(FILE2,"/home/var/spool/uucppublic/ectemp.txt");  # echeancier
@echeancier_dat=<FILE2>;
close(FILE2);
%client_idx = &get_index("client3",0);            
open(FILE2,"/home/var/spool/uucppublic/client3.txt");     
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

if ($selection eq "john"){
	$titre="JOHN";
	$lettre="J";
}
if ($selection eq "chantal"){
	$titre="CHANTAL";
	$lettre="C";
}
if ($selection eq "emmanuelle"){
	$titre="EMMANUELLE";
	$lettre="E";
}
if ($selection eq "bernard"){
	$titre="BERNARD";
	$lettre="B";
}
if ($selection eq "maryline"){
	$titre="MARYLINE";
	$lettre="M";
}
if ($selection eq "lucie"){
	$titre="LUCIE";
	$lettre="LU";
}
if ($selection eq "bernard"){
	$titre="BERNARD";
	$lettre="B";
}
if ($selection eq "maryline"){
	$titre="MARYLINE";
	$lettre="M";
}
if ($selection eq "gille"){
	$titre="GILLE";
	$lettre="GS";
}
if ($selection eq "strasbourg"){
	$titre="STRASBOURG";
	$lettre="STG";
}
if ($selection eq "londres"){
	$titre="LONDRES";
	$lettre="LE";
}

if ($selection eq "nonaffecte"){
	$titre="NON AFFECTES";
	$lettre="SP;N;BX;PO;AL;AV;LO;SU";
}


if ($selection eq "tout"){
	$titre="TOUS LES COMMERCIAUX";
	$lettre="J;M;C;B;E";
}
print $titre;
if ($detail==1){print "<br>FACTURES PARTIELLEMENT SOLDEES<br>";}
if ($detail==8){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 0 A 1 SEMAINE<br>";}
if ($detail==29){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 2 A 4 SEMAINES<br>";}
if ($detail==57){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 4 A 8 SEMAINES<br>";}
if ($detail==85){print "<br>FACTURES IMPAYEES DANS UN DELAI DE 8 A 12 SEMAINES<br>";}
if ($detail==100){print "<br>FACTURES IMPAYEES DANS UN DELAI AU DELA DE 12 SEMAINES<br>";}

print "<br></b><br><br><table border=1><tr><td><b>Facture</td><td><b>nom</td><td><b>Montant</td><td><b>Date</td><td><B>Relance Interdite</B></td></tr>";

foreach (@echeancier_dat) {
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev,$bug)  = split(/;/,$_);
	if ( grep /[a-z,A-Z,0-9]/,$bug){
		print "<center><br><font color=red>Erreur dans le fichier echeancier , merci de prevenir sylvain<br></font>";
		print "$ec_cd_cl $ec_no_fact *$bug*";
		#`echo "stat echeancier erreur" | mail sylvain`;
		exit;
		}
        if (&nbjour($ec_dt)<&nbjour(10102) && ($periode==2002)){next;}
   	if (&nbjour($ec_dt)>=&nbjour(10102) && ($periode==2001)){next;}
  
	$ec_mont+=0;
	$ec_reg+=0;
	if (($ec_mont==0)&&($ec_reg==0)){next;}

	(@tab)=split(/;/,$client_dat[$client_idx{$ec_cd_cl}]);
		(@lettre)=split(/;/,$lettre);
	$ok=0;
	foreach (@lettre){
	if ($tab[6]eq ""){$tab[6]="N";}
	if ($tab[6]=~/^$_/){$ok=1;}
	}
	if ($ok==0){next;}

	if ($ec_no_fact < 0) {
		$vente_bois+=$ec_mont-$ec_reg;
		next;
	}

	$ec_cd_cl+=0;
	$ec_dt+=0;
	if($ec_cd_cl == 0){
		print "<font color=red>$ec_no_fact<br></font>";
		next;}
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
	if ($detail==1){&compta();}


}
print "</table><center><br><br><b>";
print "$nbfact factures pour un total de ";
print &separateur($total);
print " €<br>";
print "<br>edition du ";
print &date($date);
print "</body></html>";


sub separateurs{
return(&separateur(@_));
#return(@_);

}

	

sub compta{
	if ($ec_cd_cl != $ec_tampon){
		@tabcl=&selecte("/home/var/spool/uucppublic/client3.txt",$ec_cd_cl,0);
		print "<tr><td colspan=5><b>$ec_cd_cl $tabcl[1] -->$tabcl[6]</b></td></tr>";
		$ec_tampon=$ec_cd_cl;
	}
	print "<tr><td>$ec_no_fact</td><td><font color=red>$ec_nom";
	print "</td><td align=right>";
	print &separateur($ec_mont);
	if ($detail==1){
		print " reglé:";
		print &separateur($ec_reg);
		print " reste dû:";
		$ec_mont-=$ec_reg;
		print &separateur($ec_mont);
	}
		
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