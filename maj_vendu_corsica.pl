#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";

open(FILE,"vendu_712.csv");
@tab=<FILE>;
 &go(712);
&save("update vendu_corsica_mois,produit set vdu_famille='PARFUMS',vdu_sous_famille='FEMME'   where vdu_famille='DIVERS' and vdu_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5)");
&save("update vendu_corsica_mois set vdu_sous_famille='HOMME' where vdu_cd_pr=3360372100515");
&save("update vendu_corsica_mois set vdu_sous_famille='HOMME' where vdu_cd_pr=3760048930987");
&save("update vendu_corsica_mois set vdu_sous_famille='HOMME' where vdu_cd_pr=3423470485950");
&save("update vendu_corsica_mois set vdu_sous_famille='HOMME' where vdu_cd_pr=3423470485882");
&save("update vendu_corsica_mois set vdu_sous_famille='HOMME' where vdu_cd_pr=3346131400041");
&save("update vendu_corsica_mois set vdu_sous_famille='FEMME' where vdu_cd_pr=737052081731");
&save("update vendu_corsica_mois set vdu_sous_famille='FEMME' where vdu_cd_pr=737052028439");
&save("update vendu_corsica_mois set vdu_sous_famille='FEMME' where vdu_cd_pr=88300162550");
&save("update vendu_corsica_mois set vdu_sous_famille='FEMME' where vdu_cd_pr=737052099477");
&save("update vendu_corsica_mois set vdu_sous_famille='FEMME' where vdu_cd_pr=737052655369");
&save("update vendu_corsica_mois set vdu_sous_famille='FEMME' where vdu_cd_pr=3365440246713");

close(FILE);
print "ok";

sub go
{
$mois=$_[0];
 &save ("delete from vendu_corsica_mois where vdu_mois=$mois");

   foreach (@tab){
	 # print "$_<br>";
	 while ($_=~s/"//){};
	 ($neptune,$desi,$prac,$navire,$type,$null,$qte,$vte,$null,$famille,$sous_famille)=split(/;/,$_);
	 $prac=~s/,/./;
	 $vte=~s/,/./;
	 $navire=int($navire/100);
	 if ($navire == 4){$navire="MARINA";}
	 if ($navire == 8){$navire="VICTORIA";}
	 if ($navire == 1){$navire="REGINA";}
	 if ($navire == 9){$navire="MEGA 1";}
	 if ($navire == 12){$navire="MEGA 2";}
	 if ($navire == 7){$navire="EXPRESS 3";}
	 if ($navire == 2){$navire="SERENA II";}
	 if ($navire == 3){$navire="EXPRESS 2";}
	 if ($navire == 11){$navire="SARDINIA EXPRESS";}
	 if ($navire == 6){$navire="VERA";}
	 if ($navire == 15){$navire="MEGA 4";}
	 if ($navire == 14){$navire="MEGA 3";}
	 if ($navire == 16){$navire="MEGA 6";}
	

	 # $pr_cd_pr=&get("select nep_codebarre from neptune where nep_cd_pr='$neptune' and nep_codebarre in (select nav_cd_pr from navire2 where nav_type=1 and nav_date>'2007-01-01')","af");
	 
	 $nbref=0+&get("select count(*) from neptune where nep_cd_pr='$neptune'","af");
         if ($nbref==0){
	 	print "<font color=red>$neptune $desi</font><br>";
	 	next;
	 }
         if ($nbref==1){
	 	 $pr_cd_pr=&get("select nep_codebarre from neptune where nep_cd_pr='$neptune'","af");
	}
         if ($nbref>1){
	 	# modifié le "22-10-07" suite a des code barre inconnu non testé
	 	# $nbref=&get("select count(*) from neptune where nep_cd_pr='$neptune' and nep_codebarre in (select nav_cd_pr from navire2 where nav_type=1 and nav_date>'2007-01-01')","af");
                $query="select nav_cd_pr,count(*) as qte  from navire2 where nav_type=1 and nav_date>'2007-01-01' and nav_cd_pr in (select nep_codebarre from neptune where nep_cd_pr='$neptune') group by nav_cd_pr order by qte desc limit 1";
                $sth=$dbh->prepare($query);
		$sth->execute();
		($produit,$nbref)=$sth->fetchrow_array;
                if ($nbref eq ""){
               		$pr_cd_pr=&get("select nep_codebarre from neptune where nep_cd_pr='$neptune'","af");
                }
                else
                {
	 	 	$pr_cd_pr=$produit;
		}
	}
	 
	 
	 print "$navire $neptune $pr_cd_pr $desi $qte<br>";
	 $prac*=$qte;	
	 $qte_old=0+&get("select vdu_qte from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $qte+=$qte_old;
	 $prac_old=0+&get("select vdu_prac from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $prac+=$prac_old;
	 $vte_old=0+&get("select vdu_vte from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $vte+=$vte_old;
	 
	 &save("replace into vendu_corsica_mois values ('$mois','$pr_cd_pr','$type','$navire','$qte','$famille','$sous_famille','$prac','$vte')","af");
 }
 
}
