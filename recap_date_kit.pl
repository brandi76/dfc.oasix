
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
if ($action eq ""){&premiere();}
if ($action eq "remise"){&go();}
if ($action eq "client"){&clien();}
if ($action eq "cout"){&cout();}

sub premiere{
	print "<center>Recap<br><form>";
	&form_hidden();
	print "Mois (MMAA)( date du vol) :<input type=text name=mois value='$mois'><br>";
	print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=$base_client><br><br>"; 	
	print "Controle des dates de remise <input type=submit name=action value=remise><br>"; 
	print "Cout de chargement <input type=submit name=action value=cout>";
	print "</form>";	

}

sub clien{
	$query="select distinct cl_cd_cl,cl_nom from client,trolley where floor(tr_code/10)=cl_cd_cl order by cl_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
		print "$cl_cd_cl $cl_nom <br>";
	}
}

sub go{
	$t_xof_1,$t_xof_2,$t_xof_3,$t_xof_4,$t_xof_5,$t_xaf_1,$t_xaf_2,$t_xaf_3,$t_xaf_4,$t_dol_1,$t_dol_2,$t_dol_3,$t_dol_4,$t_dol_5,$t_dol_6,$t_eur_1,$t_eur_2,$t_eur_3,$t_eur_4,$t_eur_5,$t_eur_6=0;
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	print "Mois:$mois   Client:$cl_nom <br>";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Appro</th><th>No vol</th><th>Rot</th><th>Bordereau</th><th>Date du vol</th><th>Date saisie du retour</th><th>Date saisie de caisse</th><th>Date remise en banque</th><th>Xof</th><th>Xaf</th><th>Dollar</th><th>Euro</th><th>Carte</th></tr>";
	$query="select v_code,v_vol,v_dest,v_date,ca_rot,ca_total,ca_border from vol,caissesql  where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=ca_rot and v_code=ca_code and v_code >0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_dest,$v_date,$ca_rot,$montant_caisse,$ca_border)=$sth->fetchrow_array){
		$total_xof=$total_xaf=$total_dol=$total_eur=$total_stim=$total_cb=0;
		print "<td align=right nowrap>$v_code</td><td align=right nowrap>$v_vol</td><td align=right nowrap>$ca_rot</td><td>$ca_border</td>";
		$v_date_ref=&datemysql($v_date);
		print "<td align=right nowrap>";
		print &date_iso($v_date_ref);
		print "</td>";
		$date_retour=&get("select infr_date from inforetsql where infr_code=$v_code");
		print "<td>";
		$ecart=&get("select datediff('$date_retour','$v_date_ref')");
		print &date_iso($date_retour);
		print "(+$ecart)";
		print "</td>";
		$date_creation=&get("select date_creation from bordereau  where no='$ca_border' ");
		print "<td>";
		$ecart=&get("select datediff('$date_creation','$v_date_ref')");
		print &date_iso($date_creation);
		print "(+$ecart)";
		print "</td>";
		# $date_remise=&get("select date_remise from bordereau  where no='$ca_border' and devise='$base_dev1' ");
		$date_remise=&get("select max(date_remise) from bordereau where no='$ca_border'");
		print "<td bgcolor=";
		
		$ecart=&get("select datediff('$date_remise','$v_date_ref')");
		if ($date_remise eq "0000-00-00"){
			$ecart=&get("select datediff(curdate(),'$date_creation')","af");
			print "pink>";
		}
		else {
			print "white>";
		}
		print &date_iso($date_remise);
		print "(+$ecart)";
		print "</td>";
		$query="select ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_code='$v_code' and ca_rot='$ca_rot'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth2->fetchrow_array;
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
		print "<td align=right>$total_xof";
		print "</td>";
		print "<td align=right>$total_xaf";
		print "</td>";
		print "<td align=right>$total_dol";
		print "</td>";
		print "<td align=right>$total_eur";
		print "</td>";	
		print "<td align=right>$total_carte";
		print "</td>";
		print "</tr>";
		$totalt_xof+=$total_xof;
		$totalt_xaf+=$total_xaf;
		$totalt_dol+=$total_dol;
		$totalt_eur+=$total_eur;
		$totalt_carte+=$total_carte;

	}
	print "<tr><td colspan=7><b>total</b></td>";
	print "<td align=right><b>$totalt_xof</b>";
	print "</td>";
	print "<td align=right><b>$totalt_xaf</b>";
	print "</td>";
	print "<td align=right><b>$totalt_dol</b>";
	print "</td>";
	print "<td align=right><b>$totalt_eur</b>";
	print "</td>";	
	print "<td align=right><b>$totalt_carte</b>";
	print "</td>";
	print "</table>";
}
sub cout{
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	print "Mois:$mois   Client:$cl_nom <br>";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Appro</th><th>No vol</th><th>Date du vol</th><th>Ca</th><Th>Trolley</th><th>Cout</th></tr>";
	$query="select v_code,v_vol,v_dest,v_date,v_troltype from vol  where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 and v_code >0 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_dest,$v_date,$v_troltype)=$sth->fetchrow_array){
		$ca=&get("select sum(ca_total) from caissesql where ca_code='$v_code'")+0;
		$cout=&get("select lot_cout from lot where lot_nolot='$v_troltype'")+0;
		$color="white";
		if ($cout==0){$color="pink";}
		if ($ca==0){$color="#efefef";}
		
		print "<tr bgcolor=$color>";
		print "<td align=right nowrap>$v_code</td><td align=right nowrap>$v_vol</td>";
		$v_date_ref=&datemysql($v_date);
		print "<td align=right nowrap>";
		print &date_iso($v_date_ref);
		print "</td>";
		print "<td align=right>$ca";
		print "</td>";
		print "<td align=right>$v_troltype";
		print "</td>";
		$cout=&get("select lot_cout from lot where lot_nolot=$v_troltype")+0;
		print "<td align=right>$cout";
		if ($ca!=0){$total{$cout}++;}
		print "</td>";
		$total_ca+=$ca;
		print "</tr>";

	}
	print "</table>";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Description</th><th>Nombre</th><th>prix total</th></tr>";
	foreach $cle (keys %total){
	  print "<tr><td>Nombre de chargement à $cle Euros</td><td>$total{$cle}</td>";
	  $px_total=$cle*$total{$cle};
	  print "<td align=right>$px_total Euros<br></tr>";
	  $totalpx+=$px_total;
	}
	if ($base_dbh eq "togo"){
	  print "<tr><td>Commision sur CA:</td><td>$total_ca Euros</td>";
	  $com=$total_ca/100;
	  print "<td align=right>$com Euros</td></tr>";
	  $totalpx+=$com;
	}
	print "</table>";
	
	print "Total euros:$totalpx euros";
}


;1