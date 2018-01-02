if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "<select name=tr_code>";
	$query="select tr_code from trolley";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($row)=$sth->fetchrow_array){
		print "<option value=$row";
		print ">$row</option>";
	}	
	print "</select>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit>";
	print "</form>"
}	

print "Fichier <input name=fichier><br>";
print "champ <input name=champ><br>";

print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";	


if ($action eq "go"){
	$fichier=$html->param("fichier");
	$base=$html->param("database");
	$champ=$html->param("champ");
	
print <<EOF;	
    <pre>
	if (\$action eq ""){
		print "\&lt;form\>";
		&form_hidden();
		print "\&lt;select name=$champ\>";
		\$query="select $champ from $fichier";
		\$sth=\$dbh-\>prepare(\$query);
		\$sth-\>execute();
		while ((\$row)=\$sth-\>fetchrow_array){
			print "\&lt;option value=\$row";
			print "\>\$row\&lt;/option\>";
		}	
		print "\&lt;/select\>";
		print "&lt;input type=hidden name=action value=go>";
		print "&lt;input type=submit>";
		print "&lt;/form>";
	}
	</pre>
EOF
}

;1 

