#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require ("outils_corsica.pl");
require ("outils_perl2.pl");

print $html->header;
$navire=$html->param("navire");
$produit=$html->param("produit");
$action=$html->param("action");
$choix=$html->param("choix");

require "./src/connect.src";
print "<center><h3>Tableau de bord navire </h3><br><br>";
 print "<title>tableau de bord</title>";
if ($choix eq ""){
	print "<form><br> Votre Choix<br>";
   	print "<br><select name=choix>\n";
    	print "<option value=livraison>Controle de la livraison\n";
    	print "<option value=Commande>Controle de la commande fournisseur\n";
    	print "<option value=stock>Controle du stock a bord\n";
	print "<option value=vente>Controle de la reception des vendus\n";
	print "<option value=inven>Controle de la reception de l'inventaire\n";
	# print "<option value=vente>Controle de la mise reception de l'inventaire\n";

	print "</select><br>\n";
	print "<br><input type=submit></form>";
}

if ($choix eq "livraison"){&livraison();}
if ($choix eq "stock"){&stock_navire();}
if ($choix eq "vente"){&vente_navire();}
if ($choix eq "inven"){&inven_navire();}

sub inven_navire {
	# print &semaine('2007-02-11');
	print "<table border=1 cellspacing=0>";
	$max=&semaine("2008-12-31");
	print "<tr><th>semaine</th>";
	for ($i=1;$i<=$max;$i++){
		print "<th align=center>$i</td>";
	}
	print "</tr>";
	
	$debut=&jourdelan();
	$query="select nav_nom from navire order by nav_nom";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($nav_nom) = $sth->fetchrow_array) {
		print "<tr><th>$nav_nom</th>";
		@tab=();
		$query="select nav_date,sum(nav_qte) from navire2,produit where nav_nom=\"$nav_nom\" and nav_type=1 and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) and nav_date>='$debut' group by nav_date ";
		$sth2 = $dbh->prepare($query);
		$sth2->execute;
		# print "$query<br>";
		while (($nav_date,$nav_qte) = $sth2->fetchrow_array) {
			$tab[&semaine($nav_date)]=$nav_qte;
		}
		for ($i=1;$i<=$max;$i++){
			if ($tab[$i]==0){
				$coef=&get("select se_coef from semaine2 where se_no='$i' and se_navire=\"$nav_nom\"","af")+0;
				if ($coef==0){
					print "<td bgcolor=#efefef>&nbsp;</td>";}
				else {print "<td bgcolor=red>&nbsp;</td>";}
			}
			else { print "<td align=right>$tab[$i]</td>";}
		}
		print "</tr>";			
	}
	print "</table>";
}
sub vente_navire {
	# print &semaine('2007-02-11');
	print "<table border=1 cellspacing=0>";
	$max=&semaine();
	print "<tr><th>semaine</th>";
	for ($i=1;$i<=$max;$i++){
		print "<th align=center>$i</td>";
	}
	print "</tr>";
	
	$debut=&jourdelan();
	$query="select nav_nom from navire order by nav_nom";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($nav_nom) = $sth->fetchrow_array) {
		print "<tr><th>$nav_nom</th>";
		@tab=();
		$query="select nav_date,sum(nav_qte) from navire2,produit where nav_nom=\"$nav_nom\" and nav_type=2 and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and (pr_sup!=4 and pr_sup!=5) and nav_date>='$debut' group by nav_date ";
		$sth2 = $dbh->prepare($query);
		$sth2->execute;
		# print "$query<br>";
		while (($nav_date,$nav_qte) = $sth2->fetchrow_array) {
			$tab[&semaine($nav_date)]=$nav_qte;
		}
		for ($i=1;$i<=$max;$i++){
			if ($tab[$i]==0){
				$coef=&get("select se_coef from semaine2 where se_no='$i' and se_navire=\"$nav_nom\"","af")+0;
				if ($coef==0){
					print "<td bgcolor=#efefef>&nbsp;</td>";}
				else {print "<td bgcolor=red>&nbsp;</td>";}
			}
			else { print "<td align=right>$tab[$i]</td>";}
		}
		print "</tr>";			
	}
	print "</table>";
}
	
sub stock_navire {
	print "<form>";
	&select_navire("$navire");
	print "<input type=hidden name=choix value=stock>";
	print "<input type=hidden name=action value=stock><input type=submit>";
	print "</form>";
	if ($action eq "stock")
	{
		$qte_parfum=0;		
		$query="select nav_cd_pr from navire2,produit where nav_nom=\"$navire\" and nav_type=0 and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3 or pr_sup=5)";
		$sth = $dbh->prepare($query);
		$sth->execute;
		while (($produit) = $sth->fetchrow_array) {
			%calcul=&table_navire("$navire",$produit);
			# print "$produit;".$calcul{"stock_navire"}."<br>";
			$qte_parfum+=$calcul{"stock_navire"};
			$qte_parfum_plancher+=$calcul{"stock_plancher"};
			$dernier_vendu+=$calcul{"dernier_vendu"};
			
		}
		print "qte parfum à bord:$qte_parfum qte commercial:$qte_parfum_plancher<br>";
		$theo=$qte_parfum_plancher-$dernier_vendu;
		print "derniere semaine de vente:$dernier_vendu qte commercial theorique:$theo<br>";
		$ecart=$qte_parfum-$theo;		
		print "ecart:$ecart<br>"	
	}
}	

sub livraison {
	print "<form>";
	&select_navire("$navire");
	print "<br> choix d'un produit <br><input type=text size=20 name=produit><br>";
# &select_produit();
	print "<input type=hidden name=choix value=livraison>";
	print "<input type=hidden name=action value=prod><input type=submit>";
	print "</form>";
	
	if ($action eq "prod")
	{
		%calcul=&table_navire("$navire",$produit);
		$desi=&get("select pr_desi from produit where pr_cd_pr=$produit");
		print "<table border=0><tr><td align=left>";
		print "$navire $prod $desi<br>";
		print "<br>";
		print "date du dernier inventaire:";
		print  $calcul{"date_mini"};
		print "<br>";
		print "premier numero de facture apres le dernier inventaire:";
		print  $calcul{"nofact_mini"};
		print "<br>";
		print "quantite livré:";
		print  $calcul{"liv"};
		print "<br>";
		print "quantite vendu:";
		print  $calcul{"vendu"};
		print "<br>";
		print "quantite maximum vendu sur une semaine:";
		print  $calcul{"max"};
		print "<br>";
		print "semaine de reference:";
		print  $calcul{"semaine"};
		print " coef1:";
		print  $calcul{"coef1"};
		print " coef2:";
		print  $calcul{"coef2"};
		print " coef3:";
		print  $calcul{"coef3"};
		print " coef4:";
		print  $calcul{"coef4"};
		print "<br>";		
		print "Stock navire:";
		print  $calcul{"stock_navire"};
		print "<br>";
		print "prevision de vente semaine:".$calcul{"semaine"}." et ".$calcul{"semaine"}."+1:";
		print  $calcul{"prev"};
		print "<br>";
		print "stock plancher:";
		print  $calcul{"stock_plancher"};
		print "<br>";
		print "stock alerte retenu:";
		print  $calcul{"stockmini"};
		print "<br>";
		print "qte a livre:";
		print  $calcul{"alivrer"};
		print "<br>";
		print "qte pour la semaine suivante:";
		print  $calcul{"stockmini_suiv"};
		print "<br>";
		print "</td></tr></table>";
	        print "<br> <a href=http://ibs.oasix.fr/cgi-bin/tableau_de_bord.pl>retour</a>";
		}
}                                            22