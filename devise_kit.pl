print "<title>Gestion des devises</title>";

require "./src/connect.src";
$dev=$html->param("dev");
$action=$html->param("action");
$cours=$html->param("cours");

print "<center>";

if ($dev eq ""){
	print "<h2>Cours devise</h2><br>";
	$query="select trigramme,desi from devise order by trigramme";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form>";
	require ("form_hidden.src");
	print "<select name=dev>";
	print "<option value=nill>Devise</option>";	
	while (($dev,$desi)=$sth->fetchrow_array)
	{
		print "<option value=$dev>$dev $desi</option>";	
	}
	print "<input type=hidden name=action value=go>";
	print "</select><br><br><input type=submit></form>";
}
if ($action eq "change")
{
	$query="update devise set cours='$cours' where trigramme='$dev'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "Modification effectuée<br>";
	$query="select desi,cours from devise where trigramme='$dev'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($desi,$cours)=$sth->fetchrow_array;
	print "$dev $desi $cours";
	if ($dev eq "AOA") {$base_dbh="test";}
	system("/var/www/cgi-bin/dfc.oasix/send_changement_devise.pl $base_dbh &");
}
if ($action eq "go")
{
	$query="select desi,cours from devise where trigramme='$dev'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($desi,$cours)=$sth->fetchrow_array;
	print "<form>";
	require ("form_hidden.src");
	print "$dev $desi <input type=text name=cours value=$cours> <input type=submit><input type=hidden name=action value=change><input type=hidden name=dev value=$dev></form>";
}	
;1
