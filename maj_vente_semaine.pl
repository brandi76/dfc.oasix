#!/usr/bin/perl
use CGI;
use DBI();
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
if ($action eq ""){
	print "<body><center><h1>IMPORTATION VENDU AVEC INFO LEG  (DETAIL_VENT.xls) NAVIRE</h1><br>";
	print "format<pre>";
	print "Nave  : MEGA EXPRESS 2                															
P E R I O D O  :      du   01/03/08   au   31/03/08															
Date Dep	Ligne	Heure Dep.	Code	Libelle	Prx Achat	Caisse	Type vente	ref. Four	Qte	Tot. PV	Marge en %	Famille	Sous-Famille	SS-Famille	TVA
";
	print "</pre>";			

	print "<a name=haut></a>";
	print "<form method=post>";
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";
        print "<br><input type=reset>";
    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form><a href=#haut>haut</a></body>";
}
	

if ($action eq "import"){
	(@tab)=split(/\n/,$texte);
	$ok=0;
	foreach $ligne (@tab){
 		$lignev=$ligne;
 		while($lignev=~s/\t/*/){};
 		print "<font color=red>$lignev</font><br>";
		if (grep /TOTALE PER/,$ligne){
			print "<font color=green size=+5>FIN DE FICHIER</font> Nb de parfums vendus:$nbparf";
		}
		if (grep /TOTAL PAR/,$ligne){
			print "<font color=green size=+5>FIN DE FICHIER</font> Nb de parfums vendus:$nbparf";
		}
		while($ligne=~s/^ //){};
		while($ligne=~s/^\t//){};
		if ((grep -/^Navire/,$ligne)||(grep -/^Nave/,$ligne)){
 			($null,$navire_ex)=split(/ : /,$ligne);
			$navire_ex=~ s/^ //;
			if (grep /^MARINA/,$navire_ex){$navire_ex="MARINA";}
			if ((grep /^MEGA/,$navire_ex)&&(grep /1/,$navire_ex)){$navire_ex="MEGA 1";}
			if ((grep /^MEGA/,$navire_ex)&&(grep /2/,$navire_ex)){$navire_ex="MEGA 2";}
			if ((grep /^MEGA/,$navire_ex)&&(grep /3/,$navire_ex)){$navire_ex="MEGA 3";}
			if ((grep /^MEGA/,$navire_ex)&&(grep /4/,$navire_ex)){$navire_ex="MEGA 4";}

			if (grep /^REGINA/,$navire_ex){$navire_ex="REGINA";}
			if (grep /^VICTORIA/,$navire_ex){$navire_ex="VICTORIA";}
			if ((grep /^EXPRESS II/,$navire_ex)&&(!grep /^EXPRESS III/,$navire_ex)){$navire_ex="EXPRESS 2";}
			if (grep /^EXPRESS III/,$navire_ex){$navire_ex="EXPRESS 3";}
			if (grep /^VERA/,$navire_ex){$navire_ex="VERA";}
			if (grep /^S EXPRESS/,$navire_ex){$navire_ex="SARDINIA EXPRESS";}
			if (grep /^SERENA II/,$navire_ex){$navire_ex="SERENA II";}
		
			print "<b>$navire_ex</b><br>";
		}	

		if ((! grep /PUBLIC/,$ligne)&&(! grep /EQUIPAGE/,$ligne)&&(! grep /OFFICIERS/,$ligne)&&(! grep /Remise/,$ligne)){next;}
		($date,$leg,$heure,$neptune,$desi,$prac,$caisse,$type,$refour,$qte,$prixv,$marge,$famille,$null,$null,$tva)=split(/\t/,$ligne);
                if (grep/[A-Z]/,$date){
                	$ligne=~s/2008/2008\t/;
#                 		print "<b>$ligne</b>";
			($date,$leg,$heure,$neptune,$desi,$prac,$caisse,$type,$refour,$qte,$prixv,$marge,$famille,$null,$null,$tva)=split(/\t/,$ligne);
                }	
                if ($tva eq ''){
                	print "<font color=red><h1> FORMAT FICHIER INVALIDE </h1>";
			exit;
		}
                ($jour,$mois,$an)=split( /\//,$date);
                $date="$an-$mois-$jour";
                $pr_cd_pr=-1;
		$query="select nep_codebarre from neptune where nep_cd_pr='$neptune'";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		$max_ref=-1;
		while (($nep_codebarre)=$sth2->fetchrow_array){
			$max=&get("select max(coc_no) from comcli,infococ2 where coc_cd_pr=$nep_codebarre and coc_no=ic2_no and ic2_cd_cl=500","af")+0;
			if ($max > $max_ref){$pr_cd_pr=$nep_codebarre;}
			$max_ref=$max;
		}
		$desi=$dbh->quote($desi);
 		$prixv=~s/,/./;
 		$prac=~s/,/./;
 		$tva=~s/,/./;
 		$marge=~s/,/./;
 		$qte=~s/,/./;

 		&save("replace into corsica_tva values ('$navire_ex','$date','$leg','$heure','$neptune','$qte',$desi,'$prac','$caisse','$type','$pr_cd_pr','$refour','$prixv','$marge','$famille','$sfamille','$ssfamille','$tva')","aff");
		print "<font color=$color> $neptune;$pr_cd_pr;$pr_desi $info;<b>$qte</b>;$pr_sup</font>;$pr_type<br></a>";
	}
}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}
