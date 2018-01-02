print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF

if ($action eq ""){
	print "<div class=\"alert alert-info\">";
	print "<h3>Stat fournisseur Aerien + Boutique Afrique</h3>";
	print "	</div>";
	# ($debut,$fin)=&get("select min(facture),max(facture) from facture_corse");
	 print "<table class=\"table table-condensed table-bordered table-striped table-hover \" style=font-size:0.8em>";
	 print "<thead>";
	 print "<tr style=font-size:0.8em class=\"info\">";
	 print "<th>Fournisseur</th>";
	 print "<th>Adresse</th>";
	 print "<th>Contact</th>";
	 print "<th>Tel</th>";
	 print "<th>Mail</th>";
	 print "<th>Montant maxi</th>";
	 print "<th>Montant Moyen par facture</th>";
	 print "<th>Montant annuel</th>";
	 print "<th>Nb de facture par mois</th>";
	&save("create temporary table sit_tmp (four int(8),an int(8),mois int(8),montant int(8),nb int(8),primary key(four,an,mois))");
	$base_query="livh_base='aircotedivoire' or livh_base='togo' or livh_base='tacv' or livh_base='camairco' or livh_base='cameshop'";
	$query="select * from livraison_h where $base_query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
		if (($livh_base eq "cameshop")&&($livh_id<700)){next;}
		
		$local=&get("select fo2_identification from $livh_base.fournis where fo2_cd_fo='$livh_four'");
		if ($local==1){next;}
		if ($livh_four==0){next;}
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		$an=&get("select year('$livh_date_facture')");
		$mois=&get("select month('$livh_date_facture')");
		&save("insert ignore into sit_tmp values ('$livh_four','$an','$mois','$montant',0)");
		&save("update sit_tmp set nb=nb+1,montant=montant+$montant where four='$livh_four' and an='$an' and mois='$mois'","af");
	}
	$query="select distinct(four) from sit_tmp order by four";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($four)=$sth->fetchrow_array){
		$total=0;
		$total_nb=0;
		($fo_add,$fo2_contact,$fo2_telph,$fo2_mail)=&get("select fo2_add,fo2_contact,fo2_telph,fo2_email from fournis where fo2_cd_fo='$four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$fo_add=~s/\*/ /g;
		if ($fo_nom eq ""){next;}
		$montant_max=&get("select max(montant) from sit_tmp where four='$four'");
		$montant_moyen=&get("select avg(montant) from sit_tmp where four='$four'");
		$montant_total=&get("select sum(montant) from sit_tmp where four='$four'");
		
		($first_an,$first_mois)=&get("select 2015,min(mois) from sit_tmp where four='$four' and an=2015");
		$first_mois+=0;
		$first_date="2015-$first_mois-01";
		if ($first_mois==0){
		 	($first_an,$first_mois)=&get("select 2016,min(mois) from sit_tmp where four='$four' and an=2016");
			$first_date="2016-$first_mois-01";
		}
		$ecart_date=&get("select datediff(curdate(),'$first_date')");
		$nb_facture=&get("select sum(nb) from sit_tmp where four='$four'");
		$moyenne_nb=$nb_facture*30/$ecart_date;
		$montant_an=$montant_total*365/$ecart_date;
		printf("<tr><td>$fo_nom</td><td>$fo_add</td><td>$fo2_contact</td><td>$fo2_telph</td><td>$fo2_mail</td><td align=right>%d</td><td align=right>%d</td><td align=right>%d</td><td align=right>%.1f</td></tr>",$montant_max,$montant_moyen,$montant_an,$moyenne_nb,$montant_an);
	}
	print "</table>";
}	
print "		
		</div>
	</div>
</div>";
