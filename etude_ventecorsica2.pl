#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;

require "./src/connect.src";


	$query="select vdu_cd_pr,sum(vdu_qte) as qte from vendu_corsica_mois,produit where vdu_cd_pr=pr_cd_pr and vdu_mois>=601 and vdu_mois<=609 and vdu_famille like 'PARFUMS' group by vdu_cd_pr order by qte desc limit 60";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr)=$sth->fetchrow_array){
		@liste06[$i++]=$pr_cd_pr;
	}
	$i=0;
	print "<table border=1 cellspacing=0><tr><th>position</th><th>&nbsp;</td><th>evolution</th></tr>";
	$query="select vdu_cd_pr,sum(vdu_qte) as qte,pr_desi from vendu_corsica_mois,produit where vdu_cd_pr=pr_cd_pr and vdu_mois>=701 and vdu_mois<=709 and vdu_famille like 'PARFUMS' group by vdu_cd_pr order by qte desc limit 60";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$null,$pr_desi)=$sth->fetchrow_array){
		$i++;
		$trouve=-1;
		for ($j=0;$j<60;$j++){
			if ( @liste06[$j]==$pr_cd_pr){$trouve=$j;}
		}
		$ecart=$trouve-$i;
		$signe="+";
		$signe="" if ($ecart<0);
		if ($trouve==-1){
			$ecart="entree";
			$signe="";
		}
		 
		
		print "<tr><td>$i</td><td>$pr_cd_pr $pr_desi</td><td>$signe$ecart</td></tr>";
	}
	print "</table>";

exit;









@liste1=("MEGA 1","MEGA 2","MARINA","MEGA 3","REGINA","VICTORIA","VERA");
 @liste1=("MEGA 2");

foreach $navire (@liste1){
	@liste06=();
	@liste07=();
	@tabec=();
	$nb=$egal=0;
	$query="select distinct vdu_cd_pr from vendu_corsica_mois where vdu_mois>=601 and vdu_mois<=609 and vdu_navire='$navire' and vdu_famille like 'PARFUMS' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr)=$sth->fetchrow_array){
		push (@liste06,$pr_cd_pr);
	}
	$query="select distinct vdu_cd_pr from vendu_corsica_mois where vdu_mois>=701 and vdu_mois<=709 and vdu_navire='$navire' and vdu_famille like 'PARFUMS' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr)=$sth->fetchrow_array){
		if (grep /$pr_cd_pr/,@liste06){
			push (@liste07,$pr_cd_pr);
		}
	}
	@liste07=("3423470317527","3348900588233","3360372058861","737052351100","88300165605","3352818518008","3595200501138","3365440206663","3352818517001","3145891236309");	
	@liste07=("3423470317527");	

	print "<table border=1 cellspacing=0><tr><td>mois</td>";
	for ($mois=1;$mois<=9;$mois++){
		$color="white";
		$reste=int($mois%2);
		if ($reste){$color="yellow";}
		print "<th bgcolor=$color>$mois<br>06</th><th bgcolor=$color>$mois<br>07</th>";
	}
	print "</tr>";        
        foreach $pr_cd_pr (@liste07){
		$desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
		print "<tr><td>$pr_cd_pr $desi</td>";
		for ($mois=1;$mois<=9;$mois++){
			$color="white";
			$reste=int($mois%2);
			if ($reste){$color="yellow";}

			$mois06=$mois+600;
			$mois07=$mois+700;
			$nb++;
			$qte06=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire like '$navire' and vdu_famille like 'PARFUMS' and vdu_mois=$mois06 and vdu_cd_pr=$pr_cd_pr","af");
			$qte07=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire like '$navire' and vdu_famille like 'PARFUMS' and vdu_mois=$mois07 and vdu_cd_pr=$pr_cd_pr","af");
			 print "<td bgcolor=$color>$qte06</td><td bgcolor=$color>$qte07</td>";
			if ($qte06==$qte07){$egal++;}
			$ecart=$qte07-$qte06;
			$ecart=0-$ecart if ($ecart<0);
			$tabec[3]++ if ($ecart<=3 && $ecart>0);
			$tabec[5]++ if ($ecart>3 && $ecart<=5);
			 if ($ecart>5){
			 	$tabec[10]++;
			 	$tabec[50]++ if int($ecart*200/($qte06+$qte07))>50;
			 	}
	
		}
		 print "</tr>";
	}
	 print "</table>";
	print "<br><b>$navire</b><br>";
	print "nombre de comparaison:$nb<br>";
	$pour=int($egal*100/$nb);
	print "nombre d'egalité:$egal $pour%<br>";
	$pour=int($tabec[3]*100/$nb);
	print "nombre d'ecart<=3:$tabec[3] $pour%<br>";
	$pour=int($tabec[5]*100/$nb);
	print "nombre d'ecart>3 et <=5:$tabec[5] $pour%<br>";
	$pour=int($tabec[10]*100/$nb);
	print "nombre d'ecart>5:$tabec[10] $pour%";
	$pour=int($tabec[50]*100/$tabec[10]);
	print " avec l'ecart>50% des ventes:$pour%<br>";

}
