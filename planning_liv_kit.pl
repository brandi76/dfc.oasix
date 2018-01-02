$date=$html->param("date");
if (grep(/\//,$date)) {
	($jj,$mm,$aa)=split(/\//,$date);
	$date=$aa."-".$mm."-".$jj;
}

if ($action eq "add"){
  &save("insert ignore into depart value ('$date')");
}
if ($action eq "sup"){
  &save("delete from depart where date='$date'");
}

$query="select date from depart where date >curdate() order by date";
$sth=$dbh->prepare($query);
$sth->execute();
while (($date)=$sth->fetchrow_array){
  print "$date <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&date=$date onclick=\"return confirm('Etes vous sur de vouloir supprimer')\"><img border=0 src=../../images/b_drop.png title='Supprimer'></a><br>";
}
print "<form>";
form_hidden();
print "Nouvelle date <input type=texte id=datepicker name=date><br>";
print "<input type=hidden name=action value=add>";
print "<input type=submit>";
print "</form>";
;1
