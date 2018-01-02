$pr_cd_pr=$html->param("pr_cd_pr");
$base=$html->param("base");
$qte=$html->param("qte");
if ($action eq "go"){
	$ok=1;
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
	if ($pr_desi eq ""){
		print "<p style=background:pink>Produit inconnu </p>";
		$ok=0;
		$action="";
	}
	$qte+=0;
	if (($qte>1000)||($qte<1)){
		print "<p style=background:pink>Qte invalide </p>";
		$ok=0;
		$action="";
	}	
	$check=&get("select count(*) from enso where es_cd_pr=$pr_cd_pr and es_dt=curdate() and es_type=24")+0;
	if ($check){
		print "<p style=background:pink>Un mouvment a déjà été enregistré pour aujourd'hui action refusée</p>";
		$ok=0;
		$action="";
	}
	if ($ok){
		print "$pr_cd_pr $pr_desi Qte:$qte<br>";
		print "<form> Choisir la destination";
		&form_hidden();
		print "<select name=base>";
		print "<option value=togo>Togo</option>";
		print "<option value=aircotedivoire>Cote d ivoire</option>";
		print "<option value=camairco>Cameroun</option>";
		print "</select>";
		print "<input type=hidden name=action value=mouve>";
		print "<input type=hidden name=pr_cd_pr value='$pr_cd_pr'>";
		print "<input type=hidden name=qte value='$qte'>";
		print "<input type=submit>";
		print "</form>";
	}
}

if ($action eq "mouve"){
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
	$qte*=100;
	$today=&get("select curdate()");
	$ok=1;
	$check=&get("select count(*) from $base.enso where es_cd_pr='$pr_cd_pr' and es_type=24 and es_dt='$today'")+0;
    if ($check){
		print "<p style=background:pink>$base $pr_cd_pr deja present dans les mouvements d'aujourd'hui</p>";
		$ok=0;
	}
	if ($ok){
		&save("update produit set pr_stre=pr_stre-$qte where pr_cd_pr='$pr_cd_pr'");
		&save("update $base.produit set pr_stre=pr_stre+$qte where pr_cd_pr='$pr_cd_pr'");
		&save("insert into enso values ($pr_cd_pr,'','$today','$qte','0','24')");	
		&save("insert into $base.enso values ($pr_cd_pr,'','$today','0','$qte','24')");	
		$qte/=100;
		print "<p style=background:lightgreen>$pr_cd_pr $pr_desi $qte basculé vers $base</p>";
	}
	$action="";
}
if ($action eq ""){
	print "Bascule d'un produit Vers une autre base<br>";
	print "<form>";
	&form_hidden();
	print "Code produit <input name=pr_cd_pr><br>";
	print "Qte <input name=qte size=3><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit>";
	print "</form>";
}

;1