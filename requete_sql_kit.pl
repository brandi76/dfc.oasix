$choix=$html->param("choix");
print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
if ($choix eq ""){
print "<form>";
&form_hidden();
print "<ul>";
print "<li> Liste des marques pour les cosmetiques de corsica <input type=radio name=choix value=1></li>";
print "<li> Liste des codes douanes pour les vins de camshop <input type=radio name=choix value=2></li>";
print "<li> Commande dfa pour cameshop <input type=radio name=choix value=3></li>";

print "<button type=\"submit\" class=\"btn btn-info\">Go</button>";
print "</form>";
}
else{
	if ($choix==1){	
		print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
		print "<thead>";
		print "<tr class=\"success\"><th>Marque</th></tr>";
		print "</thead>";
		$query="select distinct marque from corsica.produit_desi,corsica.produit_plus where code=pr_cd_pr and pr_famille=5";
		$sth = $dbh->prepare($query);
		$sth->execute;
		while(($marque) = $sth->fetchrow_array){
			print "<tr><td>$marque</td></tr>";
		}
		print "</table>";
	}	
	if ($choix==2){	
		print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
		print "<thead>";
		print "<tr class=\"success\"><th>Vin</th></tr>";
		print "</thead>";
		$query="select distinct pr_douane from cameshop.produit,cameshop.produit_plus where produit.pr_cd_pr=produit_plus.pr_cd_pr and pr_famille=20";
		$sth = $dbh->prepare($query);
		$sth->execute;
		while(($pr_douane) = $sth->fetchrow_array){
			print "<tr><td>$pr_douane</td></tr>";
		}
		print "</table>";
		print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
		print "<thead>";
		print "<tr class=\"success\"><th>Champagne</th></tr>";
		print "</thead>";
		$query="select distinct pr_douane from cameshop.produit,cameshop.produit_plus where produit.pr_cd_pr=produit_plus.pr_cd_pr and pr_famille=24";
		$sth = $dbh->prepare($query);
		$sth->execute;
		while(($pr_douane) = $sth->fetchrow_array){
			print "<tr><td>$pr_douane</td></tr>";
		}
		print "</table>";
	}
	if ($choix==3){	
		print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
		print "<thead>";
		print "<tr class=\"success\"><th>Vin</th></tr>";
		print "</thead>";
		$query="select produit_id,designation,code_barre,ean from dutyfreeambassade.panier_web,dutyfreeambassade.produit_web,dutyfreeambassade.produit_info where produit_id=produit_web.code and cde_id=133532 and produit_web.code=produit_info.code";
		$sth = $dbh->prepare($query);
		$sth->execute;
		while(($produit_id,$pr_desi,$pr_codebarre,$pr_douane) = $sth->fetchrow_array){
			print "<tr><td>$produit_id</td><td>$pr_desi</td><td>$pr_codebarre</td><td>$pr_douane</td></tr>";
			$query="select pr_cd_pr,pr_desi from cameshop.produit where pr_cd_pr=$pr_codebarre";
			$sth2 = $dbh->prepare($query);
			$sth2->execute;
			($pr_cd_pr,$pr_desi) = $sth2->fetchrow_array;
			print "<tr class=info><td>$pr_cd_pr</td><td>$pr_desi</td><td></td></tr>";
		}
		
		print "</table>";
	}	

}	
print "		
		</div>
	</div>
</div>";
;1
