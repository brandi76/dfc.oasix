print "Liste des doublons pour des produits differents <br>";
print "<table>";
print "<tr><th>Base</th><th>Produit</th><th>etat</th><th>Qte vendue les deux derniers mois</th></tr>";
# foreach $client (@bases_client) {
#     if ($client eq "dfc"){next;}
#     if ($client eq "tacv"){next;}
#     print "<th>$client</th>";
# }
# print "</tr>";
@etat=("0 actif","1 supprimé","2 destockage","3 new","4 délisté par le fournisseur"); 
$query="select produit_plus.pr_cd_pr from produit_plus where pr_remplace='loc' ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code)=$sth->fetchrow_array){
 if ($color eq "white"){$color="lightblue";}else {$color="white";}
 foreach $client (@bases_client) {
#     if ($client eq "dfc"){next;}
    if ($client eq "tacv"){next;}
    $desi=&get("select pr_desi from $client.produit where pr_cd_pr=$code");
    $pr_sup=&get("select pr_sup from $client.produit where pr_cd_pr=$code");
    
    print "<tr bgcolor=$color><td>$client</td><td>$code $desi</td>";
    $qte="";
    if ($client ne "dfc"){
      $qte=&get("select floor(sum(ro_qte)/100) from $client.rotation,$client.vol where ro_code=v_code and datediff(curdate(),v_date_sql)<60 and v_rot=1 and ro_cd_pr='$code'") ; 
    }
    print "<td align=right>$etat[$pr_sup]</td>";
    print "<td align=right>$qte</td>";
    print "</tr>";
 }
}
print "</table>";
;1
