#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$pr_cd_pr=$html->param("pr_cd_pr");

require "./src/connect.src";
$besoin=0;
$besoin_suiv=0;

&commande_navire;
sub commande_navire {
	my ($sthg) = $dbh->prepare("select nav_nom from navire");
	$sthg->execute;
	my($stock_suiv,$alivrer,$besoin_suiv,$alivrer_suiv)=0;
	while ((my($navire)) = $sthg->fetchrow_array) {
		%calcul=&table_navire($navire,$pr_cd_pr);
	 	
	 	print "<br><b>$navire ".&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'")."</b><BR>";
	 	print "date du dernier inventaire=$calcul{'date_mini'}<br>";
	 	print "premier no facture apres le dernier inventaire=$calcul{'nofact_mini'}<br>";
	 	print "inventaire=$calcul{'inv'}<br>";
	 	print "vendu=$calcul{'vendu'}<br>";
	 	print "livré=$calcul{'liv'}<br>";
	 	print "vendu max=$calcul{'max'}<br>";
	 	print "stock mini j+1 j+2=$calcul{'stockmini'}<br>";
	 	print "stock actuel=$calcul{'stock_navire'}<br>";
	 	print "a livrer=$calcul{'alivrer'} <br>";
		print "stock mini j+3 j+4=$calcul{'stockmini_suiv'}<br>";
		$alivrer+=$calcul{'alivrer'};
		# print "*$alivrer<br>";
		$vendu+=$calcul{'vendu'};

		$stock_suiv=$calcul{'stock_navire'}-$calcul{'stockmini'}-$calcul{'stockmini_suiv'};
		if ($stock_suiv<0){$stock_suiv=0;}
		$besoin_suiv=$calcul{'stockmini_suiv'}-$stock_suiv;
		if ($besoin_suiv<0){$besoin_suiv=0;}
		print "livraison à faire dans 15 jours:$besoin_suiv<br>";
		$alivrer_suiv+=$besoin_suiv;
	} 
	print "<br><hr width=50%><br>";	
	%stock=&stock($pr_cd_pr,'','quick');
	my($pr_stre)=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	print "vendu:$vendu<br>";
	print "stock entrepot:$pr_stre<br>";
	print "stock à livrer:$alivrer<br>";
	my($livrereel)=$alivrer;
	if ($alivrer>$pr_stre){
		$livrereel=$pr_stre;
	}
	print "stock qui va être livrer:$livrereel<br>";
	$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'";
	my($sth2)=$dbh->prepare($query);
	$sth2->execute();
	(my($qte_commande))=$sth2->fetchrow_array+0;
	$qte_commande=0;
	$pr_stre+=$qte_commande;
	my($fin2sem)=$pr_stre-$alivrer;
	if ($fin2sem<0){$fin2sem=0;}
	my($acommande);
	$acommande=$alivrer_suiv-$fin2sem;
	print "livraison à faire dans 15 jours= $alivrer_suiv<br>";
	print "commande à faire :$acommande";
	# return($acommande);
}
sub table_navire(){
	my $navire=$_[0];
	my $pr_cd_pr=$_[1];
	my(@liste_date_liv)=(); 
	my(@liste_date_ven)=();
	my(%calcul);
	
	# verification si le produits est listé à bord
	my($existe)=get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr='$pr_cd_pr'")+0;
	
	if (! $existe){return(%calcul);}

	# recuperation de la date la plus recentes d'inventaire
	$query="select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=1 and nav_cd_pr='$pr_cd_pr'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$calcul{'date_mini'}=$sth->fetchrow_array;
	if ($calcul{'date_mini'}eq""){$calcul{'date_mini'}="2005-07-10";}
	# recuperation du premier numero de facture apres le dernier inventaire
	my($date_mini_simple)=&datesimple($calcul{'date_mini'});	
	$query="select min(ic2_no) from infococ2 where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000 ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$calcul{'nofact_mini'}=$sth->fetchrow_array;
	if ($calcul{'nofact_mini'} eq "") {$calcul{'nofact_mini'}=99999999999;}

	# recuperation de la liste des factures  apres le dernier inventaire
	$query="select ic2_date from infococ2 where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000 group by ic2_date order by ic2_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((my($no))=$sth->fetchrow_array){
		push (@liste_date_liv , $no);
	}

	# recuperation des dates de ventes  apres le dernier inventaire
	$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_date>'".$calcul{'date_mini'}."' and nav_cd_pr='$pr_cd_pr' group by nav_date order by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no)=$sth->fetchrow_array){
		push (@liste_date_ven , $no);
	}

	# recuperation de l'inventaire
	$query="select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='".$calcul{'date_mini'}."' and nav_cd_pr='$pr_cd_pr'";
	# print "$query <br>";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$calcul{"inv"}=$sth2->fetchrow_array+0;
	
	# quantite livré
	my($liv_d)=0;
	foreach (@liste_date_liv){
		$query="select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_no=ic2_no and coc_cd_pr='$pr_cd_pr' and ic2_no>='".$calcul{'nofact_mini'}."' and ic2_date='$_' group by coc_cd_pr"; 
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$liv_d=$sth2->fetchrow_array+0;
		# print "$liv_d $query<br>";
	
		$calcul{"liv"}+=$liv_d;
	}
	
	# quantite vendu
	my($vendu_d)=0;
	my($date);
	my($semaine);
	my($max);
	foreach (@liste_date_ven){
		$query="select sum(nav_qte),nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_date='$_' group by nav_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($vendu_d,$date)=$sth2->fetchrow_array;
		$vendu_d+=0;
		$calcul{"vendu"}+=$vendu_d;
		$semaine=&semaine("$date");
		$coef=&get("select se_coef from semaine where se_no='$semaine'");
		if ($coef){
			# print "$date $vendu_d $semaine<br>";
			$calcul{"max"}=$vendu_d if ($vendu_d/$coef)>$calcul{"max"};
		}
	}
	(my $vendu_cumul)=&get("select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=3 and nav_cd_pr='$pr_cd_pr' group by nav_cd_pr");
	if ($vendu_cumul>0){$calcul{"vendu"}=$vendu_cumul;}	

	# stock navire
	$calcul{"stock_navire"}=$calcul{'inv'}+$calcul{'liv'}-$calcul{'vendu'}+0;
	
	# maximum de vendu 
	# $query="select max(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr";
	# $sth2=$dbh->prepare($query);
	# $sth2->execute();
	# (my($max))=($sth2->fetchrow_array+0);
	
	# si les vendu sont inferieur au stock depart on ajoute 6 arbitrairement au vendu
	if (($calcul{"liv"}==0)&&($calcul{"inv"}<6)){$calcul{"max"}=6;}

	$semaine=&semaine("")+1;
	my($coef1,$coef2);
	$coef1=&get("select se_coef from semaine where se_no='$semaine'");
	$semaine++;
	$coef2=&get("select se_coef from semaine where se_no='$semaine'");
	$calcul{"stockmini"}=($calcul{"max"}*$coef1)+($calcul{"max"}*$coef2);
	
	$calcul{'alivrer'}=$calcul{'stockmini'}-$calcul{'stock_navire'};
	
	# si la quantite a livrer est negative c'est du sur_stock
	if ($calcul{'alivrer'}<=0){
		$calcul{'alivrer'}=0;
	}

	my($suivant)=0;
	$semaine++;
	$coef1=&get("select se_coef from semaine where se_no='$semaine'");
	$semaine++;
	$coef2=&get("select se_coef from semaine where se_no='$semaine'");
	$calcul{'stockmini_suiv'}=($calcul{"max"}*$coef1)+($calcul{"max"}*$coef2);
	
	return(%calcul);
	
}



sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}