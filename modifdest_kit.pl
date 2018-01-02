print "<title>destination</title>";
require "./src/connect.src";
print "<center><div class=titrefixe> Modification de la destination<br></div>";
$action=$html->param("action");
$appro=$html->param("appro");

if (($action eq "")||($action eq "retour")){
	print "<form>";
	require ("form_hidden.src");
	print "Appro <input type=text name=appro><br>";	
	print "<input type=submit name=action value=go>";
	print "</form>";

}
if ($action eq "validation"){
	$query=	"select v_rot from vol where v_code='$appro' order by v_rot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (	($v_rot)=$sth->fetchrow_array){
		$newdest=$html->param("dest$v_rot");
		&save("update vol set v_dest=\"$newdest\" where v_code=$appro and v_rot=$v_rot");
	}
	$action="go";
}

if ($action eq "go"){
	print "<form >";
	require ("form_hidden.src");
	$query=	"select v_vol,v_date,v_dest,v_rot from vol where v_code='$appro' order by v_rot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (	($v_vol,$v_date,$v_dest,$v_rot)=$sth->fetchrow_array){
		print "vol:<b>$v_vol rotation:$v_rot du:$v_date <input type=text name=dest$v_rot value=$v_dest> <br>";
	}
	print "<br><input type=submit name=action value=validation>";
	print "<input type=hidden name=appro value=$appro>";
	print " <input type=submit name=action value=retour>";
	print "</form>";
	
}


;1
