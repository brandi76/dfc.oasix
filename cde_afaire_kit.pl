$query="select date,datediff(date,curdate()) from depart where date>curdate() order by date";
$sth=$dbh->prepare($query);
$sth->execute();
while (($date,$delai)=$sth->fetchrow_array){
  print "$date $delai<br>";
  $query="select fo2_cd_fo,fo2_add from fournis where fo2_delai<=$delai and fo2_delai>0";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($pr_four,$fo2_add)=$sth2->fetchrow_array){
    ($fo_nom)=split(/\*/,$fo2_add);
    if (! grep /pr_four/,@liste){
      print "$pr_four $fo_nom<br>";
      push(@liste,$pr_four);
    }
  }  
}
;1