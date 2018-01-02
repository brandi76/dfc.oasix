$foir=$html->param("four");
$no=$html->param("no");
$base=$html->param("base");
$code=$html->param("code");
$qte=$html->param("qte");
$prix=$html->param("prix");
$option=$html->param("option");
$blabla=$html->param("blabla");

if ($action eq "modif_cde"){
  &save("update $base.commande set com2_qte=$qte*100, com2_prac='$prix' where com2_no='$no' and com2_cd_pr='$code'");
  if ($qte==0){
   $check=&get("select com2_qte from $base.commande where com2_no='$no' and com2_cd_pr='$code'")+0;
   if ($check==0){
      &save("delete from $base.commande where com2_no='$no' and com2_cd_pr='$code'");
   }
  } 
  $action="voir";
}
if ($action eq "ajout_cde"){
  &save("insert ignore into $base.commande values ('$no','$foir_choisi','$code','$qte','$prix','',curdate(),'','','')");
  $action="voir";
}      
if ($action eq "ajout_montant"){
  &save("replace into enthfacture values ('$base','$no','plus','$prix',\"$blabla\")");
  $action="voir";
}      
if ($action eq "ajout_blabla"){
  &save("replace into enthfacture values ('$base','$no','blabla','0',\"$blabla\")");
  $action="voir";
}      
if ($action eq "ajout_ref"){
  &save("replace into enthfacture values ('$base','$no','ref_fournisseur','0',\"$blabla\")");
  $action="voir";
}      

if ($action eq "go") {
	$ok=0;
	&save("replace into retour value('$ENV{\"REMOTE_USER\"}','$ENV{\"QUERY_STRING\"}')");
	$fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$foir' ");
	($fo_nom)=split(/\*/,$fo_add);
	print "Base:$base fournisseur:$foir $fo_nom <br>";
	$color="lavender";
	print "<form>";
	&form_hidden();
	$query="select com2_no,com2_cd_pr,com2_qte/100,com2_prac from $base.commande where com2_cd_fo='$foir' order by com2_no,com2_cd_pr"; 
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
	    if ($html->param("coche$no") eq "on"){$ref="checked";}
	    if ($html->param("decoche$no") eq "on"){$ref="";}
	    print "$ref></td></tr>";
	  }
	  print "</table>";
	  $query="select distinct(com2_no) from $base.commande where com2_cd_fo='$foir' order by com2_no"; 
	  $sth=$dbh->prepare($query);
	  $sth->execute();
	  while (($com2_no)=$sth->fetchrow_array){
	    print "Tout Cocher $com2_no <input type=checkbox name=coche$no> Tout Decocher $com2_no <input type=checkbox name=decoche$no><br>";
	  }
	  print "<input type=hidden name=base value=$base>";
	  print "<input type=hidden name=four value=$foir>";
	  print "<input type=hidden name=action value=go>";
	  print "<input type=submit>";
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
	print "<div class=titre>Creation des documents 'import'</div><br>";
	print "<form name=maform>";
	&form_hidden();
	print "<select name=base>";
	foreach $base (@bases_client){
	  if ($base eq "dfc"){next;}
	  print "<option value=$base>$base</option>";
	}
	print "</select>";
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
	print "<br><br> Liste des importations en attente<br>";
	$query="select enfh_id,enfh_base,enfh_fo,enfh_date from enthfacture where enfh_arrive='0000-00-00'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($enfh_id,$base,$enfh_fo,$enfh_date)=$sth->fetchrow_array){
	  print "$enfh_id,$base,$enfh_fo,$enfh_date";
	  print "<br>";
	}
	print "</div>";
	
}

if ($action eq "voir"){
   &enhfacture();
   $fo_add=&get("select fo2_add from $base.fournis where fo2_cd_fo='$foir_choisi' ");
   ($fo_nom)=split(/\*/,$fo_add);
   print "$base<br>";
   print "<div class=titre>$foir $fo_nom</div>";
   print "<strong>Commande no:$no</strong><br>";
   
   $query="select pr_cd_pr,pr_desi,com2_qte/100,com2_prac from $base.commande,$base.produit where com2_cd_pr=pr_cd_pr and com2_no=$no"; 
   $sth=$dbh->prepare($query);
   $sth->execute();
   print "<table border=1 cellspacing=0>";
   print "<tr><th colspan=2>Produit</th><th>Qte cde</th><th>Prac</th><th>Valeur</th></tr>";

   while (($prod,$pr_desi,$qte_cde,$prac)=$sth->fetchrow_array){
	 $qte_cde+=0;
	 $valeur=$qte_cde*$prac;
	 print "<tr><td>$prod</td><td>$pr_desi</td>";
	 if ($option eq $prod){
	      print "<form>";
	      &form_hidden();
	      print "<td align=right><input type=text name=qte value=$qte_cde size=3 style=background:yellow></td>";
	      print "<td align=right><input type=text name=prix value=$prac size=3 style=background:yellow></td>";
	      print "<td><input type=submit value=maj></td>";
	      print "<input type=hidden name=four_choisi value=$foir_choisi>";
	      print "<input type=hidden name=action value=modif_cde>";
	      print "<input type=hidden name=base value=$base>";
	      print "<input type=hidden name=no value=$no>";
	      print "<input type=hidden name=code value=$prod>";
	      print "</form>";
	 }
	 else{
	  print "<td align=right>$qte_cde</td>";
	  print "<td align=right>$prac</td>";
	  print "<td align=right>$valeur</td>";
	 }
	 print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=voir&option=$prod&no=$no&base=$base&four_choisi=$foir_choisi><img border=0 src=../../images/b_edit.png title='Modifier'></a></td>";
	 print "</tr>"; 
	 $total+=$valeur;
   }
    print "</table>";
    print "<strong>Total:$total</strong><br>";
    print "<hr></hr><br>";
    print "<form>";
    &form_hidden();
    print "<select name=code>";
    print "<option></option>";
    $query="select pr_cd_pr,pr_desi from $base.produit where pr_four='$foir_choisi' and pr_cd_pr not in (select enf_code from entfacture where enf_no='$no' and enf_base='$base')";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
      print "<option value=$pr_cd_pr>$pr_cd_pr $pr_desi</option>";
    }
    print "</select>";
    print "Qte <input type=text name=qte size=3>";
    print " Prix <input type=text name=prix size=3>";
    print "<input type=hidden name=four_choisi value='$foir_choisi'>";
    print "<input type=hidden name=action value=ajout_cde>";
    print "<input type=hidden name=base value=$base>";
    print "<input type=hidden name=no value=$no>";
    print " <input type=submit value='Ajouter un produit'></form>"; 
    print "<form>";
    &form_hidden();
    print "Montant <input type=text name=prix size=4 name=prix value=$montant_plus>";
    print "Libellé <input type=text name=blabla value='$blabla_plus'>";
    print "<input type=hidden name=four_choisi value='$foir_choisi'>";
    print "<input type=hidden name=action value=ajout_montant>";
    print "<input type=hidden name=base value=$base>";
    print "<input type=hidden name=no value=$no>";
    print " <input type=submit value='Ajouter un cout'></form>"; 
    if ($montant_plus+0!=0){
     $total+=$montant_plus;
     print "<strong>Total avec ecart:$total</strong><br><br>";
    }
    print "<form>";
    &form_hidden();
    print "<Textarea cols=\"80\" rows=\"4\" placeholder=commentaire name=blabla>$blabla</textarea>";
    print "<input type=hidden name=four_choisi value='$foir_choisi'>";
    print "<input type=hidden name=action value=ajout_blabla>";
    print "<input type=hidden name=base value=$base>";
    print "<input type=hidden name=no value=$no>";
    print " <input type=submit value='Ajouter un commentaire'></form>"; 
    print "<form>";
    &form_hidden();
    $color="white";
    if ($ref_fournisseur eq ""){$color="pink";}
    print "<input type=text name=blabla value='$ref_fournisseur' style=background:$color size=50>";
    print "<input type=hidden name=four_choisi value='$foir_choisi'>";
    print "<input type=hidden name=action value=ajout_ref>";
    print "<input type=hidden name=base value=$base>";
    print "<input type=hidden name=no value=$no>";
    print "<input type=submit value='Ajouter la reference fournisseur'></form>"; 
    $query=&get("select query from retour where user='$ENV{\"REMOTE_USER\"}'");
    print "<br><br><a href=?$query>Retour</a>";
}
sub enhfacture {
   $montant_plus="";
   $blabla_plus="";
   $blabla="";
   $ref_fournisseur="";
   $query="select enfh_prix,enfh_blabla from enthfacture where enfh_base='$base' and enfh_no='$no' and enfh_type='plus'";
   $sth2=$dbh->prepare($query);
   $sth2->execute();
   ($montant_plus,$blabla_plus)=$sth2->fetchrow_array;
   $query="select enfh_blabla from enthfacture where enfh_base='$base' and enfh_no='$no' and enfh_type='blabla'";
   $sth2=$dbh->prepare($query);
   $sth2->execute();
   ($blabla)=$sth2->fetchrow_array;
   $query="select enfh_blabla from enthfacture where enfh_base='$base' and enfh_no='$no' and enfh_type='ref_fournisseur'";
   $sth2=$dbh->prepare($query);
   $sth2->execute();
   ($ref_fournisseur)=$sth2->fetchrow_array;
}


;1