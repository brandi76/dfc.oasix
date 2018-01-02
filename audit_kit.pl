require "./src/connect.src";
@base_client=("dfc","camairco","togo","aircotedivoire");
&save("create temporary table produit_tmp (code int(11),primary key (code))");

foreach $client (@base_client){
    &save("insert ignore into produit_tmp select pr_cd_pr from $client.produit");
}
$query="select * from produit_tmp order by code";
$nbprod++;
$sth=$dbh->prepare($query);
$sth->execute();
while (($code)=$sth->fetchrow_array){
$nbprod++;
  $ko=0;
  $first=1;
  foreach $client (@base_client){
      $query="select pr_desi,pr_four from $client.produit where pr_cd_pr='$code'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($pr_desi,$pr_four)=$sth2->fetchrow_array;
      if (! $first){
	if ($pr_desi ne $desi_tamp){$ko=1;}
	if ($pr_four ne $four_tamp){$ko=1;}
      }
      $first=0;
      $desi_tamp=$pr_desi;
      $four_tamp=$pr_four;
  }    
  if ($ko){
    $nb++;
    print "<hr></hr>";
    foreach $client (@base_client){
      $query="select pr_desi,pr_four from $client.produit where pr_cd_pr='$code'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($pr_desi,$pr_four)=$sth2->fetchrow_array;
      print "$client $code $pr_desi four:$pr_four <br>";
    }
  }
}
print "<br>Nombre de produit:$nbprod nombr de produit en erreur:$nb<br>";


;1
