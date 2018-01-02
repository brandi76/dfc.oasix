print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
@base_liste=("togo","aircotedivoire","camairco","tacv","cameshop");
if ($action eq ""){
	print "<div class=\"alert alert-info\">";
	print "<h3>Stat fournisseur Aerien + Boutique Afrique</h3>";
	print "	</div>";
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \" style=font-size:0.8em>";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Fournisseur</th>";
	print "<th>Adresse</th>";
	print "<th>Contact</th>";
	print "<th>Tel</th>";
	print "<th>Mail</th>";
	print "<th>Produit</th>";
	print "<th>Delai de paiement</th>";
	print "<th>Montant maxi</th>";
	print "<th>Montant Moyen par facture</th>";
	print "<th>Montant annuel</th>";
	print "<th>Nb de facture par mois</th>";
	print "<th>Nb de reference sortie par mois (moyenne)</th>";
	&save("create temporary table sit_tmp (four int(8),an int(8),mois int(8),montant int(8),nb int(8),qte int(8), primary key(four,an,mois))");
	#&save("truncate table sit_tmp");
	$base_query="livh_base='aircotedivoire' or livh_base='togo' or livh_base='tacv' or livh_base='camairco' or livh_base='cameshop'";
	$query="select * from livraison_h where $base_query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
		if (($livh_base eq "cameshop")&&($livh_id<757)){next;}
		$local=&get("select fo2_identification from $livh_base.fournis where fo2_cd_fo='$livh_four'");
		if ($local==1){next;}
		if ($livh_four==0){next;}
		$check=&get("select count(*) from $livh_base.enthead where enh_document='$livh_id'");
		#pas d'entree
		if ($check==0){next;}
		($qte,$montant)=&get("select sum(livb_qte_fac),sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");

		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		$an=&get("select year('$livh_date_facture')");
		$mois=&get("select month('$livh_date_facture')");
		&save("insert ignore into sit_tmp values ('$livh_four','$an','$mois','$montant',0,'0')");
		&save("update sit_tmp set nb=nb+1,montant=montant+$montant,qte=qte+$qte where four='$livh_four' and an='$an' and mois='$mois'","af");
		
	}
	$query="select distinct(four) from sit_tmp order by four";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($four)=$sth->fetchrow_array){
		$total=0;
		$total_nb=0;
		($fo_add,$fo2_contact,$fo2_telph,$fo2_mail,$fo2_delai)=&get("select fo2_add,fo2_contact,fo2_telph,fo2_email,fo_delai_pai from fournis where fo2_cd_fo='$four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$fo_add=~s/\*/ /g;
		if ($fo_nom eq ""){next;}
		$montant_max=&get("select max(montant) from sit_tmp where four='$four'");
		$montant_moyen=&get("select avg(montant) from sit_tmp where four='$four'");
		$montant_total=&get("select sum(montant) from sit_tmp where four='$four'");
		$qte_total=&get("select sum(qte) from sit_tmp where four='$four'");
		
		$query="select distinct fa_desi from togo.produit_plus,togo.produit,famille where pr_famille=fa_id and produit_plus.pr_cd_pr=produit.pr_cd_pr and pr_four='$four' and pr_four!=0 and pr_famille<50 and (pr_sup=0 or pr_sup=3)";
		$famille="";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($fa_desi)=$sth2->fetchrow_array){
			$famille.="$fa_desi ";
		}
		if (! grep(/[a-z]/,$famille) ){
			# $famille="*";
			$query="select distinct fa_desi from cameshop.produit_plus,cameshop.produit,cameshop.famille where pr_famille=fa_id and produit_plus.pr_cd_pr=produit.pr_cd_pr and pr_four='$four' and pr_four!=0 and pr_famille!=99 and (pr_sup=0 or pr_sup=3)";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($fa_desi)=$sth2->fetchrow_array){
				$famille.="$fa_desi ";
			}
			# $famille=$query;
		}
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
		# $moyenne_qte=$qte_total*30/$ecart_date;
		$total_nbref=0;
		for ($i=5;$i<10;$i++){
			$query="select count(distinct(code)) from dfc.vendu_mensuel,dfc.produit where pr_cd_pr=code and pr_four=$four and an=2016 and mois=$i group by code";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($nb)=$sth2->fetchrow_array){
				$total_nbref+=$nb;
			}	
		}
		$moyenne_qte=$total_nbref/5;
		# j'avais mis moyenne de qte par facture que j'ai remplacé par moyenne de nombre de ref de vendu
		printf("<tr><td>$four $fo_nom</td><td>$fo_add</td><td>$fo2_contact</td><td>$fo2_telph</td><td>$fo2_mail</td><td>$famille</td><td>$fo2_delai</td><td align=right>%d</td><td align=right>%d</td><td align=right>%d</td><td align=right>%.1f</td><td align=right>%.1f</td></tr>",$montant_max,$montant_moyen,$montant_an,$moyenne_nb,$moyenne_qte);
	}
	print "</table>";

	####### Par mois #############

	print "Par mois <table class=\"table table-condensed table-bordered table-striped table-hover \" style=font-size:0.8em>";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Fournisseur</th><th align=right>06/2015</th>";
	for ($i=7;$i<13;$i++){
		print "<th align=right>$i/2015</th>";
	}	
	for ($i=1;$i<10;$i++){
		print "<th align=right>$i/2016</th>";
	}	
	print "</tr>";
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
		print "<tr><td>$fo_nom</td><td align=right>0</td>";
		for ($i=7;$i<13;$i++){
			$montant=&get("select sum(montant) from sit_tmp where four='$four' and an=2015 and mois=$i");
			print "<td align=right>$montant</td>";
		}	
		for ($i=1;$i<10;$i++){
			$montant=&get("select sum(montant) from sit_tmp where four='$four' and an=2016 and mois=$i");
			print "<td align=right>$montant</td>";
		}
		print "</tr>";
	}
	print "<tr style=font-weight:bold><td>Total Achat</td><td align=right>0</td>";
	$index=0;
	for ($i=7;$i<13;$i++){
		$montant=&get("select sum(montant) from sit_tmp where an=2015 and mois=$i");
		print "<td align=right>$montant</td>";
		$fin[$index++]=$montant
	}	
	for ($i=1;$i<10;$i++){
		$montant=&get("select sum(montant) from sit_tmp where an=2016 and mois=$i");
		print "<td align=right>$montant</td>";
		$fin[$index++]=$montant
	}
	print "</tr><tr>";
	### stock ####	
	foreach $base (@base_liste){
		print "<tr><td>$base</td>";
	    $stock=int(&get("select sum(qte*prac) from stock_mensuel where base='$base' and date='2015-06-30'")+0);
		print "<td align=right>$stock</td>";
		$total_stock+=$stock;
		print "</tr>";
	}
	print "<tr style=font-weight:bold><td>Total Stock</td><td align=right>$total_stock</td></tr>";
	### vente ###
	foreach $base (@base_liste){
		print "<tr><td>$base</td><td>&nbsp;</td>";
		for ($i=7;$i<13;$i++){
			$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where base='$base' and an=2015 and mois=$i")+0);
			print "<td align=right>$vendu</td>";
		}
		for ($i=1;$i<10;$i++){
			$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where base='$base' and an=2016 and mois=$i")+0);
			print "<td align=right>$vendu</td>";
		}
		print "</tr>";
	}
	$index=0;
	print "<tr style=font-weight:bold><td>Total sortie</td><td>&nbsp;</td>";
	for ($i=7;$i<13;$i++){
		$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where an=2015 and mois=$i")+0);
		print "<td align=right>$vendu</td>";
		$fin[$index++]-=$vendu;
	}
	for ($i=1;$i<10;$i++){
		$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where an=2016 and mois=$i")+0);
		print "<td align=right>$vendu</td>";
		$fin[$index++]-=$vendu;
	}
	print "</tr>";
	
	print "<tr style=font-weight:bold><td>Stock fin de mois</td><td>&nbsp;</td>";
	for ($i=7;$i<13;$i++){
		$total_stock+=$fin[$i];
		print "<td align=right>$total_stock</td>";
	}
	for ($i=1;$i<10;$i++){
		$total_stock+=$fin[$i];
		print "<td align=right>$total_stock</td>";
	}
	print "</tr>";
	print "</table>";	
	print "Stock au 30-09-2016<br>";
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \" style=font-size:0.8em>";
	$total_gen=0;
	push(@base_liste,'corsica');
	
	foreach $base (@base_liste){
	    $total=&get("select sum(qte*prac) from stock_mensuel,$base.produit_plus where base='$base' and code=pr_cd_pr and date='2016-09-30' and pr_famille<100","af" )+0;
		$query="select fag_desi,sum(qte*prac) from stock_mensuel,$base.produit_plus,dfc.famille_group where base='$base' and code=pr_cd_pr and date='2016-09-30' and pr_famille<100 and fag_id=pr_famille group by fag_desi";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($famille,$stock)=$sth2->fetchrow_array){
			if ($stock<0){$total-=$stock;next;}
			#$fa_desi=&get("select fa_desi from $base.famille where fa_id=$pr_famille");
			# $fa_desi=&get("select fag_desi from dfc.famille_group where fag_id=$pr_famille");
			# $fa_desi2=&get("select fa_desi from $base.famille where fa_id=$pr_famille");
			$stock=int($stock);
			$pour=$stock*100/$total;
			$pour=int($pour*100)/100;
			print "<tr><td>$base</td><td>$famille</td>";
			print "<td align=right>$stock</td>";
			print "<td align=right>$pour%</td>";
			$fam{"$famille"}+=$stock;
			print "</tr>";
		}
		$total_gen+=$total;
	}
	$base="dutyfreeambassade";
	$total=&get("select sum(qte*prac) from stock_mensuel where base='$base'  and date='2016-09-30' ","af" )+0;
	$query="select libelle,sum(qte*prac) from stock_mensuel,$base.produit_web,$base.famille where base='$base' and stock_mensuel.code=produit_web.code and date='2016-09-30' and famille_index=type_douane group by libelle";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($famille,$stock)=$sth2->fetchrow_array){
		$famille=~s/^.//g;
		$famille=~s/\t//g;
		
		$famille="Alcool" if $famille eq "Alcools";
		$famille="Vin-Champagne" if $famille eq "Champagne libre";
		$famille="Vin-Champagne" if $famille eq "ABV VDL";
		$famille="Vin-Champagne" if $famille eq "VDN";
		$famille="Vin-Champagne" if $famille=~/Vin/;
		$famille="Autre" if $famille eq "";
		$famille="Autre" if length($famille)<3;
		$famille="Cigarrette-Cigare-Tabac" if $famille eq "Cigares";
		$famille="Parfum_Cosmetique" if $famille eq "Cosmetique";
		$famille="Parfum_Cosmetique" if $famille eq "Parfums";
		$famille="Alcool" if $famille=~/Rhum/;
		$famille="Cigarrette-Cigare-Tabac" if (grep /Tabac/,$famille);
		$famille="Autre" if $famille eq "Valeures";
		
		#$fa_desi=&get("select fa_desi from $base.famille where fa_id=$pr_famille");
		# $fa_desi=&get("select fag_desi from dfc.famille_group where fag_id=$pr_famille");
		# $fa_desi2=&get("select fa_desi from $base.famille where fa_id=$pr_famille");
		# $stock=int($stock);
		# $pour=$stock*1000000/$total;
		# $pour=int($pour)/100;
		# print "<tr><td>$base</td><td>$famille</td>";
		# print "<td align=right>$stock</td>";
		# print "<td align=right>$pour%</td>";
		$fam{"$famille"}+=$stock;
		$fam_dfa{"$famille"}+=$stock;
		# print "</tr>";
	}	
	$total_gen+=$total;
	
	foreach $cle (keys %fam_dfa){
       $val=int($fam_dfa{$cle});
		print "<tr><td>DutyfreeAmbassade</td><td>$cle</td><td align=right>".$val."</td>";
		$pour=$fam_dfa{$cle}*100/$total;
		$pour=int($pour*100)/100;
		print "<td align=right>$pour% </td></tr>";
	}
	
	foreach $cle (keys %fam){
		print "<tr><td>Total</td><td>$cle</td><td align=right>".$fam{$cle}."</td>";
		$pour=$fam{$cle}*100/$total_gen;
		$pour=int($pour*100)/100;
		print "<td align=right>$pour%</td></tr>";
	}
	print "</table>"
	
}	

print "		
		</div>
	</div>
</div>";
