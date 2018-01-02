$mag1=$html->param("mag1");	
$mag2=$html->param("mag2");	

if ($action eq ""){
  print "<form style=margin-left:100px;>";
  print "Comparer le magazine<br>";
  &form_hidden();
  print "<select name=mag1>";
  $query = "select distinct mag from mag order by mag desc ";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($mag)=$sth->fetchrow_array){
    print "<option value='$mag'>$mag</option>";
  }
  print "</select>";
  print "Avec le magazine<br>";
  print "<select name=mag2>";
  $query = "select distinct mag from mag order by mag desc ";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($mag)=$sth->fetchrow_array){
    print "<option value='$mag'>$mag</option>";
  }
  print "</select>";
  print "<input type=hidden name=action value=go>";
  print "<br><input type=submit>";
  print "</form>";
}
if ($action eq "go"){
  print "produit Present dans le magazine:$mag1 mais pas dans le magazine:$mag2<br>";
  $query="select code,pr_desi,page from mag,produit where mag='$mag1' and code=pr_cd_pr and code>0 and code not in (select code from mag where mag='$mag2')";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $nontrouve=1;
  while (($code,$desi,$page)=$sth->fetchrow_array){
    print "$code $desi page:$page<br>";
    $nontrouve=0;
  }
  print "<hr></hr><br>";
  print "produit Present dans le magazine:$mag2 mais pas dans le magazine:$mag1<br>";
  $query="select code,pr_desi,page from mag,produit where mag='$mag2'  and code=pr_cd_pr and code >0 and code not in (select code from mag where mag='$mag1')";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code,$desi,$page)=$sth->fetchrow_array){
    print "$code $desi page:$page<br>";
  }
  
  print "<hr></hr><br>";
  print "Changement de prix <br>";
  $query="select code,pr_desi,prix,prix_xof,page from mag,produit where mag='$mag2' and code=pr_cd_pr and code >0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code,$desi,$prix1,$prix_xof1,$page1)=$sth->fetchrow_array){
		$query="select prix,prix_xof,page from mag where mag='$mag1' and code='$code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($prix2,$prix_xof2,$page2)=$sth2->fetchrow_array){
			if (($prix1!=$prix2)||($prix_xof1!=$prix_xof2)){
				print "$code $desi<br>$mag2:$prix1 $prix_xof1 page:$page1<br>$mag1:$prix2 $prix_xof2 page:$page2<br>";
			}
		}
	}		
 print "<hr></hr><br>";
  print "Changement de place <br>";
  $query="select code,pr_desi,page,cases from mag,produit where mag='$mag2' and code=pr_cd_pr and code >0";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code,$desi,$page,$case)=$sth->fetchrow_array){
		$case2=&get("select cases from mag where mag='$mag1' and code='$code' and page='$page'");
		if (($case2 ne "")&&($case2 != $case1)){
				print "$code $desi  page:$page <br>";
		}
	}		

}
;1 

