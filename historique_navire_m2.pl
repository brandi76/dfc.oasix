#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$option=$html->param("option");

require "./src/connect.src";

if ($action eq ""){
	print "<body><center><h1>Historique navire<br><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=voir></form></body>";
}
	

if ($action eq "visu"){
	print "<font color=red>mise à jour de importcsv<br></font><br>";
	$query = "delete from corsica ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$query = "replace into corsica values (10001,'2000469',0,'200')";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$stock_navire_gg=0;

	if ($navire ne "tout") {
		&table($navire);
	}
	else 
	{
		$sthg = $dbh->prepare("select nav_nom from navire");
		$sthg->execute;
		while (($navire) = $sthg->fetchrow_array) {
      			&table($navire);
		}
	}
      
	
	print "</body></html>";
}


sub table(){
	my $navire=$_[0];
	$stock_navire_g=0;
	$trop=0;
	$pastrop=0;
	@liste_date_liv=(); 
	@liste_date_ven=();
	print "<h1>$navire</h1>";
	$query="select min(nav_date) from navire2 where nav_nom='$navire' and nav_type=1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($date_mini)=$sth->fetchrow_array;
	$date_mini_simple=&datesimple($date_mini);	
	$query="select min(ic2_no) from infococ2 where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($icc_mini)=$sth->fetchrow_array;
	if ($icc_mini eq "") {$icc_mini=99999999999;}

	$query="select ic2_date from infococ2 where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000 group by ic2_date order by ic2_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no)=$sth->fetchrow_array){
		push (@liste_date_liv , $no);
	}


	$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_date>'$date_mini' group by nav_date order by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no)=$sth->fetchrow_array){
		push (@liste_date_ven , $no);
	}
	
	$query="select nav_cd_pr,pr_desi from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 order by nav_cd_pr";
	if ($option ne ""){
		$query="select nav_cd_pr,pr_desi from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and nav_cd_pr='$option' order by nav_cd_pr";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>neptune</th><th>désignation</th><th>$date_mini<br>$date_mini_simple</th>";
	foreach (@liste_date_liv){
		print "<th>livraison du $_</th>";
		}
	foreach (@liste_date_ven){
		print "<th>vendu du $_</th>";
		}
	print "<th>Vendu cumulé</th><th>stock navire</th><th>stock mini</th><th>A livrer</th></tr>";
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$vendu_cu=0;
		$query="select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($inv)=$sth2->fetchrow_array;
		$nep_cd_pr=&get("select nep_cd_pr from neptune where nep_codebarre='$pr_cd_pr'");
		print "<tr><td>$pr_cd_pr</td><td>$nep_cd_pr</td><td>$pr_desi</td><td align=right>$inv</td>";
		foreach (@liste_date_liv){
			$query="select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no>='$icc_mini' and ic2_date='$_' group by coc_cd_pr"; 
			$sth2=$dbh->prepare($query);
			# print "$query<br>";
			$sth2->execute();
			($liv_d)=$sth2->fetchrow_array+0;
			print "<td align=right>$liv_d</td>";
		}
		foreach (@liste_date_ven){
			$query="select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr and nav_date='$_' group by nav_cd_pr";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vendu_d)=$sth2->fetchrow_array+0;
			print "<td align=right>$vendu_d</td>";
		}

		%calcul=&table_navire($navire,$pr_cd_pr);
		print "<td align=right>$calcul{'vendu'}</td>";

		print "<td align=right><b>$calcul{'stock_navire'}</b></td>";
		
		# stock alerte 
		$query="select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr=$pr_cd_pr group by nav_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($stockal)=$sth2->fetchrow_array;
		
		if ($stockal>100){	
			$calcul{'alivrer'}=$stockal;
			}
		print "<td align=right>$calcul{'stockmini'}</td>";
		$color="black";
		if ($calcul{'alivrer'}>0){
			$query = "replace into corsica values (10001,'$pr_cd_pr',0,'".$calcul{'alivrer'}."')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$color="red";
		}
		print "<td align=right><font color=$color>".$calcul{'alivrer'}."</td>";
	
		print "</tr>";
	}
	print "</table>";

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
	$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=2 and nav_date>'$date_mini' and nav_cd_pr='$pr_cd_pr' group by nav_date order by nav_date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no)=$sth->fetchrow_array){
		push (@liste_date_ven , $no);
	}

	# recuperation de l'inventaire
	$query="select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$calcul{"inv"}=$sth2->fetchrow_array+0;
	
	# quantite livré
	my($liv_d)=0;
	foreach (@liste_date_liv){
		$query="select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_no=ic2_no and coc_cd_pr='$pr_cd_pr' and ic2_no>='$icc_mini' and ic2_date='$_' group by coc_cd_pr"; 
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$liv_d=$sth2->fetchrow_array+0;
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
			$calcul{"max"}=$vendu_d if ($vendu_d/$coef)>$calcul{"max"};
		}
	}
	
	
	(my $vendu_cumul)=&get("select max(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' group by nav_cd_pr");
	$calcul{"vendu"}=$vendu_cumul;	
	
	#if ($vendu_cumul>0){$calcul{"vendu"}=$vendu_cumul;}	
	
	# stock navire
	$calcul{"stock_navire"}=$calcul{'inv'}+$calcul{'liv'}-$calcul{'vendu'}+0;
	if ($calcul{"stock_navire"}<0){$calcul{"stock_navire"}=0};	
	
	# si les vendu sont inferieur au stock depart on ajoute 6 arbitrairement au vendu
	if (($calcul{"liv"}==0)&&($calcul{"inv"}<6)){$calcul{"max"}=6;}

	$semaine=&semaine("")+1;
	my($coef1,$coef2);
	$coef1=&get("select se_coef from semaine where se_no='$semaine'");
	$semaine++;
	$coef2=&get("select se_coef from semaine where se_no='$semaine'");
	# $calcul{"stockmini"}=($calcul{"max"}*$coef1)+($calcul{"max"}*$coef2);
	$calcul{"stockmini"}=$calcul{"vendu"};
	
	if ($calcul{"stockmini"}<3){$calcul{"stockmini"}=3};
	
	$calcul{'alivrer'}=$calcul{'stockmini'}-$calcul{'stock_navire'};
	
	# si la quantite a livrer est negative c'est du sur_stock
	if ($calcul{'alivrer'}<=0){
		$calcul{'alivrer'}=0;
	}
	if (($calcul{"stock_navire"}>5)&&($calcul{'alivrer'}<3)){
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