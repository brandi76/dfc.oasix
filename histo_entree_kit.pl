require "./src/connect.src";

$user=$ENV{"REMOTE_USER"};
$four=$html->param("four");
$action=$html->param("action");
$pr_cd_pr=$html->param("pr_cd_pr");
$no=$html->param("no");
if ($pr_cd_pr eq ""){$pr_cd_pr="pr_cd_pr";}
if ($no eq ""){$no="enh_no";}
if ($four eq ""){$four="pr_four";}
print "<center>";

if ($action eq "modifi") {
#    print "<div class=titre>$pr_cd_pr $four $no</div><br>";
   $query="select enh_no,pr_four,pr_cd_pr,pr_desi,enh_date,enb_quantite/100,pr_prac from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and enh_no=$no and pr_four=$four and pr_cd_pr=$pr_cd_pr order by enh_date desc"; 
   $sth=$dbh->prepare($query);
   $sth->execute();
   while (($no_cde,$pr_four,$prod,$pr_desi,$enh_date,$qte,$pr_prac)=$sth->fetchrow_array){
		$pr_prac=$pr_prac/100;
		$ref=$no_cde."_".$prod;
	  $qte_new=$html->param("$ref");
	  if ($qte_new!=$qte){
 		 $es_qte_en=&get("select es_qte_en from enso where es_cd_pr='$prod' and es_no_do='$no_cde'")/100;
		 if ($es_qte_en != $qte) {
			print "<span style=color:red> pr_four,$prod,$pr_desi,$qte $qte_new impossible voir sylvain </span><br />";
		 }			
		 $diff=($qte_new-$qte)*100;
		 &save("update produit set pr_stre=pr_stre+$diff where pr_cd_pr='$prod'");
		 &save("update enso set es_qte_en=es_qte_en+$diff where es_cd_pr='$prod' and es_no_do='$no_cde'");
		 &save("update entbody  set enb_quantite='$qte_new'*100 where enb_no='$no_cde' and enb_cdpr='$prod'");
		 print "$pr_four,$prod,$pr_desi,$qte_new  modifié<br>";
	  }
   }
   $action="creation";
}


if ($action eq ""){
	print "<div class=titre>Historique des entrées</div><br>";
	print "<form>";
	&form_hidden();
    print "<br>Fournisseur<br><select name=four><option value=''></option>";
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
	$sth2->execute;
	while (my @four = $sth2->fetchrow_array) {
		next if $four eq $four[0];
		($four[1])=split(/\*/,$four[1]);
		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
	}
	
	print "</select>";
	print "<br> ou Code produit:<input type=text name=pr_cd_pr><br>";
	print "<br> ou No entree:<input type=text name=no><br>";
	print "<br><input type=hidden name=action value=creation><input type=submit value='Historique'></form><br><br>"; 
	$query="select distinct pr_four,enh_date,enh_no from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no order by enh_date desc limit 50"; 
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table><caption> 50 dernieres entrées</caption>";
	while (($pr_four,$enh_date,$enh_no)=$sth->fetchrow_array){
		print "<tr><td><b>$enh_no</b>";
		print &julian($enh_date);
		print " $pr_four ";
		print &get("select fo2_add from fournis where fo2_cd_fo='$pr_four'");
		print "</td></tr>";
	}
	print "</table>";
}
if ($action eq "creation") {
   print "<div class=titre>$no</div><br>";
   $query="select enh_no,pr_four,pr_cd_pr,pr_desi,enh_date,enb_quantite/100,pr_prac from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and enh_no=$no and pr_four=$four and pr_cd_pr=$pr_cd_pr order by enh_date desc"; 
   # print $query;
   $sth=$dbh->prepare($query);
   $sth->execute();
   print "<table border=1 cellspacing=0>";
   print "<tr><th>no ent</th><th>Four</th><th colspan=2>Produit</th><th>Date</th><th>Qte</th><th>Prac</th></tr>";

   while (($no_cde,$pr_four,$prod,$pr_desi,$enh_date,$qte,$pr_prac)=$sth->fetchrow_array){
	 $pr_prac=$pr_prac/100;
	 print &ligne_tab("","<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=creation&no=$no_cde>$no_cde</a>",$pr_four,$prod,$pr_desi,&julian($enh_date),$qte,$pr_prac);
	 $total+=$qte*$pr_prac;
   }
   print "</table>";
   print "Total:$total";
   $bon_de_livraison=&get("select enh_document from enthead where enh_no=$no");
   print "<bR>Bon de livraison:$bon_de_livraison<br>";
	if (($user eq "philippe")||($user eq "sylvain")||($user eq "daniel")) {
	   print "<form>";
	   &form_hidden();
	   print "<input type=hidden name=action value=modifier>";
	   print "<input type=hidden name=no value=$no>";
	   print "<input type=hidden name=four value=$four>";
	   print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
 	   print "<input type=submit value=modifier style=background-color:pink;>";
	   print "</form>";
   }
}

if ($action eq "modifier") {
   	print "<form>";

   print "<div class=titre>$pr_cd_pr $four $no</div><br>";
	$query="select enh_no,pr_four,pr_cd_pr,pr_desi,enh_date,enb_quantite/100,pr_prac from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and enh_no=$no and pr_four=$four and pr_cd_pr=$pr_cd_pr order by enh_date desc"; 
    # print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0>";
	print "<tr><th>no ent</th><th>Four</th><th colspan=2>Produit</th><th>Date</th><th>Qte</th><th>Prac</th></tr>";

	while (($no_cde,$pr_four,$prod,$pr_desi,$enh_date,$qte,$pr_prac)=$sth->fetchrow_array){
		$pr_prac=$pr_prac/100;
		$ref=$no_cde."_".$prod;
		print &ligne_tab("","$no_cde",$pr_four,$prod,$pr_desi,&julian($enh_date),"<input type=text name=$ref value=$qte>",$pr_prac);
		$total+=$qte*$pr_prac;
	}
	print "</table>";
	print "Total:$total";
	&form_hidden();
	print "<input type=hidden name=action value=modifi>";
	print "<input type=hidden name=no value=$no>";
	print "<input type=hidden name=four value=$four>";
   print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
 	print "<input type=submit>";
	print "</form>";
}

;1	
# -E historique des entrées fly 08/06	
