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
  &save("create temporary table lta_tmp (pr_douane varchar(30),qte decimal(8,2) , valeur decimal(8,2), primary key (pr_douane))");
  $client=&get("select livh_base from dfc.livraison_h where livh_lta='$lta'");
  
  $frais_facture=&get("select sum(livh_cout) from dfc.livraison_h where livh_lta='$lta'")+0;
  $frais_facture*=655.957;
  $frais_facture=&xof($frais_facture);
  $frais+=$frais_facture;
	$query="select enh_no from $client.enthead,dfc.livraison_h where livh_id=enh_document and livh_lta='$lta'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($enh_no)=$sth->fetchrow_array){
	print "$enh_no<br>";
	}	
=pod 
 
	$query="select livh_facture,pr_douane,livb_qte_fac,livb_prix,pr_cd_pr,pr_desi,livh_cout from dfc.livraison_b,$client.produit,dfc.livraison_h where livh_lta='$lta' and livb_id=livh_id and livb_code=pr_cd_pr";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $total_qte=0;
  &switch_color();
  $run="nil";
  while (($facture,$pr_douane,$qte,$prix,$pr_cd_pr,$pr_desi,$cout)=$sth->fetchrow_array){
    if ($qte==0){
#     print "Bon de livraison:$livb_id $pr_cd_pr $pr_desi qte:0<br>";
    }
#     print "$facture;$pr_douane;$qte;$prix;$pr_cd_pr;$pr_desi;$cout<br>";
    $total_qte=$qte+&get("select qte from lta_tmp where pr_douane='$pr_douane'");
    $total_valeur=$qte*$prix+&get("select valeur from lta_tmp where pr_douane='$pr_douane'");
    if ($pr_douane eq "") {print "Tarif vide:$pr_cd_pr $pr_desi<br>";}
    &save("replace into lta_tmp values ('$pr_douane','$total_qte','$total_valeur')","af");
  }
  print "<table border=1><tr><th> N° NOMENCLATURE </th><th>Libelle</th><th> QTE </th><th> VALEUR </th></tr>";
  $total_valeur=&get("select sum(valeur) from lta_tmp");
  $total_valeur=$total_valeur*655.957;
  $query="select * from lta_tmp order by pr_douane";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  $total=0;
  while (($pr_douane,$qte,$valeur)=$sth2->fetchrow_array){
    if ($valeur==0){next;}
    $valeur=$valeur*655.957;
    $en_plus=$valeur*$frais/$total_valeur;
    $valeur+=$en_plus;
    $valeur=&xof($valeur);
    print "<tr><td>$pr_douane</td><td style=font-size:0.8em>";
	$chap_desi=&get("select chap_desi from dfc.chapitre where chap_douane='$pr_douane'","af");
	if ($chap_desi eq "") {$chap_desi="<span style=background:pink>Code douane inconnu</span>";}
	print "$chap_desi</td><td align=right>$qte</td><td align=right>$valeur</td></tr>";  
    $total+=$valeur;
  }
  print "</table>";
  print "Total:$total XOF";
  print "<br><br>Detail<br>";
  print "<table border=1><tr><th>produit</th><th> N° NOMENCLATURE </th><th>Libelle</th><th> QTE </th><th> VALEUR </th></tr>";
    $query="select pr_cd_pr,pr_desi,pr_douane,livb_qte_fac,livb_prix from dfc.livraison_b,$client.produit,dfc.livraison_h where livh_lta='$lta' and livb_id=livh_id and livb_code=pr_cd_pr order by pr_douane";
  $sth=$dbh->prepare($query);
  $sth->execute();
 while (($pr_cd_pr,$pr_desi,$pr_douane,$qte,$prix)=$sth->fetchrow_array){
	print "<tr><td>$pr_cd_pr $pr_desi</td><td>$pr_douane</td>";
	$chap_desi=&get("select chap_desi from dfc.chapitre where chap_douane='$pr_douane'","af");
	if ($chap_desi eq "") {$chap_desi="<span style=background:pink>Code douane inconnu</span>";}
	print "<td>$chap_desi</td>";
	print "<td>$qte</td><td>$prix</td></tr>";
	}	
 print "</table>"; 
=cut 
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
