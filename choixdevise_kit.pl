print "<title>Gestion des devises</title>";

require "./src/connect.src";
$dev=$html->param("dev");
$action=$html->param("action");

print "<center>";
if ($action eq "go")
{
	&save("update atadsql set dt_no='$dev' where dt_cd_dt=20","af");
}	

print "<h2>Choix devise</h2><br>";

$query="select trigramme,desi from devise,atadsql where id=dt_no and dt_cd_dt=20";
$sth=$dbh->prepare($query);
$sth->execute();
($dev,$desi)=$sth->fetchrow_array;
print "Devise actuelle $desi $dev <br><br>";
$query="select id,trigramme,desi from devise where cours!=0 order by trigramme";
$sth=$dbh->prepare($query);
$sth->execute();
print "<form>";
require ("form_hidden.src");
print "<select name=dev>";
print "<option value=nill>Choisir une nouvelle devise</option>";	
while (($id,$dev,$desi)=$sth->fetchrow_array)
{
	print "<option value=$id>$dev $desi</option>";	
}
print "<input type=hidden name=action value=go>";
print "</select><br><br><input type=submit></form>";
print "</center>";
;1
