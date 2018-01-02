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
	print "<body><center><h1>IMPORTATION VENDU (ASIS.ZIP) NAVIRE</h1><br>";

	print "<a name=haut></a>";
	print "<br> selectionner un bateau une date (ou la dernière date pour une vente d'une semaine) puis faire un copier coller d'openoffice<br><br>";
	print "<form method=post>";
	print "<br><h1> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";
        print "<br><input type=reset>";
    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form></body>";
}
	

if ($action eq "import"){
	(@tab)=split(/\n/,$texte);
	$ok=0;
	if ($texte ne ""){
		foreach $ligne (@tab){
	# 		print "<font color=red>$ligne</font><br>";
	
			while($ligne=~s/^ //){};
			while($ligne=~s/^\t//){};
			($navire,$date,$null,$heure,$caisse,$null,$pr_cd_pr,$desi,$qte,$null,$prac,$null,$null,$null,$null,$null,$null,$priv)=split(/;/,$ligne);
			if ($pr_cd_pr eq ""){next;}
			$nep_cd_pr=$pr_cd_pr;
			$query="select pr_cd_pr,pr_desi,pr_sup,pr_type from produit where pr_cd_pr='$pr_cd_pr'";
			$sth2=$dbh->prepare($query);
			$sth2->execute;
			($pr_cd_pr,$pr_desi,$pr_sup,$pr_type)=$sth2->fetchrow_array;
			if ($pr_cd_pr <100000){$pr_desi="<font color=red>$desi</font>";$pr_cd_pr=$nep_cd_pr; }
                        $qte+=0;
                        $priv+=0;
                        $prac+=0;
                        ($jour,$mois,$an)=split(/\//,$date);
                        $date="$an-$mois-$jour";	
			print "$date $pr_cd_pr $pr_desi $qte $prac $priv <br>";
			$qte_anc=&get("select vda_qte from vendu_corsica_auto where vda_navire='$navire' and vda_date='$date' and vda_cd_pr='$pr_cd_pr'");
			$priv_anc=&get("select vda_vte from vendu_corsica_auto where vda_navire='$navire' and vda_date='$date' and vda_cd_pr='$pr_cd_pr'");
			$qte+=$qte_anc;
			$pric+=$priv_anc;
			&save("insert ignore into vendu_corsica_auto values ('$date','$pr_cd_pr','$navire','$qte','$prac','$priv')","aff");
		}
	}
}

