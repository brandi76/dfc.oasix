$query="select produit.pr_cd_pr,pr_desi,pr_stre/100,pr_prac,pr_four,pr_famille from produit,produit_plus where pr_stre>0 and produit.pr_cd_pr=produit_plus.pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1 cellspacing=0><tr><th>Produit</th><th>Four</th><th>Famille</th><th>Stock</th><th>Prix achat</th><th>Vente/jour</th><th>Rotation (Jour)</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_prac,$pr_four,$pr_famille)=$sth->fetchrow_array){
	$pr_stre=int($pr_stre);
	$pr_prac/=100;
	$firstdate=&get("select min(v_date_sql) from rotation,vol where ro_code=v_code and ro_cd_pr='$pr_cd_pr' and v_rot=1 and v_date_sql>'2010-01-01'") ; 
	if ($firstdate ne ""){	
		$nb_jour=&get("select datediff(curdate(),'$firstdate')")+0;
		if ($nb_jour>365){$firstdate=&get("select subdate(curdate(),interval 365 day)");$nb_jour=365;}
		$nb_jour=1 if ($nb_jour==0);
		$vendu=&get("select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and ro_cd_pr='$pr_cd_pr' and v_date_sql>='$firstdate'  and v_rot=1")+0 ; 
		if ($vendu !=0){
			$moyenne=$vendu/$nb_jour;
			$rot=$pr_stre/$moyenne;
			$rot=int($rot*100)/100;
			$moyenne=int($moyenne*100)/100;
			print "<tr><td>$pr_cd_pr $pr_desi</td><td>$pr_four</td><td>$pr_famille</td><td align=right>$pr_stre</td><td align=right>$pr_prac</td><td align=right>$moyenne</td><td align=right>$rot</td></tr>";
			$nb++;
			$total+=$rot;
		}
		else {
				print "<tr><td>$pr_cd_pr $pr_desi</td><td>$pr_four</td><td>$pr_famille</td><td align=right>$pr_stre</td><td align=right>$pr_prac</td><td align=right>0</td><td align=right>9999999</td></tr>";
		}
	}
} 
print "</table>";
$moyenne=int($total/$nb);
print "Rotation moyenne:$moyenne Jours<br>";
;1