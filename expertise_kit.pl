print "<style>";
print "ul {list-style-type:none;}";
print "li {width:80%;padding:10px;}";
print "li:nth-child(even){background-color:lightcyan;}";
print "</style>";
require "./src/connect.src";
$pr_cd_pr=$html->param("pr_cd_pr");
print "<form>";
&form_hidden();
print "code <input type=text name=pr_cd_pr>";
print "<input type=submit></form><br>";

if ($pr_cd_pr ne ""){
    if ($action eq "go"){
      $pr_sup=$html->param("pr_sup");
      $client=$html->param("client");
      &save ("update $client.produit set pr_sup=$pr_sup where pr_cd_pr=$pr_cd_pr");
    }
    print "<ul>";
 foreach $client (@bases_client){
    print "<li>";
    print "<div class=titre>$client</div>";
    $pr_desi=&get("select pr_desi from $client.produit where pr_cd_pr=$pr_cd_pr");
    $check=&get("select pr_cd_pr from $client.produit where pr_cd_pr=$pr_cd_pr")+0;
    if ($check==0){print "<b>Inexistant</b><br>";}
    else {print "<b>$pr_cd_pr $pr_desi</b><br>";}
    if ($client eq "dfc"){next;};
    $check=&get("select count(*) from $client.produit where pr_cd_pr='$pr_cd_pr'")+0;
    if (! check) {next;}
    $pr_sup=&get("select pr_sup from $client.produit where pr_cd_pr='$pr_cd_pr'")+0;
    @liste=("actif","supprimé","délisté","new","déstockage","délisté par le fournisseur");
    $etat=$liste[$pr_sup];
    print "Etat $pr_sup $etat ";
    print "<form>";
    &form_hidden();
    print "<select name=pr_sup>";
    $i=0;
    foreach $option (@liste){
      print "<option value=$i ";
      if ($i==$pr_sup){print "selected";}
      print ">$option</option>";
      $i++;
    }
    print "<input type=hidden name=action value=go>";
    print "<input type=hidden name=client value=$client>";
    print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
    print "<input type=submit>";
    print "</form>";
	%stock=&stock_expertise($pr_cd_pr);
	$pr_stre=$stock{"stock"};
    # $pr_stre=&get("select pr_stre/100 from $client.produit where pr_cd_pr='$pr_cd_pr'")+0;
    print "Stock:$pr_stre ";
	
    $pr_stvol=&get("select pr_stvol/100 from $client.produit where pr_cd_pr='$pr_cd_pr'")+0;
    print "Stock en vol:$pr_stvol ";
    $vendu=&get("select sum(ro_qte)/100 from $client.rotation where ro_cd_pr='$pr_cd_pr'")+0;
    print "Vendu:$vendu ";
    $cde=&get("select sum(com2_qte)/100 from $client.commande where com2_cd_pr='$pr_cd_pr'")+0;
    print "En cde:$cde <br>";
    $query="select mag from $client.mag where code='$pr_cd_pr'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    $non=1;
    while (($mag)=$sth->fetchrow_array){
      print "Produit present dans le mag:$mag<br>";
      $non=0;
    }
    if ($non){
      print "<span style=color:red>Present dans aucun magazine</span><br>";
    }
    $non=1;
    $query="select tr_code,lot_flag,lot_desi,tr_qte from $client.trolley,$client.lot where tr_code=lot_nolot and tr_cd_pr='$pr_cd_pr' and lot_flag=1";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($tr_code,$flag,$lot_desi,$tr_qte)=$sth->fetchrow_array){
      print "Present dans le trolley actif:$tr_code qte:$tr_qte $lot_desi <br>";
      $non=0;
    }
    if ($non){
      print "<span style=color:red>Present dans aucun trolley actif</span><br>";
    }
    print "</li>";
   }
   print "</ul>";
}
sub stock_expertise {
	my($prod)=$_[0];
	my($today)=$_[1];
	my($option)=$_[2];
	my($option2)=$_[3];

	my($stock,$non_sai,$pastouch,$max,$pastouch2,$retourdujour,$errdep);
	my(%stock);
	my($query) = "select * from $client.produit where pr_cd_pr=$prod";
	
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	my($produit)=$sth->fetchrow_hashref;
	if ($option ne "quick"){
		# stock entrepot
		$query = "select sum(ret_retour)  from  $client.non_sai,$client.retoursql where ret_cd_pr=$prod and ns_code=ret_code";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$non_sai=$sth->fetchrow*100;
		$stock{"nonsai"}=$non_sai/100;
		$query = "select sum(ap_qte0) from  $client.appro,$client.geslot where (gsl_ind=10 or gsl_ind=11) and gsl_apcode=ap_code and ap_cd_pr=$prod";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$stock{"pastouch"}=$sth->fetchrow;
		
		# $query = "select max(liv_dep)  from  geslot,listevol where gsl_nolot=liv_nolot and gsl_ind=11";
	 	# $sth=$dbh->prepare($query);
		# $sth->execute();
		# $max = $sth->fetchrow;
		
		# $query = "select sum(ap_qte0)  from  appro,listevol where ap_code=liv_aprec and ap_cd_pr=$prod and liv_dep='$max'";
	 	# $sth=$dbh->prepare($query);
		# $sth->execute();
		# $pastouch2 = $sth->fetchrow;  # pas touche des pas touche dans le depart
		
		
		#$stock{"pastouch"}=$pastouch+$pastouch2;
		if ($option eq "retour"){
 			$query = "select sum(ret_retour) from $client.retoursql,$client.retjour,$client.geslot,$client.etatap where at_code=rj_appro and at_nolot=gsl_nolot and ret_cd_pr=$prod and rj_appro=ret_code and rj_date>=$today and gsl_ind!=10 and gsl_ind!=11";
# 			print "$query";
			$sth=$dbh->prepare($query);
 			$sth->execute();
			$retourdujour = $sth->fetchrow;
			$stock{"retourdujour"}=$retourdujour;
	        }
		# $query = "select sum(ap_qte0)  from  appro,geslot,retjour where gsl_ind=10 and gsl_apcode=ap_code and ap_cd_pr=$prod and rj_appro=gsl_apcode and rj_date>=$today";
		# $sth=$dbh->prepare($query);
		# $sth->execute();
		# $pastouchdujour = $sth->fetchrow;
		# $stock{"pastouchdujour"}=$pastouchdujour/100;
	
	}
	$stock{"vol"}=$produit->{'pr_stvol'}/100;
	$query = "select sum(erdep_qte) from $client.errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$errdep=$sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
		
	
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	$stock{"pr_stre"}=$stock{"stre"}-$stock{"casse"}+$stock{"diff"}+$stock{"errdep"}; # stock comptable
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100; # entrepot
	if ($option2 eq "debug"){
		print "$prod<br>";
		print "stock compta:$stock{'pr_stre'}<br>";
		print "casse:$stock{'casse'}<br>";
		print "en vol:$stock{'vol'}<br>";
		print "diff :$stock{'diff'}<br>";
		print "errdep :$stock{'errdep'}<br>";
        	print "entrepot:$stock{'stock'}<br>";
        	print "non saisie:";
		print $non_sai/100;
		print "<br>";
		print "pas touche: $stock{'pastouch'}<br>";
      
		
	}	
	return(%stock);
}

;1
