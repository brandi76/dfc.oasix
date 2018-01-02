$datesql="2015-05-01";
&save("create temporary table sortie_tmp (pr_douane varchar(14),qte decimal(8,2) , valeur decimal (8,2), primary key (pr_douane))");
$query="select infr_code from inforetsql where infr_date>'$datesql'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code)=$sth->fetchrow_array){
  $query="select pr_douane,ret_qte-ret_retour,ret_prix from retoursql,produit where ret_code='$code' and ret_cd_pr=pr_cd_pr";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($pr_douane,$qte,$prix)=$sth2->fetchrow_array){
    $valeur=$qte*$prix;
    &save("update sortie_tmp set qte=qte+$qte,valeur=valeur+$valeur where pr_douane='$pr_douane'");
    &save("insert ignore into sortie_tmp values ('$pr_douane','$qte','$valeur')");
  }
}
$query="select pr_douane,qte,valeur from sortie_tmp where qte>0 order by pr_douane";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_douane,$qte,$valeur)=$sth->fetchrow_array){
  print "$pr_douane $qte $valeur<br>";
}

;1