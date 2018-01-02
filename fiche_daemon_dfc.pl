$client_choisi=$html->param("client_choisi");
$mag=$html->param("mag");
$noratio=$html->param("noratio");
if ($action eq "modif_2"){
  &save("replace into alerte_daemon values ('$client_choisi','$mag','$noratio')");
  $action eq "";
}  

print "<table border=1><tr><th>Base</th><th>Mag</th><th>Ratio forcé</th><th>Action</th></tr>";
foreach $client (@bases_client){
  if ($client eq "dfc"){next;}
  if ($client eq "formation"){next;}
  $query="select mag,noratio from alerte_daemon  where client='$client'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($mag,$noratio)=$sth->fetchrow_array){
    print "<tr><td>$client</td>";
    print "<form>";
    &form_hidden();
    if ($action eq "modif"){
      if ($client eq $client_choisi) {
	print "<td style=background:yellow>";
	print "<select name=mag >";
	$query="select distinct mag from $client.mag order by mag";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($mag_mag)=$sth2->fetchrow_array){
	  print "<option value=$mag_mag ";
	  if ($mag eq $mag_mag){print "selected";}
	  print ">$mag_mag </option>";
	}
         print "<option></option>";
	print "</select>";
	print "</td>";
	print"<td style=background:yellow><input type=checkbox name=noratio ";
	if ($noratio eq "on"){print "checked";}
	print "></td>";
	print "<td><input type=submit value=maj></td></tr>";
	print "<input type=hidden name=action value=modif_2>";
      }
      else {print "<td>$mag&nbsp;</td><td>$noratio&nbsp;</td><td>&nbsp;</td></tr>";}
    }
    else {print "<td>$mag&nbsp;</td><td>$noratio&nbsp;</td><td><input type=submit value=maj></td></tr><input type=hidden name=action value=modif>";}
    print "<input type=hidden name=client_choisi value=$client></form>";
  }
}
print "</table>";
;1