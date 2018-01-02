if ($action eq "flag"){
  $client=$html->param("client");
  $trolley=$html->param("trolley");
  &save("update $client.lot set lot_flag=0 where lot_nolot='$trolley'");
}
if ($action eq ""){
  foreach $client (@bases_client) {
    if ($client eq "dfc"){next;}
    if ($client eq "tacv"){next;}
    print "<div style=\"border:1px;box-shadow:2px 2px 6px #888;width:80%;\"><p style=font-weight:bold;color:navy;font-size:1.2em>$client</p>";
    print "<br>";
    $query="select lot_nolot,lot_desi,lot_mag,lot_coef from $client.lot where lot_flag=1 order by lot_nolot";
    $sth=$dbh->prepare($query);
    $sth->execute();
    print "<table border=1><tr><th>Lot</th><th>Intitulé</th><th>Date</th><th>Plus utilisé depuis (jours)</th><th>mag</th><th>Passé/Avenir</th><th>Coef</th></tr>";
    while (($lot_nolot,$lot_desi,$lot_mag,$lot_coef)=$sth->fetchrow_array){
      $date=&get("select max(v_date_sql) from $client.vol where v_troltype='$lot_nolot'");
      $diff='';
      if ($date ne ''){ $diff=&get("select datediff(now(),'$date')");}
      $color='white';
      if ($diff>30){$color='pink';}
      print "<tr><td>$lot_nolot</td><td>$lot_desi</td><td>$date</td><td align=right bgcolor=$color>$diff</td><td>$lot_mag</td>";
      $passe=&get("select count(*) from $client.vol where v_troltype=$lot_nolot and v_rot=1 and datediff(curdate(),v_date_sql)<=35 and datediff(curdate(),v_date_sql)>0")+0;
      $avenir=&get("select count(*) from $client.flyhead where fl_troltype=$lot_nolot and datediff(fl_date_sql,curdate())>0 and datediff(fl_date_sql,curdate())<=35")+0;
       $ratio=0;
      if ($passe>0){$ratio=int($avenir*100/$passe)/100;}
      print "<td>$passe/$avenir $ratio%</td>";
      if ($lot_coef==1){print "<td>Actif</td>";}else {print "<td>&nbsp;</td>";}
     if ($diff>30){print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=flag&client=$client&trolley=$lot_nolot>desactiver</a></td>";}
      else {
	print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif_produit&client=$client&trolley=$lot_nolot>verifier</a></td>";
	print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=edite&client=$client&trolley=$lot_nolot>editer</a></td>";
	  }

    print "</tr>";
    }
    print "</table>";
    print "</div>";
  }
}
if ($action eq "actif_produit"){
  $client=$html->param("client");
  $trolley=$html->param("trolley");
  $code=$html->param("code");
  &save("update $client.produit set pr_sup=0 where pr_cd_pr='$code'");
  $action="verif_produit";
}

if ($action eq "verif_produit"){
  $client=$html->param("client");
  $trolley=$html->param("trolley");
  $query="select pr_cd_pr,pr_desi,pr_sup from $client.produit,$client.trolley where (pr_sup!=0 and pr_sup!=3) and pr_cd_pr=tr_cd_pr and tr_code='$trolley'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $pass=0;
  while (($pr_cd_pr,$pr_desi,$pr_sup)=$sth->fetchrow_array){
      print "$pr_cd_pr $pr_desi $pr_sup <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=actif_produit&client=$client&trolley=$lot_nolot&code=$pr_cd_pr>activer</a><br>";
      $pass=1;
  }
  if ($pass==0){print "Tous les produits sont actif";}
  print "<br>";
  print "Produits nouveaux:<br>";
  $query="select pr_cd_pr,pr_desi,tr_prix/100,pr_sup from $client.produit,$client.trolley where pr_cd_pr=tr_cd_pr and tr_code='$trolley'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $pass=0;
  while (($pr_cd_pr,$pr_desi,$prix,$pr_sup)=$sth->fetchrow_array){
    $vendu=&get("select sum(ap_qte0) from $client.appro,$client.vol where ap_cd_pr='$pr_cd_pr' and ap_code=v_code and datediff(curdate(),v_date_sql)>30")+0;
    if ($vendu==0){
      print "$pr_cd_pr $pr_desi $prix $pr_sup<br>";
      &save("update $client.produit set pr_sup=3 where pr_cd_pr='$pr_cd_pr'");
    }  
  } 
  print "<br> <input type=button value=retour onclick=history.back()>";
  
}
@etat=("0 actif","1 supprimé","2 destockage","3 new","4 délisté par le fournisseur");

if ($action eq "edite"){
  $client=$html->param("client");
  $trolley=$html->param("trolley");
  $lot_mag=&get("select lot_mag from $client.lot where lot_nolot='$trolley'");
  $query="select pr_cd_pr,pr_desi,pr_sup from $client.produit,$client.trolley where tr_code='$trolley' and pr_cd_pr=tr_cd_pr order by pr_sup,pr_cd_pr ";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $sup=-1;
  while (($pr_cd_pr,$pr_desi,$pr_sup)=$sth->fetchrow_array){
      if ($pr_sup != $sup){print "<h3>".$etat[$pr_sup]."</h3>";$sup=$pr_sup;}
      print "$pr_cd_pr $pr_desi<br>";
      $check=&get("select count(*) from $client.mag where mag='$lot_mag' and code='$pr_cd_pr'")+0;
      if ($check==0&& $pr_sup!=2){
	print "<span style=color:red>$pr_cd_pr $pr_desi pas dans mag sup a:$pr_sup</span><br>";
# 	&save("update $client.produit set pr_sup=2 where pr_cd_pr='$pr_cd_pr'","aff");
      }
      if (($check!=0) && ($pr_sup!=0)&&($pr_sup!=3)){
	print "<span style=color:red>$pr_cd_pr $pr_desi dans mag sup a:$pr_sup</span><br>";
      }
      
  }
}

;1
  