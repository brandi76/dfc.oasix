#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser); 
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$texte=$html->param('texte');
$save=$html->param('save');
$type=$html->param('type');

require "./src/connect.src";
                
print "<title>Importation code neptune</title>";
open(FILE,"/home/intranet/cgi-bin/DETAIL_VENT.xls");
@tab=<FILE>;
close(FILE);
$ok=0;
print `date`;
foreach $ligne (@tab){
	chop($ligne);
	if (length($ligne)<3) {next;}
	while($ligne=~s/\t/;/){};
	
	$lignev=$ligne;
	while($lignev=~s/;/*/){};
	if (grep /^Date Dep/,$ligne){
		next;
	}

	if (grep /TOTALE PER/,$ligne){
		print "<font color=green size=+5>FIN DE FICHIER</font> Ca:$ca";
		last;
	}
     if (grep /TOTAL PER/,$ligne){
		print "<font color=green size=+5>FIN DE FICHIER</font> Ca:$ca";
		last;
	}
		
if (grep /TOTAL PAR/,$ligne){
		print "<font color=green size=+5>FIN DE FICHIER</font> Ca:$ca";
		last;
	}
	while($ligne=~s/^ //){};
	while($ligne=~s/^\t/;/){};
	if ((grep -/^P E R I O D O/,$ligne)||(grep -/^P E R I O D E/,$ligne)){
		while ($ligne=~s/ //){}
		$debut="20".substr($ligne,16,2)."-".substr($ligne,13,2)."-".substr($ligne,10,2);
		$fin="20".substr($ligne,26,2)."-".substr($ligne,23,2)."-".substr($ligne,20,2);
		&save("delete from corsica_tva  where tva_date>='$debut' and tva_date<='$fin' and tva_nom='$navire_ex'","aff");
		$sup=1;
		next;
	}
	if ((grep -/^Navire/,$ligne)||(grep -/^Nave/,$ligne)){
		($null,$navire_ex)=split(/ : /,$ligne);
		$navire_ex=~ s/^ //;
		if (grep /^MARINA/,$navire_ex){$navire_ex="MARINA";}
		if ((grep /^MEGA/,$navire_ex)&&(grep /1/,$navire_ex)){$navire_ex="MEGA 1";}
		if ((grep /^MEGA/,$navire_ex)&&(grep /2/,$navire_ex)){$navire_ex="MEGA 2";}
		if ((grep /^MEGA/,$navire_ex)&&(grep /3/,$navire_ex)){$navire_ex="MEGA 3";}
		if ((grep /^MEGA/,$navire_ex)&&(grep /4/,$navire_ex)){$navire_ex="MEGA 4";}
		if ((grep /^MEGA/,$navire_ex)&&(grep /5/,$navire_ex)){$navire_ex="MEGA 5";}
		if (grep /^REGINA/,$navire_ex){$navire_ex="REGINA";}
		if (grep /^VICTORIA/,$navire_ex){$navire_ex="VICTORIA";}
		if ((grep /^EXPRESS II/,$navire_ex)&&(!grep /^EXPRESS III/,$navire_ex)){$navire_ex="EXPRESS 2";}
if ((grep /^EXPRESS 2/,$navire_ex)&&(!grep /^EXPRESS III/,$navire_ex)){$navire_ex="EXPRESS 2";}
				
if (grep /^EXPRESS III/,$navire_ex){$navire_ex="EXPRESS 3";}
		if (grep /^VERA/,$navire_ex){$navire_ex="VERA";}
		if (grep /^S EXPRESS/,$navire_ex){$navire_ex="SARDINIA EXPRESS";}
		if (grep /^SERENA/,$navire_ex){$navire_ex="SERENA II";}
		if (grep /^MEGA SM/,$navire_ex){$navire_ex="SMERALDA";}
		if (grep /^SMERALDA/,$navire_ex){$navire_ex="SMERALDA";}
	
		print "<b>$navire_ex</b><br>";
		next;
	}	
	
	if ( grep /Date Dep/,$ligne){
		if ($ligne ne "Date Dep;Ligne;Heure Dep.;Code;Libelle;Prx Achat;Caisse;Type vente;ref. Four;Qte;Tot. PV;Marge en %;Famille;Sous-Famille;SS-Famille;TVA;Tot. PV HT;Tot PA HT;Tot PA TTC;Fournisseur;"){
			print "<font color=red><h1> FORMAT FICHIER INVALIDE (Colonne)</h1><br>";
			print "Date Dep;Ligne;Heure Dep.;Code;Libelle;Prx Achat;Caisse;Type vente;ref. Four;Qte;Tot. PV;Marge en %;Famille;Sous-Famille;SS-Famille;TVA;Tot. PV HT;Tot PA HT;Tot PA TTC;Fournisseur;<br>$ligne<br>";
			exit;
		}
		next;
	}
	if ($sup !=1) {
		print "<font color=red><h1> FORMAT FICHIER INVALIDE (date fichier)</h1><br>-$ligne-<br>";
		exit;
	}
	if ($navire_ex eq "") {
		print "<font color=red><h1> FORMAT FICHIER INVALIDE (nom du navire)</h1><br>-$ligne-<br>";
		exit;
	}
	
	($date,$leg,$heure,$neptune,$desi,$prac,$caisse,$type,$refour,$qte,$prixv,$marge,$famille,$sfamille,$ssfamille,$tva)=split(/;/,$ligne);
	if (($date eq "")&&($leg eq "")){next;}
	if (grep/[A-Z]/,$date){
		print "<font color=red><h5> FORMAT FICHIER INVALIDE (date ligne)</h5><br>$date</h1><br>-$ligne-<br>";
				exit;
	#                 	$ligne=~s/2008/2008\t/;
	#                 		print "<b>$ligne</b>";
	# 			($date,$leg,$heure,$neptune,$desi,$prac,$caisse,$type,$refour,$qte,$prixv,$marge,$famille,$sfamille,$ssfamille,$tva)=split(/;/,$ligne);
	}	
	if ($tva eq ''){
		print "<font color=red><h5> FORMAT FICHIER INVALIDE (code tva)</h5><br>-$ligne-<br>";
		exit;
	}
	($jour,$mois,$an)=split( /\//,$date);
	if ($jour<10){
		$jour+=0;
		$jour='0'.$jour;
	}
	$date="$an-$mois-$jour";
	$pr_cd_pr=-1;
	$query="select nep_codebarre from neptune where nep_cd_pr='$neptune'";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	$max_ref=-1;
	
	if ($sth2->rows >1){ # produit a plusieurs code barre
		while (($nep_codebarre)=$sth2->fetchrow_array){
			$max=&get("select max(coc_no) from comcli,infococ2 where coc_cd_pr=$nep_codebarre and coc_no=ic2_no and ic2_cd_cl=500","af")+0;
			if ($max > $max_ref){$pr_cd_pr=$nep_codebarre;}
			$max_ref=$max;
		}
	}
	if ($sth2->rows ==1){ 
			$pr_cd_pr=$sth2->fetchrow_array;
	}
	if ($sth2->rows==0){ #inconnu
		print "produit inconnu:$neptune $desi <br>-$ligne-<br>";
	}
	if ($pr_cd_pr==-1){ #inconnu
		print "produit inconnu 2:$neptune $desi <br>-$ligne-<br>";
	}
	
	
	$desi=$dbh->quote($desi);
	$prixv=~s/,/./;
	$prac=~s/,/./;
	$tva=~s/,/./;
	$marge=~s/,/./;
	$qte=~s/,/./;
			
	#  		$qteanc=&get("select tva_qte from corsica_tva where tva_nom='$navire_ex' and tva_date='$date' and tva_leg='$leg' and tva_heure='$heure' and tva_neptune='$neptune' and tva_desi=$desi","aff")+0;
	#                 print "$qteanc<br>";
	#                 $qte+=$qteanc;
	&save("insert into corsica_tva values ('$navire_ex','$date','$leg','$heure','$neptune','$qte',$desi,'$prac','$caisse','$type','$pr_cd_pr','$refour','$prixv','$marge','$famille','$sfamille','$ssfamille','$tva')","af");
# 	  		print ".";
	$ca+=$prixv;
	$cumul+=$qte;
}
$verif=&get("select sum(tva_qte) from corsica_tva where tva_date>='$debut' and tva_date<='$fin' and tva_nom='$navire_ex'","af");
# print "---------$verif------------";

if ($verif !=$cumul){print "<br>cumul:$cumul<->fichier:$verif ici";exit}
$verif=&get("select count(*) from corsica_tva where tva_date='0000-00-00'");
if ($verif >0){print "<font color=red><h2>erreur importation stop</h2></font>";exit;}
$verif=&get("select sum(tva_qte) from corsica_tva where tva_date>='$debut' and tva_date<='$fin' and tva_nom='$navire_ex'");
print "<br>Verification qte=$verif<br>";
print `date`;
