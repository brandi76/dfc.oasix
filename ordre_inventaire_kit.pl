require "./src/connect.src";

$four=$html->param("four");
$action=$html->param("action");
$auto=$html->param("auto");
$pr_cd_pr=$html->param("pr_cd_pr");
$no=$html->param("no");
if ($pr_cd_pr eq ""){$pr_cd_pr="pr_cd_pr";}
if ($no eq ""){$no="enh_no";}
if ($four eq ""){$four="pr_four";}
print "<center>";
if ($action eq ""){
	print "<div class=titre>Rangement des produits</div><br>";
	print "<form>";
	require ("form_hidden.src");
        print "<br>Fournisseur<br><select name=four><option value=''></option>";
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis group by fo2_add");
	$sth2->execute;
	while (my @four = $sth2->fetchrow_array) {
		next if $four eq $four[0];
		($four[1])=split(/\*/,$four[1]);
		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
	}
	
	print "</select>";
	print "<br><input type=hidden name=action value=go><input type=submit value='envoyer'></form><br><br>"; 
}

if ($action eq "modif") {
	if ($auto eq "on"){
		$query="select pr_cd_pr,pr_cd_pr%10000 as modulo from produit where (pr_type=1 or pr_type=5) and pr_four=$four  and pr_desi not like 'testeur%'  and pr_cd_pr>10000000 order by modulo";
		if ($four==2070){
			$query="select pr_cd_pr,pr_cd_pr%100000 as modulo from produit where (pr_type=1 or pr_type=5) and pr_four=$four  and pr_desi not like 'testeur%'  and pr_cd_pr>10000000 order by modulo";
		}		
		$sth=$dbh->prepare($query);
		$sth->execute;
		$class=10;
		while (($pr_cd_pr)=$sth->fetchrow_array){
			&save("update produit set pr_emb=$class where pr_cd_pr=$pr_cd_pr");
			$class+=10;
		}
	}
	else
	{
		$query="select pr_emb,pr_cd_pr,pr_cd_pr%10000 as modulo from produit where (pr_type=1 or pr_type=5) and pr_four=$four  and pr_desi not like 'testeur%' and pr_cd_pr>10000000 order by modulo";
		
		# print "$query<br>";
		$sth=$dbh->prepare($query);
		$sth->execute;
		while (($pr_emb,$pr_cd_pr)=$sth->fetchrow_array){
			if ($html->param($pr_cd_pr)!=$pr_emb){
				$emb=$html->param($pr_cd_pr);
				&save("update produit set pr_emb=$emb where pr_cd_pr=$pr_cd_pr");
			}
		}
	}
	$action="go";
}


if ($action eq "go") {
	print "<div class=titre> $four </div><br>";
	$query="select pr_emb,pr_cd_pr,pr_desi,pr_cd_pr%10000 as modulo from produit where (pr_type=1 or pr_type=5) and pr_four=$four and pr_desi not like 'testeur%' and pr_cd_pr>10000000 order by modulo";
	if ($four==2070){
		$query="select pr_emb,pr_cd_pr,pr_desi,pr_cd_pr%100000 as modulo from produit where (pr_type=1 or pr_type=5) and pr_four=$four and pr_desi not like 'testeur%' and pr_cd_pr>10000000 order by modulo";

	}		
		
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<form>";
	require ("form_hidden2.src");
	print "<table border=1 cellspacing=0>";
	print "<tr><th>ordre</th><th>produit</th></th>&nbsp;</th></tr>";
	while (($ordre,$pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$digit_f=$pr_cd_pr%10000+10000;
		$digit_f=substr($digit_f,1,4);
		$digit_p=int($pr_cd_pr/10000);
		$single="";
		if ($four==2070){
			$digit_f=$pr_cd_pr%100000+100000;
			$digit_f=substr($digit_f,1,5);
			$digit_p=int($pr_cd_pr/100000);
		}

	
		print "<tr><td><input type=text name=$pr_cd_pr value=$ordre size=3></td><td>$digit_p <font size=+2><b>$digit_f</b></td><td>$pr_desi</td></tr>";
	}
	print "</table>";
	print "<input type=hidden name=four value=$four>";
	print "<input type=hidden name=action value=modif><input type=submit value=modifier> <input type=checkbox name=auto></form>";
}
;1	
