$datesql=&get("select curdate()","af");
($an,$mois,$jour)=split(/-/, $datesql, 3); 
$datesimple="1".substr($an,2,2).$mois.$jour;
$datesimple-=5;
&save("create temporary table sortie_tmp (pr_douane varchar(14),qte decimal(8,2) , valeur decimal (8,2), primary key (pr_douane))");
$query="select aj_code from apjour where aj_date>'$datesimple'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($ap_code)=$sth->fetchrow_array){
  $query="select pr_douane,ap_qte0/100,ap_prix/100,pr_douane from appro,produit where ap_code='$ap_code' and ap_cd_pr=pr_cd_pr and ap_qte0>0";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($pr_douane,$qte,$prix)=$sth2->fetchrow_array){
    $valeur=$qte*$prix;
    &save("update sortie_tmp set qte=qte+$qte,valeur=valeur+$valeur where pr_douane='$pr_douane'");
    &save("insert ignore into sortie_tmp values ('$pr_douane','$qte','$valeur')");
  }
}
$query="select pr_douane,qte,valeur from sortie_tmp order by pr_douane";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_douane,$qte,$valeur)=$sth->fetchrow_array){
  print "$pr_douane $qte $valeur<br>";
}

;1