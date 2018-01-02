#!/usr/bin/perl
use CGI;
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$date = `/bin/date '+%d%m%y'`;   
chop($date);  
$fluo="#00FFCC";
print $html->header;

$action=$html->param("action");
$selection=$html->param("selection");
$periode=$html->param("periode");
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
	$lettre="J;M;C;B;E;NA";
}

$premier=$html->param("premier");
$dernier=$html->param("dernier");
$premieredt=$html->param("premieredt");
$dernieredt=$html->param("dernieredt");

`cat /home/var/spool/uucppublic/echecom.txt /home/var/spool/uucppublic/archive/ec-2001.txt >/home/var/spool/uucppublic/ectemp.txt`;
open(FILE2,"/home/var/spool/uucppublic/ectemp.txt");  # echeancier
@echeancier_dat=<FILE2>;
close(FILE2);
%client_idx = &get_index("client3",0);            
open(FILE2,"/home/var/spool/uucppublic/client3.txt");     
@client_dat = <FILE2>;
close (FILE2);
$action=$html->param("action");
if ($action eq ""){
	&html;
	exit;
	}

$premiere="100150";
$premiercl=9999999999;
foreach (@echeancier_dat) {
	$compteur++;
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev,$bug)  = split(/;/,$_);
	$ibug++;
	if ( grep /[a-z,A-Z,0-9]/,$bug){
		print "<center><br><font color=red>Erreur dans le fichier echeancier , merci de prevenir sylvain<br></font>";
		print "$ibug $ec_cd_cl $ec_no_fact $ec_nom $ec_dt *$bug*<br>";
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
		while ($tab[6]=~s/ //){};
	if ($tab[6]eq ""){$tab[6]="N";}
	if ($tab[6]=~/^$_$/){$ok=1;}
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
	
	if ($ec_cd_cl<$premiercl){$premiercl=$ec_cd_cl;}
	if ($ec_cd_cl>$derniercl){$derniercl=$ec_cd_cl;}
	if (&nbjour($ec_dt)<&nbjour($premiere)){$premiere=$ec_dt;}
	if (&nbjour($ec_dt)>&nbjour($derniere)){$derniere=$ec_dt;}
	
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
			next;
		}
		if ($delai <29){
			$nonreg29+=1;	
			$duno29+=$reste;
			next;
		}
		if ($delai <57){
			$nonreg57+=1;	
			$duno57+=$reste;
			next;
		}
		if ($delai <85){
			$nonreg85+=1;	
			$duno85+=$reste;
			next;
		}
		$nonreg100+=1;	
		$duno100+=$reste;
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

$totalca=$casol+$cano+$capa+$catr+$acasol+$acano+$acapa+$acatr;
$totaldu=$dusol+$duno+$dupa+$dutr+$adusol+$aduno+$adupa+$adutr;
$totalenc=$resol+$reno+$repa+$retr+$aresol+$areno+$arepa+$aretr;
$total=$ca;
$qtotaldu=$partiel+$troppercu+$nonregle+$apartiel+$atroppercu+$anonregle;
$qtotalenc=$solde+$partiel+$troppercu+$asolde+$apartiel+$atroppercu;
$qtotal=$facture;
print "<center><b>Statistique du chiffre d'affaire du ";
print &date($premiere);
print " au ";
print &date($derniere);
print "<br>";
print "Premier client:";
print $premiercl;
@tabcl=&selecte("/home/var/spool/uucppublic/client3.txt",$premiercl,0);
print " $tabcl[1] $tabcl[2]";

print "<br>Dernier client:";
print $derniercl;
@tabcl=&selecte("/home/var/spool/uucppublic/client3.txt",$derniercl,0);
print " $tabcl[1] $tabcl[2]";
print "<br><br>";

print "$titre<br>";
print "</center>";
print "<table border=1>";
print "<tr><td>&nbsp;</td><td>&nbsp;</td><td colspan=3 align=middle bgcolor=#efefef><b>Chiffre d'affaire</td><td colspan=3 align=middle><b>Encaissement</td><td colspan=3 align=middle bgcolor=#efefef><b>Dû</td></tr>";
print "<tr><td>&nbsp;</td><td align=middle><b>Nombre de document</td><td bgcolor=#efefef><b>% en quantité</td><td bgcolor=#efefef><b>Valeur</td><td bgcolor=#efefef><b>% en valeur</td><td><b>% en quantité</td><td><b>Valeur</td><td><b>% en valeur</td><td bgcolor=#efefef><b>% en quantité</td><td bgcolor=#efefef><b>Valeur</td><td bgcolor=#efefef><b>% en valeur</td></tr>";

print "<tr><td><b>Factures</td><td align=right>$facture</td><td align=right bgcolor=#efefef>";
print "&nbsp;";
print "</td><td align=right bgcolor=#efefef>";
print &separateurs($ca);
print "</td><td align=right bgcolor=#efefef>";
print "&nbsp;";
print "</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td></tr>";

print "<tr><td><b>Avoir</td><td align=right>$avoir</td><td align=right bgcolor=#efefef>";
print "&nbsp;";
print "</td><td align=right bgcolor=#efefef>";
print &separateurs($aca);
print "</td><td align=right bgcolor=#efefef>";
# print &separateurs($aca*100/$total);
print "&nbsp;";
print "</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td></tr>";


if ($solde>0){
	print "<tr><td><b>Factures Soldées</td>";
	print "<td align=right><b>";
	print $solde;
	print "</td><td bgcolor=#efefef align=right><b>";
	print &separateurs($solde*100/$qtotal);
	print "</td><td bgcolor=#efefef><b>";
	print &separateurs($casol);
	print "</td><td bgcolor=#efefef align=right><b>";
	print &separateurs($casol*100/$total);
 	print "</td><td align=right><b>";
	print "100";
	print "</td><td align=right><b>";
	print &separateurs($resol);
	print "</td><td align=right><b>";
	print "100";
	print "</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>";
	print &separateurs($dusol);
	print "</td><td bgcolor=#efefef>&nbsp;</td></tr>";

	print "<tr><td>Soldée entre 0 et 1 semaine</td>";
	print "<td align=right>";
	print $solde8;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($solde8*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol8);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol8*100/$total);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($solde8*100/$solde);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol8);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol8*100/$resol);
	$cumul=$casol8*100/$total;
	print "</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td></tr>";

	print "<tr><td>Soldée entre 1 et 4 semaines</td>";
	print "<td align=right>";
	print $solde29;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($solde29*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol29);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol29*100/$total);
	$cumul+=$casol29*100/$total;
	print "<br><font size=-2>";
	print &separateurs($cumul);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($solde29*100/$solde);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol29);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol29*100/$resol);
	print "</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td></tr>";

	
	print "<tr><td>Soldée entre 4 et 8 semaines</td>";
	print "<td align=right>";
	print $solde57;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($solde57*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol57);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol57*100/$total);
	$cumul+=$casol57*100/$total;
	print "<br><font size=-2>";
	print &separateurs($cumul);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($solde57*100/$solde);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol57);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol57*100/$resol);
	print "</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td></tr>";

	print "<tr><td>Soldée entre 8 et 12 semaines</td>";
	print "<td align=right>";
	print $solde85;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($solde85*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol85);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol85*100/$total);
	$cumul+=$casol85*100/$total;
	print "<br><font size=-2>";
	print &separateurs($cumul);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($solde85*100/$solde);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol85);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol85*100/$resol);
	print "</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td></tr>";

	print "<tr><td>Soldée aprés 12 semaines</td>";
	print "<td align=right>";
	print $solde100;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($solde100*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol100);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($casol100*100/$total);
	$cumul+=$casol100*100/$total;
	print "<br><font size=-2>";
	print &separateurs($cumul);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($solde100*100/$solde);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol100);
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($casol100*100/$resol);
	print "</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef>&nbsp;</td></tr>";
}

if ($partiel>0){
	print "<tr><td><b>Factures Partielement Soldées</td>";
	print "<td  align=right>";
	print $partiel;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($partiel*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($capa);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($capa*100/$total);
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right>";
	print &separateurs($repa);
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td><td align=right bgcolor=#efefef>";
	print "<a href=http://ibs.oasix.fr/cgi-bin/stat-echeancier-detail.pl?detail=1&premier=$premiercl&dernier=$derniercl&premieredt=$premiere&dernieredt=$derniere&selection=$selection&periode=$periode";
	foreach $cle (keys(%table_lettre)){print "&$cle=on";}
	print ">";

	print &separateurs($dupa);
	print "</a></td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td></tr>";
}
if ($troppercu>0){
	print "<tr><td><b>Factures avec un trop perçu</td>";
	print "<td  align=right>";
	print $troppercu;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($troppercu*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($catr);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($catr*100/$total);
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right>";
	print &separateurs($retr);
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td><td align=right bgcolor=#efefef>";
	print &separateurs($dutr);
	print "</td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td></tr>";

}

if ($nonregle>0){
	print "<tr><td><b>Factures impayées</td>";
	print "<td  align=right><b>";
	print $nonregle;
	print "</td><td bgcolor=#efefef align=right><b>";
	print &separateurs($nonregle*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right><b>";
	print &separateurs($cano);
	print "</td><td bgcolor=#efefef align=right><b>";
	print &separateurs($cano*100/$total);
	print "</td><td align=right>";
	print "&nbsp;";
	print "</td><td align=right>";
	print &separateurs($reno);
	print "&nbsp;";
	print "</td><td align=right>";
	print "&nbsp;";
	print "</td><td align=right bgcolor=#efefef><b>";
	print "100";
	print "</td><td align=right bgcolor=#efefef><b>";
	print &separateurs($duno);
	print "</td><td align=right bgcolor=#efefef><b>";
	print "100";
	print "</td></tr>";

	print "<tr><td>Reste dû entre 0 et 1 semaine</td>";
	print "<td  align=right>";
	print $nonreg8;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($nonreg8*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno8);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno8*100/$total);
	print "</td><td >&nbsp;</td><td >&nbsp;</td><td >&nbsp;</td>";
	print "<td align=right bgcolor=$fluo>";
	print &separateurs($nonreg8*100/$nonregle);
	print "</td><td align=right bgcolor=$fluo>";
	print "<a href=http://ibs.oasix.fr/cgi-bin/stat-echeancier-detail.pl?detail=8&premier=$premiercl&dernier=$derniercl&premieredt=$premiere&dernieredt=$derniere&selection=$selection&periode=$periode";
	foreach $cle (keys(%table_lettre)){print "&$cle=on";}
	print ">";
	print &separateurs($duno8);
	print "</a>";
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($duno8*100/$duno);
	print "</td></tr>";

	print "<tr><td>Reste dû entre 1 et 4 semaines</td>";
	print "<td  align=right>";
	print $nonreg29;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($nonreg29*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno29);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno29*100/$total);
	print "</td><td >&nbsp;</td><td >&nbsp;</td><td >&nbsp;</td>";
	print "<td align=right bgcolor=$fluo>";
	print &separateurs($nonreg29*100/$nonregle);
	print "</td><td align=right bgcolor=$fluo>";
	print "<a href=http://ibs.oasix.fr/cgi-bin/stat-echeancier-detail.pl?detail=29&premier=$premiercl&dernier=$derniercl&premieredt=$premiere&dernieredt=$derniere&selection=$selection&periode=$periode";
	foreach $cle (keys(%table_lettre)){print "&$cle=on";}
	print ">";
	print &separateurs($duno29);
	print "</a>";
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($duno29*100/$duno);
	print "</td></tr>";

	
	print "<tr><td>Reste dû entre 4 et 8 semaines</td>";
	print "<td  align=right>";
	print $nonreg57;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($nonreg57*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno57);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno57*100/$total);
	print "</td><td >&nbsp;</td><td >&nbsp;</td><td >&nbsp;</td>";
	print "<td align=right bgcolor=$fluo>";
	print &separateurs($nonreg57*100/$nonregle);
	print "</td><td align=right bgcolor=$fluo>";
	print "<a href=http://ibs.oasix.fr/cgi-bin/stat-echeancier-detail.pl?detail=57&premier=$premiercl&dernier=$derniercl&premieredt=$premiere&dernieredt=$derniere&selection=$selection&periode=$periode";
	foreach $cle (keys(%table_lettre)){print "&$cle=on";}
	print ">";
	print &separateurs($duno57);
	print "</a>";
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($duno57*100/$duno);
	print "</td></tr>";

	print "<tr><td>Reste dû entre 8 et 12 semaines</td>";
	print "<td  align=right>";
	print $nonreg85;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($nonreg85*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno85);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno85*100/$total);
	print "</td><td >&nbsp;</td><td >&nbsp;</td><td >&nbsp;</td>";
	print "<td align=right bgcolor=$fluo>";
	print &separateurs($nonreg85*100/$nonregle);
	print "</td><td align=right bgcolor=$fluo>";
	print "<a href=http://ibs.oasix.fr/cgi-bin/stat-echeancier-detail.pl?detail=85&premier=$premiercl&dernier=$derniercl&premieredt=$premiere&dernieredt=$derniere&selection=$selection&periode=$periode";
	foreach $cle (keys(%table_lettre)){print "&$cle=on";}
	print ">";
	print &separateurs($duno85);
	print "</a>";
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($duno85*100/$duno);
	print "</td></tr>";

	print "<tr><td>Reste dû au dela de 12 semaines</td>";
	print "<td  align=right>";
	print $nonreg100;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($nonreg100*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno100);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($duno100*100/$total);
	print "</td><td >&nbsp;</td><td >&nbsp;</td><td >&nbsp;</td>";
	print "<td align=right bgcolor=$fluo>";
	print &separateurs($nonreg100*100/$nonregle);
	print "</td><td align=right bgcolor=$fluo>";
	print "<a href=http://ibs.oasix.fr/cgi-bin/stat-echeancier-detail.pl?detail=100&premier=$premiercl&dernier=$derniercl&premieredt=$premiere&dernieredt=$derniere&selection=$selection&periode=$periode";
	foreach $cle (keys(%table_lettre)){print "&$cle=on";}
	print ">";
	print &separateurs($duno100);
	print "</a>";
	print "</td><td align=right bgcolor=$fluo>";
	print &separateurs($duno100*100/$duno);
	print "</td></tr>";




}


if ($asolde>0){
	print "<tr><td><b>Avoirs Soldés</td>";
	print "<td align=right>";
	print $asolde;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($asolde*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($acasol);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($acasol*100/$total);
 	print "</td><td align=right>";
	print "&nbsp;";
	print "</td><td align=right>";
	print &separateurs($aresol);
	print "</td><td align=right>";
	print "&nbsp;";
	print "</td><td bgcolor=#efefef>&nbsp;</td><td bgcolor=#efefef align=right>";
	print &separateurs($adusol);
	print "</td><td bgcolor=#efefef>&nbsp;</td></tr>";
}
if ($apartiel>0){
	print "<tr><td><b>Avoirs Partielements Soldés</td>";
	print "<td  align=right>";
	print $apartiel;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($apartiel*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($acapa);
	print "</td><td bgcolor=#efefef align=right>&nbsp;";
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right>";
	print &separateurs($arepa);
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td><td align=right bgcolor=#efefef align=right>";
	print &separateurs($adupa);
	print "</td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td></tr>";

}
if ($atroppercu>0){
	print "<tr><td><b>Avoirs avec un trop perçu</td>";
	print "<td  align=right>";
	print $atroppercu;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($atroppercu*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($acatr);
	print "</td><td bgcolor=#efefef align=right>&nbsp;";
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right>";
	print &separateurs($aretr);
	print "</td><td align=right>&nbsp;";
	print "</td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td><td align=right bgcolor=#efefef>";
	print &separateurs($adutr);
	print "</td><td align=right bgcolor=#efefef>&nbsp;";
	print "</td></tr>";
}
if ($anonregle>0){
	print "<tr><td><b>Avoirs non utilisés</td>";
	print "<td  align=right>";
	print $anonregle;
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($anonregle*100/$qtotal);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($acano);
	print "</td><td bgcolor=#efefef align=right>";
	print &separateurs($acano*100/$total);
	print "</td><td align=right>";
	print "&nbsp;";
	print "</td><td align=right>";
	print &separateurs($areno);
	print "</td><td align=right>";
	print "&nbsp;";
	print "</td><td align=right bgcolor=#efefef>";
	print "&nbsp;";
	print "</td><td align=right bgcolor=#efefef>";
	print &separateurs($aduno);
	print "</td><td align=right bgcolor=#efefef>";
	print "&nbsp;";
	print "</td></tr>";
}

print "<tr><td><b>Total</td><td align=right><b>";
print $facture+$avoir;
print "</td><td align=right bgcolor=#efefef>&nbsp;</td><td align=right bgcolor=#efefef><b>";
print &separateurs($ca+$aca);
print "</td><td bgcolor=#efefef>&nbsp;</td><td align=right><b>";
print "&nbsp;";
print "</td><td align=right><b>";
print &separateurs($totalenc);
print "</td><td>&nbsp;</td><td align=right bgcolor=#efefef><b>";
print "&nbsp;</td><td align=right bgcolor=#efefef><b>";

print &separateurs($totaldu);
print "</td><td bgcolor=#efefef>&nbsp;</td><td align=right bgcolor=#efefef><b>";
print "<tr><td>&nbsp;</td><td align=middle><b>Nombre de document</td><td bgcolor=#efefef><b>% en quantité</td><td bgcolor=#efefef><b>Valeur</td><td bgcolor=#efefef><b>% en valeur</td><td><b>% en quantité</td><td><b>Valeur</td><td><b>% en valeur</td><td bgcolor=#efefef><b>% en quantité</td><td bgcolor=#efefef><b>Valeur</td><td bgcolor=#efefef><b>% en valeur</td></tr>";
print "<tr><td>&nbsp;</td><td>&nbsp;</td><td colspan=3 align=middle bgcolor=#efefef><b>Chiffre d'affaire</td><td colspan=3 align=middle><b>Encaissement</td><td colspan=3 align=middle bgcolor=#efefef><b>Dû</td></tr>";
print "</table>";
print "<br><font color=red>Chêque en bois :";
print &separateur($vente_bois);
print "</b></font></br>";
@temps=times;
print "<br><font size=-2>edition du ",&date($date)," $compteur enregistrements traités en ",$temps[0],"s</body></html>";

print "</body></html>";

sub ligne{
	my ($var)=@_;	
print "$var;$ec_cd_cl;$ec_no_fact;$ec_nom;$ec_mont;$ec_reg<br>";
}


sub separateurs{
return(&separateur(@_));
#return(@_);

}

sub html
{
	&tete("STATISTIQUE DU CHIFFRE D'AFFAIRE","/home/var/spool/uucppublic/echecom.txt","");
	print "<form name=commer action=stat-echeancier.pl><input type=hidden name=action value=edition>";
	print "<br>\n\n<br>\n\n";
	print "<center><table width=40% border=2 cellspacing=0 cellpadding=0 bordercolorlight=#f4#b0#2d bordercolordark=darkgoldenrod >";
	print "<tr>\n<td align=center>";
	print "JOHN <input type=radio name=selection value=john><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "CHANTAL<input type=radio name=selection value=chantal><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "BERNARD <input type=radio name=selection value=bernard><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "EMMANUELLE <input type=radio name=selection value=emmanuelle><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "MARYLINE <input type=radio name=selection value=maryline><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "LUCIE <input type=radio name=selection value=lucie><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "STRASBOURG <input type=radio name=selection value=strasbourg><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "GILLE <input type=radio name=selection value=gille><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "LONDRE <input type=radio name=selection value=londre><br>\n";
       	print "</td></tr>";			    
 	print "<tr>\n<td align=center>";
	print "NON AFFECTES <input type=radio name=selection value=nonaffecte><br>\n";
       	print "</td></tr>";			    
	print "<tr>\n<td align=center>";
	print "TOUS LES COMMERCIAUX (sans les non-affectés)<input type=radio name=selection value=tout><br>\n";
	print "</td><tr>\n</table><br>\n\n<br>";
	print "2001 <input type=radio name=periode value=2001 ><br>";
	print "2002 <input type=radio name=periode value=2002 ><br>";
	print "2003 <input type=radio name=periode value=2002 ><br>";
	print "2004 <input type=radio name=periode value=2003 checked><br><br><center><Input type=submit value=valider></form>";
	
}
	

	
# -E stat de du client
