#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);
print $html->header;
print "<title>tresorie</title>";
require "./src/connect.src";

print "<center><table border=1 cellspacing=0><caption><h2>produits aeriens</h2></caption><tr><th>code</th><th>designation</th><th>en commande</th><th>en vol</th><th>entrepot</th></tr>";
$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where (pr_type=1 or pr_type=5) and pr_cd_pr <10000000 and pr_desi not like 'testeur%' order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
&tablea();
print "</table>";


print "<table border=1 cellspacing=0><caption><h2>recapitulatif aerien</h2></caption>";
print "<tr><th>&nbsp;</th><th>nb piece</th><th>moyenne</th><th>objectif fin decembre</th></tr>";

print "<tr><th>commande</th><th align=right>$total_commande</th><td>&nbsp;</td><td>&nbsp;</td></tr>";
$moy=int($total_envol/$nbref);

print "<tr><th>en vol</th><td align=right>$total_envol</td><td align=right>$moy</td><td>2160</td></tr>";
$moy=int($total_entrepot/$nbref);
print "<tr><th>entrepot</th><td align=right>$total_entrepot</td><td align=right>$moy</td><td>1920</td></tr>";
print "</table><br>";
$total_entrepota=$total_entrepot;



print "<table border=1 cellspacing=0><caption><h2>produits maritimes actifs</h2></caption><tr><th>code</th><th>designation</th><th>en commande</th><th>en mer</th><th>entrepot</th></tr>";
$total_commande=$total_enmer=$total_entrepot=$nbref=0;
$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) and pr_cd_pr >=10000000 and pr_desi not like 'testeur%'  order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
&tablen();
print "</table><br>";
print "<table border=1 cellspacing=0><caption><h2>recapitulatif produits maritimes actifs</h2></caption>";
print "<tr><th>&nbsp;</th><th>nb piece</th><th>moyenne</th><th>objectif fin decembre</th></tr>";

print "<tr><th>commande</th><th align=right>$total_commande</th><td>&nbsp;</td><td>1361</td></tr>";
$moy=int($total_envol/$nbref);

print "<tr><th>en mer</th><td align=right>$total_enmer</td><td align=right>$moy</td><td>4575</td></tr>";
$moy=int($total_entrepot/$nbref);
print "<tr><th>entrepot</th><td align=right>$total_entrepot</td><td align=right>$moy</td><td>5280</td></tr>";
print "</table>";
$total_entrepotn=$total_entrepot;
$total_enmer_n=$total_enmer;

print "<table border=1 cellspacing=0><caption><h2>produits delistés</h2></caption><tr><th>code</th><th>designation</th><th>en commande</th><th>en mer</th><th>entrepot</th></tr>";
$total_commande=$total_enmer=$total_entrepot=$nbref=0;
$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit where (pr_type=1 or pr_type=5) and (pr_sup!=0 and pr_sup!=3) and pr_cd_pr >=10000000 and pr_desi not like 'testeur%'  order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
&tablen();
print "</table><br>";
print "<table border=1 cellspacing=0><caption><h2>recapitulatif produits delistés</h2></caption>";
print "<tr><th>&nbsp;</th><th>nb piece</th><th>moyenne</th></tr>";

print "<tr><th>commande</th><th align=right>$total_commande</th><td>&nbsp;</td></tr>";
$moy=int($total_envol/$nbref);

print "<tr><th>en mer</th><td align=right>$total_enmer</td><td align=right>$moy</td></tr>";
$moy=int($total_entrepot/$nbref);
print "<tr><th>entrepot</th><td align=right>$total_entrepot</td><td align=right>$moy</td></tr>";
print "</table>";
&save("replace into tresorie values (now(),'$total_envol','$total_enmer_n','$total_enmer','$total_entrepota','$total_entrepotn','$total_entrepot')","af");



sub tablea{
	$dateref=$today-15;
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup)=$sth->fetchrow_array)
	{
		$qte_commande=0+&get("select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'");
		%stock=&stock($pr_cd_pr,'','','');
		$qte_compta=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	        $qte_entrepot=$stock{"stock"};
		$qte_envol=$qte_compta-$qte_entrepot;
		if (($qte_compta==0)&&($qte_commande==0)){next;}
		print "<tr><td>$pr_cd_pr</td><td>";
		$actif=0+&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1");
		if ($actif==0){print "<font color=gray>";}
		print "$pr_desi</td>";
		print "<td align=right>$qte_commande</td>";
		print "<td align=right>$qte_envol</td>";
		print "<td align=right>$qte_entrepot</td>";
		print "</tr>";
		$total_commande+=$qte_commande;
		$total_envol+=$qte_envol;
		$total_entrepot+=$qte_entrepot;
		$nbref++;
	}
}

sub tablen{
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup)=$sth->fetchrow_array)
	{
		$qte_commande=0+&get("select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'");
		%stock=&stock($pr_cd_pr,'','quick','');
		$qte_compta=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	        $qte_entrepot=$stock{"stock"};
		%cumul=&cumul_navire();
		$qte_enmer=$cumul{"stock_navire"};
		if (($qte_compta==0)&&($qte_commande==0)&&($qte_enmer==0)){next;}
		print "<tr><td>$pr_cd_pr</td><td>";
		if (($qte_commande==0)&&($qte_enmer==0)){
			# $erdep_qte=0-$qte_entrepot;
			# &save("replace into errdep values ('$pr_cd_pr','','','$erdep_qte')");
			# $erdep_qte*=100;
			# &save("replace into trace_jour values (now(),'9','$pr_cd_pr','$erdep_qte','sylvain','stock pas sur','')"); 			
			# print "<font color=gray>";
		}
		print "$pr_desi</td>";
		print "<td align=right>$qte_commande</td>";
		print "<td align=right>$qte_enmer</td>";
		print "<td align=right>$qte_entrepot</td>";
		print "</tr>";
		$total_commande+=$qte_commande;
		$total_enmer+=$qte_enmer;
		$total_entrepot+=$qte_entrepot;

		$nbref++;
	}
}

sub cumul_navire {
	my(%cumul);
	my(%calcul);
	my($stock_suiv,$alivrer,$besoin_suiv,$alivrer_suiv)=0;
	my($navire,$flag);
	my($semaine)=&semaine("");

	my ($sthg) = $dbh->prepare("select nav_nom from navire,semaine2 where nav_nom=se_navire and se_no>=$semaine and se_no<=$semaine+5 and se_coef!=0 group by nav_nom order by nav_nom"); 
	$sthg->execute;
	while (($navire) = $sthg->fetchrow_array) {
		$qte=&get("select nav_qte from navire2 where nav_type=1 and nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date>DATE_SUB(curdate(),INTERVAL 20 DAY) order by nav_date desc limit 1","af");
		# print "$qte<br>";
		$cumul{"stock_navire"}+=$qte;
	}
	
	return(%cumul);
}
