print "<title>Verification des code douanes</title>";


if ($action eq ""){
	print "<form> Trolley type <input type=texte name=trolley><br>";
	require ("form_hidden.src");
	print "<input type=hidden name=action value=go ><input type=submit ></form>";
}

print "<style>";
print "#brandi tr:nth-child(even){background:lavender;}";
print "</style>";
if ($action eq "go") {
	$trolley=$html->param("trolley");
	print "<table id=brandi><th>Produit</th><th>Code douane</th><th>Libellé</th></tr>";	
	$query="select tr_cd_pr,pr_douane,pr_desi from trolley,produit where tr_code='$trolley' and tr_cd_pr=pr_cd_pr order by tr_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tr_cd_pr,$pr_douane,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$tr_cd_pr $pr_desi</td><td>$pr_douane</td><td style=font-size:0.8em>";
		$chap_desi=&get("select chap_desi from dfc.chapitre where chap_douane='$pr_douane'","af");
		if ($chap_desi eq "") {$chap_desi="<span style=background:pink>Code douane inconnu</span>";}
		print "$chap_desi</td></tr>";  
	}
	print "</table>";
}
;1
