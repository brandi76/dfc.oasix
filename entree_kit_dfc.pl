$four=$html->param("four");
$date=$html->param("date");
$liv_id=$html->param("liv_id");
$base=$html->param("base");
$code=$html->param("code");
$qte=$html->param("qte");
$qte_fac=$html->param("qte_fac");
$qte_liv=$html->param("qte_liv");
$qte_ent=$html->param("qte_ent");
$qte=$html->param("qte");
$prix=$html->param("prix");
$option=$html->param("option");
$blabla=$html->param("blabla");
$lta=$html->param("lta");
$frais=$html->param("frais");
$frais_desi=$html->param("frais_desi");
push(@bases_client,"formation");
if (grep /\//,$date){
  ($j,$m,$a)=split(/\//,$date);
  $date="$a-$m-$j";
}  
  
if ($action eq "sup"){
  &save("delete from dfc.livraison_h where livh_id='$liv_id' limit 1");
  $base=&get("select livh_base from livraison_h where livh_is='$liv_id'");
  &save("update $base.commande set com2_liv=0 where com2_liv='$liv_id'");
  print "<p style=backgroundcolor:pink> $liv_id supprimé</p>";
  $action="";
}

if ($action eq "modif_cde"){
  &save("update dfc.livraison_b set livb_qte_fac=$qte_fac,livb_qte_liv=$qte_liv,livb_qte_ent=$qte_ent,livb_prix='$prix' where livb_id='$liv_id' and livb_code='$code'");
  if (($qte_fac==0)&&($qte_liv==0)&&($qte_ent==0)){
      &save("delete from dfc.livraison_b where livb_id='$liv_id' and livb_code='$code'");
      &save("update $base.commande set com2_liv=0 where com2_liv='$liv_id'");
  } 
  if (($base_dbh eq "dfc")&&(&liv_etat() eq "")){
    &save("update dfc.livraison_b set livb_qte_liv=livb_qte_fac where livb_id='$liv_id' and livb_code='$code'");
  }
  $action="voir";
}
if ($action eq "ajout_cde"){
  &save("insert ignore into dfc.livraison_b values ('$liv_id','$code','$qte','$qte','0','$prix')");
  $action="voir";
}      
if ($action eq "modif_h"){
  &save("update dfc.livraison_h set livh_blabla=\"$blabla\",livh_cout='$frais',livh_cout_desi=\"$frais_desi\",livh_facture=\"$facture\",livh_lta=\"$lta\" where livh_id='$liv_id'");
  $action="voir";
}      

if ($action eq "creer") {
  $ok=0;
  $query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_cd_fo='$four' order by com2_no,com2_cd_pr"; 
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
      $ref=$com2_no.":".$com2_cd_pr;
      if ($html->param("$ref") eq "on"){$ok=1;}
  }    
  if ($ok==0){
    print "<p style=background:pink>Aucun produit selectionné</p>";
    $action="go";
  }
  else {
    if ($date eq ""){$date=&get("select curdate()");}
    &save("insert into dfc.livraison_h (livh_base,livh_date,livh_four,livh_user) values ('$base','$date','$four','$user')","af");
    $liv_id=&get("SELECT LAST_INSERT_ID() FROM dfc.livraison_h");
    $query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_cd_fo='$four' and com2_liv=0 order by com2_no,com2_cd_pr"; 
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
	$ref=$com2_no.":".$com2_cd_pr;
	if ($html->param("$ref") eq "on"){
	    $check=&get("select count(*) from dfc.livraison_b where livb_id=$liv_id and livb_code=$com2_cd_pr")+0;
	    if ($check==0){
	      &save("insert into dfc.livraison_b values ('$liv_id','$com2_cd_pr','$com2_qte','$com2_qte','0','$com2_prac')");
	    }
	    else
	    {
	      &save("update dfc.livraison_b set liv_qte_liv=liv_qte_liv+$com2_qte,liv_qte_fac=liv_qte_fac+$com2_qte where livb_id='$liv_id' and livb_cd_pr='$com2_cd_pr'");
	    }
	    &save("update $base.commande set com2_liv='$liv_id' where com2_no='$com2_no' and com2_cd_pr='$com2_cd_pr'");
	}
    }
    $action="voir";
  }
}

if (($action eq "go")||($action eq "refresh")) {
	$ok=0;
	&save("replace into retour value('$ENV{\"REMOTE_USER\"}','$ENV{\"QUERY_STRING\"}')");
	$fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
	($fo_nom)=split(/\*/,$fo_add);
	print "Base:$base fournisseur:$four $fo_nom <br>";
	$color="lavender";
	print "<form>";
	&form_hidden();
	$query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_cd_fo='$four' order by com2_no,com2_cd_pr"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	 if ($sth->rows){
	  print "<table border=1 cellspacing=0><tr><th>No cde</th><th>Code</th><th>Produit</th><th>Qte</th><th>Prix<th>Valeur</th><th>Action</th></tr>";
	  while (($com2_no,$com2_cd_pr,$com2_qte,$com2_prac)=$sth->fetchrow_array){
	    if ($com2_no ne $com2_no_tamp){if ($color eq "lavender"){$color="white";}else{$color="lavender";}$com2_no_tamp=$com2_no;}
	    $com2_qte+=0;
	    $valeur=$com2_qte*$com2_prac;
	    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$com2_cd_pr'");
	    $ref=$com2_no.":".$com2_cd_pr;
	    print "<tr bgcolor=$color><td>$com2_no</td><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right>$com2_qte</td><td align=right>$com2_prac</td><td align=right>$valeur</td><td><input type=checkbox name=$ref ";
	    $check="";
	    if ($html->param("$ref") eq "on"){$ref="checked";}
	    if ($html->param("coche$com2_no") eq "on"){$ref="checked";}
	    if ($html->param("decoche$com2_o") eq "on"){$ref="";}
	    print "$ref></td></tr>";
	  }
	  print "</table>";
	  $query="select distinct(com2_no) from $base.commande where com2_cd_fo='$four' order by com2_no"; 
	  $sth=$dbh->prepare($query);
	  $sth->execute();
	  while (($com2_no)=$sth->fetchrow_array){
	    print "Tout Cocher $com2_no <input type=checkbox name=coche$com2_no> Tout Decocher $com2_no <input type=checkbox name=decoche$com2_no><br>";
	  }
	  print "<input type=hidden name=base value=$base>";
	  print "<input type=hidden name=four value=$four>";
	  print "<input type=submit name=action value='refresh'>";
	  print "<br><br><input type=hidden name=action value=creer>";
	  print "<br>Date de livraison <input type=texte id=datepicker name=date size=5> ";
	  print "<input type=submit value='Creer le document de livraison'>";
	  print "</form>";
	}
	else
	{
	  print "<div style=background:lavender>Aucun resultat à votre demande</div>";
	}
	print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
}

if ($action eq ""){
	&save("create temporary table four_tmp (code int(8),nom varchar(30),primary key (code))");
	foreach $base (@bases_client){
	  &save("insert ignore into four_tmp (select distinct pr_four,fo2_add from $base.entbody,$base.produit,$base.fournis where enb_cdpr=pr_cd_pr and fo2_cd_fo=pr_four)","af"); 
	}
	print "<div style=position:absolute;margin:20px>";
	print "<div class=titre>Creation des documents de livraison</div><br>";
	print "<form name=maform>";
	&form_hidden();
	if ($base_dbh eq "dfc"){
	  print "<select name=base>";
	  foreach $base (@bases_client){
	    if ($base eq "dfc"){next;}
	    print "<option value=$base>$base</option>";
	  }
	  print "</select>";
	}
	else {print "<input type=hidden name=base value='$base_dbh'>";}
	print "Fournisseur <select name=four><option value=Tous>Tous</option>";
	$query="select code,nom from four_tmp order by nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$nom)=$sth->fetchrow_array){
		  ($nom)=split(/\*/,$nom);
	      print "<option value=$code>$nom</code>";
	}
	print "</select>";
	print "<br><br><input type=hidden name=action value=go>";
	print "<br><br><input type=submit></form>"; 
	print "<br><br> Liste des bons de livraisons en cours<br>";
	print "<table border=1 cellsapcing=0><tr><th>Base</th><th>User</th><th>No</th><th>Date</th><th>Fournisseur</th><th>Montant</th><th>Facture</th><th>LTA</th><th colspan=3>Action</th></tr>";
	$query="select * from dfc.livraison_h order by livh_id desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_user,$livh_lta,$livh_user)=$sth->fetchrow_array){
	  print "<tr>";
	  $fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	  ($fo_nom)=split(/\*/,$fo_add);
	  $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	  $montant=int($montant*100)/100;
	  if ($livh_facture eq ""){$livh_facture="&nbsp;";}
	  if ($livh_lta eq ""){$livh_lta="&nbsp;";}
	  print "<td>$livh_base</td><td>$livh_user</td><td>$livh_id</td><td>$livh_date</td><td>$livh_four $fo_nom</td><td>$montant</td><td>$livh_facture</td><td>$livh_lta</td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=voir&liv_id=$livh_id><img src=/images/b_edit.png border=0 title=\"Modifier\"></a></td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=entree&liv_id=$livh_id><img src=/images/b_in.png border=0 title=\"Faire l'entrée\"></a></td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&liv_id=$livh_id><img src=/images/b_drop.png border=0 title=\"Supprimer\" onclick=\"return confirm('Etes vous sur de vouloir supprimer ?')\"></a></td>";
	 print "</tr>";
	}
	print "</table>";
	print "</div>";
}

if ($action eq "voir"){
   $query="select livh_base,livh_four,livh_cout,livh_cout_desi,livh_date,livh_blabla,livh_four,livh_facture,livh_lta from dfc.livraison_h where livh_id='$liv_id'";
   $sth2=$dbh->prepare($query);
   $sth2->execute();
   ($base,$livh_four,$livh_cout,$livh_cout_desi,$livh_date,$livh_blabla,$four,$livh_facture,$livh_lta)=$sth2->fetchrow_array;
   $fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
   ($fo_nom)=split(/\*/,$fo_add);
   print "<div class=titre>$base $four $fo_nom</div>";
   print "<strong>Livraison no:$liv_id du $livh_date </strong><br>";
   
   $query="select pr_cd_pr,pr_desi,livb_qte_fac,livb_qte_liv,livb_qte_ent,livb_prix from dfc.livraison_b,$base.produit where pr_cd_pr=livb_code and livb_id='$liv_id'"; 
   $sth=$dbh->prepare($query);
   $sth->execute();
   print "<table border=1 cellspacing=0>";
   print "<tr><th colspan=2>Produit</th><th>Qte Fac</th><th>Qte Liv</th><th>Qte Ent</th><th>Prix</th><th>Valeur</th></tr>";

   while (($prod,$pr_desi,$qte_fac,$qte_liv,$qte_ent,$prix)=$sth->fetchrow_array){
	 $qte_liv+=0;
	 $qte_fac+=0;
	 $qte_ent+=0;
	 
	 $valeur=$qte_liv*$prix;
	 print "<tr><td>$prod</td><td>$pr_desi</td>";
	 if ($option eq $prod){
	      &set_in();
	      print "<form>";
	      &form_hidden();
	      if ($in_fac) {print "<td align=right><input type=text name=qte_fac value=$qte_fac size=3 style=background:yellow></td>";}else{print "<td align=right bgcolor=gray><input type=hidden name=qte_fac value=$qte_fac>$qte_fac</td>";} 
	      if ($in_liv) {print "<td align=right><input type=text name=qte_liv value=$qte_liv size=3 style=background:yellow></td>";}else{print "<td align=right bgcolor=gray><input type=hidden name=qte_liv value=$qte_liv>$qte_liv</td>";} 
	      if ($in_ent) {print "<td align=right><input type=text name=qte_fac value=$qte_fac size=3 style=background:yellow></td>";}else{print "<td align=right bgcolor=gray><input type=hidden name=qte_ent value=$qte_ent>$qte_ent</td>";} 
	      if ($in_prix) {print "<td align=right><input type=text name=prix value=$prix size=3 style=background:yellow></td>";}else{print "<td align=right><input type=hidden name=prix value=$prix>$prix</td>";} 
	      print "<td><input type=submit value=maj></td>";
	      print "<input type=hidden name=action value=modif_cde>";
	      print "<input type=hidden name=liv_id value=$liv_id>";
	      print "<input type=hidden name=code value=$prod>";
	      print "</form>";
	 }
	 else{
	  print "<td align=right>$qte_fac</td>";
	  print "<td align=right bgcolor=$color>$qte_liv</td>";
	  print "<td align=right bgcolor=$color>$qte_ent</td>";
	  print "<td align=right>$prix</td>";
	  print "<td align=right>$valeur</td>";
	  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=voir&option=$prod&liv_id=$liv_id&base=$base><img border=0 src=../../images/b_edit.png title='Modifier'></a></td>";
	 }
	 print "</tr>"; 
	 $total+=$valeur;
   }
    print "</table>";
    print "<strong>Total:$total";
    if ($livh_cout+0!=0){
     $total+=$livh_cout;
     print " Total avec frais:$total";
    }
    print "</strong><br>";
    print "<hr></hr><br>";
    print "<form>";
    &form_hidden();
    print "<select name=code>";
    print "<option></option>";
    $query="select pr_cd_pr,pr_desi from $base.produit where pr_four='$four' and pr_cd_pr not in (select livb_code from dfc.livraison_b where livb_id='$liv_id')";
    print $query;
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
      print "<option value=$pr_cd_pr>$pr_cd_pr $pr_desi</option>";
    }
    print "</select><br>";
    print "Qte <input type=text name=qte size=3>";
    print " Prix <input type=text name=prix size=3>";
    print "<input type=hidden name=action value=ajout_cde>";
    print "<input type=hidden name=base value=$base>";
    print "<input type=hidden name=liv_id value=$liv_id>";
    print " <input type=submit value='Ajouter un produit'></form>"; 
    print "<form>";
    &form_hidden();
    print "Frais <input type=text name=prix size=4 name=frais value=$livh_cout>";
    print "Libellé <input type=text name=frais_desi value='$livh_cout_desi'><br>";
    print "<Textarea cols=\"160\" rows=\"3\" placeholder=commentaire name=blabla>$livh_blabla</textarea><br>";
    $color="white";
    if ($livh_facture eq ""){$color="pink";}
    print "No Facture <input type=text name=facture value='$livh_facture' style=background:$color size=30><br>";
    print "No LTA <input type=text name=lta value='$livh_lta' size=30><br>";
    print "<input type=hidden name=action value=modif_h>";
    print "<input type=hidden name=liv_id value='$liv_id'>";
    print "<input type=submit></form>"; 
#     $query=&get("select query from retour where user='$ENV{\"REMOTE_USER\"}'");
#     print "<br><br><a href=?$query>Retour</a>";
    print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
 
}
if ($action eq "entree"){
  $query="select livh_base,livh_four,livh_cout,livh_cout_desi,livh_date,livh_blabla,livh_four,livh_facture from dfc.livraison_h where livh_id='$liv_id'";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  ($base,$livh_four,$livh_cout,$livh_cout_desi,$livh_date,$livh_blabla,$four,$livh_facture)=$sth2->fetchrow_array;
  $fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$four' ");
  ($fo_nom)=split(/\*/,$fo_add);
  print "<div class=titre>$base $four $fo_nom</div>";
  print "<strong>Livraison no:$liv_id du $livh_date </strong><br>";
  
  $query="select pr_cd_pr,pr_desi,livb_qte_fac,livb_qte_liv,livb_qte_ent,livb_prix from dfc.livraison_b,$base.produit where pr_cd_pr=livb_code and livb_id='$liv_id'"; 
  $sth=$dbh->prepare($query);
  $sth->execute();
  print "<table border=1 cellspacing=0>";
  print "<tr><th colspan=2>Produit</th><th>Qte Liv</th><th>Prix</th><th>Valeur</th></tr>";
  while (($prod,$pr_desi,$qte_fac,$qte_liv,$qte_ent,$prix)=$sth->fetchrow_array){
    $qte_liv+=0;
    $qte_fac+=0;
    $qte_ent+=0;
    $valeur=$qte_liv*$prix;
    print "<tr><td>$prod</td><td>$pr_desi</td>";
    print "<td align=right bgcolor=$color>$qte_liv</td>";
    print "<td align=right>$prix</td>";
    print "<td align=right>$valeur</td>";
    print "</tr>"; 
    $total+=$valeur;
  }
  print "</table>";
  print "<strong>Total:$total";
  if ($livh_cout+0!=0){
    $total+=$livh_cout;
    print " Total avec frais:$total";
  }
  print "</strong><br>";
  if ($base_dbh ne "dfc"){
    print "<form>";
    &form_hidden();
    print "<input type=hidden name=action value=ok_entree>";
    print "<input type=hidden name=liv_id value='$liv_id'>";
    print "<input type=submit value=\"faire l'entrée\"></form>"; 
  }
  else
  {
    print "<p style=background:lavender>L' entrée doit se faire sur chaque base respective</p>";
  }
   print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";
}

if ($action eq "ok_entree"){
	$date=`/bin/date +%d/%m/%y`;
	$dateenso=`/bin/date +%Y%m%d`;
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an=`/bin/date '+%Y'`;
	chop($jour);
	chop($mois);
	chop($an);
	chop($dateenso);
	chop($date);
	$datejl=nb_jour($jour,$mois,$an);
	&save("update atadsql set dt_no=dt_no+1 where dt_cd_dt=207");
	$no=&get("select dt_no from atadsql where dt_cd_dt=207");
	print "Date d'entree:$date<br>";
	print "Numero d'entree:$no<br>";
	&save("replace into enthead values ('$no','$datejl','$scelle','$provenance','$liv_id','$lieu')");
	$total=0;
	$query="select livb_code,livb_qte_liv,livb_prix from dfc.livraison_b where livb_id='$liv_id' and livb_ent=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if ($sth->rows) {
	  print "<table cellspacing=0 border=1><tr><th>code produit</th><th>produit</th><th>Prix</th><th>Valeur</th><th>qte à entrer</th><th>stock restant</th><th>check</th></tr>";
	  while (($code,$qte,$prix)=$sth->fetchrow_array){
	    print "<tr><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td><td align=right>$prix</td>";
	    $val=$prix*$qte;
	    $total+=$val;
	    print "<td align=right>$val</td><td align=right>";
	    &carton($code,$qte);
	    print "</td>";
	    $qte*=100;
	    &save("replace into enso values ('$code','$no','$dateenso','0','$qte','10')");
	    &save("update produit set pr_stre=pr_stre+$qte where pr_cd_pr='$code'");
	    # &save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
	    &save("replace into entbody values ('$no','$code','$qte')");
	    &save("update dfc.livraison_b set livb_ent=livb_liv where livb_id=$liv_id and livb_code=$code");
	    %stock=&stock($code,"","");
	    $pr_stre=$stock{"stock"};
	    print "<td>";
	    &carton($code,$pr_stre);
	    print "</td></tr>";
	    $qte*=100;
	    $query="select * from commande where com2_liv='$liv_id' and com2_cd_pr='$code'";
	    $sth2=$dbh->prepare($query);
	    $sth2->execute();
	    while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$com2_qte,$com2_prac,$com2_type,$com2_date,$com2_delai,$com2_liv)=$sth2->fetchrow_array){
	      if ($qte<=0){last;}
	      if ($qte>=$com2_qte){
	   	    &save("delete from commande where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr");
		    &save("replace into commandearch values ('$com2_no','$com2_cd_fo','$com2_cd_pr','$com2_qte','$com2_prac','0','$com2_date','0')");
	      }
	      else
	      {
		    &save("update commande set com2_qte=com2_qte-$qte,com2_liv=0 where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr");
	      }
	      $qte-=$com2_qte;
	    }
	  }
	  print "</table><br>";
	  print "Total :".&deci($total)."<br>";
	}
	else
	{ print "<p style=background:lavender>Aucun produit pour votre demande, certainement que l'entrée a déjà été faite";}
}

sub set_in{
  $in_fac=0;
  $in_prix=0;
  $in_liv=0;
  $in_ent=0;
  if ($base_dbh eq "dfc"){
    $in_fac=1;
    $in_prix=1;
  }
  else
  {
    $in_liv=1;
    $in_ent=1;
  }
}
sub liv_etat{
  my($mess)="";
  $check=&get("select sum(livb_qte_ent) from dfc.livraison_b where livb_id='$liv_id'")+0;
  if ($check!=0){$mess="entree";}
  return($mess);
}  
;1