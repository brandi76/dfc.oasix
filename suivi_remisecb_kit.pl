print "<title>Gestion des bordereaux de remise Cb</title>";
print "<table><tr><th>Date</th><th>Appro</th><th>Rotation</th><th>Montant</th></tr>";
$query="select tra_code,tra_rot,tra_total from transfertcb order by tra_code desc";
$sth=$dbh->prepare($query);
$sth->execute();
while (($tra_code,$tra_rot,$tra_total)=$sth->fetchrow_array){
  $date=&get("select date_creation from bordereau,caissesql where ca_code='$tra_code' and ca_rot='$tra_rot' and ca_border=no");
  print "<tr><td>$date</td><td>$tra_code</td><td>$tr_rot</td><td>$tra_total</td></tr>";
}
print "</table>";
;1
