#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
$html=new CGI;
print $html->header;
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>inventaire</title></head><body>";

require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$sth=$dbh->prepare("select pr_cd_pr,pr_desi,pr_sup,pr_four,pr_prac,mod(pr_cd_pr,10000) as digit from produit where pr_cd_pr>10000000 and (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) and pr_cd_pr in (select nav_cd_pr from navire2 where nav_nom='MEGA 2' and nav_type=0) order by pr_cd_pr");
$sth->execute();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 60";
# print $query;
$sth2=$dbh->prepare($query);
$sth2->execute();
while (($pr_cd_pr,$qte)=$sth2->fetchrow_array){
	push (@top60,$pr_cd_pr);
}
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 120";
$sth2=$dbh->prepare($query);
$sth2->execute();
while (($pr_cd_pr,$qte)=$sth2->fetchrow_array){
	if (! (grep /$pr_cd_pr/,@top60)){push (@top120,$pr_cd_pr);}
}
		
&titre();
while (($pr_cd_pr,$pr_desi,$pr_sup,$pr_four,$pr_prac)=$sth->fetchrow_array){

	
	$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
	$sth2->execute();
	($car_carton,$car_pal)=$sth2->fetchrow_array;
	%stock=&stock($pr_cd_pr,$today,"quick");
	$pr_stre=$stock{"stock"};
	if (($pr_stre==0)&&($pr_sup!=0)&&($pr_sup!=3)) { next;}
	$color="black";
 	%cumul=&cumul_navire();
 	
	$digit_f=$pr_cd_pr%1000000+1000000;
	$digit_f=substr($digit_f,3,4);
	
	$digit_p=int($pr_cd_pr/10000);
	$pr_stre+=0;
	$nbligne++;

	print "<tr";	
	$vendu=&get("select sum(nav_qte) from navire2 where nav_cd_pr=$pr_cd_pr and nav_type=2 and nav_date > DATE_SUB(curdate(),INTERVAL 4 MONTH)")+0;
	# if (($pr_stre>$vendu)&&($pr_sup!=3)){print " style=color:red";}
	# if ($pr_sup==3){print " style=color:blue";}

	print "> ";
	print "<td>$digit_p <b>$digit_f</b></td><td><a href=fiche_produit.pl?pr_cd_pr=$pr_cd_pr&action=visu><font color=$color>$pr_desi</a></td>";
	print "<td>&nbsp;";
	# if ($pr_sup==2){print "delisté";}
	@part=("actif","supprimé","delisté","new","déstockage","suivi par paul","délisté par paul","délisté par le fournisseur");
	if (grep /$pr_cd_pr/,@top60){$part[$pr_sup]="top 60";}
	if (grep /$pr_cd_pr/,@top120){$part[$pr_sup]="top 120";}
	print "$part[$pr_sup]";
	print "</td>";
	$totalqte+=$pr_stre;
	$totalval+=$pr_stre*$pr_prac/100;
	print "<td align=right>";
	if ($pr_stre==0){
		print "Rupture";
		$manq++;
		if (grep /$pr_cd_pr/,@top60){$manq60++;}
		if (grep /$pr_cd_pr/,@top120){$manq120++;}
	}else{&carton($pr_cd_pr,$pr_stre);}
	print "<td align=right><a href=http://ibs.oasix.fr/cgi-bin/inv_mer.pl?produit=$pr_cd_pr&action=go>".$cumul{"stock_navire"}."</a></td>";
	print "</td><td>&nbsp;</td><td>";
	print "$vendu</td>";
	$qte_com=&get("select sum(com2_qte)/100 from commande where com2_cd_pr='$pr_cd_pr'")+0;
	print "<td";
	if (((($pr_stre<$vendu/3)&&(($pr_sup==0)||$pr_sup==3))||($pr_sup==3 && $pr_stre<60))&&($qte_com==0)){ print " bgcolor=green";}
	print ">"; 
	print $qte_com ;
	print "</td></tr>";
	$nb++;
	
}
print "</table>";
print "<br>qte:$totalqte<br>valeur:$totalval<br>";
print "Nb de produit:$nb<br>";
print "Nb de manquant:$manq<br>";
print "Nb de manquant top 60:$manq60<br>";
print "Nb de manquant top 120:$manq120<br>";
$pour=100*$manq/$nb;
print "Pourcentage de manquant:$pour<br>";

sub titre(){
		print "<table border=1 cellspacing=0>";
		print "<tr bgcolor=#FFFF66><td>&nbsp;</td><td>&nbsp;</td>";
		print "<th>Part</th><th>Dispo</th><th>Stock navire</th><th>Check</th><th>Vente (4 mois)</th><th>Commande</th></tr>";
		$nbligne=0;
}
sub cumul_navire {
	my(%cumul);
	my(%calcul);
	my($stock_suiv,$alivrer,$besoin_suiv,$alivrer_suiv)=0;
	my($navire,$flag);
	my ($sthg) = $dbh->prepare("select nav_nom,nav_nationalite from navire where nav_nationalite=1"); 
	$sthg->execute;
	while (($navire,$flag) = $sthg->fetchrow_array) {
		%calcul=&table_navire($navire,$pr_cd_pr);
		$cumul{"stock_navire"}+=$calcul{"stock_navire"};
		$cumul{"alivrer"}+=$calcul{"alivrer"};
		$cumul{"stockmini_suiv"}+=$calcul{"stockmini_suiv"};
		$cumul{"stockmini_suivsuiv"}+=$calcul{"stockmini_suivsuiv"};

	}
	
	#
	
	
	#	$alivrer+=$calcul{'alivrer'};
	#	$stock_suiv=$calcul{'stock_navire'}-$calcul{'stockmini'}-$calcul{'stockmini_suiv'};
	#	if ($stock_suiv<0){$stock_suiv=0;}
	#	$besoin_suiv=$calcul{'stockmini_suiv'}-$stock_suiv;
	#	if ($besoin_suiv<0){$besoin_suiv=0;}
	#	$alivrer_suiv+=$besoin_suiv;
	#} 
	#%stock=&stock($pr_cd_pr,'','quick');
	#my($pr_stre)=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	#my($livrereel)=$alivrer;
	#if ($alivrer>$pr_stre){
	#	$livrereel=$pr_stre;
	#}
	#$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'";
	#my($sth2)=$dbh->prepare($query);
	#$sth2->execute();
	#(my($qte_commande))=$sth2->fetchrow_array+0;
	#$pr_stre+=$qte_commande;
	#my($fin2sem)=$pr_stre-$alivrer;
	#if ($fin2sem<0){$fin2sem=0;}
	#my($acommande);
	#$acommande=int($alivrer_suiv-$fin2sem);
	return(%cumul);
}
