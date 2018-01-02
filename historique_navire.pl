#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$option=$html->param("option");
print "$option";
require "./src/connect.src";
print "<title>Historique navire</title>";
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
	$query="select max(nav_date) from navire2 where nav_nom='$navire' and nav_type=1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($date_mini)=$sth->fetchrow_array;
	$date_mini_simple=&datesimple($date_mini);	
	
	$query="select min(ic2_no) from infococ2 where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($icc_mini)=$sth->fetchrow_array;
	if ($icc_mini eq "") {$icc_mini=99999999999;}

	$query="select ic2_date from infococ2,comcli,produit where ic2_com1='$navire' and ic2_date>$date_mini_simple and ic2_date<10000000 and ic2_no=coc_no and coc_in_pos=5 and coc_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and coc_qte>0 group by ic2_date order by ic2_date";
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
	
	$query="select nav_cd_pr,pr_desi,pr_prac/100,pr_sup,nav_pos from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and pr_sup!=5 and (pr_type=1 or pr_type=5) order by nav_cd_pr";
	if ($option ne ""){
		$query="select nav_cd_pr,pr_desi,pr_prac/100,pr_sup from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and nav_cd_pr='$option' order by nav_cd_pr";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>neptune</th><th>désignation</th><th>$date_mini<br>$date_mini_simple</th>";
	foreach (@liste_date_liv){
		print "<th>livraison du $_</th>";
		}
	foreach (@liste_date_ven){
		print "<td bgcolor=#ffffcc><b>vendu du $_</b><br>";
		 print &semaine("$_");
   	 	 $sem=&semaine("$_");
   	 	print "<br>";
   	 	print &get("select se_coef from semaine2 where se_no='$sem' and se_navire='$navire'");
		print "</th>";
		}
# print "<th>Vendu cumulé</th><th>stock navire</th><th>stock plancher</th><th>A livrer</th></tr>";
 	print "<th>stock navire</th><th>stock plancher</th><th>Qte vendu ref</th><th>A livrer</th></tr>";
	
	while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_sup,$nav_pos)=$sth->fetchrow_array){
		
		$vendu_cu=0;
		$query="select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_date='$date_mini' and nav_cd_pr=$pr_cd_pr";
		# print "$query";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($inv)=$sth2->fetchrow_array;
		if ($inv eq ""){
			&save("insert into navire2 values ('$navire','$pr_cd_pr','$date_mini',1,0,'')");
			$inv=0;
		}
		$nep_cd_pr=&get("select nep_cd_pr from neptune where nep_codebarre='$pr_cd_pr'");
		%calcul=&table_navire($navire,$pr_cd_pr);
                if ($calcul{'stock_entrepot'}<2 && (($pr_sup==7)||($pr_sup==1))){next; } # produit deliste
		print "<tr><td>$pr_cd_pr</td><td>$nep_cd_pr</td><td";
		if ($nav_pos==1){print " bgcolor=pink";}
		print "><font size=-3>$pr_desi</td><td align=right>$inv</td>";
		$index=0;
		foreach (@liste_date_liv){
			$query="select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no>='$icc_mini' and ic2_date='$_'"; 
			$sth2=$dbh->prepare($query);
			# print "$query<br>";
			$sth2->execute();
			($liv_d)=$sth2->fetchrow_array+0;
			print "<td align=right>$liv_d</td>";
			$livre[$index++]+=$liv_d;
		}
		$index=0;
		foreach (@liste_date_ven){
			$query="select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr=$pr_cd_pr and nav_date='$_' ";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vendu_d)=$sth2->fetchrow_array+0;
			print "<td align=right bgcolor=#ffffcc>$vendu_d</td>";
			$vendu[$index++]+=$vendu_d;
		}

# print "<td align=right>* $calcul{'vendu'}</td>";

		if ($calcul{'stock_navire'}==0){
			print "<td align=right bgcolor=red><font color=white><b>$calcul{'stock_navire'}</b></td>";
			$manquant++;
		}
		else {
			print "<td align=right><b>$calcul{'stock_navire'}</b></td>";
		      }
		$ecart=0;
		if (($navire eq "MEGA 1")||($navire eq "MEGA 2")){
			print "<td align=right>$calcul{'douchette'}</td>";
			$ecart=$calcul{'douchette'}-$calcul{'stock_navire'};
			print "<td align=right>$ecart</td>";
		}
		# stock alerte 
		$query="select sum(nav_qte) from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($stockal)=$sth2->fetchrow_array;
		
		if ($stockal>100){	
			$calcul{'alivrer'}=$stockal;
			}
		# print "<td align=right>$calcul{'stockmini'}</td>";
		print "<td align=right>$calcul{'stock_plancher'}</td>";
		$vendu_ref=int($calcul{'max'}*100)/100;
		print "<td align=right>$vendu_ref	</td>";

		$total_plancher+=$calcul{'stock_plancher'};
		$val_plancher+=$calcul{'stock_plancher'}*$pr_prac;
		
		$color="black";
		$calcul{'alivrer'}-=$calcul{'stockmini_suiv'};
		$calcul{'alivrer'}-=$ecart;
		if ($calcul{'alivrer'}<0){$calcul{'alivrer'}=0;}
		if ($calcul{'alivrer'}>18){$calcul{'alivrer'}=18;}  # secu qte a livrer
		if ($calcul{'alivrer'}>0){
			$query = "replace into corsica values (10001,'$pr_cd_pr',0,'".$calcul{'alivrer'}."')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$color="red";
		}
		print "<td align=right><font color=$color>".$calcul{'alivrer'};
		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot 

		if ($calcul{'alivrer'} > $pr_stre)
		{
			print "/<font color=green>$pr_stre</font>";
			$total_alivrerm-=($calcul{'alivrer'}-$pr_stre);
		
		}
		print "</td>";
		$total_alivrer+=$calcul{'alivrer'};
		$total_alivrerm+=$calcul{'alivrer'};
	
		$val_alivrer+=$calcul{'alivrer'}*$pr_prac;
		$total_navire+=$calcul{'stock_navire'};	
		$val_navire+=$calcul{'stock_navire'}*$pr_prac;	
		print "</tr>";
	}
	print "<tr><td colspan=3><b>TOTAL</td>";
			$query="select sum(nav_qte),sum(nav_qte*pr_prac/100) from navire2,produit where nav_nom='$navire' and nav_type=1 and nav_cd_pr=pr_cd_pr and nav_date='$date_mini' and pr_sup!=5 and (pr_type=1 or pr_type=5)";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($qte,$val)=$sth2->fetchrow_array;
			# print "<td align=right>$qte<br>$val</td>";
       			print "<td align=right></td>";
                $index=0;
		foreach (@liste_date_liv){
			# $query="select floor(sum(coc_qte/100)),sum(coc_qte*pr_prac/10000) from infococ2,comcli,produit where ic2_cd_cl=500 and ic2_com1='$navire' and coc_cd_pr=pr_cd_pr and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and ic2_no>='$icc_mini' and ic2_date='$_' and (pr_type=5 or pr_type=1) and pr_sup!=5"; 
			# $sth2=$dbh->prepare($query);
			# $sth2->execute();
			# ($qte,$val)=$sth2->fetchrow_array;
			print "<td align=right>$livre[$index++]</td>";

			# print "<td align=right>$qte<br>$val</td>";
		}
		$index=0;
		foreach (@liste_date_ven){
			# $query="select sum(nav_qte),sum(nav_qte*pr_prac/100) from navire2,produit where nav_nom='$navire' and nav_type=2 and nav_cd_pr=pr_cd_pr and nav_date='$_' and pr_sup!=5 and (pr_type=1 or pr_type=5)";
			# print "$query<br>";
			# $sth2=$dbh->prepare($query);
			# $sth2->execute();
			# ($qte,$val)=$sth2->fetchrow_array;
			# print "<td align=right>$qte<br>$val</td>";
			print "<td align=right>$vendu[$index++]</td>";
	
		}
print "<td align=right> $total_navire<br>$val_navire</td>";
print "<td align=right> $total_plancher<br>$val_plancher</td>";
print "<td>&nbsp;</td><td align=right>$total_alivrer<font color=green>/$total_alivrerm<br>$val_alivrer</td></tr>";

		
print "</table><br>Nombre references manquantes=$manquant";
}

