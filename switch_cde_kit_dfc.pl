$cde1=$html->param("cde1");
$base1=$html->param("base1");
$base2=$html->param("base2");
print "Bascule d'une commande <br>";
print "<form>";
&form_hidden();
print "No <input name=cde1><br>";
print "<select name=base1>";
foreach $base (@bases_client){
	next if ($base eq "dfc");
	print "<option value=$base>$base</option>";
}
print "</select>";
print "Vers<br>";
print "<select name=base2>";
push(@bases_client,"cameshop");
foreach $base (@bases_client){
	next if ($base eq "dfc");
	print "<option value=$base>$base</option>";
}
print "</select>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";

if ($action eq "go"){
	$today=&get("select curdate()");
	$ok=1;
	$check=&get("select count(*) from $base1.commande where com2_no='$cde1'")+0;
	if ($check==0){
		print "<p style=background:pink> $cde1 inconnue</p>";
		$ok=0;
	}
	if ($ok){
		$query="select dt_no from $base2.atadsql where dt_cd_dt=205";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($nocde)=$sth->fetchrow_array;
		$nocde+=1;
		&save("update $base2.atadsql set dt_no=$nocde where dt_cd_dt=205","aff");
		&save("insert ignore into $base2.commande_info select $nocde,date,user,etat,blabla,poids,volume,relance,accuse from $base1.commande_info where com_no=$cde1","aff");
		&save("insert ignore into $base2.commande select $nocde,com2_cd_fo,com2_cd_pr,com2_qte,com2_prac,com2_type,com2_date,com2_no_liv,com2_liv,com2_designation from $base1.commande where com2_no=$cde1","aff");
		print "<p style=background:lightgreen>$base1 $cde1 basculée vers $base2 $nocde (commande non supprimée)</p>";
	}
}
;1