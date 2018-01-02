require "./src/connect.src";
@base_client=("dfc","camairco","togo","aircotedivoire");
$action=$html->param("action");
$code=$html->param("code");	
$client_bon=$html->param("client");

if ($action eq "maj"){
   $query="select pr_desi,pr_four,pr_prac from $client_bon.produit where pr_cd_pr='$code'";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    ($pr_desi,$pr_four,$pr_prac)=$sth2->fetchrow_array;
  
    foreach $client (@base_client){
      if ($client eq $client_bon){next;}
      &save ("update $client.produit set pr_desi='$pr_desi',pr_four='$pr_four' where pr_cd_pr='$code'","aff");
    }
    $action="";
}


if ($action eq ""){
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
#     &save("update dfc.produit_plus set pr_remplace='lock' where pr_cd_pr='$code'","aff");
    $nb++;
    print "<table border=1><tr><th>client</th><th>code</th><th>pr_desi</th><th>pr_four</th><th>pr_type</th><th>pr_prac</th></tr>";
    foreach $client (@base_client){
      $pr_type=&get("select pr_famille from $client.produit_plus where pr_cd_pr='$code'");
      $query="select pr_desi,pr_four,pr_prac from $client.produit where pr_cd_pr='$code'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($pr_desi,$pr_four,$pr_prac)=$sth2->fetchrow_array;
      $fo2_add=&get("select fo2_add from $client.fournis where fo2_cd_fo='$pr_four'");
      ($add)=split(/\*/,$fo2_add);
      print "<tr><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=maj&code=$code&client=$client>$client</a></td><td><a href=?onglet=&sous_onglet=0&sous_sous_onglet=2&pr_cd_pr=$code>$code</a></td><td>$pr_desi</td><td>$pr_four $add</td><td>$pr_type</td><td>$pr_prac</td></tr>";
    }
   print "</table>"; 
  }
}
print "<br>Nombre de produit:$nbprod nombr de produit en erreur:$nb<br>";

}


;1
