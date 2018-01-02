$dbh_cam = DBI->connect("DBI:mysql:host=195.114.27.208:database=togo;","web","admin",{'RaiseError' => 1});
$dbh_aci = DBI->connect("DBI:mysql:host=195.114.27.208:database=aircotedivoire;","web","admin",{'RaiseError' => 1});

$base1="togo";
$base2="aci";
$action=$html->param("action");
if ($action eq ""){
	print "<div class=titre>Syncronisation de la base de donnée produit</div><br>";
	print "<form>";
	require ("form_hidden.src");
        print "<br><input type=hidden name=action value=go><input type=submit value='Recherche'></form>"; 
}
if ($action eq "go"){
	$query="select pr_cd_pr,pr_desi from produit order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$query="select pr_cd_pr from produit where pr_cd_pr=$pr_cd_pr ";
		$sth_cam=$dbh_cam->prepare($query);
		$nb=$sth_cam->execute()+0;
		if ($nb != 1) {
			print "vers $base1 -->$pr_cd_pr $pr_desi<br />";
		}
		$query="select pr_cd_pr from produit where pr_cd_pr=$pr_cd_pr ";
		$sth_aci=$dbh_aci->prepare($query);
		$nb=$sth_aci->execute()+0;
		if ($nb != 1) {
			print "vers $base2 -->$pr_cd_pr  $pr_desi<br />";
		}

	}
	print "<form>";
	require ("form_hidden.src");
        print "<br><input type=hidden name=action value=go2><input type=submit value='Valider'></form>"; 
}
if ($action eq "go2"){
	$query="select * from produit order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@tab)=$sth->fetchrow_array){
		$pr_cd_pr=$tab[0];
		$query="select pr_cd_pr from produit where pr_cd_pr=$pr_cd_pr ";
		$sth_cam=$dbh_cam->prepare($query);
		$nb=$sth_cam->execute()+0;
		if ($nb != 1) {
			$query = "INSERT ignore INTO `produit` (`pr_cd_pr`, `pr_desi`, `pr_casse`, `pr_prx_rev`, `pr_stre`, `pr_douane`, `pr_ventil`, `pr_stanc`, `pr_type`, `pr_prx_vte`, `pr_stvol`, `pr_sup`, `pr_emb`, `pr_prac`, `pr_deg`, `pr_pdn`, `pr_diff`, `pr_acquit`, `pr_orig`, `pr_pdb`, `pr_qte_comp`, `pr_cond`, `pr_devac`, `pr_four`, `pr_refour`, `pr_codebarre`) VALUES (";
			foreach (@tab){
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
# 			print "$query<br />";
			$sth_cam=$dbh_cam->prepare($query);
			$sth_cam->execute();
			$query="update produit set pr_stanc=0,pr_stvol=0,pr_casse=0,pr_stre=0,pr_diff=0 where pr_cd_pr=$pr_cd_pr";
			$sth_cam=$dbh_cam->prepare($query);
			$sth_cam->execute();
			$query="select * from carton where car_cd_pr='$pr_cd_pr'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($car_cd_pr,$car_carton,$car_pal)=$sth2->fetchrow_array;
			$query="replace into carton value ('$pr_cd_pr','$car_carton','$car_pal')";
			$sth_cam=$dbh_cam->prepare($query);
			$sth_cam->execute();
			$query="select * from produit_plus where pr_cd_pr='$pr_cd_pr'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($null,$pr_date_creation,$pr_date_modification,$pr_nom,$pr_newflag,$pr_saison,$pr_impose,$pr_remplace,$pr_date_deb,$pr_date_fin,$pr_fragrance,$pr_vapo,$pr_remise_com,$pr_famille)=$sth2->fetchrow_array;
			$query="replace into produit_plus values('$pr_cd_pr','$pr_date_creation',now(),'$pr_nom','$pr_newflag','$pr_saison','$pr_impose','$pr_remplace','$pr_date_deb','$pr_date_fin','$pr_fragrance','$pr_vapo','$pr_remise_com','$pr_famille')";
			$sth_cam=$dbh_cam->prepare($query);
			$sth_cam->execute();
			print "vers $base1 -->$pr_cd_pr $pr_desi effectué<br />";
		}
		$query="select pr_cd_pr from produit where pr_cd_pr=$pr_cd_pr ";
		$sth_aci=$dbh_aci->prepare($query);
		$nb=$sth_aci->execute()+0;
		if ($nb != 1) {
			$query = "INSERT ignore INTO `produit` (`pr_cd_pr`, `pr_desi`, `pr_casse`, `pr_prx_rev`, `pr_stre`, `pr_douane`, `pr_ventil`, `pr_stanc`, `pr_type`, `pr_prx_vte`, `pr_stvol`, `pr_sup`, `pr_emb`, `pr_prac`, `pr_deg`, `pr_pdn`, `pr_diff`, `pr_acquit`, `pr_orig`, `pr_pdb`, `pr_qte_comp`, `pr_cond`, `pr_devac`, `pr_four`, `pr_refour`, `pr_codebarre`) VALUES (";
			foreach (@tab){
				$query.="'".$_."',";
			}
			chop($query);
			$query.=")";
# 			print "$query<br />";
			$sth_aci=$dbh_aci->prepare($query);
			$sth_aci->execute();
			$query="update produit set pr_stanc=0,pr_stvol=0,pr_casse=0,pr_stre=0,pr_diff=0 where pr_cd_pr=$pr_cd_pr";
			$sth_aci=$dbh_aci->prepare($query);
			$sth_aci->execute();
			$query="select * from carton where car_cd_pr='$pr_cd_pr'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($car_cd_pr,$car_carton,$car_pal)=$sth2->fetchrow_array;
			$query="replace into carton value ('$pr_cd_pr','$car_carton','$car_pal')";
			$sth_aci=$dbh_aci->prepare($query);
			$sth_aci->execute();
			$query="select * from produit_plus where pr_cd_pr='$pr_cd_pr'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($null,$pr_date_creation,$pr_date_modification,$pr_nom,$pr_newflag,$pr_saison,$pr_impose,$pr_remplace,$pr_date_deb,$pr_date_fin,$pr_fragrance,$pr_vapo,$pr_remise_com,$pr_famille)=$sth2->fetchrow_array;
			$query="replace into produit_plus values('$pr_cd_pr','$pr_date_creation',now(),'$pr_nom','$pr_newflag','$pr_saison','$pr_impose','$pr_remplace','$pr_date_deb','$pr_date_fin','$pr_fragrance','$pr_vapo','$pr_remise_com','$pr_famille')";
			$sth_aci=$dbh_aci->prepare($query);
			$sth_aci->execute();
			print "vers $base2 -->$pr_cd_pr $pr_desi effectué<br />";

		}
	}
}

;1	
