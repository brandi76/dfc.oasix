
print "<title>ajout rototation</title>";
require("./src/connect.src");
$action=$html->param("action");
$appro=$html->param("appro");
$rot=$html->param("rot");

if ($action eq "annuler"){$action="";}


if ($action eq "ajouter"){
	$rot++;
	$query="select * from vol where v_code='$appro'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_pax,$v_date_sql)=$sth->fetchrow_array;
	&save("insert ignore into vol value ('$v_code','$rot','$v_vol','$v_date','$v_type','$v_pnc','$v_ca','$v_dest','$v_cd_cl','$v_nom','$v_dest2','$v_retour','$v_troltype','$v_date_jl','0','$v_date_sql')","af");
	&save("insert ignore into caisse values ('$appro','$rot','0','0','0','0','0','0','0','0','','0','0','','')","af");
	print "rotation ajoutee<br>";	
}
	
if ($action eq "saisie"){
	$nb_rot=&get("select count(*) from vol where v_code='$appro' ")+0;
	$vol=&get("select v_vol from vol where v_code='$appro' and v_rot=1");
	$v_date=&get("select v_date from vol where v_code='$appro' and v_rot=1");
	if ($nb_rot==0){
		print "vol inconnu<br>";
		$action="";
	}
	else {
		print "<form>";
		require ("./src/form_hidden.src");
		print "$appro no de vol :$vol du $v_date nb de rotation :$nb_rot<br>";
		print "<input type=submit name=action value=annuler> <input type=submit name=action value=ajouter> ";
		print "<input type=hidden name=appro value='$appro'>";
		print "<input type=hidden name=rot value='$nb_rot'>";
		print "</form>";
	}	
}		

if (($action eq "")){

       print "<form>";
	require ("./src/form_hidden.src");
	print "<table>";
	$var1="appro";
	$var2="appro";
	print "<tr><td>$var1</td><td><input type=text name=$var2 value=\"$var3\" size=6></td></tr>";
	print "<tr><td colspan=2><input type=submit value=valider></td></tr>";
	print "</table>";
	print "<input type=hidden name=action value=saisie>";
	print "</form>";
}	

;1
