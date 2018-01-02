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
	print "<body><center><h1>IMPORTATION VENDU (DETAIL_VENT.xls) NAVIRE</h1><br>";
	print "format<pre>";
	print "Navire : REGINA                                   			
	P E R I O D E :       du   01/01/07       au   07/01/07			
	181	PUBLIC	null	1
	TOTAL PAR";
	print "</pre>";			

	print "<a name=haut></a>";
	print "<br> selectionner un bateau une date (ou la dernière date pour une vente d'une semaine) puis faire un copier coller d'openoffice<br><br>";
	print "<form method=post>";
	print "<br><h1> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
        print "</h1><font color=red>mise a jour <input type=checkbox checked name=save></font>";
   	print "<br><select name=type>\n";
    	print "<option value=0>0 stock commercial";
    	print "<option value=1>1 inventaire";
    	print "<option value=2 selected>2 vendu par semaine";
  	print "<option value=3>2 vendu pour deux semaines";
  	print "<option value=4>4 vendu par mois";
  	print "<option value=7>7 temporaire";
       	print "</select><br>\n";
   
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
   	&select_date();
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";
        print "<br><input type=reset>";
    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form><a href=#haut>haut</a></body>";
}
	

if ($action eq "import"){
	if ($mois<10){$mois='0'.$mois;}
	if ($jour<10){$jour='0'.$jour;}
	$date=$an.'-'.$mois.'-'.$jour;
	$date2=$date;
	print $date."<br>";
  	# 15 jours
  	if ($type==3){
  		$date2=&get("select date_sub('$date',interval 7 day)");
  		print $date2."<br>";	  	
  	}
	(@tab)=split(/\n/,$texte);
	$ok=0;
	if ($texte ne ""){
		foreach $ligne (@tab){
	# 		print "<font color=red>$ligne</font><br>";
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
				if ($navire_ex eq $navire){$ok=1;}
			}	
			if ((grep /^P E R I O D /,$ligne)||(grep /^PERIOD/,$ligne)){
				if ($ok==0){					
					print "<font color=red><h1>BATEAU INVALIDE </h1>";
					exit;
				}
				($null,$date_ex)=split(/au   /,$ligne);
				($jour_ex,$mois_ex,$an_ex)=split(/\//,$date_ex)  ;
				$an_ex+=2000;
				$date_ex=$an_ex."-".$mois_ex."-".$jour_ex;
				print "<b>$date_ex</b><br>";
				if ($date_ex eq $date){$ok=2;}
							
				if ($save eq "on"){
					if ($ok==2){				
						if ($type !=3){
							&save ("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=$type","aff");
						}
						else
						{
							&save ("delete from navire2 where nav_nom='$navire' and (nav_date='$date' or nav_date='$date2') and nav_type=2","aff");
	
						}
						
					}
					else
					{
						print "<font color=red><h1> DATE INVALIDE </h1>";
						exit;
					}
				}
			}
	# 		print "$ligne <br>";		
	
			if ((! grep /PUBLIC/,$ligne)&&(! grep /EQUIPAGE/,$ligne)&&(! grep /OFFICIERS/,$ligne)&&(! grep /Remise/,$ligne)){next;}
			if (($save eq "on")&&($ok !=2)){
				print "<font color=red><h1> FORMAT FICHIER INVALIDE </h1>";
				exit;
			}	
			$ligne=~s/([A-Z])/ ;$1/;	
			$ligne=~s/PUBLIC/PUBLIC ;/;	
			$ligne=~s/EQUIPAGE/EQUIPAGE ;/;	
			$ligne=~s/OFFICIERS/OFFICIERS ;/;	
			$ligne=~s/Remise/Remise ;/;	
	
	# print "$ligne <br>";		
			($neptune,$part1,$part2)=split(/ ;/,$ligne);
			$part2=~s/\t/;/g;
	# print "$part2<br>";	
			($null,$null,$qte)=split(/;/,$part2);
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
			
			$query="select pr_desi,pr_sup,pr_type from produit where pr_cd_pr='$pr_cd_pr'";
			$sth2=$dbh->prepare($query);
			$sth2->execute;
			($pr_desi,$pr_sup,$pr_type)=$sth2->fetchrow_array;
			
			$color="black";
			$info="";
			if (($pr_type==1 or $pr_type==5)&& $pr_sup!=4 && $pr_sup!=5){
				$livre=&get("select count(*) from comcli,infococ2 where coc_cd_pr=$pr_cd_pr and coc_no=ic2_no and ic2_cd_cl=500 and ic2_date>1070101","af")+0;
				if ($livre==0){$color="red"; # parfumerie non livre et non paul
					$info="parfumerie non livrée et non paul";
				}
				$nbparf+=$qte;
	# 			print "$neptune;$pr_cd_pr;$pr_desi;$qte<br>";
				
			}
			
			if ($pr_desi eq ''){
				$query="select nep_codebarre,nep_desi,nep_prac,nep_prx_vte from neptune where nep_cd_pr='$neptune'";			 
				#print "$query<br>";
				$sth2=$dbh->prepare($query);
				$sth2->execute;
				($pr_cd_pr,$pr_desi,$nep_prac,$nep_prx_vte)=$sth2->fetchrow_array;
				if ($pr_desi ne "") {
					while ($pr_desi=~s/'/ /){};
					&save("insert ignore into produit value ('$pr_cd_pr','$pr_desi','0','0','0','0','0','0','4','$nep_prx_vte','0','5','0','$nep_prac','0','0','0','0','0','0','0','0','12','0','0','$pr_codebarre')","af");
				}
				else {
					$color="red";
					$pr_desi=$part1;
					chop($neptune);
					chop($pr_desi);
					while($pr_desi=~s/ /_/){};
					while($pr_desi=~s/\t\t/\t/){};
					while($pr_desi=~s/\n//){};
					($desi,$pv)=split(/\t/,$pr_desi);
					print "<a href=update_neptune.pl?neptune='$neptune'&desi='$desi'&pv='$pv'>$ligne produit inconnu</a>";
				}
			}	
			print "<font color=$color> $neptune;$pr_cd_pr;$pr_desi $info;<b>$qte</b>;$pr_sup</font>;$pr_type<br></a>";
			if (($pr_desi ne $part1)&&($save eq "on")){
				# 15 jours
				$qte1=$qte;
				if ($type==3) {
					$qte1=int($qte/2);
					$qte2=$qte-$qte1;
					$qte2+=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date='$date2' and nav_type=$type")+0;			 
					$query="replace into navire2 values ('$navire','$pr_cd_pr','$date2','2','$qte2','9999')";
					# print "$query<br>";		
					$sth=$dbh->prepare($query);
					$sth->execute();
					$qte1+=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date='$date' and nav_type=$type")+0;			 
					$query="replace into navire2 values ('$navire','$pr_cd_pr','$date','2','$qte1','9999')";
					# print "$query<br>";		
					$sth=$dbh->prepare($query);
					$sth->execute();
				}
				else
				{
					$qte1+=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date='$date' and nav_type=$type")+0;			 
					$query="replace into navire2 values ('$navire','$pr_cd_pr','$date','$type','$qte1','9999')";
					# print "$query<br>";		
					$sth=$dbh->prepare($query);
					$sth->execute();
				}
			}
		}
# 	if ($type==7){
# 			print "<hr></hr><br><table>";
# 			$query="select nav_cd_pr,nav_qte from navire2,produit where nav_nom='$navire' and nav_date='$date' and nav_type=$type and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5)";			 
# 		 	print $query;
# 		 	$sth=$dbh->prepare($query);
# 		 	$sth->execute;
# 			while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
# 			print "<tr><td>$pr_cd_pr</td><td>$qte</td></tr>";
# 			}
# 			print "</table>";
# 	}
	}
	else
	{
		# via fichier tva
  		$date2=&get("select date_sub('$date',interval 6 day)");
# 		$query="select nav_nom from navire";  		
# 		$sth2=$dbh->prepare($query);
# 		$sth2->execute();
# 		while ($navire=$sth2->fetchrow_array){
			$total=0;
			&save ("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=2","af");
			$query="select tva_refour,sum(tva_qte) from corsica_tva,produit where tva_nom='$navire' and tva_date>='$date2' and tva_date<='$date' and tva_refour=pr_cd_pr and ((pr_type=1 or pr_type=5)&& pr_sup!=4 && pr_sup!=5) group by tva_refour";
#  			print "$query";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($tva_cd_pr,$tva_qte)=$sth->fetchrow_array){
				&save("replace into navire2 values ('$navire','$tva_cd_pr','$date','2','$tva_qte','9999')","af");
				$total+=$tva_qte;
			}
			if ($total!=0){print "$navire :$total<br>";}
# 		}
	}

}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}
