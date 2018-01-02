#!/usr/bin/perl                  
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/./outils_corsica.pl";

$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

print $html->header;

$action=$html->param("action");
$four=$html->param("four");
$option=$html->param("option");

if ($html->param("option") eq "on"){$option="aerien";};


if (($four eq "")||($four eq "TOUS")){$four="%";}
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
#saut { page-break-after : right }         

th:hover div {
	font-weight:normal;
	background-color:lightyellow;
	display:block;
}

th div {
	display:none;
}

</style><title>stock alerte</title></head>";
print "<body link=black>version 2.0<br>";


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
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from ordre,fournis,produit where (pr_cd_pr=ord_cd_pr and pr_four=fo2_cd_fo) or (pr_four=2070) or (pr_four=2252) or (pr_four=105)  group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
        print "<option value='TOUS'>TOUS\n";
    	
    	print "</select>";
	print "<br>aerien  <input type=checkbox name=option checked>";
	print "<br><input type=submit>";
	print "<input type=hidden name=action value=phase1></form>";
}

if ($action ne  ""){
	$process=$$;
	&save("create temporary table liste1$process (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
	$liste_nav="and (nav_nom='MEGA 1' or nav_nom='MEGA 2' or nav_nom='MEGA 4') ";
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_navire group by nav_cd_pr order by qte desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$i=0;
	while (($nav_cd_pr,$null)=$sth->fetchrow_array){
		&save("insert into liste1$process values ('$nav_cd_pr','$i')","af");
		$i++;
	}
	&save("create temporary table liste2$process (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
	$liste_nav="and (nav_nom!='MEGA 1' and nav_nom!='MEGA 2' and nav_nom!='MEGA 4') ";
	$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_navire group by nav_cd_pr order by qte desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$i=0;
	while (($nav_cd_pr,$null)=$sth->fetchrow_array){
		&save("insert into liste2$process values ('$nav_cd_pr','$i')","af");
		$i++;
	}
# 	$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit,fournis where ((pr_cd_pr >100000000  and (pr_type=1 or pr_type=5)) or (pr_cd_pr <100000000 and (pr_type!=1 and pr_type!=5)) or pr_cd_pr=100751 or pr_cd_pr=220200 or pr_four=2252) and (pr_sup=0 or pr_sup=3) and pr_four=fo2_cd_fo and fo2_delai>0 and pr_four like '$four' order by pr_four";	
#  	$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit,fournis where ((pr_cd_pr >100000000  and (pr_type=1 or pr_type=5)) or (pr_cd_pr <100000000 and (pr_type=1 or pr_type=5)) or pr_cd_pr=100751 or pr_cd_pr=220200 or pr_four=2252) and (pr_sup=0 or pr_sup=3) and pr_four=fo2_cd_fo and fo2_delai>0 and pr_four like '$four' order by pr_four";
	if ($option eq "aerien") {
		      $query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit,fournis,trolley,lot where pr_cd_pr=tr_cd_pr and tr_code=lot_nolot and lot_flag=1 and (pr_sup=0 or pr_sup=3) and pr_four=fo2_cd_fo and fo2_delai>0 and pr_four like '$four' group by pr_cd_pr order by pr_four";
# 	       print $query;
}
	else
	{
	  $query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit,fournis where pr_cd_pr >100000000  and (pr_type=1 or pr_type=5) and (pr_sup=0 or pr_sup=3) and pr_four=fo2_cd_fo and fo2_delai>0 and pr_four like '$four' order by pr_four";	
	}  	
#   print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	&table();
	print "fin";
}

sub table{
	$dateref=$today-21;
	$dateref2=$today-120;
	print "<form action=commande.pl><table border=1 cellspacing=0>";
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup,$rank)=$sth->fetchrow_array)
	{
		$rank_fam1=&get("select tmp_rank from liste1$process where tmp_cd_pr=$pr_cd_pr");
		$rank_fam2=&get("select tmp_rank from liste2$process where tmp_cd_pr=$pr_cd_pr");
		
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
		
		if ($option eq "aerien") {
		# recherche si un produit avec le meme code barre existe dans les references 6 chioffres
 		$query="select pr_cd_pr from produit where pr_codebarre=$pr_cd_pr and pr_cd_pr<1000000 and pr_cd_pr in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1)";
		# print $query;
 		$sth2=$dbh->prepare($query);
 		$sth2->execute();
 		$prodavion=$sth2->fetchrow_array;
 		if ($pr_cd_pr<1000000){$prodavion=$pr_cd_pr;} # pour les produits non navire
 		$stock_avion=0;
 		if (($prodavion eq "")&&($option eq "aerien")){next;}
		}
		%stock=&stock($pr_cd_pr,'','quick','');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	
		
		if ($prodavion ne ""){
			# pour les produit navire qui ont une correspondance avec un code avion on ajoute le stock avion
			%stock=&stock($prodavion,'','quick');
			$stock_avion=$stock{"pr_stre"};
			$query="select max(pi_qte) from pick where pi_cd_pr='$prodavion' and pi_date > DATE_SUB(now(),INTERVAL 15 DAY)";
			# print $query;
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$pick=$sth2->fetchrow_array+0; # stock enlair maximum depuis les 15 derniers jours
			$pr_supa=&get("select pr_sup from produit where pr_cd_pr='$prodavion'");
			if ($pr_supa==3 && $pick==0){$pick=60;}
			if ($pr_supa==2){$pick=0;}
			if (($pick==0)&&($option eq "aerien")){next;}
			# ventes avions sur les 15 derniers jours
			$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_cd_pr=pr_cd_pr and ro_code=v_code and v_date_jl>$dateref and v_rot=1 and pr_cd_pr='$prodavion' group by ro_cd_pr";
  			# print "$query";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vendu)=$sth2->fetchrow_array+0;
			$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_cd_pr=pr_cd_pr and ro_code=v_code and v_date_jl>$dateref2 and v_rot=1 and pr_cd_pr='$prodavion' group by ro_cd_pr";
  			# print "$query";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vendu_3mois)=$sth2->fetchrow_array+0;
			if ($pr_supa==2){$vendu=0;} # pour les produits delistés on force les ventes à zero
		}
		$color="white";
		$stock_ideal=$vendu+$pick+int($vendu/2);
		$besoin_avion=$stock_ideal-$stock_avion;
	 	
	 	# si il y a un besoin avion et une quantite en commande on l'affecte au besoin avion
	 	$reliquat_commande=$qte_commande;
# 	 	print "<td> <fontcolor=red>$reliquat_commande</td>";
	 	if (($qte_commande>0)&&($besoin_avion>0)){
	 		$reliquat_commande=$qte_commande-$besoin_avion;
	 		$besoin_avion-=$qte_commande;
	 		if ($reliquat_commande<0){$reliquat_commande=0;}
	 		}
		if ($besoin_avion<0){$besoin_avion=0;}
	 	
		print "<tr><td>";
		if ($action eq "phase1"){print "<a href=?action=commande&four=$pr_four&option=$option>";}
		print "$pr_cd_pr</a></td><td  bgcolor=$color><a href=fiche_produit.pl?pr_cd_pr=$pr_cd_pr&action=visu>$pr_desi</a></td>";
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
		if ($pr_cd_pr >1000000000){  
		print "<td align=right>$pr_stre</td>";
		}
		else {print "<td align=right>$vendu_3mois</td>";}
		# stock navire 
		print "<td align=right><a href=http://ibs.oasix.fr/cgi-bin/inv_mer_new.pl?produit=$pr_cd_pr&action=go target=_blank>".$cumul{"stock_navire"}."</a></td>";
		print "<td align=right><a href=http://ibs.oasix.fr/cgi-bin/livraison_prochainenew.pl?produit=$pr_cd_pr&action=go target=_blank>".$cumul{"besoin"}."</a></td>";
		$besoin_navire=$cumul{"besoin"}-$pr_stre;
		if ($besoin_navire<0){$besoin_navire=0;}
		print "<td align=right bgcolor=lightyellow><b>$besoin_navire</td>";
		$ecart=(0-$besoin_navire-$besoin_avion+$reliquat_commande);
# 		if ($pr_cd_pr==3346470101838){ print " $pr_cd_pr $ecart<br>";}

		$query="select car_carton from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($carton)=$sth2->fetchrow_array;
		print "<td align=right>$carton</td>";
		$carton+=0;
		if ($carton==0){$carton=24;}
		#### un carton de securite ##############
		if (($ecart==0)&&($pr_stre<24)){$ecart=$pr_stre-24;}
		
		$proposition=int((0-$ecart)/$carton)*$carton;
# 		print "<td>$proposition $ecart $carton $besoin_navire $besoin_avion *$reliquat_commande*</td>";
		if ($ecart%$carton!=0){$proposition+=$carton;}
		if (($proposition<=0)||($ecart>0)){$proposition="";}
	        if ($action eq "commande"){
			print "<td><input type=text name=$pr_cd_pr value='$proposition' size=5></td>";
		}
		else
		{
			print "<td>$proposition</td>";

		}
                print "<td><b>($rank_fam1) </b>";
		if ($pr_sup==2){print "<font color=blue>délisté";}
		if ($pr_sup==3){print "<font color=red>new";}
		print "</td></tr>";
	}
	print "</table>";
	if ($action eq "commande"){
		print "<input type=hidden name=action value=creer>";
		print "<input type=hidden name=four value=$four>";
		print "<br><input type=submit value=\"Ok pour faire la commande\"></form>";
	}
}
sub titre {
	print "</table><table border=1 cellspacing=0><tr height=100><th colspan=19>$fournisseur $fo_nom</th></tr>";
	print "<tr><th>Code produit</th><th>Désignation</th>";
	print "<th>Pick<div>Stock en l'air maxi sur les 15 derniers jours<br />si le produit a l index new le pick est force a 60 <br /> si le produit a l index deliste le pick est force a zero (pick 0 le produit n'apparait pas)</div></th>";
	print "<th>Ventes vab<div>Vendu sur les 3 dernieres semaines</div></th>";
	print "<th>En commande</th><th>Stock<br>avion<br>(Ent+air)</th>";
	print "<th>Stock ideal<br>avion<div >Vendu + pick + vendu/2</div></th>";
	print "<th>Besoin avion<div >stock ideal - stock avion</div></th>";
	print "<th>Ventes sur 3 mois</th><th>Stock navire (mer)</th><th>prochaine livraison</th><th>Besoin navire</th><th>Packing</th><th>A commander</th><th>Ranking</th></tr>";
	$nbligne=0;
}


sub cumul_navire {
	my(%cumul);
	my($stock_navire)=0;
	my($navire);
	my($stock_navire);
	my($besoin);
	my($semaine)=&semaine("");
	if ($pr_cd_pr >1000000000){
		my ($sthg) = $dbh->prepare("select nav_nom from navire,semaine2 where nav_nom=se_navire and se_no>=$semaine and se_no<=$semaine+5 and se_coef!=0 group by nav_nom order by nav_nom"); 
		$sthg->execute;
		while (($navire) = $sthg->fetchrow_array) {
			$besoin=0;
			$stock_navire=&stock_navire($pr_cd_pr,"$navire")+0;
# 			print "***** phase 1 *****<br>";
			%res=&tablenew_navire($pr_cd_pr,$rank_fam1,$rank_fam2,"$navire");
			$cumul{"s+0"}+=$res{"s+0"};
			$cumul{"s+1"}+=$res{"s+1"};
			$cumul{"s+2"}+=$res{"s+2"};
			$cumul{"s+3"}+=$res{"s+3"};
			$cumul{"s+4"}+=$res{"s+4"};
			$cumul{"s+5"}+=$res{"s+5"};
			$cumul{"s+6"}+=$res{"s+6"};
# 			print "**** phase 2 *****";
# 			exit;
# 	   		print "$navire $stock_navire ".$res{"s+0"}." ".$res{"s+1"};
			$stock_navire=$stock_navire-$res{"s+0"}-$res{"s+1"};
			if ($stock_navire<0){$stock_navire=0;}
			$besoin=($res{"s+2"}+$res{"s+3"})-$stock_navire;
			$flag=&get("select count(*) from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_type=0")+0;
			if ($flag==0){$besoin=0;}  # produit non reference sur le bateau
			if ($besoin<0){$besoin=0;}
			$cumul{"besoin"}+=$besoin;
# 	 		if ($pr_cd_pr==3346470101838){ print " $pr_cd_pr $besoin<br>";}
		}
		my ($sthg) = $dbh->prepare("select nav_nom from navire,semaine2 where nav_nom=se_navire and se_no=$semaine and se_coef!=0 group by nav_nom order by nav_nom"); 
		$sthg->execute;
		while (($navire) = $sthg->fetchrow_array) {
			$stock_navire=&stock_navire($pr_cd_pr,"$navire")+0;
			$cumul{"stock_navire"}+=$stock_navire;
		}
        }
	return(%cumul);
}
# -E stock alerte
