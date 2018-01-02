$mois=$html->param("mois");
$montant=$html->param("montant");
$client=$base_client_code;
print "<title>Recap de caisse</title>";

if ($action eq "validation de la facture"){
	$dbh->do("replace into recapclient values ('$client','$mois',now(),'$montant')");
	$action="go";
}
if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
if ($mois <100){$mois=`/bin/date +%m%y`+1099;} 

if ($action eq ""){
	print "<center>Recap<br><form>";
	&form_hidden();
	print "Mois (MMAA):<input type=text name=mois value='$mois'><br>";
	print " <input type=submit>"; 
	print "<input type=hidden name=action value=go>";
	print "</form>";
	print "<br>Liste des 15 dernieres recaps validées<br><br>";
	print "<table border=1 cellspacing=0 width=70%><tr><th>Mois validé</th><th>Date de validation</th><th>Client</th></tr>";
	$query="select date,mois,cl_nom from recapclient,client where cl_cd_cl=client order by date desc limit 15";	
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($date,$mois,$cl_nom)=$sth->fetchrow_array){
		print "<tr><td>date:$mois</td><td>$date</td><td>$cl_nom</td></tr>";
	}
	print "</table><br><br>";
	print "<br>Liste des recaps validées<br><br>";
	print "<table border=1 cellspacing=0 width=70%><tr><th>Mois validé</th><th>Date de validation</th><th>Client</th></tr>";
	$query="select date,mois,cl_nom from recapclient,client where cl_cd_cl=client order by cl_cd_cl,date desc";	
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($date,$mois,$cl_nom)=$sth->fetchrow_array){
		print "<tr><td>date:$mois</td><td>$date</td><td>$cl_nom</td></tr>";
	}
	print "</table>";
}

if ($action eq "go"){
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	print "Mois:$mois   Client:$cl_nom <br>";
	$query="select v_code from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1  and v_troltype>100 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 bordercolor=black cellspacing=0 style=\"border: solid;\"><tr><th>Bon</th><th>Date</th><th>Rot</th><th>Type</th><th>Commentaire</th><th>PNC</th><TH>Caisse</th><th>bordereau</th><TH>Stim</th><th>Vol</th><th>Destination</th>";
	print "<th><font size=-2>Chiffre d'affaire constaté par DFC</th><th><font size=-2>Valeur de la marchandise manquante constatée au départ</th>";
	print "<th>Total Caisse</th>";
	print"<th >Ecart caisse</th><th><font size=-2>Valeur des caisses manquantes</th></tr>\n";
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
			$etat=&get("select at_etat from etatap where at_code='$v_code'");
			if ($etat<5){$color="pink";}
			print "<tr bgcolor=$color ><td align=right nowrap>$v_code</td><td align=right nowrap>$v_date</td><td align=right nowrap>$v_rot</td><td>$v_troltype</td>";
			print "<td>";
			$commentaire=&get("select com_reponse from commentaire where com_appro=$v_code and com_rot=$v_rot");
			print $commentaire;
			print "</td>";	
			print "<td><font size=-1>&nbsp;<nobr>";
			$eq_tri="";
			$query="select eq_cc,eq_equipage from equipagesql where eq_code='$v_code' and eq_rot='$v_rot'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($eq_cc,$eq_tri)=$sth2->fetchrow_array;
			print &pnc($eq_cc)." ";
			(@equipe)=split(/;/,$eq_tri);
			foreach (@equipe){
				print &pnc($_)." "; 
			}
			$query="select ca_total,ca_papi from caissesql where ca_code='$v_code' and ca_rot='$v_rot'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
			$ca_recettes+=0;
			if ($ca_recettes==0){
				$query="select ca_recettes/100,ca_cheque/100 from caisse where ca_code='$v_code' and ca_rot='$v_rot'";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
			}
			
			$ca_recettes-=$ca_papi;
			print "</td><td align=right nowrap>";
			print &deci($ca_recettes);
			print "</td><td align=right nowrap>";
			$ca_border=&get("select ca_border from caissesql where ca_code='$v_code' and ca_rot='$v_rot'");
			print $ca_border;
			print "</td><td align=right nowrap>";
			print &deci($ca_papi);
			$total_papi+=$ca_papi;
			print "<td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
			if ($v_rot==1){
				$ca_fly="";
				$query="select sum(ca_fly/100) from caisse where ca_code='$v_code' group by ca_code";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($ca_fly)=$sth2->fetchrow_array;
				$query="select sum(ca_total),sum(ca_papi) from caissesql where ca_code='$v_code' group by ca_code";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
				$ca_recettes-=$ca_papi;
				if ($ca_recettes==0){
					# print "<td>*";
					$query="select sum(ca_recettes/100),sum(ca_cheque/100) from caisse where ca_code='$v_code' group by ca_code";
					$sth2=$dbh->prepare($query);
					$sth2->execute();
					($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
				}
				$query="select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code' and ret_type=1 group by ret_code";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($vol)=$sth2->fetchrow_array;
				$ca_fly-=$vol;
				if (($v_code eq "31385")&&($client==180)){$ca_fly=995;}
				if (($v_code eq "31390")&&($client==180)){$ca_fly=104;}
	            
				$ca_ristourne=&get("select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code'  and (ret_cd_pr=280700 or ret_cd_pr=280600 )")+0;
				
				$query="select ecpn_prix from ecartpn where ecpn_code='$v_code'";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($ecart_pn)=$sth2->fetchrow_array;
				$query="select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code' and ret_type!=1 group by ret_code";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($ecart_fly)=$sth2->fetchrow_array;
				$vente_pn=$ca_fly-$ecart_fly+$ecartpn; # retiré le 15 septembre 2011 pas raison d'ecart
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
				if ($vta_rot1!=0){
					if ($vta_flag1==1){print "<font color=red>";}
				}
				if ($vta_rot2!=0){
					if ($vta_flag2==1){print "<font color=red>";}
				}
				if ($vta_rot3!=0){
					if ($vta_flag3==1){print "<font color=red>";}
				}
				if ($vta_rot4!=0){
					if ($vta_flag1==1){print "<font color=red>";}
				}
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
				print "<td rowspan=$nbrot align=right nowrap>";
				# ici chiffre d affaire constater
				print &deci($ca_fly);
				print "</td>";
				print "<td rowspan=$nbrot align=right nowrap>";
				print &deci($ecart_pn);
				print "</td>";
				print "<td rowspan=$nbrot align=right nowrap>";
				print &deci($ca_recettes);
				print "</td><td rowspan=$nbrot align=right nowrap>";
				$ecart_caisse=$ca_recettes+$ca_papi-$ca_fly;		
				print &deci($ecart_caisse);
				print "</td><td rowspan=$nbrot align=right nowrap>";
				print &deci($manquante);
				print "</td>";
				$total_vpn+=$vente_pn;	
				$total_vfly+=$ca_fly;	
				$total_efly+=$ecart_pn;	
				$total_epn+=$ecart_fly;	
				$total_caisse+=$ca_recettes;	
				$total_compn+=$compn;	
				$total_ecart+=$ecart_caisse;	
				$total_manq+=$manquante;	
				$total_ristourne+=$ca_ristourne;
			}
			print "</tr>\n";
		}
	}
	print "<tr><th colspan=7>TOTAL</th>";
	print "<th  align=right>";
	print &deci($total_papi);
	print "<th colspan=2>&nbsp;</th>";
	print "<th align=right>";
	print &deci($total_vfly);
	print "</th><th align=right>";
	print &deci($total_efly);
	print "</th><th align=right>";
	print &deci($total_caisse);
	print "</th><th align=right>";
	print &deci($total_ecart);
	print "</th><th align=right>";
	print &deci($total_manq);
	print "</th></tr>\n</table>";
	print "<br><Table border=1><tr><th>&nbsp;</th><th>Eur</th><th>Xof</th></tr>";
	print "<tr><td><b>Chiffre d'affaire:</td><td align=right><b>";
	print &deci($total_vfly);
	print "</td><td align=right>";
	print int($total_vfly*655.957);
	print "</td></tr>\n";
	print "<tr><td><b>Net encaissé:</td><td align=right><b>";
	print &deci($total_caisse);
	print "</td><td align=right>";
	print int($total_caisse*655.957);
	print "</td></tr>\n";
	print "<tr><td>Commissions $cl_com1%</td><td align=right>";
	if (cl_com1 eq ""){$cl_com1=100;}
	$com=($total_caisse-$total_ristourne)*$cl_com1/100;
	print &deci($com);
	print "</td><td align=right>";
	print int($com*655.957);
	print "</td></tr>";
	$com_ristourne=0;
	if ($total_ristourne >0){
		print "<tr><td>Commissions 10%</td><td align=right>";
		if (cl_com1 eq ""){$cl_com1=100;}
		$com_ristourne=($total_ristourne)*10/100;
		print &deci($com_ristourne);
		print "</td><td align=right>";
		print int($com_ristourne*655.957);
		print "</td></tr>";
	}
	print "<tr><td>Produits manquants</td><td align=right>";
	print &deci($total_epn);
	print "</td><td align=right>";
	print int($total_epn*655.957);
	print "</td></tr>";
	print "<tr><td>Ecart de caisse</td><td align=right>";
	print &deci($total_ecart);
	print "</td><td align=right>";
	print int($total_ecart*655.957);
	print "</td></tr>";
	print "<tr><td>Caisses manquantes</td><td align=right>";
	print &deci($total_manq);
	print "</td><td align=right>";
	print int($total_manq*655.957);
	print "</td></tr>";
	print "<tr><td><b>Soldes</td><td align=right><b>";
	$solde=$com+$com_ristourne-$total_epn-$total_compn+$total_ecart-$total_manq;
	print &deci($solde);
	print "</td><td align=right>";
	print int($solde*655.957);
	print "</td></tr>";
	print "</table>";
	$query="select date,montant from recapclient where client='$client' and mois='$mois'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($recap_date,$montant)=$sth->fetchrow_array;
	$montant+=0;
	if ($recap_date eq ""){
		print "<form>";
		&form_hidden();
		print "<br>Montant pris en charge <input type=text name=montant> <input type=submit name=action value=\"validation de la facture\"><input type=hidden name=client value=$client>";
		print "<input type=hidden name=mois value=$mois></form>";
	}
	else
	{
		print "<br>Montant pris en charge par DFC: $montant<h3><font color=red>validation par philippe Perraud le $recap_date</font></h3>";
	}
}
sub pnc{
	my $pnc=$_[0];
	if ($pnc eq "") { return;}
	my $query="select hot_tri from hotesse where (hot_mat='$pnc' or hot_tri='$pnc') and hot_cd_cl='$client'";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	(my $hot_tri)=$sth->fetchrow_array;
	if ($hot_tri eq ""){return "<a href=equipage.pl?client=$client&appro=$v_code&rot=$v_rot><font color=red>$pnc</font></a>";}
	else{
		return($hot_tri);
	}
}

;1

