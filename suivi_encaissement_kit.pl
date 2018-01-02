$dev=$html->param("dev");
$date_ref="2013-06-30";

if ($action eq "" ){
	print "<center>Suivi encaissement<br><form>";
	&form_hidden();
	print "Base de $base_ville<br>";
	print "Position au ";
	print &today();
	print "<br>";
	print "<table cellspacing=0 border=1>";
	print "<tr><th>Devise</th><th>Position au ";
	print &date_iso($date_ref);
	print "</th><th>Traitement de la periode</th><th>Remise de la periode </th><th>Position fin de periode</th></tr>";
	$query="select distinct (no) from bordereau where date_creation >'$date_ref'";
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
			$ecart=&get("select datediff('$date_vol','$date_ref')")+0;
			if ($ecart <1){next;}
		
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
		}
		$total{"XOF"}+=$total_xof;
		$total{"XAF"}+=$total_xaf;
		$total{"USD"}+=$total_dol;
		$total{"EUR"}+=$total_eur;
# 		 print "<tr><td>$no:".$total{"EUR"}."</td></tr>";
		

	}
	
	@tabdevise=("XOF","XAF","USD","EUR");
	for $devise (@tabdevise) {
		$val_anc=&get("select montant from encaissement where date='$date_ref' and devise='$devise'","af")+0;
		print "<tr><td align=right>$devise</td><td align=right>$val_anc</td>";
		$val_ent=$total{"$devise"};
		print "<td  align=right><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=det&dev=$devise>$val_ent</a></td>";
		$val_sor=&get("select sum(montant) from bordereau where date_remise >'$date_ref' and date_creation>'$date_ref' and devise='$devise'")+0;
		print "<td  align=right><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=det_rem&dev=$devise>$val_sor</a></td>";
		$val_res=$val_anc-$val_sor+$val_ent;
		print "<td  align=right>$val_res</td></tr>";
	}
	print "</table>";
}

if ($action eq "det"){
	print "<center>Suivi encaissement<br><form>";
	&form_hidden();
	print "Base de $base_ville<br>";
	print "Position au ";
	print &today();
	print "<br>";
	print "<table cellspacing=0 border=1>";
	print "<tr><th>Bordereau</th><th>Devise ";
	print "</th></tr>";
	$query="select distinct (no) from bordereau where date_creation >'$date_ref' ";
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
			$ecart=&get("select datediff('$date_vol','$date_ref')")+0;
			#print " $ecart";
			#print "<br>";
			if ($ecart <1){next;}
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
		}
		$montant=0;
		if ($dev eq "XAF") { $montant=$total_xaf;}
		if ($dev eq "XOF") { $montant=$total_xof;}
		if ($dev eq "USD") { $montant=$total_dol;}
		if ($dev eq "EUR") { $montant=$total_eur;}

		if ($montant !=0){
			print "<tr><td>$no</td><td align=right>$montant</td></tr>";
		}
		$total_gen+=$montant;
	
	}
	
	print "<tr><td><b>Total</b></td><td align=right><b>$total_gen</b></td></tr>";
	print "</table>";
}
	
if ($action eq "det_rem"){
	print "<center>Suivi encaissement<br><form>";
	&form_hidden();
	print "Base de $base_ville<br>";
	print "Position au ";
	print &today();
	print "<br>";
	print "<table cellspacing=0 border=1>";
 	print "<tr><th>Date</th><th>Montant</th><th>Libelle ";
 	print "</th></tr>";
 	$query="select date_remise,montant,ref from bordereau where date_remise >'$date_ref' and date_creation>'$date_ref' and devise='$dev'";
 	$sth=$dbh->prepare($query);
 	$sth->execute();
 	while (($date_remise,$montant,$ref)=$sth->fetchrow_array){
 		print "<tr><td>$date_remise</td><td align=right>$montant</td><td align=right>$ref</td></tr>";
 		$total_gen+=$montant;
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
	
	print "<tr><td ><b>Total</b></td><td align=right><b>$total_gen</b></td></tr>";
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