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

require "./src/connect.src";

if ($action eq ""){
	print "<body><center><h1>IMPORTATION MAIL NAVIRE</h1><br>";
	print "<br> selectionner un bateau une date (ou la dernière date pour une vente d'une semaine) puis faire un copier coller du mail<br><br>";
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
   	&select_date();
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";

    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form></body>";
}
	

if ($action eq "import"){
	print "<center><h1>$navire</h1>";
	if ($mois<10){$mois='0'.$mois;}
	if ($jour<10){$jour='0'.$jour;}
	$date=$an.'-'.$mois.'-'.$jour;
        print "<table border=1 cellspacing=0><tr bgcolor=lightblue><th>neptune</th><th>code barre</th><th>designation</th><th>inventaire</th><th>vendu entre 01/01/06 et inventaire</th><th>inventaire</th><th>prix achat</th><th>valeur</th></tr> ";
	(@tab)=split(/\n/,$texte);
	foreach $ligne (@tab){
		($neptune,$desi,$qte)=split(/\t/,$ligne);
		$neptune+=0;
		$qte+=0;
		if ($neptune==0){next;}
		if ($qte==0){next;}
		$pr_type=&get("select pr_type from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
 		if (($pr_type!=1)&&(pr_type!=5)){next;}
		$pr_desi=&get("select pr_desi from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$pr_prac=&get("select pr_prac/100 from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$pr_sup=&get("select pr_sup from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$pr_cd_pr=&get("select pr_cd_pr from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$color="white";
		if ($pr_desi eq ''){
			$color="pink";
			$pr_desi=$desi;
		}	

		print "<tr bgcolor=$color><td align=right>$neptune</td><td align=right>$pr_cd_pr</td><td align=right>$pr_desi </td>";
		$date_mini=&get("select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=1","af");
	        $date_mini_simple=&datesimple($date_mini);	
	        $date_maxi_simple=&datesimple($date);	
	        
	        $icc_mini=&get("select min(ic2_no) from infococ2 where ic2_com1='$navire' and ic2_date>'$date_mini_simple' and ic2_date<10000000","af");
		if ($icc_mini eq "") {$icc_mini=99999999999;}

                $inv=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr=$pr_cd_pr")+0;
	
                $qte_livre=&get("select floor(sum(coc_qte)/100) from comcli,infococ2 where coc_cd_pr='$pr_cd_pr' and coc_qte>0 and coc_no=ic2_no and ic2_com1='$navire' and ic2_date>'$date_mini_simple' and ic2_date<$date_maxi_simple","af")+0;
	
                $qte_vendu=&get("select nav_qte from navire2 where nav_cd_pr='$pr_cd_pr' and nav_type=20 and nav_nom='$navire'","af")+0;
		$stock=$qte-$qte_vendu+0;
		print "<td align=right>$qte</td><td align=right>$qte_vendu</td><td align=right>$stock</td>";
 		print "<td align=right>$pr_prac</td>";
		$val=$pr_prac*$stock;	
 		print "<td align=right>$val</td>";
		print "</tr>";

		$total+=$val;
	}		

print "</table><br> valeur du stock:$total<br>";


}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}
