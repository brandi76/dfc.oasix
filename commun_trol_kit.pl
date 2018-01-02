$base=$html->param("base");
$base2=$html->param("base2");
$tr_code=$html->param("tr_code");
$tr_code2=$html->param("tr_code2");


if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "Base <br>";
	print "<select name=base>";
	print "<option value=aircotedivoire>aircotedivoire</option>";
	print "<option value=togo>togo</option>";
	print "<option value=camairco>camairco</option>";
	print "</select><br>";
	print "Trolley <br>";
	print "<input name=tr_code>";
	print "<hr></hr>";
	print "Base <br>";
	print "<select name=base2>";
	print "<option value=aircotedivoire>aircotedivoire</option>";
	print "<option value=togo>togo</option>";
	print "<option value=camairco>camairco</option>";
	print "</select><br>";
	print "Trolley <br>";
	print "<input name=tr_code2>";
	print "<input type=hidden name=action value=go>";
	print "<br><input type=submit>";
	print "<form>";
}	
  
if ($action eq "go"){  
	print "<h3>$base $tr_code avec $base2 $tr_code2</h3>";
	$query="select a.tr_cd_pr from $base.trolley a INNER JOIN $base2.trolley b on a.tr_cd_pr=b.tr_cd_pr and a.tr_code='$tr_code' and b.tr_code='$tr_code2' order by a.tr_ordre"; 
	#print $query;
    $sth=$dbh->prepare($query);
    $sth->execute();
	while (($tr_cd_pr)=$sth->fetchrow_array){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$tr_cd_pr");
		print "$tr_cd_pr  $pr_desi <br>";
	}
}
;1