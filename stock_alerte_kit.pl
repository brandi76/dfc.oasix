$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);
$action=$html->param("action");
$four=$html->param("four");
$mag=$html->param("mag");


if (($four eq "")||($four eq "TOUS")){$four="%";}
print "<title>stock alerte</title>";
print "<style type=\"text/css\">
#saut { page-break-after : right }         
th:hover div {
	font-weight:normal;
	background-color:lightyellow;
	display:block;
}

th div {
	display:none;
}

</style>";

if ($action eq ""){
	print "<form> Code fournisseur ? <select name=four>";
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo  group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
        print "<option value='TOUS'>TOUS\n";
    	
    	print "</select>";
    	print "<br>Produit present dans le mag <select name=mag>";
    	print "<option></option>";
    	$sth2 = $dbh->prepare("select distinct mag from mag order by mag desc");
    	$sth2->execute;
    	while ($mag = $sth2->fetchrow_array) {
       		print "<option value='$mag'>$mag</option>";
    	}
    	print "</select>";
	&form_hidden();
	
	print "<br><input type=submit>";
	print "<input type=hidden name=action value=phase1></form>";
}

if ($action ne  ""){
	$query="select pr_cd_pr,pr_desi,pr_type,pr_four,pr_sup from produit,fournis,trolley,lot where pr_cd_pr=tr_cd_pr and tr_code=lot_nolot and lot_flag=1 and (pr_sup=0 or pr_sup=3) and pr_four=fo2_cd_fo and fo2_delai>0 and pr_four like '$four' group by pr_cd_pr order by pr_four";
# 	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	&table();
}

sub table{
	$dateref=$today-21;
	$dateref2=$today-120;
	print "<form>$mag<table border=1 cellspacing=0>";
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_four,$pr_sup,$rank)=$sth->fetchrow_array)
	{
	        if ($mag ne ""){
		  $check=&get("select count(*) from mag where code=$pr_cd_pr")+0;
		  if ($check==0){next;}
		 } 
		$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_commande)=$sth2->fetchrow_array+0;
		$query="select max(com2_date) from commande where com2_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($date_commande)=$sth2->fetchrow_array-10000000;
		
		if ($date_commande<0){$date_commande=""};
		
		if ($pr_four ne $fournisseur){
			$sth3=$dbh->prepare("select fo2_cd_fo,fo2_add from fournis where fo2_cd_fo='$pr_four'");
			$sth3->execute();
			($fournisseur,$fo_nom)=$sth3->fetchrow_array;
			&titre();
		}
		$vendu=0;
		$pick=0;
		
		%stock=&stock($pr_cd_pr,'','quick','');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
		$prodavion=$pr_cd_pr;
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
# 		if ($pick==0){next;}
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
		$color="white";
		
		$nb_jour=&get("select count(distinct at_date) from etatap where at_etat=5")+0;
		if ($nb_jour >21) {$nb_jour=21;} 
		if ($nb_jour==0) {$nb_jour=21;} 
		
		#$stock_ideal=$vendu+$pick+int($vendu/2);
		# modifié par daniel le 26 aout 2013 pour demarrage de aircote d'ivoire
		$stock_ideal=int($vendu*30/$nb_jour)+$pick;
	
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
		print "<a href=?onglet=0&sous_onglet=0&sous_sous_onglet=&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a>";
		print "</td><td >$pr_desi</td>";
		print "<td align=right>";
		print "$pick</td><td align=right>$vendu</td>";
		print "<td align=right>&nbsp;";
		if ($qte_commande>0){print "$qte_commande ".&date($date_commande);}
		print "</td>";
		print "<td align=right>$stock_avion</td><td align=right>$stock_ideal</td><td align=right bgcolor=lightyellow><b>$besoin_avion </td>";
		print "<td align=right>$vendu_3mois</td>";
		$ecart=(0-$besoin_navire-$besoin_avion+$reliquat_commande);
		$query="select car_carton from carton where car_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($carton)=$sth2->fetchrow_array;
		print "<td align=right>$carton &nbsp;</td>";
		$carton+=0;
		$proposition=0-$ecart;
		if ($carton >0){
			$proposition=int((0-$ecart)/$carton)*$carton;
			if ($ecart%$carton!=0){$proposition+=$carton;}
		}
 		if (($proposition<=0)||($ecart>0)){$proposition="";}
	       	print "<td><input type=text name=$pr_cd_pr value='$proposition' size=5></td>";
		print "</tr>";
	}
	print "</table>";
	print "<input type=hidden name=onglet value=2>";
	print "<input type=hidden name=sous_onglet value=0>";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=option value=alerte>";
	print "<input type=hidden name=four value=$four>";
	print "<br><input type=submit value=\"Bascule vers l'application de commande\"></form>";
}

sub titre {
	print "</table><table border=1 cellspacing=0><tr height=100><th colspan=19>$fournisseur $fo_nom</th></tr>";
	print "<tr><th>Code produit</th><th>Désignation</th>";
	print "<th>Pick<div>Stock en l'air maxi sur les 15 derniers jours<br />si le produit a l index new le pick est force a 60 <br /> si le produit a l index deliste le pick est force a zero (pick 0 le produit n'apparait pas)</div></th>";
	print "<th>Ventes vab<div>Vendu sur les 3 dernieres semaines</div></th>";
	print "<th>En commande</th><th>Stock<br>avion<br>(Ent+air)</th>";
	print "<th>Stock ideal<br>avion<div >Vendu*30/min(nb-jour-de-vente,21) + pick </div></th>";
	print "<th>Besoin avion<div >stock ideal - stock avion</div></th>";
	print "<th>Ventes sur 3 mois<div> N'intervient pas dans le calcul</div></th><th>Packing</th><th>A commander</th></tr>";
	$nbligne=0;
}

;1
