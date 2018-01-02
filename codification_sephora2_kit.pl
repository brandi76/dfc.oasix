$marque=$html->param("marque");
$marque_seph=$html->param("marque_seph");
$pr_cd_pr=$html->param("pr_cd_pr");
$ref=$html->param("ref");
$cle_perso=$html->param("cle_perso");

print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
print "<form>";
&form_hidden();
print "<button type=\"submit\" class=\"btn btn-info\">Retour</button>";
print "</form>";
		
if (($marque eq "")&&($pr_cd_pr ne "")){
	$marque=&get("select marque from cameshop.produit_desi where code='$pr_cd_pr'");
}	
if ($action eq "maj_marque_seph"){
	&save ("update dfc.sephora set marque_dfc='$marque' where marque='$marque_seph'","af");
	$action="marque";
}	


if ($action eq "maj_marque_seph"){
	&save ("update dfc.sephora set marque_dfc='$marque' where marque='$marque_seph'","af");
	$action="marque";
}	
if ($action eq "match"){
	&save("update cameshop.produit set pr_acquit='$ref' where pr_cd_pr=$pr_cd_pr","af");
	$action="marque";
}	

if ($action eq "marque"){
	$query="select cameshop.produit.pr_cd_pr,pr_desi from cameshop.produit,cameshop.produit_desi,cameshop.produit_plus where code=produit.pr_cd_pr and marque='$marque' and (pr_sup=0 or pr_sup=3) and pr_acquit=0 and produit.pr_cd_pr=produit_plus.pr_cd_pr and (pr_famille=1 or pr_famille=3) limit 1";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($pr_cd_pr,$pr_desi) = $sth->fetchrow_array) {
		$trouve=1;
		print "<h3>$marque</h3>";
		(@tab)=split(/ /,$pr_desi);
		print "<h4><a style=color:black href=https://www.google.fr/search?q=$pr_cd_pr target=_blank>$pr_cd_pr</a> ";
		foreach (@tab){
			print "<a style=color:black href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=marque&pr_cd_pr=$pr_cd_pr&cle_perso=$_>$_</a> ";	
		}
		print "</h4>";
		print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=match&pr_cd_pr=$pr_cd_pr&ref=1>Passer</a><br>";	
		$desi=$pr_desi;
		$desi=~s/$marque//;
		($null,$cle)=split(/ /,$desi);
		$cle2="";
		if (grep /EDP/,$pr_desi){$cle2="Eau de Parfum";}
		if (grep /EDT/,$pr_desi){$cle2="Eau de Toilette";}
		# print "*$cle*$cle2*";
		if ($cle_perso ne ""){$cle=$cle_perso;}
		$query="select code,libelle,lien from dfc.sephora where marque_dfc=\"$marque\" and libelle like '%$cle%'";
		# print $query;
		$sth2 = $dbh->prepare($query);
		$sth2->execute;
		$pass=0;
		while (($code,$libelle,$lien) = $sth2->fetchrow_array) {
		    
			if ($pass==0){
				print "<span style=color:navy>Liste Sephora qui contient le mot $cle et $cle2</span><br>";
				$pass=1;
			}	
			$query="select desi,ref from sephora_ref where code='$code' and desi like '%$cle2%'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			$pass2=0;
			while (($desi,$ref)=$sth3->fetchrow_array){
				if ($pass2==0){
					print "<br><span style=font-weight:bold>$libelle</span> <a href=http://www.sephora.fr$lien>Lien Sephora</a><br>";
					$pass2=1;
				}
				print "$desi"; 
				print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=match&pr_cd_pr=$pr_cd_pr&ref=$ref>match</a>";	
				
				print "<br>";
			}
		}	
		if ($pass==0){print "Aucun produit trouvé<br>";}
		
		print "<br><div style='border:1px solid red;width:100%'> </div><br><span style=color:navy>Liste complete</span><br>";
		# if ($pass==0){
			$query="select code,libelle,lien from dfc.sephora where marque_dfc=\"$marque\"";
			$sth2 = $dbh->prepare($query);
			$sth2->execute;
			$pass=0;
			while (($code,$libelle,$lien) = $sth2->fetchrow_array) {
				if ($pass==0){
					print "Choisir un produit sephora<br>";
					$pass=1;
				}	
				print "<br><span style=font-weight:bold>$libelle</span> <a href=http://www.sephora.fr$lien>Lien Sephora</a><br>";
				$query="select desi,ref from sephora_ref where code='$code'";
				$sth3=$dbh->prepare($query);
				$sth3->execute();
				while (($desi,$ref)=$sth3->fetchrow_array){
					print "$desi";
					print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=match&pr_cd_pr=$pr_cd_pr&ref=$ref>match</a>";	
					print "<br>";
				}
			}	
		# }	
		if ($pass==0) {
			print "Choisir parmis les marques sephora<br>";
			$query="select distinct marque from dfc.sephora order by marque";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			print "<form>";
			&form_hidden();
			print "<select name=marque_seph>";
			while (($marque_seph)=$sth2->fetchrow_array){
				print "<option value='$marque_seph'>$marque_seph</option>";
			}
			print "</select>";
			print "<input type=hidden name=action value=maj_marque_seph>";
			print "<input type=hidden name=marque value='$marque'>";
			print "<br><button type=\"submit\" class=\"btn btn-info\">Submit</button>";
			print "</form>";
		}
	}
	if ($trouve!=1){$action="";}
}
if ($action eq ""){
	print "<div class=\"alert alert-info\">Codification des codes Sephora</div>";
	print "<form>";
	print "<h5>Marque</h5>";
	&form_hidden();
	$query="select distinct marque from cameshop.produit_desi where code in (select es_cd_pr from cameshop.enso)  order by marque";
	$pass=0;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<select name=marque>";
	while (($marque)=$sth->fetchrow_array){
		if ($marque eq ""){next;}
		$nb=&get("select count(*) from cameshop.produit,cameshop.produit_desi,cameshop.produit_plus where code=produit.pr_cd_pr and marque='$marque' and (pr_sup=0 or pr_sup=3) and pr_acquit=0 and produit.pr_cd_pr=produit_plus.pr_cd_pr and (pr_famille=1 or pr_famille=3)");
		if ($nb==0){next;}
		print "<option value='$marque'>$marque ($nb)</option>";
	}
	print "</select>";
	print "<input type=hidden name=action value=marque>";
	print "<br><br><button type=\"submit\" class=\"btn btn-info\">Submit</button>";
	print "</form>";
}	
print "		
		</div>
	</div>
</div>";
