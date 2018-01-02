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
        print "<table border=1 cellspacing=0><tr bgcolor=lightblue><th>neptune</th><th>code barre</th><th>designation</th><th>dernier inventaire</th><th>livré</th><th>vendu</th><th>inventaire</th><th>theorique</th><th>ecart</th></tr> ";
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
		$pr_prac=&get("select pr_prac from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$pr_sup=&get("select pr_sup from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$pr_cd_pr=&get("select pr_cd_pr from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$color="white";
		# if (($pr_sup==0)||($pr_sup==5)){ $color="white";}
		# else {$color="lightblue";}
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
	
                $qte_vendu=&get("select sum(nav_qte) from navire2 where nav_cd_pr='$pr_cd_pr' and nav_type=2 and nav_date>'$date_mini' and nav_date<='$date' and nav_nom='$navire'","af")+0;
		print "<td align=right>$inv</td><td align=right>$qte_livre</td><td align=right>$qte_vendu</td><td align=right>$qte</td>";
 		$stock=$inv+$qte_livre-$qte_vendu+0;
		print "<td align=right>$stock</td>";
		$ecart=$qte-$stock;
		print "<td align=right>";
    		if ($ecart<0){
			print "<font color=red>";
		}
		if ($ecart==0){$bon++;}
		$nb++;
	 	print "$ecart</td>";
  		print "</tr>";
		$total_stock+=$stock;
		$valeur+=($stock*$pr_prac)/100;
		$total_qte+=$qte;
		$total_ecart+=$ecart;
		$total_valeur+=($ecart*$pr_prac)/100;
		$table{$pr_cd_pr}+=$qte;
	}
print "<tr><th>total</th><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><th align=right>$total_stock</th><th align=right>$total_qte</th><th align=right>$total_ecart</th></tr></table>";
print "<br> valeur de l'ecart:$total_valeur<br>";

	print "<br>Liste des produits avec un stock theorique et non inventoriés<br>";
        print "<table border=1 cellspacing=0><tr bgcolor=lightblue><th>neptune</th><th>code barre</th><th>designation</th><th>dernier inventaire</th><th>livré</th><th>vendu</th><th>theorique</th></tr> ";
	$query="select coc_cd_pr,floor(sum(coc_qte)/100) from comcli,infococ2 where coc_qte>0 and coc_no=ic2_no and ic2_com1='$navire' and ic2_date>'$date_mini_simple' and ic2_date<'$date_maxi_simple' group by coc_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($coc_cd_pr,$qte_livre)=$sth->fetchrow_array){
		
		if ($table{$coc_cd_pr}>0){next;}
		$pr_type=&get("select pr_type from produit where pr_cd_pr='$coc_cd_pr'");  
 		if (($pr_type!=1)&&(pr_type!=5)){next;}
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$coc_cd_pr'");  
		$pr_sup=&get("select pr_sup from produit where pr_cd_pr='$coc_cd_pr'");  
		$pr_prac=&get("select pr_prac from produit where pr_cd_pr='$coc_cd_pr'");  
		$neptune=&get("select nep_cd_pr from neptune where nep_codebarre='$coc_cd_pr'");  
                $inv=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr=$coc_cd_pr")+0;
	        $qte_vendu=&get("select sum(nav_qte) from navire2 where nav_cd_pr='$coc_cd_pr' and nav_type=2 and nav_date>'$date_mini' and nav_date<='$date' and nav_nom='$navire'","af")+0;
		$stock=$inv+$qte_livre-$qte_vendu+0;
		if ($stock==0){next;}
		print "<tr><td align=right>$neptune</td><td align=right>$coc_cd_pr</td><td align=right>$pr_desi </td>";
		print "<td align=right>$inv</td><td align=right>$qte_livre</td><td align=right>$qte_vendu</td>";
 		print "<td align=right>$stock</td></tr>";
		$ecart2+=$stock;
		$valeur+=($stock*$pr_prac)/100;
		$total_valeur2+=((0-$stock)*$pr_prac)/100;
		$nb++;
	}
print "<tr><th>total</th><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><th align=right>$ecart2</th></tr>";
print "</table>";
print "<br> valeur de l'ecart:$total_valeur2<br>";
$pour=int($bon*100/$nb);
print "pourcentage de produit ou le stock correspond:$pour%<br>";
$pour=int(($total_valeur+$total_valeur2)*100/$valeur);
print "ecart en valeur:$pour%<br>";
print "Valeur du stock theorique:$valeur<br>";

}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}
