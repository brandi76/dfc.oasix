require "./src/connect.src";
print "<center><div class=titrefixe> Consultation du fichier produit <br></div>";
$action=$html->param("action");
$four=$html->param("four");
$code=$html->param("code");
$option=$html->param("option");
$param=$html->param("param");

&init_table();

if ($action eq "maj"){
  if ($option eq "pr_desi"){
    &save("update produit set pr_desi='$param' where pr_cd_pr='$code'","af");
  }
  elsif ($option eq "pr_prx_vte"){
    $param*=100;
    &save("update produit set pr_prx_vte='$param' where pr_cd_pr='$code'","af");
  }
  elsif ($option eq "pr_prac"){
    $param*=100;
    &save("update produit set pr_prac='$param' where pr_cd_pr='$code'","af");
  }
  elsif ($option eq "pr_refour"){
    &save("update produit set pr_refour='$param' where pr_cd_pr='$code'","af");
  }
  elsif ($option eq "pr_famille"){
    &save("update produit_plus set pr_famille='$param' where pr_cd_pr='$code'","af");
  }
  elsif ($option eq "pr_pdn"){
    &save("update produit set pr_pdn='$param' where pr_cd_pr='$code'","af");
  }
  elsif ($option eq "pr_fragrance"){
    &save("update produit_plus set pr_fragrance='$param' where pr_cd_pr='$code'","af");
  }
  elsif ($option eq "marque"){
    $marque_court=&get("select marque_court from produit_desi where marque='$param' and marque_court!='' limit 1");
    &save("update produit_desi set marque='$param',marque_court='$marque_court' where code='$code'","af");
  }
  $action="visu";
  $option="";	
}

if ($action eq ""){
  print "Création d'un produit<br>";
  print "Code fournisseur <br>";
  print "<form>";
  &form_hidden();
  print "<br><select name=four><option value=''></option>";
  $sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
  $sth2->execute;
  while (my @four = $sth2->fetchrow_array) {
	  next if $four eq $four[0];
	  ($four[1])=split(/\*/,$four[1]);
	  print "<option value=\"$four[0]\">$four[0] $four[1]</option>";
  }
  print "</select>"; 
  print "<input type=hidden name=action value=choix_four> <input type=submit></form>";
}

if ($action eq "choix_four"){
  print "Choisir un produit équivalent dans la liste<br>";
  print "<form>";
  &form_hidden();
  print "<br><select name=code><option value=''></option>";
  $query="select pr_cd_pr,pr_desi from produit where pr_four='$four' order by pr_desi";
  $sth=$dbh->prepare($query);
  $sth->execute;
  while (($pr_cd_pr,$pr_desi) = $sth->fetchrow_array) {
	  print "<option value=$pr_cd_pr>$pr_cd_pr $pr_desi</option>";
  }
  print "</select><br>"; 
  print "<input type=hidden name=four value=$four>";
  print "<input type=hidden name=action value=choix_prod> <input type=submit></form>";
}

if ($action eq "choix_prod"){
  $pr_desi="new ".&get("select pr_desi from produit where pr_cd_pr=$code");
  $pr_prac=0;
  $pr_refour=0;
  $pr_sup=0;
  $nouveau=$code;
  $check=1;
  while ($check){
    $nouveau++;
    $check=&get("select count(*) from produit where pr_cd_pr=$nouveau")+0;
  }
  foreach $client (@bases_client) {
    &save ("INSERT ignore into $client.produit  select '$nouveau','$pr_desi','0','0','0',pr_douane,pr_ventil,'0',pr_type,pr_prx_vte,'0',pr_sup,pr_emb,'0',pr_deg,pr_pdn,'0',pr_acquit,pr_orig,pr_pdb,pr_qte_comp,pr_cond,pr_devac,pr_four,'','' from dfc.produit where pr_cd_pr='$code'","af");
    &save ("INSERT ignore into $client.carton select '$nouveau', car_carton, car_pal from dfc.carton where car_cd_pr='$code'","af");
    &save ("INSERT ignore into $client.produit_plus select '$nouveau',curdate(),'','','','','','','','',pr_fragrance,pr_vapo,'',pr_famille,pr_four_pub from dfc.produit_plus where pr_cd_pr='$code'","af");
  }  
   &save ("INSERT ignore into dfc.produit_desi select '$nouveau','','',marque,marque_court from dfc.produit_desi where code='$code'","af");
  $code=$nouveau;
  $action="visu";
  system("/var/www/cgi-bin/dfc.oasix/send_nouveaute.pl $code &");
} 

if ($action eq "visu"){
	$query="select pr_desi,pr_pdn,pr_prx_vte,pr_prac,pr_refour from produit where pr_cd_pr='$code'";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($pr_desi,$pr_pdn,$pr_prx_vte,$pr_prac,$pr_refour)=$sth->fetchrow_array;
	$pr_prx_vte/=100;
	$pr_prac/=100;
	$query="select car_carton from carton where car_cd_pr='$code'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($car_carton)=$sth->fetchrow_array;
	$query="select pr_fragrance,pr_famille from produit_plus where pr_cd_pr='$code'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_fragrance,$pr_famille)=$sth->fetchrow_array;
	$query="select marque from produit_desi where code='$code'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($marque)=$sth->fetchrow_array;

	print "<p>Nouveau Code:$code<p>";
	print "<div style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
 	require ("form_hidden2.src");
 	&form_hidden();
	print "<div style=display:inline-block;width:150px;>Designation</div>";
	$param=$pr_desi;
	$champ="pr_desi";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Prix achat</div>";
	$param=$pr_prac;
	$champ="pr_prac";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Prix de vente</div>";
	$param=$pr_prx_vte;
	$champ="pr_prx_vte";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Ref fournisseur</div>";
	$param=$pr_refour;
	$champ="pr_refour";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Marque</div>";
	$param=$marque;
	$champ="marque";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Packing</div>";
	$param=$car_carton;
	$champ="car_carton";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Famille</div>";
	
	$param=$table_famille{$pr_famille};
	$champ="pr_famille";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Contenance</div>";
	$param=$pr_pdn;
	$champ="pr_pdn";
	&input_param();
	print "<br>";
	print "<div style=display:inline-block;width:150px;>Fragrance</div>"; 
	$param=$table_fragrance[$pr_fragrance];
	$champ="pr_fragrance";
	&input_param();
	print "<br>";
	print "</div>";
	print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>retour</a>";
}

sub input_param{
 if ($option eq $champ){
  print "<form style=display:inline>";
  &form_hidden();
  print "<input type=hidden name=action value=maj>";
  print "<input type=hidden name=option value=$option>";
  print "<input type=hidden name=code value=$code>";
  if (grep /date/,$champ){
    print "<input type=texte name=param id=datepicker value=$param>";
  }
  elsif ($champ eq "pr_famille"){
    print "<select name=param>";
    foreach $i (keys(%table_famille)){
	    print "<option value=$i";
	    if ($pr_famille==$i){print " selected";}
	    print ">$table_famille{$i}</option><br>";
    }
    print "</select>";
  }
  elsif ($champ eq "pr_fragrance"){
    print "<select name=param>";
    for ($i=0;$i<=$#table_fragrance;$i++){
	    print "<option value=$i";
	    if ($pr_fragrance==$i){print " selected";}
	    print ">$table_fragrance[$i]</option><br>";
    }
    print "</select>";
  }
  elsif ($champ eq "marque"){
    print "<select name=param style=;text-align:left;>";
    $query="select distinct marque from produit_desi order by marque";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($marque_sel)=$sth2->fetchrow_array){
	print "<option value='$marque_sel'";
	if ($marque eq $marque_sel){print " selected";}
	print ">$marque_sel</option><br>";
    }
    print "</select>";
  }
  else {print "<input type=texte name=param value='$param'>";}
  print "<input type=submit value=maj></form>";
 }
 else {print $param;&lien("$champ");}
}

sub lien{
  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&code=$code&option=".$_[0]."><img src=/images/b_edit.png border=0 title=\"Modifier\"></a>";
}

sub init_table{
  $query="select fa_id,fa_desi from famille order by fa_id";
  $sth = $dbh->prepare($query);
  $sth->execute;
  %table_famille=();
  while (($fa_id,$famille) = $sth->fetchrow_array) {
	  $table_famille{$fa_id}="$famille";
  }
  @table_fragrance=("eau de toilette","eau de parfum","eau de cologne","parfum","eau fraiche","soie de parfum","eau tonique","coffret mini");
}

;1
