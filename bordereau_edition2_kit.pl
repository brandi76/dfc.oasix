print "<title>Gestion des bordereaux de remise en banque</title>";

require "./src/connect.src";
$dev=$html->param("dev");
$no=$html->param("no");
$action=$html->param("action");
$montant=$html->param("montant");
$date=$html->param("date");
$devise=$html->param("devise");
if ($devise eq "Toute"){$devise="%";}

$ref=$html->param("ref");
$date_remise=$html->param("date_remise");
$mois=substr($date,0,2);
$an=substr($date,2,2);
$date_sql_debut="20".$an."-".$mois."-01";
$mois++;
# if ($mois <10){$mois="0".$mois;}
if ($mois ==13){$mois="01";$an++;}
$date_sql_fin="20".$an."-".$mois."-01";

print "<center>";
if ($action eq "go") {
	print "<h3>Bordereau saisie sur la periode :$date</h3>";
	# $query="select distinct ca_border from  vol,caissesql where right(v_date,4)='$date' and v_code=ca_code";
	 $query="select distinct no from bordereau where date_creation>='$date_sql_debut' and date_creation<'$date_sql_fin'" ;
	# print "$query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0 cellpadding=0><tr><th></th><th>No</th><th>Date vol</th><th>Xof</th><th>Xaf</th><th>Dollar</th><th>Euro</th><th>Carte</th><th>Stim</th></tr>";
	while (($no)=$sth->fetchrow_array){
		$t_xof_1,$t_xof_2,$t_xof_3,$t_xof_4,$t_xof_5,$t_xaf_1,$t_xaf_2,$t_xaf_3,$t_xaf_4,$t_dol_1,$t_dol_2,$t_dol_3,$t_dol_4,$t_dol_5,$t_dol_6,$t_eur_1,$t_eur_2,$t_eur_3,$t_eur_4,$t_eur_5,$t_eur_6=0;
		$total_xof=$total_xaf=$total_dol=$total_eur=$total_stim=$total_cb=0;
		# $query="select ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql,vol where ca_border='$no' and right(v_date,4)='$date' and v_code=ca_code";
		$query="select ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth2->fetchrow_array){
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
		if($color eq "white"){$color="#efefef";}else{$color="white";}
		print "<tr bgcolor=$color><td>Saisie</td><td>$no</td><td>";
		$query="SET lc_time_names = 'fr_FR'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$query="select distinct monthname(v_date_sql) from vol,caissesql where v_code=ca_code and ca_border='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($mois)=$sth2->fetchrow_array){
		print "$mois ";
		}
		print "</td>";
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
		print "<td align=right>$total_stim";
		print "</td>";
		print "</tr>";
		print "<tr bgcolor=$color><td>Remise</td><td>$no</td><td>&nbsp;</td>";
		print "<td align=right>";
		$mont=&get("select montant from bordereau where no='$no' and devise='XOF'")+0;
		print $mont;
		$totalb_xof+=$mont;
		print "</td>";
		print "<td align=right>";
		$mont= &get("select montant from bordereau where no='$no' and devise='XAF'")+0;
		print $mont;
		$totalb_xaf+=$mont;
		print "</td>";
		print "<td align=right>";
		$mont= &get("select montant from bordereau where no='$no' and devise='USD'")+0;
		print $mont;
		$totalb_dol+=$mont;
		print "</td>";
		print "<td align=right>";
		$mont= &get("select montant from bordereau where no='$no' and devise='EUR'")+0;
		print $mont;
		$totalb_eur+=$mont;
		print "</td>";	
		print "<td align=right>&nbsp;";
		print "</td>";
		print "<td align=right>&nbsp;";
		print "</td>";
		print "</tr>";
			
		$totall_xof+=$total_xof;
		$totall_xaf+=$total_xaf;
		$totall_dol+=$total_dol;
		$totall_eur+=$total_eur;
		$totall_carte+=$total_carte;
		$totall_stim+=$total_stim;
	}
	print "<tr><th>Total saisie</th><th></th><th></th><th align=right>$totall_xof</th><th align=right>$totall_xaf</th><th align=right>$totall_dol</th><th align=right>$totall_eur</th><th align=right>$totall_carte</th><th align=right>$totall_stim</th></tr>";
	print "<tr><th>Total remise</th><th></th><th></th><th align=right>$totalb_xof</th><th align=right>$totalb_xaf</th><th align=right>$totalb_dol</th><th align=right>$totalb_eur</th><th align=right>&nbsp;</th><th align=right>&nbsp;</th></tr>";
	
	print "</table>";

}

if ($action eq ""){
	print "<h2>Edition des bordereaux de remise en banque</h2><br>";
	print "<form>";
	require ("form_hidden.src");
	$query="select distinct (right (v_date,4)) from vol where v_rot=1 order by v_code desc limit 20";
	print "Mois (date de saisie):";
	print "<select name=date>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ($date=$sth->fetchrow_array){
		print "<option>$date</option>";
	}
	print "</select>";
	print "<br><br> <input type=submit value=edition>";
	print "<input type=hidden name=action value=go>";
	print "</form>";
}

;1
