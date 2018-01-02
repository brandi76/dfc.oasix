$user=$ENV{"REMOTE_USER"};
$an_ref=$html->param("an_ref");
$dev=$html->param("dev");
$date_ref_debut=$an_ref."-01-01";
if ($an_ref==2013){$date_ref_debut="2013-07-01";}
$an_reff=$an_ref+1;
#$date_ref_fin=$an_reff."-01-01";
$date_ref_fin=&datepicker($html->param("date_ref_fin"));
$option=$html->param("option");

if ($action eq "modif_sup"){
      $no=$html->param("no");
      &save("delete from bordereau where no='$no' and devise='$dev' limit 1");
      if ($dev eq "XOF"){&save("delete from cash where bordereau='$no' limit 1")};
      print "<mark> Bordereau no:$no supprimé</mark><br>";
      $action="det_rem";
} 
if ($action eq "modif_info_go"){
      $no=$html->param("no");
      $ref=$html->param("ref");
      $cash=$html->param("cash");
      $montant=$html->param("montant");
      $check=&get("select montant from bordereau where no=$no and devise='$dev'")+0;
      if ($check != $montant){
	$montant_dev=$montant;
	if ($dev eq "EUR"){$montant_dev=int($montant/655.957);}
	if ($dev eq "USD"){$montant_dev=int($montant/480);}
	&save("update bordereau set montant='$montant',montantdev='$montant_dev',ref=\"$ref\" where no='$no' and devise='$dev'","af");
      }
      &save("update bordereau set ref=\"$ref\" where no='$no' and devise='$dev'","af");
      
      if ($dev eq "XOF"){
	&save("update cash set montant='$cash' where bordereau='$no'");
      	$check=&get("select montant from cash where bordereau='$no'");
	if (($check eq "")&&($cash!=0)){
	  &save("insert into cash value ('$no','XOF',curdate(),'$cash','Modification via suivi encaissement')");
	}  
      }
      print "<mark> Bordereau no:$no modifié</mark><br>";
      $action="det_rem";
} 


if ($action eq "modif_info"){
      $no=$html->param("no");
      print "<form><table cellspacing=0 border=1>";
      print "<tr><th>Bordereau</th><th>Date</th><th>Montant</th>";
      if ($dev eq "XOF"){print "<th>Cash</th>";}
      print "<th>Libelle ";
      print "</th>";
      print "</tr>";
      $query="select no,date_remise,montant,ref,montantdev from bordereau where no='$no' and devise='$dev' and montant!=0 ";
      $sth=$dbh->prepare($query);
      $sth->execute();
      ($no2,$date_remise,$montant,$ref,$montant_dev)=$sth->fetchrow_array;
      $cash=0;
      if ($dev eq "XOF") {$cash=&get("select montant from cash where bordereau='$no'")+0;}
      $montant-=$cash;
      $montant_dev-=$cash;
      print "<tr ><td><a onclick=window.open(\"/cgi-bin/saicaisse.pl?border=$no&action=Bordereau\",\"_blank\",\"width=800,height=700,scrollbars=yes\")>$no</a></td><td>$date_remise</td><td align=right><input type=text name=montant value=$montant></td>";
      if ($dev eq "XOF"){print "<td align=right><input type=text name=cash value=$cash></td>";}
      print "<td align=right><input type=text name=ref value=$ref></td>";
      print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modif_sup&no=$no&dev=$dev&date_ref_fin=$date_ref_fin onclick=\"return confirm('Etes vous sur de vouloir supprimer')\"><img border=0 src=../../images/b_drop.png title='Supprimer'></a></td>";
      print "</tr>";
      print "</table>";
      print "<br><input type=submit value=modifier>";
      &form_hidden();
      print "<input type=hidden name=no value=$no>";
      print "<input type=hidden name=dev value=$dev>";
      print "<input type=hidden name=an_ref value=$an_ref>";
      print "<input type=hidden name=action value=modif_info_go>";
      print "</form>";
}

 	
 	
if ($action eq "" ){
$date_du_jour=&get("select curdate()");
  print "<form>";
  &form_hidden();
  if ($an_ref eq ""){$an_ref= `/bin/date +%Y`;}
  print "Année : <input type=text name=an_ref value=$an_ref><br>";
  print "Date de fin : <input type=text name=date_ref_fin id=datepicker value='$date_du_jour'><br>";
  print "<input type=hidden name=action value=go>";

  print "<input type=submit>";
  print "</form>";
}

if ($action eq "go" ){
	print "<center>Suivi encaissement $an_ref $dev<br>";
# 	&form_hidden();
# 	print "<input type=hidden name=an_ref value='$an_ref'>";
 	print "Base de $base_ville<br>";
	print "Position du ";
	print &date_iso($date_ref_debut);
	print " au ";
	print &date_iso($date_ref_fin);
	print "<br>";
	print "<table cellspacing=0 border=1>";
	print "<tr><th>Devise</th><th>Position au ";
	print &date_iso($date_ref_debut);
	print "</th><th>Traitement de la periode</th><th>Remise de la periode </th><th>Position fin de periode</th></tr>";
	$query="select distinct (no) from bordereau where date_creation >='$date_ref_debut' and date_creation<='$date_ref_fin'";
 	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no)=$sth->fetchrow_array){
		$t_xof_1,$t_xof_2,$t_xof_3,$t_xof_4,$t_xof_5,$t_xaf_1,$t_xaf_2,$t_xaf_3,$t_xaf_4,$t_dol_1,$t_dol_2,$t_dol_3,$t_dol_4,$t_dol_5,$t_dol_6,$t_eur_1,$t_eur_2,$t_eur_3,$t_eur_4,$t_eur_5,$t_eur_6=0;
		$total_xof=$total_xaf=$total_dol=$total_eur=$total_stim=$total_cb=0;
		$query="select ca_code,ca_rot,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ca_code,$ca_rot,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth2->fetchrow_array){
			$date_vol=&get("select v_date from vol where v_code=$ca_code and v_rot=$ca_rot");
			$date_vol=&date(&daten($date_vol));
			$date_vol="20".$date_vol;
			$date_vol=~s/\//-/g;
 			 $ecart=&get("select datediff('$date_vol','$date_ref_debut')")+0;
 			 # print "$date_vol  $date_ref_debut<br>";
 			if ($ecart <0){next;}
		
			($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
			($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
			($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
			($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
			$total_xof+=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
			$total_xaf+=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000+$xaf_5*500;
			$total_dol+=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
			$total_eur+=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
			$total_cb+=$ca_cab;
			$total_stim+=$ca_papi;
		}
		$total{"XOF"}+=$total_xof;
		$total{"XAF"}+=$total_xaf;
#		print "$no $total_xaf<br>";
		$total{"USD"}+=$total_dol;
		$total{"EUR"}+=$total_eur;
# 		 print "<tr><td>$no:".$total{"EUR"}."</td></tr>";
		

	}
	
	@tabdevise=("XOF","XAF","USD","EUR");
	for $devise (@tabdevise) {
		$val_anc=&get("select montant from encaissement where date='$date_ref_debut' and devise='$devise'","af")+0;
		print "<tr><td align=right>$devise</td><td align=right>$val_anc</td>";
		$val_ent=$total{"$devise"};
		print "<td  align=right><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=det&dev=$devise&an_ref=$an_ref&date_ref_fin=$date_ref_fin>$val_ent</a></td>";
		# $val_sor=&get("select sum(montant) from bordereau where date_remise >='$date_ref_debut' and date_creation>='$date_ref_debut' and date_remise <'$date_ref_fin' and date_creation<'$date_ref_fin' and devise='$devise'")+0;
		$val_sor=&get("select sum(montant) from bordereau where date_remise>='$date_ref_debut' and date_remise<='$date_ref_fin' and devise='$devise'","af")+0;
		
		if ($devise eq "XOF"){
		  # $val_sor+=&get("select sum(cash.montant) from cash,bordereau where date_remise >'$date_ref' and date_creation>'$date_ref' and bordereau=no ")+0;
		}  
		print "<td  align=right><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=det_rem&dev=$devise&an_ref=$an_ref&date_ref_fin=$date_ref_fin>$val_sor</a></td>";
		$val_res=$val_anc-$val_sor+$val_ent;
		print "<td  align=right>$val_res</td></tr>";
		if ($option eq "maj"){
		  print "<tr><td bgcolor=pink>Fonction maj desactivée voir sylvain</td></tr>";
		  # &save("replace into encaissement value('$date_ref_fin','$devise','$val_res')","aff");
		}
	}
	print "</table><br><br><br>";
	print "<form >";
	print "<input type=hidden name=an_ref value='$an_ref'>";
	&form_hidden();
	print "<input type=hidden name=option value=maj>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit style=background:pink value='Mette à jour le report'>";
	print "</form>";
}

if ($action eq "det"){
	print "<center>Suivi encaissement $an_ref<br><form>";
	print "<input type=hidden name=an_ref value='$an_ref'>";
	&form_hidden();
	print "Base de $base_ville<br>";
	print "Position au ";
	print &date_iso($date_ref_fin);
	print "<br>";
	print "<table cellspacing=0 border=1>";
	print "<tr><th>Bordereau</th><th>Date creation</th><th>Devise ";
	print "</th></tr>";
	$query="select distinct (no) from bordereau where date_creation >='$date_ref_debut' and date_creation <='$date_ref_fin' order by no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no)=$sth->fetchrow_array){
		$t_xof_1,$t_xof_2,$t_xof_3,$t_xof_4,$t_xof_5,$t_xaf_1,$t_xaf_2,$t_xaf_3,$t_xaf_4,$t_dol_1,$t_dol_2,$t_dol_3,$t_dol_4,$t_dol_5,$t_dol_6,$t_eur_1,$t_eur_2,$t_eur_3,$t_eur_4,$t_eur_5,$t_eur_6=0;
		$total_xof=$total_xaf=$total_dol=$total_eur=$total_stim=$total_cb=0;
		$query="select ca_code,ca_rot,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ca_code,$ca_rot,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth2->fetchrow_array){
			$date_vol=&get("select v_date from vol where v_code=$ca_code and v_rot=$ca_rot");
			$date_vol=&date(&daten($date_vol));
			$date_vol="20".$date_vol;
			$date_vol=~s/\//-/g;
			# print "$no $ca_code $ca_rot $date_vol";
			$ecart=&get("select datediff('$date_vol','$date_ref_debut')")+0;
			#print " $ecart";
			#print "<br>";
			if ($ecart <0){next;}
			($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
			($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
			($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
			($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
			$total_xof+=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
			$total_xaf+=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000+$xaf_5*500;
			$total_dol+=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
			$total_eur+=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
			$total_cb+=$ca_cab;
			$total_stim+=$ca_papi;
		}
		$montant=0;
		if ($dev eq "XAF") { $montant=$total_xaf;}
		if ($dev eq "XOF") { $montant=$total_xof;}
		if ($dev eq "USD") { $montant=$total_dol;}
		if ($dev eq "EUR") { $montant=$total_eur;}

		if ($montant !=0){
			$date_bor=&get("select date_creation from bordereau where no='$no'");
			$date_remise=&get("select date_remise from bordereau where no='$no' and devise='$dev'");
			print "<tr><td><a onclick=window.open(\"/cgi-bin/saicaisse.pl?border=$no&action=Bordereau\",\"_blank\",\"width=800,height=700,scrollbars=yes\")>$no</a></td><td>$date_bor</td><td align=right>$montant</td>";
 			if (($dev eq "XOF")&& ($date_remise ne "0000-00-00")){
			  $check=&get("select montant from bordereau where no='$no' and devise='$dev'")+0;
			  $cash=&get("select montant from cash where bordereau='$no' and devise='$dev'")+0;
			  print "<td>cash:$cash</td>";
			  if ($check!=$montant){
			    print "<td>Bord:$check</td>";
			    $ecarts=int($check-$montant);
			    print "<td>$ecarts</td>";
			    $total_ecart+=$ecarts;
			  }
			}
			print "</tr>";
		}
		$total_gen+=$montant;
	
	}
	
	print "<tr><td colspan=2><b>Total</b></td><td align=right><b>$total_gen</b></td></tr>";
	print "</table>";
	print "total ecart:$total_ecart";
}
	
if ($action eq "det_rem"){
	print "<center>Suivi encaissement $an_ref <br><form>";
	print "<input type=hidden name=an_ref value='$an_ref'>";
	&form_hidden();
	print "Base de $base_ville<br>";
	print "Position au ";
	print &date_iso($date_ref_fin);
	print "<br>";
	print "<table cellspacing=0 border=1>";
 	print "<tr><th>Bordereau</th><th>Date</th><th>Montant</th><th>Cash</th><th>Libelle ";
 	print "</th>";
 	if (($dev eq "EUR")||($dev eq "USD")){
	  print "<th><span style=color:red>Banque $dev</span></th>";
	}  
	print "<th><span style=color:red>Banque Xof</span></th><th><span style=color:red>Ecart Xof</span></th></tr>";
 	# $query="select date_remise,montant,ref from bordereau where date_remise >='$date_ref_debut' and date_creation>='$date_ref_debut' and date_remise <'$date_ref_fin' and date_creation<'$date_ref_fin' and devise='$dev'";
 	$query="select no,date_remise,montant,ref,montantdev from bordereau where date_remise>='$date_ref_debut' and date_remise<='$date_ref_fin' and devise='$dev' and montant!=0 order by no";
	# print $query;
	$color="white";
 	$sth=$dbh->prepare($query);
 	$sth->execute();
 	while (($no,$date_remise,$montant,$ref,$montant_dev)=$sth->fetchrow_array){
		$cash=0;
		if ($dev eq "XOF") {$cash=&get("select montant from cash where bordereau='$no'")+0;}
		$montant-=$cash;
		$montant_dev-=$cash;
		if ($ref ne $ref_tamp){
		  if ($color eq "white"){$color="lavender";}else{$color="white";}
		  $ref_tamp=$ref;
		}
		if (grep /banque/i,$ref){$style="style=background-color:lightblue";$total_bq+=$montant;}
		if ((grep /BANQUE/,$ref)||(grep /MONTEIRO/,$ref)){$ref="$ref $montant_dev";} 
 		print "<tr style=background-color:$color><td><a onclick=window.open(\"/cgi-bin/saicaisse.pl?border=$no&action=Bordereau\",\"_blank\",\"width=800,height=700,scrollbars=yes\")>$no</a></td><td>$date_remise</td><td align=right>$montant</td><td align=right>$cash</td><td align=right>$ref</td>";
 		$count{"$ref"}++;
 		$montant{"$ref"}+=$montant_dev;
 		$nb_ref=&get("select count(*) from bordereau where ref='$ref' and devise='$dev'")+0;
 		# if (((grep /^E[0-9]/,$ref)||(grep /^D[0-9]/,$ref)||(grep /^F[0-9]/,$ref)||(grep /^A[0-9]/,$ref))&&($count{"$ref"}==$nb_ref)){
		if ((grep /^[A-Z][0-9]/,$ref)&&($count{"$ref"}==$nb_ref)){
				
		($ref_bon,$null)=split(/\//,$ref);
		  print "<td align=right>";
		  $query="select montant from releve_bq where ref= '$ref_bon'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  $montant_bq=0;
		  while (($montant2)=$sth2->fetchrow_array){
		    $montant_bq+=$montant2;
		  }
		  $montant_bq_dev=$montant_bq;
		  if ($dev eq "EUR"){$montant_bq_dev=int($montant_bq/655.957);}
		  if ($dev eq "USD"){$montant_bq_dev=int($montant_bq/480);}
	
		  $ecart=$montant_bq-$montant{"$ref"};
		  if (($montant_bq==$montant{"$ref"})||($montant_bq_dev==$montant)||($ecart==-100)){
		     if (($dev eq "EUR")||($dev eq "USD")){
		      print "<img src=/images/check.png></td><td align=right>";
		    }  
		    print "<img src=/images/check.png>";
# 		    $ecart=0;
		  }
		  else
		  {
		    if (($dev eq "EUR")||($dev eq "USD")){
		      print "$montant_bq_dev</td><td align=right>";
		    }  
		    print "$montant_bq";
# 		    $ecart=$montant_bq-$montant{"$ref"};
		  }
		  print "</td>";
		  print "<td align=right>";
		  if ($ecart==0){print "&nbsp;";}else{
		  $ecart=int($ecart);
		  print "$ecart";
		  }
		  print "</td>";
		}
		else
		{
		  print "<td>&nbsp;</td><td>&nbsp;</td>";
		  if (($dev eq "EUR")||($dev eq "USD")){print "<td>&nbsp;</td>";}
		}
		if (($user eq "daniel")||($user eq "sylvain")||($user eq "philippe")){
		  print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modif_info&an_ref=$an_ref&no=$no&dev=$dev&date_ref_fin=$date_ref_fin><img border=0 src=../../images/b_edit.png title='modifier'></a></td>";
		}
		print "</tr>";
 		$total_gen+=$montant;
		$total_cash+=$cash;
 	}

# 	print "<tr><th>Bordereau</th><th>Caisse</th><th>Remise ";
# 	print "</th></tr>";
# 	$query="select no,montant from bordereau where date_remise >'$date_ref' and date_creation>'$date_ref' and devise='$dev'";
# 	$sth=$dbh->prepare($query);
# 	$sth->execute();
# 	while (($no,$montant)=$sth->fetchrow_array){
# 		$montant_init=&montant_bordereau($no,$dev)+0;
# 		print "<tr><td>$no</td><td align=right bgcolor=#efefef>$montant_init</td><td align=right>$montant</td></tr>";
# 		$total_gen+=$montant;
# 	}
	
	print "<tr><td colspan=2><b>Total</b></td><td align=right><b>$total_gen</b></td><td align=right><b>$total_cash</b></td></tr>";
# 	print "<tr><td colspan=2><b>Total remise banque</b></td><td align=right><b>$total_bq</b></td>";
	print "</tr>";

	print "</table>";
}
sub montant_bordereau{
	my $no=$_[0];
	my $total_xof,$total_dol,$total_eur,$total_stim,$total_stim,$total_cb=0;
	$query="select ca_code,ca_rot,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	while (($ca_code,$ca_rot,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth->fetchrow_array){
		($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
		($xaf_1,$xaf_2,$xaf_3,$xaf_4)=split(/:/,$ca_xaf);
		($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
		($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
		$total_xof+=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
		$total_xaf+=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000;
		$total_dol+=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
		$total_eur+=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
		$total_cb+=$ca_cab;
		$total_stim+=$ca_papi;
		# print "$no $ca_code $total_xof<br>";

	}
	my $montant=0;
	if ($_[1] eq "XAF") { $montant=$total_xaf;}
	if ($_[1] eq "XOF") { $montant=$total_xof;}
	if ($_[1] eq "USD") { $montant=$total_dol;}
	if ($_[1] eq "EUR") { $montant=$total_eur;}
	return($montant);
}
		
;1