$assurance=$html->param("assurance");
$transitaire=$html->param("transitaire");
$lta=$html->param("lta");
 
if ($action eq ""){
  print "<form>";
  &form_hidden();
  print "Lta <select name=lta>";
  $query="select distinct livh_lta from dfc.livraison_h order by livh_lta";
  if ($base_dbh ne "dfc"){
    $query="select distinct livh_lta from dfc.livraison_h where livh_base='$base_dbh' order by livh_lta";
  }
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($livh_lta)=$sth->fetchrow_array){
    print "<option value='$livh_lta'>$livh_lta</option>";
  }
  print "</select><br>";
  print "<input type=hidden name=action value=go>";
  print "<input type=submit></form>";
}
if ($action eq "maj"){
  &save("replace into dfc.lta value ('$lta','$transitaire','$assurance')");
  $action="go";
}

if ($action eq "go"){
  print "<h3>$lta</h3>";
  $query="select transitaire,assurance from dfc.lta where lta='$lta'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($transitaire,$assurance)=$sth->fetchrow_array;
  $transitaire+=0;
  $assurance+=0;
  print "<form>";
  &form_hidden();
  print "<br>Facture transitaire Eur<input type=text name=transitaire value=$transitaire><br>";
  print "<br>Assurance XOF<input type=text name=assurance value=$assurance><br>";
  $transitaire*=655.957;
  $transitaire=&xof($transitaire);
  $frais=$transitaire+$assurance;
 
  print "<input type=hidden name=action value=maj>";
  print "<input type=hidden name=lta value='$lta'>";
  print "<input type=submit value=maj></form>";
  &save("create temporary table lta_tmp (pr_cd_pr bigint(12),no_entree int(8),livh_four int(8),pr_desi varchar (30),pr_douane varchar(30),qte decimal(8,2) , valeur decimal(8,2), primary key (pr_cd_pr,no_entree))");
  $client=&get("select livh_base from dfc.livraison_h where livh_lta='$lta'");
  $frais_facture=&get("select sum(livh_cout) from dfc.livraison_h where livh_lta='$lta'")+0;
  $frais_facture*=655.957;
  $frais_facture=&xof($frais_facture);
  $frais+=$frais_facture;
 $query="select livh_id,livh_four,livh_facture,pr_douane,livb_qte_fac,livb_prix,pr_cd_pr,pr_desi from dfc.livraison_b,$client.produit,dfc.livraison_h where livh_lta='$lta' and livb_id=livh_id and livb_code=pr_cd_pr and livb_qte_fac>0";
  $sth=$dbh->prepare($query);  
  $sth->execute();
  $total_qte=0;
  &switch_color();
  $run="nil";
  while (($livh_id,$livh_four,$facture,$pr_douane,$qte,$prix,$pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
	$enh_no=&get("select enh_no from $client.enthead,dfc.livraison_b where livb_id=enh_document and livb_id='$livh_id' and livb_code='$pr_cd_pr'");
	$total_valeur=$qte*$prix;
    &save("replace into lta_tmp values ('$pr_cd_pr','$enh_no','$livh_four',\"$pr_desi\",'$pr_douane','$qte','$total_valeur')","af");
  }
  print "<table border=1 cellspacing=0><tr><th>Fournisseur</th><th>No entree</th><th>Produit</th><th>N° NOMENCLATURE</th><th>Libelle</th><th>QTE</th><th>VALEUR</th></tr>";

  $total_valeur=&get("select sum(valeur) from lta_tmp");
  $total_valeur=$total_valeur*655.957;
  $query="select * from lta_tmp order by pr_douane,livh_four";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  $total=0;
  while (($pr_cd_pr,$enh_no,$livh_four,$pr_desi,$pr_douane,$qte,$valeur)=$sth2->fetchrow_array){
	if (($pr_douane ne $douane)&&($douane ne "")){
		print "<tr><th colspan=5>Total $douane</th><th>$total_qte_int</th><th>$total_int</th></tr>";
		$total_int=0;
		$total_qte_int=0;
	}
    $valeur=$valeur*655.957;
    if ($total_valeur>0){$en_plus=$valeur*$frais/$total_valeur;}
    $valeur+=$en_plus;
    $valeur=&xof($valeur);
	($fo_desi)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$livh_four'"));
	$pr_douane=substr($pr_douane,0,8);
    print "<tr><td>$fo_desi</td><td>$enh_no</td><td style=font-size:0.8em>$pr_cd_pr $pr_desi</td><td>$pr_douane</td><td style=font-size:0.8em>";
	$chap_desi=&get("select chap_desi from dfc.chapitre where chap_douane='$pr_douane'","af");
	if ($chap_desi eq "") {$chap_desi="<span style=background:pink>Code douane inconnu</span>";}
	print "$chap_desi</td><td align=right>$qte</td><td align=right>$valeur</td></tr>";  
    $total+=$valeur;
	$total_int+=$valeur;
	$total_qte_int+=$qte;
	$douane=$pr_douane;
	
  }
print "<tr><th colspan=5>Total $douane</th><th>$total_qte_int</th><th>$total_int</th></tr>";
	$total_int=0;
	$total_qte_int=0;
  print "</table>";
  print "Total:$total XOF";
} 

sub xof(){
 my $valeur=$_[0];
 $valeur=int($valeur/1000)*1000;
 my $plus=0;
 if (($valeur%1000) >200){$plus=500;}
 elsif (($valeur%1000) >700){$plus=1000;}
 $valeur+=$plus;
 return($valeur) 
}

;1
