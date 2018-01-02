$pr_cd_pr=$html->param("pr_cd_pr");

if ($action eq "sav"){
	$query="select pr_desi,pr_refour from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_desi,$pr_refour)=$sth->fetchrow_array;
	print "$pr_cd_pr $pr_desi<br>";
	(@multicolor)=split(/\*/,$pr_refour);
	$i=1;
	foreach (@multicolor){
		$stock=$html->param("${pr_cd_pr}_${i}");
		&save("replace into multicolor_inv values ('$pr_cd_pr','$_',curdate(),'$stock')");
		print "<span style=font-size:0.8em>$_</span> $stock<br>";
		$i++;
	}
	print "<p style=background:lightgreen>Stock sauvegarde</p>";
	$action="";
}

print "<form>";
&form_hidden();
if ($action eq ""){
	$query="select pr_cd_pr,pr_desi from produit where pr_refour like '%*%'";
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
	$query="select pr_desi,pr_refour from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_desi,$pr_refour)=$sth->fetchrow_array;
	print "$pr_cd_pr $pr_desi<br>";
	$date=&get("select max(date) from multicolor_inv where pr_cd_pr='$pr_cd_pr'");
	print "Derniere saisie:$date<br>";
	(@multicolor)=split(/\*/,$pr_refour);
	$i=1;
	foreach (@multicolor){
		$stock=&get("select qte from multicolor_inv where pr_cd_pr='$pr_cd_pr' and code='$_'")+0;
		print "<span style=font-size:0.8em>$_</span> <input type=text name='${pr_cd_pr}_${i}' value='$stock' size=3><br>";
		$i++;
	}
	print "<input type=hidden name=action value=sav>";
	print "<input type=hidden name=pr_cd_pr value='$pr_cd_pr'>";
	print "<input type=submit></form>";
}

;1