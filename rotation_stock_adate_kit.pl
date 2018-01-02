print "Stock actuel moins les entrées sorties depuis la date indiquée<br>";
$client=$html->param("client");
$date_ref=$html->param("date_ref");
($j,$m,$a)=split(/\//,$date_ref);
if ($a ne ""){$date_ref="$a-$m-$j";}
print "<form>";
&form_hidden();
print "<select name=client>";
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	print "<option value=$client>$client</option>";
}
print "</select >";
print "Date du stock <input type=date name=date_ref id=datepicker>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";

if (($action eq "go")&&($client ne "")&&($date_ref ne "")){
	&save("create temporary table rotation_tmp (pr_cd_pr bigint(16), pr_desi varchar(40),pr_stre int (8),pr_prac decimal (8,2),vendu int(8), moyenne decimal (6,3))");
	$query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$an=&get("select year('$date_ref')");
	print "<h3>$an $client</h3>";
	$date_ref_debut="$an-01-01";
	$nb_jour=&get("select datediff('$date_ref','$date_ref_debut')")+0;
	$nb_jour=1 if ($nb_jour==0);
	while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array){
		%stock=&stock_comptable($pr_cd_pr,'',"quick");
		$stck=$stock{"pr_stre"};
		# if ($stck <0){next;}
		# if ($stck==0){next;}
		$sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
		$entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
		$stck-=$entree;
		$stck+=$sortie;
		$pr_stre=int($stck);
		# $pr_prac=int($pr_prac*100)/100;
		$vendu=&get("select floor(sum(ro_qte)/100) from $client.rotation,$client.vol where ro_code=v_code and ro_cd_pr='$pr_cd_pr' and year(v_date_sql)=year('$date_ref') and v_date_sql<='$date_ref'  and v_rot=1")+0 ; 
		$moyenne=0;
		if ($vendu !=0){
			$moyenne=$vendu/$nb_jour;
			$rot=$pr_stre/$moyenne;
			$rot=int($rot);
			# $moyenne=int($moyenne*100)/100;
			$nb++;
		}
		&save("insert ignore into rotation_tmp values ('$pr_cd_pr','$pr_desi','$pr_stre','$pr_prac','$vendu','$moyenne')");
	}
	print "<table border=1 cellspacing=0><tr><th>Produit</th><th>Stock</th><th>Prix achat</th><th>Vendu</th><th>Vente/jour</th><th>Valeur</th></tr>";
	$query="select * from rotation_tmp order by moyenne desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_prac,$vendu,$moyenne)=$sth->fetchrow_array){
		$valeur=$pr_prac*$pr_stre;
		print "<tr><td>$pr_cd_pr $pr_desi</td><td align=right>$pr_stre</td><td align=right>$pr_prac</td><td align=right>$vendu</td><td align=right>";
		printf("%.3f",$moyenne);
		print "</td><td align=right>";
		printf("%.2f",$valeur);
		print "</td></tr>";
		$total+=$valeur;
	}	
	print "<tr><th colspan=5>Total</th><th align=right>$total</td></tr></table>";
}	
sub stock_comptable {
	my($prod)=$_[0];
	my($stock,$non_sai,$pastouch,$max,$pastouch2,$retourdujour,$errdep);
	my(%stock);
	my($query) = "select * from $client.produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	my($produit)=$sth->fetchrow_hashref;
	$stock{"vol"}=$produit->{'pr_stvol'}/100;
	$query = "select sum(erdep_qte) from $client.errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$errdep=$sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	$stock{"pr_stre"}=$stock{"stre"}-$stock{"casse"}+$stock{"diff"}+$stock{"errdep"}; # stock comptable
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100; # entrepot
	return(%stock);
}

;1