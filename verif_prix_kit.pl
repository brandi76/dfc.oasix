print "<title>Verification des prix</title>";


if ($action eq ""){
	print "<form> Trolley type <input type=texte name=trolley><br>";
	require ("form_hidden.src");

	print "Fichier excel , faire copier coller (code produit, designation, prix)<br>";
	print "<textarea name=texte cols=\"300\" rows=\"30\"></textarea>";
	
	print "<input type=hidden name=action value=go ><input type=submit ></form>";
}

if ($action eq "go") {
	$texte=$html->param("texte");
	$trolley=$html->param("trolley");
	
	(@ligne)=split(/\n/,$texte);

	print "<table><tr><td>";
	foreach $ligne (@ligne){
		chop($ligne);
		($produit_ex,$desi_ex,$prix_ex)=split(/\t/,$ligne);
		$prix=&get("select tr_prix/100 from trolley where tr_code='$trolley' and tr_cd_pr='$produit_ex'","af");
		push(@liste,$produit_ex);
		if ($prix eq ""){
				print "$produit_ex $desi_ex non trouve dans le trolley:$trolley<br>";
		}
		else
		{
			if ($prix_ex ne int($prix)){
				print "$produit_ex $desi_ex $prix_ex prix different avec le trolley:$trolley dont le prix est:$prix<br>";
			}
			else
			{
				print "$produit_ex $desi_ex ok<br>";
			}
		}
	}
	$query="select tr_cd_pr,tr_prix/100 from trolley where tr_code='$trolley' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tr_cd_pr,$tr_prix)=$sth->fetchrow_array){
		if (! grep/$tr_cd_pr/,@liste){
			$tr_prix=int($tr_prix);
			$desi=&get("select pr_desi from produit where pr_cd_pr='$tr_cd_pr'");
			print "$tr_cd_pr $desi int($tr_prix) dans le trolley:$trolley mais pas dans le fichier excel<br>";
		}
	}
}
;1
