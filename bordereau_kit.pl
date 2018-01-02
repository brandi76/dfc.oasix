print "<title>Gestion des bordereaux de remise en banque</title>";

require "./src/connect.src";
$dev=$html->param("dev");
$no=$html->param("no");
$action=$html->param("action");
$montant=$html->param("montant");
$edition=$html->param("edition")+0;
$edition2=$html->param("edition2")+0;
$devise=$html->param("devise");
if ($devise eq "Toute"){$devise="%";}

$ref=$html->param("ref");
$date_remise=$html->param("date_remise");
if (grep(/\//,$date_remise)) {
        ($jj,$mm,$aa)=split(/\//,$date_remise);
        $date_remise=$aa."-".$mm."-".$jj;
}

print "<center>";
if ($action eq "go")
{
	$ok=1;
	if ($dev eq "nill"){ print "<p class=erreur>Merci de choisir une devise</p>";$ok=0;}
	if ($date_remise eq ""){ print "<p class=erreur>Merci de mettre une date</p>";$ok=0;}
	if ($montant eq ""){ print "<p class=erreur>Merci de mettre un montant</p>";$ok=0;}

	if (($no eq "nill")&&($ok==1)){
		$no=&get("select max(no) from bordereau where no <10000")+1;
		if ($no==1){$no=1000;}
		&save("insert into bordereau value ('$no','$dev','$date_remise','$date_remise','$ref','$montant')");
		print "Remise no: $no Enregistrée<br>";
		$ok=0;
	}
	if ($ok==1){
		$ref=~s/'//g;
		$query="update bordereau set montant='$montant',date_remise='$date_remise',ref='$ref' where no='$no' and devise='$dev'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "Bordereau $no Modification effectuée<br>";
	}
}

	print "<h2>Gestion des bordereaux de remise en banque</h2><br>";
	print "<form>";
	require ("form_hidden.src");
	$query="select distinct no from bordereau where date_remise='0000-00-00' order by no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "Facultatif <select name=no>";
	print "<option value=nill>Choisir un bordereau</option>";	
	while (($dev,$desi)=$sth->fetchrow_array)
	{
		print "<option value=$dev>$dev $desi</option>";	
	}
	print "</select><br><br>";
	$query="select distinct devise from bordereau where date_remise='0000-00-00' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<select name=dev>";
	print "<option value=nill>Choisir une devise</option>";	
	while (($dev,$desi)=$sth->fetchrow_array)
	{
		print "<option value=$dev>$dev $desi</option>";	
	}
	print "</select><br><br>";
	print "Montant <input type=text name=montant><br><br>";
	print "Reference banque - justificatif  <input type=text name=ref size=20><br><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date_remise><br><br>";
	print "<input type=hidden name=action value=go>";
	print "<br><br><input type=submit>";
	print "</form>";

;1
