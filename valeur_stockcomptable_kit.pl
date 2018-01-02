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

if ($action eq "go"){
	$query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "stock comptable $client $date_ref<br>";
	print "<table><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
	{
			%stock=&stock_comptable($pr_cd_pr,'',"quick");
			$stck=$stock{"pr_stre"};
			# if ($stck <0){next;}
			# if ($stck==0){next;}
			$sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			$entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			$stck-=$entree;
			$stck+=$sortie;
			$total=$stck*$pr_prac;
			$total_gen+=$total;
			print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
	}
	print "</table>";
	print "<b>total:$total_gen</b>";
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