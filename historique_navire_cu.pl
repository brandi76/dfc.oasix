#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");

require "./src/connect.src";
$sthg = $dbh->prepare("select nav_nom from navire");
$sthg->execute;
$stock_navire_g=0;
$trop_g=0;
$pastrop_g=0;

while (($navire) = $sthg->fetchrow_array) {
      	$trop=0;
      	$pastrop=0;
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
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>désignation</th><th>$date_mini<br>$date_mini_simple</th>";
	foreach (@liste_date_liv){
		print "<th>livraison du $_</th>";
		}
	foreach (@liste_date_ven){
		print "<th>vendu du $_</th>";
		}
	print "<th>stock navire</th><th>stock mini</th><th>stock mini new</th><th>A livrer</th></tr>";
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$query="select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($inv)=$sth2->fetchrow_array;
		
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$inv</td>";
		$liv=0;
		foreach (@liste_date_liv){
			$query="select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no>='$icc_mini' and ic2_date='$_' group by coc_cd_pr"; 
			$sth2=$dbh->prepare($query);
			# print "$query<br>";
			$sth2->execute();
			($liv_d)=$sth2->fetchrow_array+0;
			print "<td align=right>$liv_d</td>";
			$liv+=$liv_d;
		}
		$vendu=0;
		foreach (@liste_date_ven){
			$query="select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr and nav_date='$_' group by nav_cd_pr";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vendu_d)=$sth2->fetchrow_array+0;
			print "<td align=right>$vendu_d</td>";
			$vendu+=$vendu_d;
		}
		# stock navire
		$stock_navire=$inv+$liv-$vendu+0;
		print "<td align=right><b>$stock_navire</b></td>";
		
		# stock alerte 
		$query="select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr=$pr_cd_pr group by nav_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($stockal)=$sth2->fetchrow_array;
		print "<td align=right>$stockal</td>";
		
		if ($stockal<100){$stock_navire_g+=$stock_navire;}
		
		# maximum de vendu *2
		$query="select max(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($max)=($sth2->fetchrow_array+0)*2;
		
		# premiere livraison
		
		$query="select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no>='$icc_mini' and ic2_date='1050711' group by coc_cd_pr"; 
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($liv11)=($sth2->fetchrow_array+0);
		
		# si les vendu sont inferieur au stock depart on ajoute 6 arbitrairement au vendu
		if ($vendu>=($inv+$liv11)){$max+=6;}
		
		# produit hors parfums
		if ($stockal>100){$max=$stockal};
		print "<td align=right>$max</td>";
		
		# a licrer= stock mini (max *2) - inventaire - livraison +vendu
		# $alivrer=$stockal-$inv-$liv+$vendu;
		 $alivrer=$max-$inv-$liv+$vendu;
		
		# si la quantite a livrer est negative c'est du sur_stock
		if ($alivrer<=0){
			$alivrer=0-$alivrer;
			print "<td align=right><font color=green><b>$alivrer</td>";
			if ($stockal<100){$trop+=$alivrer};
			}
		else {
			$query = "replace into corsica values (10001,'$pr_cd_pr',0,'$alivrer')";
			# print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			print "<td align=right><font color=red><b>$alivrer</td>";
			if ($stockal<100){$pastrop+=$alivrer};
		
		}
		print "</tr>";
		$stock_nec=2*$max-$stock_navire;
		# si le stock necessaire est suprerieur  au stock navire on enregistre 
		if ($stock_nec>0){$prod{$pr_cd_pr}+=$stock_nec;}	

	}
	print "</table>";
	print "<font color=green>en trops:$trop</font> <font color=red>pas assez:$pastrop</b></font> ";
	
}
	print "<br><font color=green>en trops:$trops</font> <font color=red>pas assez:$pastrops</font> </b></font> $stock_g stock=$stock_navire_g<br>";
	foreach $cle (keys(%prod)){
		%stock=&stock($cle,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair

		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$cle'");
		print "$cle $pr_desi $pr_stre $prod{$cle}<br>";
		}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}