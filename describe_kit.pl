print "<form>";
&form_hidden();
print "<select name=database order by Database>";
$query="show databases";
$sth=$dbh->prepare($query);
$sth->execute();
while (($field)=$sth->fetchrow_array){
	print "<option value=$field";
	print " selected" if ($field eq "dfc");
	print ">$field</option>";
}	
print "</select>";
print "Fichier <input name=fichier><br>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";	


if ($action eq "go"){
	$fichier=$html->param("fichier");
	$base=$html->param("database");
	print "\$query=\"select * from $fichier\";<br>";
	print "\$sth=\$dbh->prepare(\$query);<br>";
	print "\$sth->execute();<br>";
	print "while ((";
	$query="describe $base.$fichier";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($field)=$sth->fetchrow_array){
		$string.="\$$field,";
	}	
	chop($string);
	print "$string)=\$sth->fetchrow_array){<br>";
	print "}<br>";
}

;1 

