#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

print $html->header;

$action=$html->param("action");
$four=$html->param("four");
$option=$html->param("option");

if (($four eq "")||($four eq "TOUS")){$four="%";}
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>stock alerte</title></head>";
print "<body link=black>";


require "./src/connect.src";

# top 120
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 120";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
	push (@top120,$pr_cd_pr);
}

if ($action eq ""){
	print "<form> Code fournisseur ? <select name=four>";
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from ordre,fournis,produit where (pr_cd_pr=ord_cd_pr and pr_four=fo2_cd_fo) or (pr_four=2070) group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
        print "<option value='TOUS'>TOUS\n";
    	
    	print "</select>";
	print "<br><input type=submit>";
	print "<input type=hidden name=action value=phase1></form>";
}

if ($action eq "phase1"){

# 	 print "<table cellspacing=0 border=1>";
# 	print "<tr><th>Code couleur</th><th>Explication</th><th>action à entreprendre</th></tr>";
# 	print "<tr><td bgcolor=#FFFF33 width=100><td>Commande cours stock suffisant pour le pick avion , rupture dans moins d'une semaine</td><td>Relancer le fournisseur</tr></tr>";
# 	print "<tr><td bgcolor=#FFCC33 width=100><td>Stock suffisant pour le pick avion , qte en commande trop faible</td><td>Attendre la livraison et commander aussitot</tr></tr>";
# 	print "<tr><td bgcolor=#FF99FF width=100><td>Produit en rupture</td><td>Relancer le fournisseur</tr></tr>";
# 	print "<tr><td bgcolor=#33FFFF width=100><td>Produit à commander</td><td>Faire la commande s'il n'y a pas de commande en cours</tr></tr>";
# 	print "<tr><td bgcolor=#FF0033 width=100><td>Produit à commander urgence</td><td>Faire la commande</tr></tr>";
# 	print "<tr><td bgcolor=#EFEFEF width=100><td>Produit délisté</td><td>Ne rien faire sauf si le nouveau référencement est prévu à une date lointaine</tr></tr>";

# 	print "</table><br>";
	$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit,fournis where ((pr_cd_pr >100000000  and (pr_type=1 or pr_type=5)) or (pr_cd_pr <100000000 and (pr_type!=1 and pr_type!=5))or pr_cd_pr=100751 or pr_cd_pr=220200) and (pr_sup=0 or pr_sup=3) and pr_four=fo2_cd_fo and fo2_delai>0 and pr_four like '$four'  order by pr_four";
	# print $query;
#  	 $query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where pr_cd_pr=3360372100515";
	$sth=$dbh->prepare($query);
	$sth->execute();
	&table();
}
elsif ($action eq "commande"){
	
	$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where pr_four='$four' and ((pr_cd_pr >100000000  and (pr_type=1 or pr_type=5)) or (pr_cd_pr <100000000 and (pr_type!=1 and pr_type!=5))or pr_cd_pr=100751 or pr_cd_pr=220200) and (pr_sup=0 or pr_sup=3) order by pr_four";
#  	 $query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where pr_cd_pr=3360372100515";

	if ($html->param("option")eq"tout"){
		$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where pr_four='$four' group by pr_cd_pr";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();

	&table();
	}

sub table{
	$dateref=$today-15;
	print "<form action=commande.pl><table border=1 cellspacing=0>";
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup)=$sth->fetchrow_array)
	{
		# commande en cours	
		# if (&get("select count(*) from commande where com2_cd_fo='$pr_four'")> 2){next;}
		# if (($pr_cd_pr >100000000)&&(! grep /$pr_cd_pr/,@top120)&&($pr_sup!=3)){ next;} pas de comamnde pour le flop
		$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_commande)=$sth2->fetchrow_array+0;
		$query="select max(com2_date) from commande where com2_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($date_commande)=$sth2->fetchrow_array-10000000;
		
		if ($date_commande<0){$date_commande=""};
		# if (($qte_commande >0)&&($action ne "commande")){next;}
		
		if ($pr_four ne $fournisseur){
			$sth3=$dbh->prepare("select fo2_cd_fo,fo2_add from fournis where fo2_cd_fo='$pr_four'");
			$sth3->execute();
			($fournisseur,$fo_nom)=$sth3->fetchrow_array;
			&titre();
		}
	


		# if ($nbligne++>20){&titre();}
		$corsica=0;
		$vendu=0;
		$pick=0;
		
		# recherche si un produit avec le meme code barre existe dans les references 6 chioffres
		$query="select pr_cd_pr from produit where pr_codebarre=$pr_cd_pr and pr_cd_pr<1000000 and pr_cd_pr in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1)";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$prodavion=$sth2->fetchrow_array;
		if ($pr_cd_pr<1000000){$prodavion=$pr_cd_pr;} # pour les produits non navire
		$stock_avion=0;
		if (($prodavion eq "")&&($option eq "aerien")){next;}
		
		%stock=&stock($pr_cd_pr,'','quick','');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	
		if ($prodavion ne ""){
			# pour les produit navire qui ont une correspondance avec un code avion on ajoute le stock avion
			%stock=&stock($prodavion,'','quick');
			$stock_avion=$stock{"pr_stre"};
			$query="select max(pi_qte) from pick where pi_cd_pr='$prodavion' and pi_date > DATE_SUB(now(),INTERVAL 15 DAY)";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$pick=$sth2->fetchrow_array+0; # stock enlair maximum depuis les 15 derniers jours
			if ($pr_sup==3 && $pick==0){$pick=60;}
			if ($pr_sup==2){$pick=0;}
			if (($pick==0)&&($option eq "aerien")){next;}
			# ventes avions sur les 15 derniers jours
			$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_cd_pr=pr_cd_pr and ro_code=v_code and v_date_jl>$dateref and v_rot=1 and pr_cd_pr='$prodavion' group by ro_cd_pr";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vendu)=$sth2->fetchrow_array+0;
			if ($pr_sup==2){$vendu=0;} # pour les produits delistés on force les ventes à zero
		}
		$color="white";
		$stock_ideal=$vendu+$pick+int($vendu/2);
		$besoin_avion=$stock_ideal-$stock_avion;
	 	
	 	# si il y a un besoin avion et une quantite en commande on l'affecte au besoin avion
	 	$reliquat_commande=$qte_commande;
	 	if (($qte_commande>0)&&($besoin_avion>0)){
	 		$reliquat_commande=$qte_commande-$besoin_avion;
	 		$besoin_avion-=$qte_commande;
	 		if ($reliquat_commande<0){$reliquat_commande=0;}
	 		}
		if ($besoin_avion<0){$besoin_avion=0;}
	 	
		print "<tr><td>";
		if ($action eq "phase1"){print "<a href=?action=commande&four=$pr_four>";}
		print "$pr_cd_pr</a> *";
		$query="select mag from mag where code=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($mag)=$sth2->fetchrow_array){print " $mag";}
		
		print "</td><td  bgcolor=$color><a href=fiche_produit.pl?pr_cd_pr=$pr_cd_pr&action=visu>$pr_desi</a></td>";
		print "<td align=right>";
		if ($pick>0){print "<font color=red>";}
		print "$pick</td><td align=right>$vendu</td>";
		print "<td align=right>&nbsp;";
		if ($qte_commande>0){print "<font color=red>$qte_commande ".&date($date_commande);}
		print "</td>";
		print "<td align=right>$stock_avion</td><td align=right>$stock_ideal</td><td align=right bgcolor=lightyellow><b>$besoin_avion </td>";
		
		################################ calcul du besoin navire #############################"
		
		$besoin=0;
		$besoin_suiv=0;
		# ce module se trouve a la fin du programme
		%cumul=&cumul_navire();
		
		# stock navire entrepot  
		print "<td align=right>$pr_stre</td>";
		# stock navire 
		print "<td align=right><a href=http://ibs.oasix.fr/cgi-bin/inv_mer.pl?produit=$pr_cd_pr&action=go target=_blank>".$cumul{"stock_navire"}."</a></td>";
		print "<td align=right><a href=http://ibs.oasix.fr/cgi-bin/livraison_prochaine.pl?produit=$pr_cd_pr&action=go target=_blank>".$cumul{"alivrer"}."</a></td>";
		print "<td align=right><a href=http://ibs.oasix.fr/cgi-bin/stock_mini_dieppe.pl?produit=$pr_cd_pr&action=go target=_blank>".$cumul{"stockmini_suiv"}."</a></td>";

		# $besoin_navire=$cumul{"alivrer"}+$cumul{"stockmini_suiv"}-$pr_stre;
		$besoin_navire=$cumul{"alivrer"}-$pr_stre+$cumul{"stockmini_suiv"};
		if ($besoin_navire<0){$besoin_navire=0;}
		print "<td align=right bgcolor=lightyellow><b>$besoin_navire</td>";
		$ecart=(0-$besoin_navire-$besoin_avion+$reliquat_commande);
		
		$query="select car_carton from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($carton)=$sth2->fetchrow_array;
		print "<td align=right>$carton</td>";
		$carton+=0;
		if ($carton==0){$carton=1;}
		# $proposition=(int(((($qte*2)-$qte_commande+$corsica-$pr_stre)/$carton)))*$carton+$carton;
		$proposition=int((0-$ecart)/$carton)*$carton;
		if ($ecart%$carton!=0){$proposition+=$carton;}
		if (($proposition<=0)||($ecart>0)){$proposition="";}
	
		print "<td><input type=text name=$pr_cd_pr value='$proposition' size=5></td>";

	if ($pr_sup==2){print "<td><font color=blue>délisté</td>";}
		if ($pr_sup==3){print "<td><font color=red>new</td>";}
		print "</tr>";
	}
	print "</table>";
	if ($action eq "commande"){
		print "<input type=hidden name=action value=creer>";
		print "<input type=hidden name=four value=$four>";
		print "<br><input type=submit value=\"Ok pour faire la commande\"</form>";
	}
}
sub titre {
	print "</table><table border=1 cellspacing=0><tr height=100><th colspan=19>$fournisseur $fo_nom</th></tr>";
	print "<tr><th>Code produit</th><th>Désignation</th><th>Pick</th><th>Ventes vab</th><th>En commande</th><th>Stock<br>avion<br>(Ent+air)</th><th>Stock ideal<br>avion</th><th>Besoin avion</th><th>Stock Navire (ent)</th><th>Stock navire (mer)</th><th>prochaine livraison</th><th>stock mini dieppe</th><th>Besoin navire</th><th>Packing</th><th>A commander</th><th>Particularite</th></tr>";
	$nbligne=0;
}


sub cumul_navire {
	# le calcul du besoin se fait ici dans le programme outils_corsica.pl subroutine table_navire
	my(%cumul);
	my(%calcul);
	my($stock_suiv,$alivrer,$besoin_suiv,$alivrer_suiv)=0;
	my($navire,$flag);
	my($semaine)=&semaine("");

	my ($sthg) = $dbh->prepare("select nav_nom from navire,semaine2 where nav_nom=se_navire and se_no>=$semaine and se_no<=$semaine+5 and se_coef!=0 group by nav_nom order by nav_nom"); 
	$sthg->execute;
	while (($navire) = $sthg->fetchrow_array) {
		%calcul=&table_navire($navire,$pr_cd_pr);
		$cumul{"stock_navire"}+=$calcul{"stock_navire"};
		$cumul{"alivrer"}+=$calcul{"alivrer"};
# 		 print "$semaine $pr_cd_pr $navire ".$calcul{"alivrer"}."<br>";
		$cumul{"stockmini_suiv"}+=$calcul{"stockmini_suiv"};
		$cumul{"stockmini_suivsuiv"}+=$calcul{"stockmini_suivsuiv"};

	}
	return(%cumul);
}
# -E stock alerte
