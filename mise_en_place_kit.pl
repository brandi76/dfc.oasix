$four=$html->param("four");
$trolley=$html->param("trolley");
$coef=$html->param("coef");
$four_choisi=$four;
$option=$html->param("option");

if ($option ne "Voir"){
print "<style>";
print ".pasvu {display:none;}";
print "</style>";
}
if ($action eq ""){
	print "<form> Code fournisseur ? <select name=four>";
 	print "<option value=tous>Tous</option>";
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo  group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]</option>";
    	}
    	print "</select>";
    	print "<br>Coef <input type=text name=coef><br>";
    	print "Trolley type <input type=text name=trolley><br>";
    	print "<br><input type=submit>";
    		&form_hidden();

	print "<input type=hidden name=action value=phase1></form>";
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
	print "<form>";
	
	print "<table border=1 cellspacing=0 cellpadding=0><tr><th colspan=2>Produit</th><th>Pick</th><th>Vendu</th><th>Ideal</th></th><th>Stock+Cde</th><th>Proposition</th></tr>";
	$query="select pr_cd_pr,pr_desi from produit where pr_four like '$four' order by pr_desi";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array)
	{
	    $tr_qte=&get("select tr_qte/100 from trolley where tr_cd_pr='$pr_cd_pr' and tr_code='$trolley'")+0;
	    if ($tr_qte==0){next;}
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
	$query="select distinct pr_four from produit order by pr_four";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	while (($four)=$sth3->fetchrow_array){
	  $pass=0;
	  $query="select pr_cd_pr,pr_desi from produit where pr_four like '$four' order by pr_desi";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array)
	  {
	     $tr_qte=&get("select tr_qte/100 from trolley where tr_cd_pr='$pr_cd_pr' and tr_code='$trolley'")+0;
	    if ($tr_qte==0){next;}
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
	      if ($stock<$pick){$pick_sup_stck="oui";;}
	      $vendu=0;
	      $sub=0;
	      %lot_vendu=();
	      foreach $lot_nolot (@lot){
		$lot_nolotm10=$lot_nolot-10;
		$qte=&get("select sum(ro_qte)/100 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<$fo_delai","af")+0;
		
	      # si stock > pick -> qte = vente 21 jours 
	      # si stock < pick -> qte = MAX( vente  21 jours, vente 90 jours/4)
		if ($pick_sup_stck eq "oui") {
		  $qte2_sup_qte="non";
		  $qte2=&get("select sum(ro_qte)/100 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90")+0;
# 		  print "qte2=$qte2*";
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
	      if ($presence<21){
		$vendu=int($vendu*21/$presence);
	      }
	      if ($avec_coef eq "on"){
		$coef=&get("select coef from dfc.coefficient where code=$pr_cd_pr");
		if ($coef ne ""){$vendu=int($vendu+($vendu*$coef*15/100));}
	      }
# 	      $ideal=2*$vendu+$pick;
# 	      $ideal=int(5*$vendu/3)+$pick; # mail 31/03
	      $vendu_freq=$vendu*$freq/$fo_delai;
	      $ideal=int($vendu+$vendu_freq)+$pick;
	      $encde=0;
	      $query="select com2_qte/100,com2_no_liv from commande where com2_cd_pr='$pr_cd_pr'";
	      $sth4=$dbh->prepare($query);
	      $sth4->execute();
	      while (($com2_qte,$com2_no_liv)=$sth4->fetchrow_array){
		if ($com2_no_liv >0){
		  $com2_qte=&get("select livb_qte_liv from dfc.livraison_b where livb_id='$com2_no_liv' and livb_code='$pr_cd_pr'")+0;
		}
		$encde+=$com2_qte;
	      }
	      $arrive_dans="";
	      $sera_vendu=0;
	      $a_cde="non";
	      $rupture="non";
	      $la_plus_ancienne=&get("select min(date) from commande_info,commande where com_no=com2_no and com2_cd_pr='$pr_cd_pr'");
	      $arrive_dans=$fo_delai;
	      if ($la_plus_ancienne ne ""){
		$arrive_dans=$fo_delai-&get("select datediff(curdate(),'$la_plus_ancienne')");
		$livh_date_lta=&get("select livh_date_lta from commande_info,commande,dfc.livraison_h where date='$la_plus_ancienne' and com_no=com2_no and com2_cd_pr='$pr_cd_pr' and com2_no_liv=livh_id");
 	        if (($livh_date_lta ne "")&&($livh_date_lta ne "0000-00-00")){$arrive_dans=3-&get("select datediff(curdate(),'$livh_date_lta')");}
		if ($arrive_dans<0){$arrive_dans=0;}
	      }  
	      $sera_vendu=$vendu*$arrive_dans/$fo_delai;
	      $sera_vendu=int($sera_vendu);
      	      if (($stock-$pick)<$sera_vendu){$rupture="oui";}
	      if ((($stock-$pick+$encde)<$sera_vendu)){$a_cde="oui";}
       	      $proposition=$ideal-$stock-$encde;
       	      $proposition=$tr_qte*$coef;
       	      if (($packing >0)&&($proposition> $packing*70/100)){
		  $proposition2=int($proposition/$packing)*$packing;
		  if ($proposition%$packing!=0){$proposition2+=$packing;}
		  $proposition=$proposition2;
	      }
	      if ($proposition<0){$proposition=0;}
	      if (($proposition>0)&&($proposition<3)){$proposition=$packing;}
	      if (($proposition>0)&&($proposition<3)){$proposition=3;}
	      
}

sub ligne_alerte{
    print "<tr><td>";
    print "<a href=?onglet=0&sous_onglet=0&sous_sous_onglet=&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a>";
    $color="white";
    if ($a_cde eq "oui"){$color="lightgreen";}
    print "</td><td>";
    print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&detail=$pr_cd_pr&action=$action&noratio=$noratio&four=$four_choisi&mag=$mag&avec_coef=$avec_coef&trolley=$trolley&liste=$liste><img src=/images/info.png width=15px></a>";
    $color_text="black";
    if ($magnew ne ""){
          $non_deliste=&get("select count(*) from mag where code='$pr_cd_pr' and mag='$magnew'")+0;
          if (! $non_deliste){$color_text="red";}
    }
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
      if ($la_plus_ancienne ne ""){print "<br><span style=font-size:0.8em>$la_plus_ancienne</span>";}
      print "</td>";
    }
    $color="white";
    if ($proposition>0){$color="yellow";push (@liste_four,$four);}
    if (($pick==0)&&($vendu==0)){$color="pink";}
    if ($action eq "trolley"){
      print "<td>$la_plus_ancienne</td></tr>"; 
    }
    else {
      if ($action eq "tous"){print "<td align=right bgcolor=$color>$proposition</td>";} 
      else {print "<td align=right><input type=text name=$pr_cd_pr value='$proposition' size=3 style=text-align:right;background:$color></td>";}
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
      print "en cde:$encde<br>";
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
