print "<title>Gestion de trolley</title>";

require "./src/connect.src";
$lot=$html->param("lot");

print "<head>
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";

print "<center>";
if ($lot eq ""){
	print "<h2>Fiche trolley</h2><br>";
	$query="select lot_nolot,lot_desi from lot where lot_flag=1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form>";
	require ("form_hidden.src");
	print "<select name=lot>";
	while (($lot_nolot,$lot_desi)=$sth->fetchrow_array)
	{
		print "<option value=$lot_nolot>$lot_nolot $lot_desi</option>";	
	}
	print "</select><br><input type=submit></form>";
}
else
{
	$query="select lot_desi,lot_conteneur from lot where lot_nolot=$lot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($lot_desi,$lot_conteneur)=$sth->fetchrow_array;
	print "<h2>$lot $lot_desi $lot_conteneur</h2>";
	
	print "<table border=1 cellspacing=0 cellpadding=0><tr><th>Code</th><th>Designation</th><th>Qte</th><th>Prix</th><th>Famille</th></tr>";
	$query="select tr_tiroir,tr_cd_pr,pr_desi,tr_qte/100,tr_prix/100 from trolley,produit where tr_code=$lot and tr_cd_pr=pr_cd_pr and tr_qte>0  order by tr_tiroir,tr_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tr_tiroir,$tr_cd_pr,$pr_desi,$qte,$prix)=$sth->fetchrow_array){
		
		$exist=&get("select count(*) from produit_plus  where pr_cd_pr='$tr_cd_pr'")+0;
		if ($exist <=0){
			&save("INSERT INTO produit_plus VALUES ('$tr_cd_pr', NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL ,NULL ,'0','') ");		
		}
		$ste+=0;
		if ($tr_tiroir!=$tiroir){&saut;}
		$qte+=0;
		$prix+=0;
		$famille=&get("select fa_desi from famille,produit_plus  where fa_id=pr_famille and pr_cd_pr='$tr_cd_pr'");
		
		print "<tr><td>$tr_cd_pr</td><td>$pr_desi</td><td>$qte</td><td>$prix</td><td>$famille</td></tr>" ;
		$total+=$qte;
	}
	if ($total!=0){
		print "<tr><th colspan=3>total:$total</th></tr>";
	}
	print "</table>";
}
print "</center>";
sub saut{
	if ($total!=0){
		print "<tr><th colspan=2>Total</th><th>$total</th></tr>";
 		$total=0;
 		if ($tr_tiroir==6){
 			print "</table>";
 			print "<div id=saut>.</div>";
			print "<h2>$lot $lot_desi $lot_conteneur</h2>";
			print "<table border=1 cellspacing=0 cellpadding=0><tr><th>Code</th><th>Designation</th><th>Qte</th><th>Prix</th><th>Famille</th></tr>";
	
			}

 	}

	print "<tr><th colspan=3>TIROIR No: $tr_tiroir</th></tr>";
	$tiroir=$tr_tiroir;
}
;1
