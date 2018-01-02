
push(@bases_client,"corsica");
push(@bases_client,"cameshop");

$client=$html->param("client");
	
print <<EOF;
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF


if ($action eq ""){
    if ($client eq ""){
		print "<form>";
		&form_hidden();
		print "<select name=client class=\"form-control\">";
		foreach $client (@bases_client){
			if ($client eq "dfc"){next;}
			print "<option value=$client>$client</option>";
		}
		print "</select>";
		print "<button type=\"submit\" class=\"btn btn-success\">Filtrer</button>";
		print "</form>";
		$client="%";
	}

	&save("create temporary table cde_tmp (base varchar(20),four int(8),id int(8),facture varchar(30),date_fature date,date_echance date,montant decimal (8,2),delai int(5),reglement decimal (8,2),date_reglement date)");
	$query="select * from livraison_h where livh_date >='2015-06-01' and livh_base like '$client' order by livh_date_facture";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	$total_reg=0;
	$total_cor=0;
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
		$local=&get("select fo2_identification from corsica.fournis where fo2_cd_fo='$livh_four'");
		if (($local)&&($livh_base eq "corsica")){next;}
	
		$fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
		if (&get("select year(adddate('$livh_date_facture',$fo_delai))")+0<2016){next;};
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		($reglement,$date_reglement)=&get("select sum(montant),date from dfc.reglement where reg_id='$livh_id'");
		$reglement+=0;
		# if ($reglement==$montant){next;}
		&save("insert into cde_tmp values ('$livh_base','$livh_four','$livh_id','$livh_facture','$livh_date_facture',adddate('$livh_date_facture','$fo_delai'),'$montant','$fo_delai','$reglement','$date_reglement')","af");
	}
	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des factures</h3>";
	print "	</div>";
	if ($message ne ""){
		print "<div class=\"alert alert-danger\">";
		print "<h3>$message</h3>";
		print "	</div>";
	}
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Base</th>";
	print "<th>Fournisseur</th>";
	print "<th>Delai paiement</th>";
	print "<th>Bon de livraison</th>";
	print "<th>Facture</th>";
	print "<th>Date Echeance</th>";
	print "<th>Date Facture</th>";
	print "<th>Montant</th>";
	if ($client eq "corsica"){
			print "<th>montant refacturation</td>";
	}

	print "<th>Reglement</th>";
	print "<th>Date Reglement</th>";
	print "<th>Livrée</th>";
	print "</tr>";
	print "</thead>";
	$query="select year(date_echance) as an,month(date_echance) as mois,cde_tmp.* from cde_tmp order by year(date_echance),month(date_echance),base desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=$total_reg=$total_cor=$total_int=$total_int_reg=$total_int_cor=$total_sous_int=$total_sous_int_reg=$total_sous_int_cor=0;
	while (($an,$mois,$livh_base,$livh_four,$livh_id,$livh_facture,$date_facture,$date_echeance,$montant,$delai,$reglement,$date_reglement)=$sth->fetchrow_array){
		if ($livh_base ne $base_run){
			if ($total_sous_int >0){
				print "<tr style=font-weight:bold><td colspan=7 align=right>$base_run";
				print "</td><td align=right><strong>$total_sous_int</strong></td>";
				if ($client eq "corsica"){print "<td align=right>$total_sous_int_cor</td>";}
				print "<td align=right><strong>$total_sous_int_reg</strong></td></tr>";
				$total_sous_int=0;
				$total_sous_int_reg=0;
				$total_sous_int_cor=0;
			}
			$base_run=$livh_base;
		}
		if ($mois ne $mois_run){
			if ($total_int >0){
				print "<tr style=font-weight:bold class=success><td colspan=7>Total Mois ";
				print &cal($mois_run,"l");
				print "</td><td align=right>$total_int</td>";
				if ($client eq "corsica"){print "<td align=right>$total_int_cor</td>";}
				print "<td align=right>$total_int_reg</td></tr>";
				$total_int=0;
				$total_int_reg=0;
				$total_int_cor=0;
			}
			$mois_run=$mois;
		}
		
		$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$date_entree=&get("select enh_date from $livh_base.enthead where enh_document='$livh_id'")+0; 
		if ($date_entree==0){$date_entree="0000-00-00";}else{$date_entree=&julian($date_entree,"YYYY-MM-DD");}

		print "<tr><td>$livh_base</td><td>$fo_nom</td>";
		print "<td>$delai</td>";
		print "<td>$livh_id</td><td>$livh_facture</td><td class=warning>$date_echeance</td><td>$date_facture</td><td align=right>$montant</td>";
		if ($client eq "corsica"){
			$montant_corse=&get("select total_tva from facture_corse where bl=$livh_id")+0;
			print "<td align=right>$montant_corse</td>";
			$total_corse+=$montant_corse;
		}
		print "<td align=right>$reglement</td>";
		print "<td >$date_reglement</td>";
			print "<td align=center>";
		if ($date_entree ne "0000-00-00"){
			print "<img src=http://dfc.oasix.fr/images/check.png>";
		}
		else {
			print "<img src=http://dfc.oasix.fr/images/checkr.png>";
		}	
		print "</td></tr>";
		$total+=$montant;
		$total_reg+=$reglement;
		$total_cor+=$montant_corse;
		
		$total_int+=$montant;
		$total_int_reg+=$reglement;
		$total_int_cor+=$montant_corse;
		
		$total_sous_int+=$montant;
		$total_sous_int_reg+=$reglement;
		$total_sous_int_cor+=$montant_corse;
		
	}
	
	if ($total_int >0){
		print "<tr style=font-weight:bold><td colspan=7 align=right>$base_run</td><td align=right><strong>$total_sous_int</strong></td>";
		if ($client eq "corsica"){print "<td align=right>$total_sous_int_cor</td>";}
		print "<td align=right><strong>$total_sous_int_reg</strong></td></tr>";
		print "<tr style=font-weight:bold class=success><td colspan=7>Total mois ";
		print &cal($mois_run,"l");
		print "</td><td align=right>$total_int</td>";
		if ($client eq "corsica"){print "<td align=right>$total_int_cor</td>";}
		print "<td align=right>$total_int_reg</td></tr>";
		$total_int=0;
		$total_int_reg=0;
		$total_int_cor=0;
	}
	
	print "<tr style=\"font-weight:bold\" class=danger><td colspan=7>Total</td><td align=right>$total</td>";
	if ($client eq "corsica"){print "<td align=right>$total_cor</td>";}
	print "<td align=right>$total_reg</td></tr>";
	print "</table>";
}
print "		
		</div>
	</div>
</div>";
