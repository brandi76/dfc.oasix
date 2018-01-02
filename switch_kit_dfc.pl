$produit1=$html->param("produit1");
$produit2=$html->param("produit2");
$base1=$html->param("base1");
$base2=$html->param("base2");
$qte=$html->param("qte");
$qte*=100;
print "Bascule d'un produit <br>";
print "<form>";
&form_hidden();
print "Qte <input name=qte><br>";
print "<select name=base1>";
foreach $base (@bases_client){
	next if ($base eq "dfc");
	print "<option value=$base>$base</option>";
}
print "</select>";
print "Produit <input name=produit1><br>";
print "Vers<br>";
print "<select name=base2>";
foreach $base (@bases_client){
	next if ($base eq "dfc");
	print "<option value=$base>$base</option>";
}
print "</select>";
print "Produit <input name=produit2><br>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";

if ($action eq "go"){
	$today=&get("select curdate()");
	$ok=1;
	$pr_desi1=&get("select pr_desi from $base1.produit where pr_cd_pr='$produit1'");
	if ($pr_desi1 eq ""){
		print "<p style=background:pink> $produit1 produit inconnu</p>";
		$ok=0;
	}
	$pr_desi2=&get("select pr_desi from $base2.produit where pr_cd_pr='$produit2'");
	if ($pr_desi2 eq ""){
		print "<p style=background:pink> $produit2 produit inconnu</p>";
		$ok=0;
	}
	$check=&get("select count(*) from $base1.enso where es_cd_pr='$produit1' and es_type=24 and es_dt='$today'")+0;
    if ($check){
		print "<p style=background:pink>$base1 $produit1 $pr_desi1 deja present dans les mouvements d'aujourd'hui</p>";
		$ok=0;
	}
	$check=&get("select count(*) from $base2.enso where es_cd_pr='$produit2' and es_type=24 and es_dt='$today'")+0;
    if ($check){
		print "<p style=background:pink>$base2 $produit2 $pr_desi2 deja present dans les mouvements d'aujourd'hui</p>";
		$ok=0;
	}
	if ($ok){
		&save("update $base1.produit set pr_stre=pr_stre-$qte where pr_cd_pr='$produit1'");
		&save("update $base2.produit set pr_stre=pr_stre+$qte where pr_cd_pr='$produit2'");
		&save("insert into $base1.enso values ($produit1,'','$today','$qte','0','24')");	
		&save("insert into $base2.enso values ($produit2,'','$today','0','$qte','24')");	
		$qte/=100;
		print "<p style=background:lightgreen>$base1 $produit1 $pr_desi1 $qte basculé vers $base2 $produit2 $pr_desi2 $qte</p>";
	}
}
;1