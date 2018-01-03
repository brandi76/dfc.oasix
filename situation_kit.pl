$date_ref_fin=$html->param("date_ref_fin");
$date_ref_fin=&datepicker($date_ref_fin);
$date_ref_debut=substr($date_ref_fin,0,4)."-01-01";
# print "*** $date_ref_fin  $date_ref_debut ***"; 
$mois_fin=substr($date_ref_fin,5,2).substr($date_ref_fin,2,2);
$annee=substr($date_ref_fin,2,2);

if ($action eq "" ){
  print "<div class=titre>Situation</div><form>";
  &form_hidden();
  print "Date <input type=text name=date_ref_fin id=datepicker value='30/06/2014'>";
  print "<input type=hidden name=action value=go>";
  print "<input type=submit>";
  print "</form>";
}

$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$base_client_code'";
$sth=$dbh->prepare($query);
$sth->execute();
($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
$cl_com1=int($cl_com1*100)/100;

if ($action eq "go" ){
 	print "Base de $base_ville<br>";
	print "Position du ";
	print &date_iso($date_ref_debut);
	print " au ";
	print &date_iso($date_ref_fin);
	print "<br>";
	$query="select v_code from vol where v_cd_cl='$base_client_code' and v_date%100=$annee and v_date%10000<=$mois_fin and v_rot=1 and v_troltype>100 order by v_code";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total_compn=0;
	while (($code)=$sth->fetchrow_array){
		$query="select count(*) from vol where v_code='$code' group by v_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($nbrot)=$sth2->fetchrow_array;
			
		$query="select v_code,v_rot,v_vol,v_date,v_dest,v_troltype from vol where v_code='$code' order by v_rot";
		$sthb=$dbh->prepare($query);
		$sthb->execute();
		while (($v_code,$v_rot,$v_vol,$v_date,$v_dest,$v_troltype)=$sthb->fetchrow_array){
		if ($v_code ne $code_tampon){
			if ($color eq ""){$color='#BFEFEF';} 
			else {$color="";}
			$code_tampon=$v_code;
		}
		$query="select ca_total,ca_papi from caissesql where ca_code='$v_code' and ca_rot='$v_rot'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
		$ca_recettes-=$ca_papi;
		$total_papi+=$ca_papi;
		if ($v_rot==1){
			$ca_fly="";
# 			$ca_fly=&get("select at_ca from etatap where at_code='$v_code'");
			$ca_fly=&get("select sum(ca_fly/100) from caisse where ca_code='$v_code' group by ca_code");
		
			$query="select sum(ca_total),sum(ca_papi) from caissesql where ca_code='$v_code' group by ca_code";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
			$ca_recettes-=$ca_papi;
			$query="select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code' and ret_type=1 group by ret_code";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vol)=$sth2->fetchrow_array;
			$ca_fly-=$vol;
			$query="select ecpn_prix from ecartpn where ecpn_code='$v_code'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($ecart_pn)=$sth2->fetchrow_array;
			$query="select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code' and ret_type!=1 group by ret_code";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($ecart_fly)=$sth2->fetchrow_array;
			$vente_pn=$ca_fly-$ecart_fly+$ecartpn; # retir  le 15 septembre 2011 pas raison d'ecart
			$vente_pn=$ca_fly;
			$ecart_fly=0;
			$ecart_caisse=$ca_recettes-$vente_pn;
			$manquante=0;
			if (($ecart_fly<0)&&($ecart_caisse<0)){
				if ($ecart_fly>$ecart_caisse){
					$vente_pn+=$ecart_fly;
					$ecart_caisse-=$ecart_fly;
					$ecart_fly=0;
				}
				else
				{
					$vente_pn+=$ecart_caisse;
					$ecart_fly-=$ecart_caisse;
					$ecart_caisse=0;
				}
			}	
			if (($ecart_fly>0)&&($ecart_caisse>0)){
				if ($ecart_fly<$ecart_caisse){
					$vente_pn+=$ecart_fly;
					$ecart_caisse-=$ecart_fly;
					$ecart_fly=0;
				}
				else
				{
					$vente_pn+=$ecart_caisse;
					$ecart_fly-=$ecart_caisse;
					$ecart_caisse=0;
				}
			}	
			$query="select * from ventilcasql where vta_code='$v_code'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($vta_code,$vta_rot1,$vta_flag1,$vta_rot2,$vta_flag2,$vta_rot3,$vta_flag3,$vta_rot4,$vta_flag4)=$sth2->fetchrow_array;
			$ca_fly-=$ecart_pn;
			if ($ecart_pn+0!=0){
			    if ($ecart_fly+0 >=$ecart_pn){
				$ecart_fly-=$ecart_pn;
				$ecart_pn=0;
				}
				else
				{
				$ecart_pn-=$ecart_fly;
				$ecart_fly=0;
				}
			}
			$ecart_caisse=$ca_recettes+$ca_papi-$ca_fly;		
			$total_vpn+=$vente_pn;	
			$total_vfly+=$ca_fly;	
			$total_efly+=$ecart_pn;	
			$total_epn+=$ecart_fly;	
			$total_caisse+=$ca_recettes;	
			$total_compn+=$compn;	
			$total_stim+=$ca_papi;
			$total_ecart+=$ecart_caisse;	
			$total_manq+=$manquante;	
			$ca_cons=&get("select sum(ro_qte*pr_prac)/10000 from rotation,produit where ro_code='$v_code' and ro_cd_pr=pr_cd_pr")+0;
			$total_ca_com+=$ca_cons;
			
		}

	}
	}
	print "Chiffre d'affaire:<span style=position:absolute;left:800px>";
	print &deci($total_vfly);
	print "</span><br>";
	
	print "Montant redevance $cl_com1%:<span style=position:absolute;left:800px>";
	$com=$total_vfly*$cl_com1/100;
	print &deci($com);
	print "</span></br>";
	$total_vfly-=$com;
	print "Chiffre d'affaire net:<span style=position:absolute;left:800px>";
	print &deci($total_vfly);
	print "</span><br>";
	print "Cout marchandise vendue:<span style=position:absolute;left:800px>";
	print &deci($total_ca_com);
	print "</span><br>";
	print "Montant Stim<span style=position:absolute;left:800px>";
	print &deci($total_stim);
	print "</span><br>";
	&cout();
	print "Cout chargement<span style=position:absolute;left:800px>";
	print &deci($total_chargement);
	print "</span><br>";

	print "<table cellspacing=0 border=1>";
	print "<tr><th>Devise</th><th>Position au ";
	print &date_iso($date_ref_debut);
	print "</th><th>Traitement de la periode</th><th>Remise de la periode </th><th>Position fin de periode</th></tr>";
	$query="select distinct (no) from bordereau where date_creation >='$date_ref_debut' and date_creation<=adddate('$date_ref_fin',interval 0 day) order by no";
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
			$date_vol=&get("select v_date from vol where v_code=$ca_code and v_rot=1");
			$date_vol=&date(&daten($date_vol));
			$date_vol="20".$date_vol;
			$date_vol=~s/\//-/g;
 			 $ecart=&get("select datediff('$date_vol','$date_ref_debut')")+0;
 			 # print "$date_vol  $date_ref_debut<br>";
 			if ($ecart <0){next;}
			$ecart=&get("select datediff('$date_vol','$date_ref_fin')")+0;
 			if ($ecart >0){next;}
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
# 		print "$no $total_xaf<br>";
		$total{"USD"}+=$total_dol;
		$total{"EUR"}+=$total_eur;
# 		 print "<tr><td>$no:".$total{"EUR"}."</td></tr>";
		

	}
	
	@tabdevise=("XOF","XAF","USD","EUR");
	for $devise (@tabdevise) {
		$val_anc=&get("select montant from encaissement where date='$date_ref_debut' and devise='$devise'","af")+0;
		print "<tr><td align=right>$devise</td><td align=right>$val_anc</td>";
		$val_ent=$total{"$devise"};
		print "<td  align=right>$val_ent</td>";
		$val_sor=&get("select sum(montant) from bordereau where date_creation>='$date_ref_debut' and date_creation<='$date_ref_fin' and devise='$devise'")+0;
		print "<td  align=right>$val_sor</td>";
		$val_res=$val_anc-$val_sor+$val_ent;
		print "<td  align=right>$val_res</td></tr>";
	}
	print "</table><br><br><br>";
	print "<table>";
	$xof=&get("select sum(montant) from bordereau where date_creation>='$date_ref_debut' and date_creation<'$date_ref_fin' and devise='XOF'")+0;
	print "<tr><td>Recap xof:</td><td align=right>".$xof."</td></tr>";
	$cash=&get("select sum(montant)from cash where date >='$date_ref_debut' and date<='$date_ref_fin'")+0;
 	print "<tr><td>Montant cash:</td><td align=right>".$cash."</td></tr>";
 	$euro=&get("select sum(montantdev) from bordereau where date_creation>='$date_ref_debut' and date_creation<'$date_ref_fin' and devise='EUR'")+0;
	print "<tr><td>Euro:</td><td align=right>".$euro."</td></tr>";
	$usd=&get("select sum(montantdev) from bordereau where date_creation>='$date_ref_debut' and date_creation<'$date_ref_fin' and devise='USD'")+0;
	print "<tr><td>Dollars:</td><td align=right>".$usd."</td></tr>";
	$total=$xof-$cash+$euro+$usd;
	print "<tr><td>Total XOF   la banque:</td><td align=right>".$total."</td></tr></table>";
	
}

sub cout{
	$query="select v_code,v_vol,v_dest,v_date,v_troltype from vol  where v_cd_cl='$base_client_code' and v_date%100=$annee and v_date%10000<=$mois_fin and v_rot=1 and v_code >0 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_dest,$v_date,$v_troltype)=$sth->fetchrow_array){
		$ca=&get("select sum(ca_total) from caissesql where ca_code='$v_code'")+0;
		$cout=&get("select lot_cout from lot where lot_nolot='$v_troltype'")+0;
		$cout=&get("select lot_cout from lot where lot_nolot=$v_troltype")+0;
		if ($ca!=0){$total{$cout}++;}
		$total_ca+=$ca;
	}
	foreach $cle (keys %total){
	  $px_total=$cle*$total{$cle};
	  $total_chargement+=$px_total;
	}
	$com=0;
	if ($base_dbh eq "togo"){$com=2;}
	if (($base_dbh eq "togo")&&($an==14)){$com=1;}
	if ($base_dbh eq "camairco"){$com=1;}
# 	print "*** $com  $total_ca $total_chargement **<br>";		
	if ($com!=0){
	  $com=$com*$total_ca/100;
	  $total_chargement+=$com;
	}
}

		
;1
