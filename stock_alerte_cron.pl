#!/usr/bin/perl
use CGI;
use DBI();

# $html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);
open (MAIL, ">/mnt/server-file/download/maildaniel.html");   

# print $html->header;

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>stock alerte</title></head>";
print "<body link=black>Liste des produits non commandés<br>";


require "./src/connect.src";

$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit,fournis where ((pr_cd_pr >100000000  and (pr_type=1 or pr_type=5)) or (pr_cd_pr <100000000 and (pr_type!=1 and pr_type!=5))or pr_cd_pr=100751 or pr_cd_pr=220200) and (pr_sup=0 or pr_sup=3) and pr_four=fo2_cd_fo and fo2_delai>0 and pr_cd_pr!=130320 and pr_cd_pr!=130120 order by pr_four";
$sth=$dbh->prepare($query);
$sth->execute();
$dateref=$today-15;
while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup)=$sth->fetchrow_array)
{
	$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($qte_commande)=$sth2->fetchrow_array+0;
	$query="select max(com2_date) from commande where com2_cd_pr='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($date_commande)=$sth2->fetchrow_array-10000000;
	
	if ($date_commande<0){$date_commande=""};
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
	
	
	################################ calcul du besoin navire #############################"
	
	$besoin=0;
	$besoin_suiv=0;
	# ce module se trouve a la fin du programme

	
	%cumul=&cumul_navire();
	
	$besoin_navire=$cumul{"alivrer"}-$pr_stre+$cumul{"stockmini_suiv"};
	if ($besoin_navire<0){$besoin_navire=0;}
	$ecart=(0-$besoin_navire-$besoin_avion+$reliquat_commande);
	
	$query="select car_carton from carton where car_cd_pr='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($carton)=$sth2->fetchrow_array;
	$carton+=0;
	if ($carton==0){$carton=1;}
	$proposition=int((0-$ecart)/$carton)*$carton;
	if ($ecart%$carton!=0){$proposition+=$carton;}
	if (($proposition<=0)||($ecart>0)){$proposition="";}
	if ($proposition >0){
		print MAIL "$pr_cd_pr;$pr_desi;$proposition \n";
	}
}

close(MAIL);

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
