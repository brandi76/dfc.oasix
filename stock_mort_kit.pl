if ($action eq ""){
  print "<p style=background:lavender;font-size:1.2em;margin:auto;width:90%;text-align:center;padding:5px;border-radius:10px;>Liste des produits en stock non presents dans les trolleys actifs </p>";
  &save("create temporary table liste_temp (client varchar(20),code int(8),qte int(8))");
  foreach $client (@bases_client) {
    if ($client eq "dfc"){next;}
    if ($client eq "tacv"){next;}
    
    $query="select pr_cd_pr,pr_stre/100 from $client.produit where pr_stre>0 and pr_cd_pr not in (select tr_cd_pr from $client.trolley,$client.lot where lot_nolot=tr_code and lot_flag=1 and tr_qte>0)";
    # selection via le trolley type
#     $query="select pr_cd_pr,pr_stre/100 from $client.produit where pr_stre>0 and pr_sup!=0 and pr_sup!=3";
    # selection via pr_sup
#     print $query;
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($pr_cd_pr,$pr_stre)=$sth->fetchrow_array){
      &save("insert ignore into liste_temp value ('$client','$pr_cd_pr','$pr_stre')","af");
      
    }  
  } 
  $query="select code,pr_desi,pr_famille,pr_prac/100 from liste_temp,produit,produit_plus where code=produit.pr_cd_pr and code=produit_plus.pr_cd_pr  group by code order by pr_famille";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi,$famille,$pr_prac)=$sth->fetchrow_array){
    if ($famille ne $famille_temp){
      if ($total_famille >0){ print "</table>Total $famille_desi:$total_famille valeur:$total_valeur<br>";$douleur+=$total_valeur;}
      $famille_desi=&get("select fa_desi from famille where fa_id='$famille'");
      print "<hr></hr><h3>$famille_desi</h3><br><table><tr><th> </th>";
      foreach $client (@bases_client) {
	if ($client eq "dfc"){next;}
	if ($client eq "tacv"){next;}
	 print "<th>$client</th>";
      }  
      print "<th>Total</th></tr>";
      $famille_temp=$famille;
      $total_famille=0;
      $total_valeur=0;
    }
    
    $qte=&get("select sum(qte) from liste_temp where code='$pr_cd_pr'");
    print "<tr><td><a href=?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$pr_cd_pr&commercial=on&action=visu>$pr_cd_pr</a> $pr_desi</td>";
    $qte_tot=0;
    foreach $client (@bases_client) {
      if ($client eq "dfc"){next;}
      if ($client eq "tacv"){next;}
      $qte=&get("select sum(qte) from liste_temp where code='$pr_cd_pr' and client='$client'")+0;
      print "<td  align=right>$qte</td>";
      $qte_tot+=$qte;
    }
    $valeur=$qte_tot*$pr_prac;
    print "<td align=right>$qte_tot</td></tr>";
    $total_famille+=$qte_tot;
    $total_valeur+=$valeur;
  }
  if ($total_famille >0){ print "</table>Total $famille_desi:$total_famille valeur:$total_valeur<br>";$douleur+=$total_valeur;}
  
}  
print "<h3>Total stock mort:$douleur euros</h3>";
;1
  