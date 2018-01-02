$date=$html->param("date");
$option=$html->param("option");
$date2=$date;
$date2=~s/-//g;
require "./src/connect.src";

print "<form> ";
require ("form_hidden.src");

if ($action eq ""){
print "<select name=date>";
$query="select distinct date from inventaire order by date desc";
$sth=$dbh->prepare("$query");
$sth->execute();
while (($date)=$sth->fetchrow_array){
  print "<option value=$date>$date</option>";
}
print "</select>";
print "<br><input type=hidden name=action value=go>";
print "<br><input type=submit>";
print "</form>";
}
if ($action eq "go"){
  print "<h3>$date</h3>";
  print "<table><tr><th>Code</th><th>Designation</th><th>Ecart</th><th>Prix</th><th>Valeur</th></tr>";
  $query="select code,ecart,casse,pr_desi,pr_prac from inventaire,produit where ecart!=0 and date='$date' and code=pr_cd_pr";
#   print "$query";
  $sth=$dbh->prepare("$query");
  $sth->execute();
  while (($code,$ecart,$casse,$pr_desi,$pr_prac)=$sth->fetchrow_array){
    $pr_prac/=100;
    $val=$ecart*$pr_prac;
    print "<tr><td align=right>$code</td><td align=right>$pr_desi</td><td align=right>$ecart</td><td align=right>$pr_prac</td><td align=right>$val</td></tr>";
    if ($option eq "maj"){
      &save("replace into errdep values ($code,$date2,'',$ecart)","aff");
    }  
    $total+=$val;
  } 
  print "</table>";
  print "Valeur :$total euros"
}

;1








