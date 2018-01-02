print "<title>bascule de stock</title>";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

$action=$html->param("action");
$four=$html->param("four");
$option=$html->param("option");

require "./src/connect.src";

if ($action eq ""){
	&table();
}
if ($action eq "nva"){
	$query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_codebarre from produit where (pr_type=1 or pr_type=5) and pr_cd_pr<10000000";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0><caption><h3>Stock navire vers avion</h3></caption><tr><th>Code produit</th><th>Désignation</th><th>Qte à bouger</th><th>reste</th><th>Check</th></tr>";
	$dateref=$today-15;
	while (($pr_cd_pr,$pr_sup,$pr_desi,$pr_codebarre)=$sth->fetchrow_array)
	{
		$qte=$html->param("$pr_cd_pr")+0;
		if ($qte==0){ next;}

		######################
		 &maj_nva();		
		######################

		%stock=&stock($pr_codebarre,'','');
		$pr_stre=$stock{"stock"}+0;  # stock reel entrepot 
		$digit_f=$pr_codebarre%1000000+1000000;
		$digit_f=substr($digit_f,3,4);
		$digit_p=int($pr_codebarre/10000);
		print "<tr><td>$digit_p <b>$digit_f</b></td><td>$pr_desi</td>";
		print "<td align=right>";
		&carton($pr_codebarre,$qte);
		print "</td><td align=right>";
		&carton($pr_codebarre,$pr_stre);
		print "</td><td><input type=checkbox></tr>";
		push (@table,$pr_cd_pr);
		
		%stock=&stock($pr_cd_pr,"$today","retour");
		$pr_stre=$stock{"stock"}+0-$retour;  # stock reel entrepot 
		print "<tr><td><b>$pr_cd_pr</b></td><td>$pr_desi</td>";
		print "<td align=right>";
		&carton($pr_cd_pr,$qte);
		print "</td><td align=right>";
		&carton($pr_cd_pr,$pr_stre);
		print "</td><td><input type=checkbox></tr>";
	
	
	}
	print "</table><br><br>";

}
if ($action eq "avn"){
        print "<center><h2>Bascule avion vers navire du ";
        print `date`;
        print "</h2><br>"; 
	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>Désignation</th><th>Qte à entrer</th><th>nouveau stock</th><th>Check</th></tr>";
	$query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_codebarre from produit where (pr_type=1 or pr_type=5) and pr_cd_pr<10000000";

	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_sup,$pr_desi,$pr_codebarre)=$sth->fetchrow_array)
	{
		$qte=$html->param("$pr_cd_pr")+0;
		if ($qte ==0 ){next;}
		######################
		&maj_avn();		
		######################
		
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
		print "<td align=right>";
		&carton($pr_cd_pr,$qte);
		print "</td><td align=right>";
		%stock=&stock($pr_codebarre,'','');
		$stocknavire=$stock{"stock"}+0; # stock entrepot + stock avion
        	&carton($pr_cd_pr,$stocknavire);
	        print "</td><td>&nbsp;</td>";
		print "</tr>";
	}
	print "</table>";
}

sub table{
	print "<h3>Navire vers Avion *</h3><br>";
	print "<form>";
	require ("form_hidden.src");
	print "<table border=1 cellspacing=0><tr><th>code</th><th>Designation</th><th>stock ideal</th><th>stock</th><th>stock entrepot<br>avion</th><th>stock entrepot<br>navire</th></tr>";
	$dateref=$today-15;
	$query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_codebarre from corsica,produit where pr_cd_pr=cor_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_sup,$pr_desi,$pr_codebarre)=$sth->fetchrow_array)
	{
		$pick=60;
		$vendu=0;
		%stock=&stock($pr_cd_pr,"$today","retour");
		$stockavion=$stock{"pr_stre"};
		$stockentrepot=$stock{"stock"};	
		$retour=$stock{"retourdujour"};
		$stockentrepot-=$retour;
		$stock_ideal=$pick;
		$ecart=$stockavion-$stock_ideal;
 		if ($ecart >=0) {next;}
		%stock=&stock($pr_codebarre,'','');
		$pr_stre_nav=$stock{"stock"}+0;  # stock reel entrepot
		$ecart=0-$ecart;
		 print "$pr_cd_pr $pr_desi $stock_ideal $stockavion $pr_stre_nav<br>";
		if ($ecart<=0){next;} 
		if ($stockentrepot<12){$ecart=24;}
		if ($ecart >$pr_stre_nav){$ecart=$pr_stre_nav;}
		if (($ecart<6)&&($stockentrepot>20)){next;} 

		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$stock_ideal</td><td>$stockavion</td><td>$stockentrepot</td><td>$pr_stre_nav</td><td>";
		if ($pr_stre_nav==0){print "rupture";}
		else {print "<input type=text name=$pr_cd_pr value=$ecart>";}
		print "</td></tr>";
	}
	print "</table><br>";
	print "<input type=hidden name=action value=nva><input type=submit value='ok pour la bascule navire vers avion'></form><br><br>";
	
	print "<h3>Avion vers Navire</h3><br>";
	print "<form>";
	require ("form_hidden2.src");
	print "<table border=1 cellspacing=0><tr><th>code</th><th>Designation</th><th>stock avion</th><th>stock navire</th><th>proposition</th></tr>";
	# $query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_codebarre from produit where (pr_type=1 or pr_type=5) and pr_desi not like 'TESTEUR%' and pr_cd_pr<10000000 and pr_cd_pr in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr=pr_cd_pr)";
	$query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_codebarre from produit where (pr_type=1 or pr_type=5) and pr_desi not like 'TESTEUR%' and pr_cd_pr<10000000 ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_sup,$pr_desi,$pr_codebarre)=$sth->fetchrow_array)
	{
		# print "$pr_cd_pr<br>";
		%stock=&stock($pr_cd_pr,'','');
		$pr_stre=$stock{"stock"}+0;  # stock reel entrepot 
		if ($pr_stre<=0){next;}
		$carton=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'");
		if ($carton==0) {next;}
		$prop=int(($pr_stre-$carton)/$carton)*$carton;
		if ($pr_sup!=0 && $pr_sup!=3){$prop=$pr_stre;}
		if (($pr_stre <$carton*2)&&($pr_sup==3 || $pr_sup==0)){next;}
		if ((&get("select count(*) from produit where pr_cd_pr='$pr_codebarre'")+0)==0){next;}
		%stock=&stock($pr_codebarre,'','');
		$pr_stre_nav=$stock{"stock"};  # stock reel entrepot
		print "<tr><td>$pr_cd_pr </td><td>$pr_desi</td><td>$pr_stre</td><td>$pr_stre_nav</td><td>";
		print "<input type=text name=$pr_cd_pr value=$prop>";
		print "</td></tr>";
	}
	print "</table><br><br>";
	print "<input type=hidden name=action value=avn><input type=submit value='ok pour la bascule avion vers navire'></form><br><br>";

}	
sub maj_nva {
	$query="select count(*) from enso where es_cd_pr=$pr_cd_pr and es_dt=curdate()+0 and es_type=24";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array+0;
	if ($nb>0) { 
		print "<font color=red>$pr_cd_pr $pr_desi une seule bascule de stock autorisé par jour </font><br>";
		return();
	}

	$qtemaj=$qte*-100;
	
	$query="update produit set pr_stre=pr_stre-$qtemaj where pr_cd_pr='$pr_cd_pr';";
	$sth=$dbh->prepare($query);
	$sth->execute();

	$query="insert into enso values ('$pr_cd_pr','',curdate()+0,'$qtemaj','0','24')";	
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	$query="update produit set pr_stre=pr_stre+$qtemaj where pr_cd_pr='$pr_codebarre';";
	$sth=$dbh->prepare($query);
	$sth->execute();
        $qtemaj=0-$qtemaj;
	$query="insert into enso values ('$pr_codebarre','',curdate()+0,'$qtemaj','0','24')";	
	$sth=$dbh->prepare($query);
	$sth->execute();
}

sub maj_avn {
	$query="select count(*) from enso where es_cd_pr=$pr_cd_pr and es_dt=curdate()+0 and es_type=24";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array+0;
	if ($nb>0) { 
		print "<font color=red>$pr_cd_pr $pr_desi une seule bascule de stock autorisé par jour </font><br>";
		return();
	}

	$qtemaj=$qte*100;
	$query="update produit set pr_stre=pr_stre-$qtemaj where pr_cd_pr='$pr_cd_pr';";
	$sth=$dbh->prepare($query);
	$sth->execute();

	$query="insert into enso values ('$pr_cd_pr','',curdate()+0,'$qtemaj','0','24')";	
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	$query="update produit set pr_stre=pr_stre+$qtemaj where pr_cd_pr='$pr_codebarre';";
	$sth=$dbh->prepare($query);
	$sth->execute();
        $qtemaj=0-$qtemaj;
	$query="insert into enso values ('$pr_codebarre','',curdate()+0,'$qtemaj','0','24')";	
	$sth=$dbh->prepare($query);
	$sth->execute();
}
;1
# -E bascule de stock
