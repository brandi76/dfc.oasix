#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

print $html->header;

$action=$html->param("action");
$four=$html->param("four");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "<body link=black>";


require "./src/connect.src";

	$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup,pr_prac/100,pr_prx_vte/100 from produit where pr_cd_pr >100000000 and (pr_type=1 or pr_type=5) and pr_four>0 order by pr_four";
	$sth=$dbh->prepare($query);
	$sth->execute();
	&table();

sub table{
	print "<table border=1>";
	$dateref=$today-15;
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup,$pr_prac,$pr_prx_vte)=$sth->fetchrow_array)
	{
		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
		$stock_navire=0;
		&commande_navire();
		print "<tr><td>";
		print "$pr_cd_pr</a></td><td>$pr_desi</td>";
		print "<td align=right>$pr_stre</td><td align=right>$stock_navire</td><td align=right>$pr_prac</td><td align=right>$pr_prx_vte</td></tr>";
	}
	print "</table>";
}


sub commande_navire {
	my ($sthg) = $dbh->prepare("select nav_nom from navire");
	$sthg->execute;
	my($stock_suiv,$alivrer,$besoin_suiv,$alivrer_suiv)=0;
	while ((my($navire)) = $sthg->fetchrow_array) {
		%calcul=&table_navire($navire,$pr_cd_pr);
		$alivrer+=$calcul{'alivrer'};
		$stock_navire+=$calcul{'stock_navire'};
		$stock_suiv=$calcul{'stock_navire'}-$calcul{'stockmini'}-$calcul{'stockmini_suiv'};
		if ($stock_suiv<0){$stock_suiv=0;}
		$besoin_suiv=$calcul{'stockmini_suiv'}-$stock_suiv;
		if ($besoin_suiv<0){$besoin_suiv=0;}
		$alivrer_suiv+=$besoin_suiv;
	} 
	%stock=&stock($pr_cd_pr,'','quick');
	my($pr_stre)=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	my($livrereel)=$alivrer;
	if ($alivrer>$pr_stre){
		$livrereel=$pr_stre;
	}
	$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'";
	my($sth2)=$dbh->prepare($query);
	$sth2->execute();
	(my($qte_commande))=$sth2->fetchrow_array+0;
	$pr_stre+=$qte_commande;
	my($fin2sem)=$pr_stre-$alivrer;
	if ($fin2sem<0){$fin2sem=0;}
	my($acommande);
	$acommande=int($alivrer_suiv-$fin2sem);
	return($alivrer_suiv,$livrereel);
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
		$semaine=&semaine("date");
		$coef=&get("select se_coef from semaine where se_no='$semaine'");
		if ($coef){
			$calcul{"max"}=$vendu_d if ($vendu_d/$coef)>$calcul{"max"};
		}
	}

	# stock navire
	$calcul{"stock_navire"}=$calcul{'inv'}+$calcul{'liv'}-$calcul{'vendu'}+0;
	
	
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
# -E stock alerte
