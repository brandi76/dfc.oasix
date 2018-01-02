$four=$html->param("four");
$mag=$html->param("mag");
$magnew=$html->param("magnew");
$option=$html->param("option");
$liste=$html->param("liste");
$noratio=$html->param("noratio");
$trolley=$html->param("trolley");
$avec_coef=$html->param("avec_coef");
$detail=$html->param("detail");
$four_choisi=$four;
$debug=$html->param("debug");
if ($debug eq "on"){$debug=1;}
if ($option ne "Voir"){
print "<style>";
print ".pasvu {display:none;}";
print "</style>";
}
if ($liste eq "on"){$action="daemon";}
if ($action eq ""){
	$query="select mag,noratio from dfc.alerte_daemon where client='$base_dbh'";
	$sth = $dbh->prepare($query);
	$sth->execute;
	($mag_d,$noratio_d)=$sth->fetchrow_array;       	
	print "<form> Code fournisseur ? <select name=four>";
	if (&admin()){
		print "<option value=tous>Tous</option>";
		$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo  group by fo2_cd_fo");
	}
	else {
		$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo and fo2_identification=1 group by fo2_cd_fo");
	}
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]</option>";
    	}
    	print "</select>";
    	print "<br>Produit present dans le mag <select name=mag>";
    	$sth2 = $dbh->prepare("select distinct mag from mag order by mag desc");
    	$sth2->execute;
    	while ($mag = $sth2->fetchrow_array) {
		print "<option value='$mag'";
		if ($mag eq $mag_d){print "selected";}
       		print ">$mag</option>";
    	}
    	print "<option></option>";
    	print "</select>";
    	print "<br>Prochain magazine <select name=magnew>";
    	print "<option></option>";
    	$sth2 = $dbh->prepare("select distinct mag from mag order by mag desc");
    	$sth2->execute;
    	while ($mag = $sth2->fetchrow_array) {
		print "<option value='$mag'";
       		print ">$mag</option>";
    	}
    	print "</select>";
	
	&form_hidden();
	print "<br>Etablir la liste des fournisseurs avec une commande à faire <input type=checkbox name=liste>";
	print "<br>Forcer le ratio à 1 <input type=checkbox name=noratio ";
	if ($noratio_d eq "on"){print "checked";}
	print "><br>";
	print "Appliquer le coef de la liste importée <input type=checkbox name=avec_coef><br>";
	print "Debug <input type=checkbox name=debug>";
	print "<br><input type=submit>";
	print "<input type=hidden name=action value=phase1></form>";
	print "<br><br><form>";
	&form_hidden();
	print "Trolley type <input type=text name=trolley><br>";
	print "<input type=hidden name=action value=trolley>";
	print "<input type=submit value=\"Liste trolley\">";
	print "</form>";
}

if (($action eq  "phase1")&&($four eq "tous")){
  $action="tous";
}

if ($action eq  "phase1"){
	$query="select fo2_add,fo_minicde,fo2_delai from fournis where fo2_cd_fo='$four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo_nom,$fo_minicde,$fo_delai)=$sth->fetchrow_array;
	($fo_nom)=split(/\*/,$fo_nom);
	print "<h3>$fo_nom <span style=font-size:1em;font-weight:normal>$fo_minicde</span> Delai:$fo_delai</h3>";	
	print "<form>";
	&form_hidden();
	if ($option eq "Voir"){$option="Ne pas voir";}else{$option="Voir";}
	print "<input type=hidden name=option value=$option>";
	print "<input type=hidden name=mag value='$mag'>";
	print "<input type=hidden name=four value='$four'>";
	print "<input type=hidden name=action value='$action'>";
	print "<input type=submit value='$option le detail des vendus'></form>";
	&ratio(1);
	print "<form>";
	print "Vendu en noir = ventes sur les derniers 21 jours, Vendu en vert = ventes sur les derniers 90j/4<br>";
	print "Stock+cde en rouge=commande en cours trop lente et/ou risque de rupture<br>";
	print "Designation sur fond vert=commande à faire ou à completer<br>";
	print "Designation en rouge=produit délisté<br>";
	
	print "<table border=1 cellspacing=0 cellpadding=0><tr><th colspan=2>Produit</th><th>Pick</th><th>Vendu</th><th>Ideal</th></th><th>Stock+Cde</th><th>Proposition</th></tr>";
	$query="select pr_cd_pr,pr_desi,pr_refour from produit where pr_four like '$four' order by pr_desi";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_refour)=$sth->fetchrow_array)
	{
	    $actif=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1 and tr_qte>0")+0;
		if (($actif==0)&&($debug)){print "$pr_cd_pr $pr_desi non actif (pas dans un trolley actif)<br>";}
	    if ($mag ne ""){
	      $actif=&get("select count(*) from mag where code='$pr_cd_pr' and mag='$mag'")+0;
		  if (($actif==0)&&($debug)){print "$pr_cd_pr $pr_desi non actif (pas dans le mag $mag)<br>";}
	    }
		if ($magnew ne ""){
	      $actif+=&get("select count(*) from mag where code='$pr_cd_pr' and mag='$magnew'")+0;
		   if (($actif==0)&&($debug)){print "$pr_cd_pr $pr_desi non actif (pas dans le mag $magnew)<br>";}
	    }
		$pr_date_fin=&get("select pr_date_fin from produit_plus where pr_cd_pr='$pr_cd_pr'");
		if (($pr_date_fin ne "0000-00-00")&&($pr_date_fin ne "")){
			# enleve le 08-11-16 source a bug et non utilisé
			if (&get("select datediff('$pr_date_fin',curdate())")<15){$actif=0;}
			if (($actif==0)&&($debug)){print "$pr_cd_pr $pr_desi non actif (date de fin $pr_date_fin)<br>";}
		}
	    if (! $actif){ next;}
	    &algo();
	    &ligne_alerte();
	}
	print "</table>";
	print "<input type=hidden name=onglet value=2>";
	print "<input type=hidden name=sous_onglet value=0>";
	print "<input type=hidden name=action value=creation>";
	print "<input type=hidden name=option value=alerte>";
	print "<input type=hidden name=four value=$four>";
	print "<br><input type=submit value=\"Bascule vers l'application de commande\"></form>";
}

if ($action eq "tous"){
	&ratio(1);  
	$query="select distinct pr_four from produit order by pr_four";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	while (($four)=$sth3->fetchrow_array){
	  $pass=0;
	  $query="select pr_cd_pr,pr_desi,pr_refour from produit where pr_four like '$four' order by pr_desi";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($pr_cd_pr,$pr_desi,$pr_refour)=$sth2->fetchrow_array)
	  {
	      $actif=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1 and tr_qte>0")+0;
	      if ($mag ne ""){
		$actif=&get("select count(*) from mag where code='$pr_cd_pr' and mag='$mag'")+0;
	      }
	      if (! $actif){next;}
	      if ($pass==0){
		  $query="select fo2_add,fo_minicde,fo2_delai from fournis where fo2_cd_fo='$four'";
		  $sth=$dbh->prepare($query);
		  $sth->execute();
		  ($fo_nom,$fo_minicde,$fo_delai)=$sth->fetchrow_array;
		  ($fo_nom)=split(/\*/,$fo_nom);
		  print "<h3>$fo_nom <span style=font-size:1em;font-weight:normal>$fo_minicde</span> delai:$fo_delai</h3>";	
		  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=phase1&four=$four&mag=$mag&noratio=$noratio&avec_coef=$avec_coef>Stock alerte</a>";	
		  print "<form>";
		  print "<table border=1 cellspacing=0 cellpadding=0><tr><th colspan=2>Produit</th><th>Pick</th><th>Vendu</th><th>Ideal</th></th><th>Stock+Cde</th><th>Proposition</th></tr>";
		  $pass=1;
	      }
 	      &algo();
		  &ligne_alerte();
    	  }
	  if ($pass==1){print "</table>";}
    }    
}
if ($action eq "trolley"){
      
      &ratio(1);  
      print "<strong>trolley:$trolley</strong><br><table border=1 cellspacing=0 cellpadding=0><tr><th colspan=2>Produit</th><th>Pick</th><th>Vendu</th><th>Ideal</th></th><th>Stock</th><th>Cde</th><th>Date cde</th></tr>";
      $query="select pr_cd_pr,pr_desi from produit,trolley where tr_cd_pr=pr_cd_pr and tr_code='$trolley' order by tr_ordre";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array)
      {
	&algo();
	&ligne_alerte();
      }
      print "</table>";
}

if ($action eq "daemon"){
  # verifier si c'est encore utile
  &ratio();
  $query="select distinct pr_four from produit order by pr_four";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($four)=$sth->fetchrow_array){
    $pass=0;
    $query="select pr_cd_pr,pr_desi from produit where pr_four like '$four' order by pr_desi";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array)
    {
	$actif=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1 and tr_qte>0")+0;
	if ($mag ne ""){
	  $actif=&get("select count(*) from mag where code='$pr_cd_pr' and mag='$mag'")+0;
	}
	if (! $actif){next;}
	if ($pass==0){
	    $query="select fo2_add,fo_minicde,fo2_delai from fournis where fo2_cd_fo='$four'";
	    $sth=$dbh->prepare($query);
	    $sth->execute();
	    ($fo_nom,$fo_minicde,$fo_delai)=$sth->fetchrow_array;
	    ($fo_nom)=split(/\*/,$fo_nom);
	    print "<table style=display:none>";
	    $pass=1;
	}
	&algo();
	&ligne_alerte();
	if ($proposition>0){last;}
    }
    if ($pass==1){print "</table>";}
  }
  $rien=1;
  print "<strong> Liste des fournisseurs avec une commande à faire<br></strong>";
  print "mag:$mag<br>";
  foreach $four (@liste_four){
   $fo_nom=&get("select fo2_add from fournis where fo2_cd_fo='$four'");
  ($fo_nom)=split(/\*/,$fo_nom);
   print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=phase1&four=$four&mag=$mag target=_blank>$four $fo_nom</a><br>";
   $rien=0;
  } 
  if ($rien){print "<span style=background:lavender>Aucun fournisseur avec une commande à faire</span><br>";}
}
	  
sub algo{
	$pick=$stock=$vendu=$ideal=$pick_sup_stck=$presence=$encde=$a_cde=$rupture=$sera_vendu=$arrive_dans=$proposition=$color=$color2=$color3="";
	if ($fo_delai==0){$fo_delai=21;}
	$freq=14;
	$packing=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'")+0;
	$pick=&get("select max(pi_qte) from pick where pi_cd_pr='$pr_cd_pr' and pi_date > DATE_SUB(now(),INTERVAL 15 DAY)")+0;
	if ($avec_coef eq "on"){
		$coef=&get("select coef from dfc.coefficient where code=$pr_cd_pr");
		if ($coef ne ""){$pick=int($pick*$coef);}
	}
	%stock=&stock($pr_cd_pr,'','quick');
	$stock=$stock{"pr_stre"};
	$pick_sup_stck="non";
	if ($stock<$pick){$pick_sup_stck="oui";}
	$vendu=0;
	$sub=0;
	%lot_vendu=();
	foreach $lot_nolot (@lot){
		$lot_nolotm10=$lot_nolot-10;
		$qte=&get("select sum(ro_qte)/100 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<$fo_delai","af")+0;
		$qte+=&get("select sum(ret_qte-ret_retour) from non_sai,retoursql,vol where ret_cd_pr=$pr_cd_pr and ret_code=v_code and ns_code=ret_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<$fo_delai","af")+0;
		# si stock > pick -> qte = vente 21 jours 
		# si stock < pick -> qte = MAX( vente  21 jours, vente 90 jours/4)
		if ($pick_sup_stck eq "oui") {
			$qte2_sup_qte="non";
			$qte2=&get("select sum(ro_qte)/100 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90")+0;
			$qte2+=&get("select sum(ret_qte-ret_retour) from non_sai,retoursql,vol where ret_cd_pr=$pr_cd_pr and ret_code=v_code and ns_code=ret_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90","af")+0;
			$qte2=$qte2*$fo_delai/90;
			$qte2=int($qte2);
			if ($qte2>$qte){$qte=$qte2;$qte2_sup_qte="oui";}
		}
		$ratio=$ratiot{$lot_nolot};
		if ($ratio==0){$ratio=1;}
		if ($noratio eq "on"){$ratio=1;}
		$qtenew=int($qte*$ratio);
		$vendu+=$qtenew;
		$lot_vendu{$lot_nolot}="$qtenew:$qte2_sup_qte";
	}
	$presence=&get("select max(datediff (curdate(),pi_date)) from pick where pi_cd_pr=$pr_cd_pr and datediff (curdate(),pi_date)<=30");
	if ($presence==0){$presence=1}
	$new=0;
	if ($presence<21){
		$vendu=int($vendu*21/$presence);
		$new=1;
	}
	if ($avec_coef eq "on"){
		$coef=&get("select coef from dfc.coefficient where code=$pr_cd_pr");
		if ($coef ne ""){$vendu=int($vendu+($vendu*$coef*15/100));}
	}
	# 	      $ideal=2*$vendu+$pick;
	# 	      $ideal=int(5*$vendu/3)+$pick; # mail 31/03
	$vendu_freq=$vendu*($freq+$fo_delai)/21;
	# if ($fo_delai<$freq){$vendu_freq=$vendu*$freq;}
	$ideal=int($vendu+$vendu_freq)+$pick;
	# print "$vendu $vendu_freq $freq $fo_delai<br>";
	$encde=0;
	@listeacde=();
	$query="select com2_no,com2_qte/100,com2_no_liv from commande,commande_info where com2_cd_pr='$pr_cd_pr' and etat>-1 and com_no=com2_no";
	$sth4=$dbh->prepare($query);
	$sth4->execute();
	while (($com2_no,$com2_qte,$com2_no_liv)=$sth4->fetchrow_array){
		if ($com2_no_liv >0){
			$com2_qte=&get("select livb_qte_liv from dfc.livraison_b where livb_id='$com2_no_liv' and livb_code='$pr_cd_pr'")+0;
		}
		$encde+=$com2_qte;
		push(@listeacde,$com2_no);
	}
	$arrive_dans="";
	$sera_vendu=0;
	$a_cde="non";
	$rupture="non";
	$la_plus_ancienne=&get("select min(date) from commande_info,commande where com_no=com2_no and com2_cd_pr='$pr_cd_pr' and etat>-1");
	$arrive_dans=$fo_delai;
	if ($la_plus_ancienne ne ""){
		$arrive_dans=$fo_delai-&get("select datediff(curdate(),'$la_plus_ancienne')");
		$livh_date_lta=&get("select livh_date_lta from commande_info,commande,dfc.livraison_h where date='$la_plus_ancienne' and com_no=com2_no and com2_cd_pr='$pr_cd_pr' and com2_no_liv=livh_id");
		if (($livh_date_lta ne "")&&($livh_date_lta ne "0000-00-00")){$arrive_dans=3-&get("select datediff(curdate(),'$livh_date_lta')");}
		if ($arrive_dans<0){$arrive_dans=0;}
	}  
	$sera_vendu=$vendu*($arrive_dans)/$fo_delai;
	$sera_vendu_freq=$vendu*($arrive_dans+$freq)/$fo_delai;
	$sera_vendu=int($sera_vendu);
	$sera_vendu_freq=int($sera_vendu_freq);
	if (($stock-$pick)<$sera_vendu){$rupture="oui";}
	if ((($stock-$pick+$encde)<$sera_vendu_freq)){$a_cde="oui";}
	if ((($stock-$pick+$encde)>=$sera_vendu)){$a_cde="non";}
	# modifier le 06/07/2017 remplace <$sera_vendu car ça ne me semble pas logique
	$proposition=$ideal-$stock-$encde;
	if (($packing >0)&&($proposition> $packing*70/100)){
		$proposition2=int($proposition/$packing)*$packing;
		if ($proposition%$packing!=0){$proposition2+=$packing;}
		$proposition=$proposition2;
	}
	if ($proposition<0){$proposition=0;}
	if (($proposition>0)&&($proposition<3)){$proposition=3;}
	if (($proposition<$packing)&&($new==1)){$proposition=$packing;}
}

=pod
sub algo2{
 # ancien algo , obsolete
	      print "<tr><td>";
	      print "<a href=?onglet=0&sous_onglet=0&sous_sous_onglet=&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a>";
	      $packing=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'")+0;
	      print "</td><td><span style=font-size:0.8em>$pr_desi par($packing)</span></td>";
	      $pick=&get("select max(pi_qte) from pick where pi_cd_pr='$pr_cd_pr' and pi_date > DATE_SUB(now(),INTERVAL 15 DAY)")+0;
	      if ($avec_coef eq "on"){
		$coef=&get("select coef from dfc.coefficient where code=$pr_cd_pr");
		if ($coef ne ""){$pick=int($pick*$coef);}
	      }
	      print "<td align=right>";
	      print $pick;
	      print "</td>";
	      %stock=&stock($pr_cd_pr,'','quick');
	      $stock=$stock{"pr_stre"};
	      $max=0;
	      if ($stock<$pick){$max=1;}
	      print "<td align=right>";
	      $vendu=0;
	      $sub=0;
	      foreach $lot_nolot (@lot){
		$lot_nolotm10=$lot_nolot-10;
		  $qte=&get("select sum(ro_qte)/100 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<21","af")+0;
	      # si stock > pick -> qte = vente 21 jours
	      # si stock < pick -> qte = MAX( vente  21 jours, vente 90 jours/4)
		if ($max) {
		  $qte2=&get("select sum(ro_qte)/400 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90")+0;
		  $color3="black";
		  $qte2=int($qte2);
		  if ($qte2>$qte){$qte=$qte2;$color3="green";$sub=1;}
 		}
		$ratio=$ratiot{$lot_nolot};
		if ($ratio==0){$ratio=1;}
		if ($noratio eq "on"){$ratio=1;}
		$qtenew=int($qte*$ratio);
		$vendu+=$qtenew;
		print "<span class=pasvu><span style=color:$color3>$lot_nolot:$qtenew </span><br></span>";
	      }
	      $color="black";
	      if ($sub){$color="green";}
	      $presence=&get("select max(datediff (curdate(),pi_date)) from pick where pi_cd_pr=$pr_cd_pr and datediff (curdate(),pi_date)<=30");
	      if ($presence==0){$presence=1}
	      $new=0;
	      if ($presence<21){
			$color="red";
			$vendu=int($vendu*21/$presence);
			$new=1;
	      }
	      if ($avec_coef eq "on"){
			$coef=&get("select coef from dfc.coefficient where code=$pr_cd_pr");
			if ($coef ne ""){$vendu=int($vendu+($vendu*$coef*15/100));}
	      }
	      print "<span style=color:$color>$vendu</span></td>";
# 	      $ideal=2*$vendu+$pick;
	      $ideal=int(5*$vendu/3)+$pick; # mail 31/03
	      print "<td align=right>$vendu $pick $ideal</td>";
	      $encde=0;
	      $query="select com2_qte/100,com2_no_liv from commande where com2_cd_pr='$pr_cd_pr'";
	      $sth3=$dbh->prepare($query);
	      $sth3->execute();
	      while (($com2_qte,$com2_no_liv)=$sth3->fetchrow_array){
		if ($com2_no_liv >0){
		  $com2_qte=&get("select livb_qte_liv from dfc.livraison_b where livb_id='$com2_no_liv' and livb_code='$pr_cd_pr'")+0;
		}
		$encde+=$com2_qte;
	      }
	      $arrive_dans="";
	      $sera_vendu=0;
	      $color2="white";
	      $la_plus_ancienne=&get("select min(date) from commande_info,commande where com_no=com2_no and com2_cd_pr='$pr_cd_pr'");
	      if ($la_plus_ancienne ne ""){
		$arrive_dans=21-&get("select datediff(curdate(),'$la_plus_ancienne')");
		if ($arrive_dans<0){$arrive_dans=0;}
		$sera_vendu=$vendu*$arrive_dans/21;
		if (($stock+$pick)<$sera_vendu){$color2="pink";}
		$sera_vendu+=$vendu;
		if ((($stock+$pick+$encde)<$sera_vendu)&&($color2 ne "pink")){$color2="lightgreen";}
	      }
	     if ($action eq "trolley"){
	       print "<td align=right bgcolor=$color2>$stock</td><td align=right>$encde</td>";
	     }
	     else
	     {
	       print "<td align=right bgcolor=$color2>$stock+$encde";
	       if ($la_plus_ancienne ne ""){print "<br><span style=font-size:0.8em>$la_plus_ancienne</span>";}
	       print "</td>";
	     }
       	      $proposition=$ideal-$stock-$encde;
	      if (($packing >0)&&($proposition> $packing*70/100)){
		  $proposition2=int($proposition/$packing)*$packing;
		  if ($proposition%$packing!=0){$proposition2+=$packing;}
		  $proposition=$proposition2;
	      }
	      if ($proposition<0){$proposition=0;}
	      if (($proposition>0)&&($proposition<3)){$proposition=3;}
	      $color="white";
	      if ($proposition>0){$color="yellow";push (@liste_four,$four);}
	      if (($pick==0)&&($vendu==0)){$color="pink";}
       	      if ($action eq "trolley"){
       	      	print "<td>$la_plus_ancienne</td></tr>"; 
	      }
       	      else {
 		if ($action eq "tous"){print "<td align=right bgcolor=$color>$proposition</td></tr>";} 
		else {print "<td align=right><input type=text name=$pr_cd_pr value='$proposition' size=3 style=text-align:right;background:$color></td></tr>";}
       	      }

}
=cut
sub ligne_alerte{
    print "<tr><td>";
    print "<a href=?onglet=0&sous_onglet=0&sous_sous_onglet=&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a><br>$pr_refour";
    $color="white";
    if ($a_cde eq "oui"){$color="lightgreen";}
    print "</td><td>";
    print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&detail=$pr_cd_pr&action=$action&noratio=$noratio&four=$four_choisi&mag=$mag&avec_coef=$avec_coef&trolley=$trolley&liste=$liste><img src=/images/info.png width=15px></a>";
    $color_text="black";
	$non_deliste=1;
    if ($magnew ne ""){
          $non_deliste=&get("select count(*) from mag where code='$pr_cd_pr' and mag='$magnew'")+0;
          if (! $non_deliste){$color_text="red";}
    }
	$pr_sup=&get("select pr_sup  from produit where pr_cd_pr='$pr_cd_pr' ")+0;
	if (($pr_sup!=0)&&($pr_sup!=3)){$color_text="red";$non_deliste=0;}
    print " <span style=font-size:0.8em;background:$color;color:$color_text>$pr_desi par($packing)</span></td>";
    print "<td align=right>$pick</td>";
    print "<td align=right>";
    $color="black";
    print "<span class=pasvu>";
    foreach $lot_nolot (keys(%lot_vendu)){
      $color="black";
      ($qte_lot,$qte2_sup_qte)=split(/:/,$lot_vendu{$lot_nolot});
      if ($qte2_sup_qte eq "oui"){$color="green";}
      print "<span style=color:$color>$lot_nolot:$qte_lot</span><br>";
    }
    print "</span>";
    if ($pick_sup_stck eq "oui"){$color="green";}
    if ($presence<21){$color="red";}
    print "<span style=color:$color>$vendu</span></td>";
    print "<td align=right>$ideal</td>";
    $color="white";
    if ($rupture eq "oui"){$color="pink";}
    if ($action eq "trolley"){print "<td align=right bgcolor=$color>$stock</td><td align=right>$encde</td>";}
    else
    {
		print "<td align=right bgcolor=$color>$stock+$encde";
		# if ($la_plus_ancienne ne ""){print "<br><span style=font-size:0.8em>$la_plus_ancienne</span>";}
		$query="select distinct com2_no from commande where com2_cd_pr=$pr_cd_pr";
		my($sth3)=$dbh->prepare($query);
		$sth3->execute();
		while (($com2_no)=$sth3->fetchrow_array){
			print "<br><a href=?action=entree&nocde=$com2_no&onglet=2&sous_onglet=0&sous_sous_onglet= target=_blank>cde:$com2_no</a>";
		}
		
		if (grep /\*/,$pr_refour){
			print "<div style=background-color:lightyellow>";
			(@multicolor)=split(/\*/,$pr_refour);
			foreach (@multicolor){
				$stock=&get("select qte from multicolor_inv where pr_cd_pr='$pr_cd_pr' and code='$_'")+0;
				$date=&get("select date from multicolor_inv where pr_cd_pr='$pr_cd_pr' and code='$_'");
				print "<nobr>$_ ($date) $stock<br>";
			}
			print "</div>";
		}
		print "</td>";
    }
    $color="white";
    if ($proposition>0){$color="yellow";push (@liste_four,$four);}
    if (($pick==0)&&($vendu==0)){$color="pink";}
    if ($action eq "trolley"){
      print "<td>$la_plus_ancienne</td></tr>"; 
    }
    elsif ($non_deliste) {
      if ($action eq "tous"){print "<td align=right bgcolor=$color>$proposition</td>";} 
		else {
			if (grep /\*/,$pr_refour){
				print "<td align=right>";
				(@multicolor)=split(/\*/,$pr_refour);
				$i=1;
				foreach (@multicolor){
				  print "<nobr><span style=font-size:0.8em>$_</span> <input type=text name='${pr_cd_pr}_${i}' value='$proposition' size=3 style=text-align:right;background:$color><br>";
				  $proposition=0;
				  $qte=0;
				  $i++;
				}
				print "</td>";
			}
			else {
				print "<td align=right><input type=text name=$pr_cd_pr value='$proposition' size=3 style=text-align:right;background:$color></td>";
			}
		}	
    }
    print "</tr>";
    if ($pr_cd_pr eq "$detail"){
      print "<tr><td colspan=5>";
      print "pick:$pick<br>";
      print "stock:$stock<br>";
      print "vendu:$vendu<br>";
      print "ideal:$ideal<br>";
      print "vendu_freq:$vendu_freq<br>";
      print "pick sup stock:$pick_sup_stck<br>";
      print "presence:$presence<br>";
      print "en cde:$encde (";
	  foreach(@listeacde){print "$_ ";}
	  print ")<br>";
      print "a_cde:$a_cde<br>";
      print "rupture:$rupture<br>";
      print "sera_vendu:$sera_vendu<br>";
      print "arrive_dans:$arrive_dans<br>";
      print "proposition:$proposition<br>";
      print "</td></tr>";
    }
}

sub ratio() {
  my ($passe)=0;
  my($avenir)=0;
  my ($aff)=$_[0];
  my(@ancien)=();
  $query="select lot_nolot from lot where lot_flag=1 order by lot_nolot desc";
  my ($sth)=$dbh->prepare($query);
  $sth->execute();
  while (($lot_nolot)=$sth->fetchrow_array){
    if (grep /$lot_nolot/,@ancien){next;}
    push(@lot,$lot_nolot);
    $passe=&get("select count(*) from vol where v_troltype=$lot_nolot  and v_rot=1 and datediff(curdate(),v_date_sql)<=35 and datediff(curdate(),v_date_sql)>0")+0;
    $avenir=&get("select count(*) from flyhead where fl_troltype=$lot_nolot  and datediff(fl_date_sql,curdate())>0 and datediff(fl_date_sql,curdate())<=35")+0;
    $lot_nolotm10=$lot_nolot-10;
#     $check=&get("select count(*) from lot where lot_flag=1 and lot_nolot=$lot_nolotm10")+0;
#     if ($check){
      $passe+=&get("select count(*) from vol where v_troltype=$lot_nolotm10  and v_rot=1 and datediff(curdate(),v_date_sql)<=35 and datediff(curdate(),v_date_sql)>0")+0;
      $avenir+=&get("select count(*) from flyhead where fl_troltype=$lot_nolotm10  and datediff(fl_date_sql,curdate())>0 and datediff(fl_date_sql,curdate())<=35")+0;
      push (@ancien,$lot_nolotm10);
#     } 
    $ratio=0;
    if ($passe>0){$ratio=int($avenir*100/$passe)/100;}
    $ratiot{$lot_nolot}=$ratio;	
    if ($aff){print "Trolley $lot_nolot ratio:$ratio% $avenir/$passe<br>";}
  }
}
;1
