$date_ref_fin=$html->param("date_ref_fin");
$date_ref_fin=&datepicker($date_ref_fin);
push(@bases_client,"cameshop");
if ($action eq "" ){
  print "<div class=titre>Situation</div><form>";
  &form_hidden();
  print "Date <input type=text name=date_ref_fin id=datepicker>";
  print "<input type=hidden name=action value=go>";
  print "<input type=submit>";
  print "</form>";
}

if ($action eq "go"){
  &position();
  ($an,$mois,$jour)=split(/-/,$date_ref_fin);
  $an--;
  $date_ref_fin="$an-$mois-$jour";
  print "<br><hr></hr><br>";
  &position();
}

sub position(){
  $date_ref_debut=substr($date_ref_fin,0,4)."-01-01";
#   print "*** $date_ref_fin  $date_ref_debut ***"; 
  $mois_fin=substr($date_ref_fin,5,2).substr($date_ref_fin,2,2);
  $mois_fin_2d=substr($date_ref_fin,5,2);
  $annee=substr($date_ref_fin,2,2);
  print "Position du 01/01/$annee au ";
  print &date_iso($date_ref_fin);
  print "<br>";
  &save("create  temporary table if not exists situation_tmp (base varchar(20),ca decimal(10,2), stim decimal(10,2),com decimal(10,2), achat decimal(10,2), nbvol int(8), chargement decimal(10,2),ecart decimal(10,2))");
  &save("truncate table situation_tmp");
  
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
	if (($annee==15)&&($base eq "cameshop")){next;}
    $base_client_code=&get("select v_cd_cl from $base.vol order by v_date_sql desc limit 1");
    $query="select cl_nom,cl_com1/100,cl_com2/100 from $base.client where cl_cd_cl='$base_client_code'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
    $cl_com1=int($cl_com1*100)/100;
    if ($base ne "cameshop"){&ca();}else{&ca_boutique();}
  }
  print "<table border=1 cellspacing=0><tr><th>&nbsp;</th>";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    print "<th colspan=2>";
    print uc($base);
    print "</th>";
  }
  print "<th colspan=2>TOTAL</th></tr>";
 
 $total=0;
  print "<tr><td>VENTE A BORD</td>";
  $color="lavender";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $ca=int(&get("select ca from situation_tmp where base='$base'"));
    $tot=&get("select sum(ca) from situation_tmp");
    $total+=$ca;
    $ca{"$base"}=$ca;
    if ($tot!=0){$pour=int($ca*10000/$tot)/100;}
    $total_ca=$total;
    print "<td align=right bgcolor=$color>$ca</td><td align=right bgcolor=$color>$pour%</td>";
  }
  $pour=0;
  if ($total!=0){$pour=int($ca*10000/$total)/100;}
  $total_ca=$total;
  print "<td align=right>$total</td><td align=right>100%</td></tr>";
  
  $total=0;
  print "<tr><td>STIM</td>";
  $color="lavender";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $stim=int(&get("select stim from situation_tmp where base='$base'"));
    $pour=0;
    if ($ca{"$base"}!=0){$pour=int($stim*10000/$ca{"$base"})/100;}
    $total+=$stim;
    print "<td align=right bgcolor=$color>$stim</td><td align=right bgcolor=$color>$pour%</td>";
  }
  $pour=0;
  if ($total_ca!=0){$pour=int($total*10000/$total_ca)/100;}
  print "<td align=right>$total</td><td align=right >$pour%</td></tr>";
 
 $total=0;
  print "<tr><td>COM CIE</td>";
  $color="lavender";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $com=int(&get("select com from situation_tmp where base='$base'"));
    $pour=0;
    if ($ca{"$base"}!=0){$pour=int($com*10000/$ca{"$base"})/100;}
    $total+=$com;
    print "<td align=right bgcolor=$color>$com</td><td align=right bgcolor=$color>$pour%</td>";
   }
  $pour=0;
  if ($total_ca!=0){$pour=int($total*10000/$total_ca)/100;}
  print "<td align=right>$total</td><td align=right >$pour%</td></tr>";
 $total=0;
  print "<tr><td>ECART CAISSE</td>";
  $color="lavender";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $ecart=int(&get("select ecart from situation_tmp where base='$base'"));
    $pour=0;
    if ($ca{"$base"}!=0){$pour=int($ecart*10000/$ca{"$base"})/100;}
    $total+=$ecart;
    print "<td align=right bgcolor=$color>$ecart</td><td align=right bgcolor=$color>$pour%</td>";
  }
  $pour=0;
  if ($total_ca!=0){$pour=int($total*10000/$total_ca)/100;}
  print "<td align=right>$total</td><td align=right>$pour%</td></tr>";

 
  $total=0;
  print "<tr><td>ACHAT CONSOMME</td>";
  $color="lavender";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $achat=int(&get("select achat from situation_tmp where base='$base'"));
    $pour=0;
    if ($ca{"$base"}!=0){$pour=int($achat*10000/$ca{"$base"})/100;}
    $total+=$achat;
    print "<td align=right bgcolor=$color>$achat</td><td align=right bgcolor=$color>$pour%</td>";
   }
  $pour=0;
  if ($total_ca!=0){$pour=int($total*10000/$total_ca)/100;}
  print "<td align=right>$total</td><td align=right>$pour%</td></tr>";

 
 
  $total=0;
  print "<tr><td>COUT CHARGEMENT</td>";
  $color="lavender";
 
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $chargement=int(&get("select chargement from situation_tmp where base='$base'"));
    $pour=0;
    if ($ca{"$base"}!=0){$pour=int($chargement*10000/$ca{"$base"})/100;}
    $total+=$chargement;
    print "<td align=right bgcolor=$color>$chargement</td><td align=right bgcolor=$color>$pour%</td>";
  }
  $pour=0;
  if ($total_ca!=0){$pour=int($total*10000/$total_ca)/100;}
  print "<td align=right>$total</td><td align=right>$pour%</td></tr>";
  
  $total=0;
  print "<tr><td>MARGE SUR ACHAT</td>";
  $color="lavender";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $ca=int(&get("select ca from situation_tmp where base='$base'"));
    $stim=int(&get("select stim from situation_tmp where base='$base'"));
    $com=int(&get("select com from situation_tmp where base='$base'"));
    $ecart=int(&get("select ecart from situation_tmp where base='$base'"));
    $achat=int(&get("select achat from situation_tmp where base='$base'"));
    $chargement=int(&get("select chargement from situation_tmp where base='$base'"));
    $marge=$ca-$stim-$com+$ecart-$achat-$chargement;
    $pour=0;
    if ($ca{"$base"}!=0){$pour=int($marge*10000/$ca{"$base"})/100;}
    $total+=$marge;
    print "<td align=right bgcolor=$color>$marge</td><td align=right bgcolor=$color>$pour%</td>";
  }
  $pour=0;
  if ($total_ca!=0){$pour=int($total*10000/$total_ca)/100;}
  print "<td align=right>$total</td><td align=right>$pour%</td></tr>";
  $total=0;
  $total_ca=0;
  print "<tr><td>Nb de vol/Moyenne</td>";
  $color="lavender";
  foreach $base (@bases_client){
    if ($base eq "dfc"){next;}
    if ($color eq "white"){$color="lavender";}else{$color="white";}
    $ca=int(&get("select ca from situation_tmp where base='$base'"));
    $nbvol=&get("select nbvol from situation_tmp where base='$base'");
    $moyen="&nbsp;";
    if ($nbvol!=0){$moyen=int($ca/$nbvol);}
    $total_ca+=$ca;
    print "<td align=right bgcolor=$color>$nbvol</td><td align=right bgcolor=$color>$moyen</td>";
    $total+=$nbvol;
  }
  $pour=0;
  $moyen="&nbsp;";
   if ($total!=0){$moyen=int($total_ca/$total);}
  print "<td align=right>$total</td><td align=right>$moyen</td></tr>";
  print "</table>";
} 

sub ca{
	$query="select v_code from $base.vol where v_cd_cl='$base_client_code' and v_date%100=$annee and v_date%10000<=$mois_fin and v_rot=1 and v_troltype>100 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total_ca_com=0;
	$total_ca_marge=0;
	$total_chargement=0;
	$total_stim=0;
	$total_vfly=0;
	$total_ecart=0;
	$total_recette=0;
	$nbvol=0;
	while (($v_code)=$sth->fetchrow_array){
		$ca_papi=&get("select sum(ca_papi) from $base.caissesql where ca_code='$v_code' group by ca_code");
# 		print "$v_code;$ca_papi<br>";
		$total_stim+=$ca_papi;
		$ca_recettes=&get("select sum(ca_total) from $base.caissesql where ca_code='$v_code' group by ca_code");
		$ca_fly=&get("select sum(ca_fly/100) from $base.caisse where ca_code='$v_code' group by ca_code");
		$total_vfly+=$ca_fly;
# 	 		$total_ecart+=$ca_fly-($ca_recettes+$ca_papi);
 	 	$total_ecart+=$ca_recettes-$ca_fly;
		$total_recette+=$ca_recettes-$ca_papi;
		$ca_cons=&get("select sum(ro_qte*pr_prac)/10000 from $base.rotation,$base.produit where ro_code='$v_code' and ro_cd_pr=pr_cd_pr")+0;
		$total_ca_com+=$ca_cons;
		$nbvol++;
#  		$ca_marge=&get("select sum(ro_qte*(ap_prix-pr_prac))/10000 from $base.rotation,$base.produit,$base.appro where ap_code=ro_code and ap_cd_pr=ro_cd_pr and ro_code='$v_code' and ro_cd_pr=pr_cd_pr")+0;
# 		$total_ca_marge+=$ca_marge;
	}
	# modifié en mai 2017 suite mail p+d , changement de base de com
	# $total_com=($total_vfly-$total_stim)*$cl_com1/100;
	#if ($base eq "togo"){
		$total_com=($total_recette)*$cl_com1/100;
	# }
	&cout();
	&save("insert into situation_tmp values ('$base','$total_recette','$total_stim','$total_com','$total_ca_com','$nbvol','$total_chargement','$total_ecart')","af"); 
	#&save("insert into situation_tmp values ('$base','$total_vfly','$total_stim','$total_com','$total_ca_com','$nbvol','$total_chargement','$total_ecart')","af"); }
}

sub cout{
	%total=();
	$total_ca=0;
	$query="select v_code,v_vol,v_dest,v_date,v_troltype from $base.vol  where v_cd_cl='$base_client_code' and v_date%100=$annee and v_date%10000<=$mois_fin and v_rot=1 and v_code >0 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_dest,$v_date,$v_troltype)=$sth->fetchrow_array){
		$ca=&get("select sum(ca_total) from $base.caissesql where ca_code='$v_code'")+0;
		$cout=&get("select lot_cout from $base.lot where lot_nolot='$v_troltype'")+0;
		if ($ca!=0){$total{$cout}++;}
		# if (($base eq "togo")&&($ca!=0)){print "$v_code,$v_troltype,$cout<br>";}
		# if (($base eq "togo")&&($ca==0)){$vide++;print "$vide<br>";}

		$total_ca+=$ca;
	}
	foreach $cle (keys %total){
	  $px_total=$cle*$total{$cle};
	  $total_chargement+=$px_total;
	}
	$com=0;
	if ($base eq "togo"){$com=2;}
	if (($base eq "togo")&&($annee==14)){$com=1;}
	if ($base eq "camairco"){$com=1;}
#  	print "*** $base $com  $total_ca $total_chargement **<br>";		
	if ($com!=0){
	  $com=$com*$total_ca/100;
	  $total_chargement+=$com;
	}
	if (($base eq "togo")&&($annee>16)){
	  $total_chargement-=&get("select sum(montant) from $base.recapclient where mois%100=$annee and floor(mois/100)<=$mois_fin")+0;
	}
}

sub ca_boutique{
	$annee_4d=2000+$annee;
	$total_ca_com=0;
	$total_ca_marge=0;
	$total_chargement=0;
	$total_stim=0;
	$total_vfly=0;
	$total_ecart=0;
	$nbvol=0;
	$total_vfly=&get("select sum(ticket_montant) from cameshop.ticket_caisse_js where ticket_vendeuse!='sylvain' and year(ticket_date)='$annee_4d' and month(ticket_date)<='$mois_fin_2d' and ticket_sup=0","af");
	$total_com=$total_vfly*8/100;
	$total_ca_com=&get("select sum(qte*prac) from cameshop.panier_caisse,cameshop.ticket_caisse_js where ticket_pdv=pdv and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and year(ticket_date)='$annee_4d' and month(ticket_date)<='$mois_fin_2d' and ticket_sup=0 and vendeuse!='sylvain'");
	if ($annee_4d==2016){$mois_fin_2d-=3.5;}
	$total_chargement=16000*$mois_fin_2d;
	&save("insert into situation_tmp values ('$base','$total_vfly','$total_stim','$total_com','$total_ca_com','$nbvol','$total_chargement','$total_ecart')","af"); 
}

		
;1
