$pr_cd_pr=$html->param("pr_cd_pr");

if ($action eq "sav"){
	$query="select pr_desi from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_desi)=$sth->fetchrow_array;
	print "$pr_cd_pr $pr_desi<br>";
	$stock=$html->param("$pr_cd_pr");
	&save("replace into sac_inv values ('$pr_cd_pr',curdate(),'$stock')");
	print "<span style=font-size:0.8em></span> $stock<br>";
	print "<p style=background:lightgreen>Stock sauvegarde</p>";
	$action="";
}

print "<form>";
&form_hidden();
if ($action eq ""){
	$query="select pr_cd_pr,pr_desi from produit where pr_cd_pr>=700000 and pr_cd_pr <800000";
 	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<select name=pr_cd_pr>";
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<option value=$pr_cd_pr>$pr_cd_pr $pr_desi</option>";
	}
	print "</select>";
	print "<input type=hidden name=action value=go>";

	print "<input type=submit></form>";
}

if ($action eq "go"){
	$query="select pr_desi from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_desi)=$sth->fetchrow_array;
	print "$pr_cd_pr $pr_desi<br>";
	$date=&get("select max(date) from sac_inv where pr_cd_pr='$pr_cd_pr'");
	$stock=&get("select qte from sac_inv where pr_cd_pr='$pr_cd_pr' order by date desc limit 1")+0;
	print "Derniere saisie:$date:$stock<br>";
	print "<span style=font-size:0.8em>$_</span> <input type=text name='$pr_cd_pr' value='$stock' size=3><br>";
	print "<input type=hidden name=action value=sav>";
	print "<input type=hidden name=pr_cd_pr value='$pr_cd_pr'>";
	print "<input type=submit></form>";
}

;1