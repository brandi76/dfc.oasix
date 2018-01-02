
$four=$html->param("four");
$firstdate=$html->param("firstdate");
$lastdate=$html->param("lastdate");
if (grep(/\//,$firstdate)) {
	($jj,$mm,$aa)=split(/\//,$firstdate);
	$firstdate=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$lastdate)) {
	($jj,$mm,$aa)=split(/\//,$lastdate);
	$lastdate=$aa."-".$mm."-".$jj;
}

if ($four eq "TOUS"){$four="pr_four";}
print "<center>";
if ($action eq "") {
  print "<form>";
  &form_hidden();
  print "<br>choisir un fournisseur<br><br><select name=four><option value=''></option><option value='TOUS'>TOUS</option>";
  $sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo order by fo2_add");
  $sth2->execute;
  while (my @four = $sth2->fetchrow_array) {
	  next if $four eq $four[0];
	  ($four[1])=split(/\*/,$four[1]);
	  print "<option value=\"$four[0]\">$four[0] $four[1]\n";
  }

  print "</select><br>";
  print "<br> <br>Premiere date <input id=\"datepicker\" type=text name=firstdate size=12>";
  print "<br> <br>Derniere date <input id=\"datepicker2\" type=text name=lastdate size=12>";
  print "<br> Avec les mois <input type=checkbox name=avecmois checked>";
  print "<br> <input type=hidden name=action value=go><br><input type=submit value='envoie'></form>";
}

if ($action eq "go")
{
  $avecmois=$html->param("avecmois");
  print "<h4>Période du $firstdate au $lastdate</h4>";
  $query="select pr_four,fo2_add from produit,fournis where fo2_cd_fo=pr_four and  pr_four=$four group by pr_four order by pr_four";
  $sth3=$dbh->prepare($query);
  $sth3->execute();
  while (($pr_four,$fo_nom)=$sth3->fetchrow_array){
    @mois=();
    %total_mois=();
    $query="select distinct extract(YEAR_MONTH from v_date_sql) as mois from vol where v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and v_rot=1 order by mois" ; 
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($moisd)=$sth->fetchrow_array){
      push(@mois,$moisd);
    }
    print "<h4>$pr_four $fo_nom</h4><br>";
    print "<table cellspacing=0 border=1>";
    print "<tr><th>produit</th>";
    if ($avecmois eq "on"){
      foreach $moisd (@mois){
	$an=substr($moisd,2,2);
	$mois=substr($moisd,4,2);
	print "<th>$mois/$an</th>";
	$nbcol++;
      }
    }
    print "<th>Total</th><th>Prix de vente</th><th>Ca</th></tr>";
    $query="select pr_cd_pr,pr_desi from produit where pr_four='$pr_four'";
    $totalf=0;
    $totalv=0;
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array){
      $prix=&get("select floor(avg(ap_prix)/100)  from appro,vol where ap_code=v_code and ap_cd_pr='$pr_cd_pr' and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and v_rot=1 and ap_prix<45000 ") ; 
      $query="select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and ro_cd_pr='$pr_cd_pr' and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and v_rot=1 " ; 
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($qte)=$sth->fetchrow_array;
      $qte+=0;
      if ($qte==0){next;}
      print "<tr><td width=30%>$pr_cd_pr $pr_desi</td>";
      if ($avecmois eq "on"){
	foreach $moisd (@mois){
	  $qte_mois=&get("select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and ro_cd_pr='$pr_cd_pr' and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and v_rot=1 and extract(YEAR_MONTH from v_date_sql)=$moisd")+0 ; 
	  print "<td align=right>$qte_mois</td>";
	  $total_mois{$moisd}+=$qte_mois;
	}
      }
      print "<td align=right>$qte</td>";
      print "<td align=right>$prix</td>";
      $valeur=$qte*$prix;
      print "<td align=right>$valeur</td>";
      print "</tr>";
      $totalf+=$qte;
      $totalv+=$valeur;
    }
    print "<tr><td><b>Total</td>";
    if ($avecmois eq "on"){
      foreach $moisd (@mois){
	print "<td align=right>";
	print $total_mois{$moisd};
	print "</td>";
      }
    }
  
    print "<td align=right><b>$totalf</td><td>&nbsp;</td><td align=right><b>$totalv</td></tr>";
    print "</table>";
  }
}

;1