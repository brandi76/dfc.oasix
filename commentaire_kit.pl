print "<title>commentaire</title>";
require "./src/connect.src";
print "<center><div class=titrefixe> Saisie des commentaires<br></div>";
$action=$html->param("action");
$appro=$html->param("appro");
$rot=$html->param("rot");
$question=$html->param("question");
$reponse=$html->param("reponse");
$question=~s/'/ /g;
$question=~s/"/ /g;
$reponse=~s/'/ /g;
$reponse=~s/"/ /g;


if ($action eq ""){
	print "<form>";
	require ("form_hidden.src");
	print "appro <input type=text name=appro><br>";	
	print "rotation <input type=text name=rot size=3 value=1><br>";	
	print "<input type=submit name=action value=go>";
	print "</form>";
	$query="select com_appro,com_question,com_reponse from commentaire order by com_appro desc limit 20";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table border=1 cellspacing=0>";
	while (($com_appro,$com_questio,$com_reponse)=$sth->fetchrow_array){
		$query="select v_vol,v_date from vol where v_code=$com_appro and v_rot=1";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($v_vol,$v_date)=$sth2->fetchrow_array;
		print "<tr><td><b>$com_appro</b> $v_vol $v_date</td><td>$com_questio</td><td></tr>";
	}
	print "</table>";

}
if ($action eq "validation"){
	&save("replace into commentaire values('$appro','$rot','$question','$reponse')");
	print "informations enregistrées<bR>";
	$action="go";
	}
if ($action eq "go"){
	($v_vol,$v_date,$v_dest)=&get("select v_vol,v_date,v_dest from vol where v_code='$appro' and v_rot='$rot'");
	if ($v_vol eq ""){
		print "<div class=erreur>vol inconnu</div>";
		print "<a href=$ENV{'HTTP_REFERER'}>retour</a>";
		}
	else
	{
		$question=&get("select com_question from commentaire where com_appro='$appro' and com_rot=$rot");
		$reponse=&get("select com_reponse from commentaire where com_appro='$appro' and com_rot=$rot");
		print "vol:<b>$v_vol $v_date $v_dest $v_rot<br>";
		print "<form method=POST>";
		require ("form_hidden.src");
		print "<br>Commentaire pnc:<br><div class=comment><textarea name=question>$question</textarea>";
		print "<br>Commentaire DFC<br><textarea name=reponse>$reponse</textarea><br><br>";
		print "<input type=hidden name=appro value=$appro>";
		print "<input type=hidden name=rot value=$rot>";
		print "<input type=submit name=action value=validation>";
		print "</form></div>";
	}
}
;1
