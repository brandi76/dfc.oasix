print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF

if ($action eq ""){
	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des factures Dfc à Corsica</h3>";
	print "	</div>";
	($debut,$fin)=&get("select min(facture),max(facture) from facture_corse");
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>No</th>";
	print "<th>Montant avec tva</th>";
	print "<th>Bl</th>";
	print "<th>Fournisseur</th>";
	print "<th>Delai paiement</h>";
	print "<th>Base</th>";
	print "<th>Facture fo</th>";
	print "<th>Montant</th>";
	print "<th>Ecart</th>";
	print "<th>Date facture</th>";
	print "<th>Date paiement prevu</th>";
	print "<th>Date entree</th>";
	print "</tr>";
	print "</thead>";
	for ($i=$debut;$i<=$fin;$i++){
		($total_tva,$bl)=&get("select total_tva,bl from facture_corse where facture=$i");
		$query="select * from livraison_h where livh_id=$bl";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array;
		$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$date_entree=&get("select enh_date from $livh_base.enthead where enh_document='$livh_id'")+0; 
		if ($date_entree==0){$date_entree="0000-00-00";}else{$date_entree=&julian($date_entree,"YYYY-MM-DD");}
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		$an=&get("select year('$livh_date_facture')");
		# if ($an!=$an_run){
			# if ($total >0){
				# print "<tr><td><strong>Total $an_run</td><td align=right>$total</td></tr>";
			# }
			# $an_run=$an;
			# $total=0;
		# }
		# $total+=$total_tva;	
		$total_an{"$an"}+=$total_tva;
		$rapport=0;
		$rapport=int($total_tva*10000/$montant)/100 if ($montant>0);
		$fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
		$livh_date_pai=&get("select adddate('$livh_date_facture',$fo_delai)");
		print "<tr><td>$i</td><td align=right>$total_tva</td><td>$bl</td><td>$fo_nom</td><td>$fo_delai</td><td>$livh_base</td><td>$livh_facture</td><td align=right>$montant</td><td>$rapport %</td><td>$livh_date_facture</td><td>$livh_date_pai</td><td>$date_entree</td></tr>";
	}
	foreach $cle (keys(%total_an)) {
		print "<tr><td><strong>Total $cle</td><td align=right>".$total_an{"$cle"}."</td></tr>";
	}
	print "</table>";

	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des Bl sans facture</h3>";
	print "	</div>";
	$query="select * from livraison_h where livh_base='corsica' and livh_id not in (select bl from facture_corse) order by livh_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Fournisseur</th>";
	print "<th>Bon de livraison</th>";
	print "<th>Facture</th>";
	print "<th>Date Facture</th>";
	print "<th>Montant</th>";
	print "<th>Reglement</th>";
	print "<th>Date entrée</th>";
	print "</tr>";
	
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
		$local=&get("select fo2_identification from corsica.fournis where fo2_cd_fo='$livh_four'");
		if ($local){next;}
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		$reglement=&get("select sum(montant) from dfc.reglement where reg_id='$livh_id'")+0;
		$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$date_entree=&get("select enh_date from $livh_base.enthead where enh_document='$livh_id'")+0; 
		if ($date_entree==0){$date_entree="0000-00-00";}else{$date_entree=&julian($date_entree,"YYYY-MM-DD");}
		print "<tr><td>$fo_nom</td><td>$livh_id</td><td>$livh_facture</td><td>$livh_date_facture</td><td align=right>$montant</td>";
		$reglement=&get("select montant from dfc.reglement where reg_id='$livh_id'")+0;
		print "<td align=right>$reglement</td><td>$date_entree</td></tr>";
		$total+=$montant;
	}
	print "<tr><td colspan=4><strong>Total</td><td align=right>$total</td></tr>";
	print "</table>";
	
}
print "		
		</div>
	</div>
</div>";
