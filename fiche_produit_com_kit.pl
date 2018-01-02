$pr_cd_pr=$html->param("pr_cd_pr");

print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
print "<form>";
&form_hidden();
print "<button type=\"submit\" class=\"btn btn-info\">Retour</button>";
print "</form>";
		

if ($action eq "go"){
	$inode=&get("select inode from produit_inode where code='$pr_cd_pr'");
	$query="select designation1 from produit_master where inode='$inode'";
	$sth = $dbh->prepare($query);
	$sth->execute;
	($designation1) = $sth->fetchrow_array;
	print "$designation1<br>";
	$query="select code,ref,desi from sephora_ref where inode='$inode'";
	$sth = $dbh->prepare($query);
	$sth->execute;
	($se_code,$se_ref,$se_desi) = $sth->fetchrow_array;
	print "$se_code $se_ref $se_desi<br>";
}

if ($action eq ""){
	print "<div class=\"alert alert-info\">Fiche produit</div>";
	print "<form>";
	&form_hidden();
	print "<input type=text name=pr_cd_pr>";
	print "<input type=hidden name=action value=go>";
	print "<br><br><button type=\"submit\" class=\"btn btn-info\">Submit</button>";
	print "</form>";
}	
print "		
		</div>
	</div>
</div>";
