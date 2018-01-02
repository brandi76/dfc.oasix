print "<title>Gestion des bordereaux de remise en banque</title>";

require "./src/connect.src";
$dev=$html->param("dev");
$no=$html->param("no");
$action=$html->param("action");
$montant=$html->param("montant");
$edition=$html->param("edition")+0;
$edition2=$html->param("edition2")+0;
$devise=$html->param("devise");
if ($devise eq "Toute"){$devise="%";}

$ref=$html->param("ref");
$date_remise=$html->param("date_remise");

print "<center>";
if ($action eq "go") {
	$query="select * from bordereau where no >='$edition' and no <='$edition2' and devise like '$devise'";
	
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table><tr><th>No</th><th>Devise</th><th>Date de creation</th><th>Date de remise</th><th>Reference</th><th>Montant saisie</th><th>Montant remis</th><th>Montant cash</th><th>Ecart</th></tr>";
	while (($no,$devise,$date_creation,$date_remise,$ref,$montant)=$sth->fetchrow_array){
		# &save("insert ignore into bordereau values ('$no','EUR','$date_creation','','','')","aff");
		# &save("insert ignore into bordereau values ('$no','USD','$date_creation','','','')","aff");
	
		$t_xof_1,$t_xof_2,$t_xof_3,$t_xof_4,$t_xof_5,$t_xaf_1,$t_xaf_2,$t_xaf_3,$t_xaf_4,$t_xaf_5,$t_dol_1,$t_dol_2,$t_dol_3,$t_dol_4,$t_dol_5,$t_dol_6,$t_eur_1,$t_eur_2,$t_eur_3,$t_eur_4,$t_eur_5,$t_eur_6=0;
		$total_xof=$total_xaf=$total_dol=$total_eur=0;
		$query="select ca_xof,ca_xaf,ca_dol,ca_eur from caissesql where ca_border='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ca_xof,$ca_xaf,$ca_dol,$ca_eur)=$sth2->fetchrow_array){
			($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
			($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
			($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
			($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
			$total_xof+=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
			$total_xaf+=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000+$xaf_5*500;
			$total_dol+=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
			$total_eur+=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
		}
		
		$saisie=0;
		
		if ($devise eq "XOF"){$saisie=$total_xof;}
		if ($devise eq "XAF"){$saisie=$total_xaf;}
		if ($devise eq "USD"){$saisie=$total_dol;}
		if ($devise eq "EUR"){$saisie=$total_eur;}
		$cash=0;
		if ($devise eq "XOF") {$cash=&get("select montant from cash where bordereau='$no'")+0;}
		$montant-=$cash;
		print "<tr><td>$no</td><td>$devise</td><td>$date_creation</td><td>$date_remise</td><td>$ref</td><td>$saisie</td><td>$montant</td><td>$cash</td>";
		$ecart=$montant+$cash-$saisie;
		print "<td>$ecart</td>";
		print "</tr>";

		$total_saisie+=$saisie;
		$total_montant+=$montant;	
		$total_cash+=$cash;	
		
	}
	$ecart=$total_montant+$total_cash-$total_saisie;
	print "<tr><th colspan=5>Total</th><th>$total_saisie</th><th>$total_montant</th><th>$total_cash</th><th>$ecart</th></table>";

}

if ($action eq ""){
	print "<h2>Edition des bordereaux de remise en banque</h2><br>";
	print "<form>";
	require ("form_hidden.src");
	print "Edition depuis le numero de bordereau ? <input type=text name=edition >";
	print "<br>Jusqu'au numero de bordereau ? <input type=text name=edition2 value=\"99999999\">";
	
	$query="select distinct devise from bordereau where date_remise='0000-00-00' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<br>Choisir une devise <select name=devise>";
	print "<option value=Toute>Toute</option>";	
	while (($dev,$desi)=$sth->fetchrow_array)
	{
		print "<option value=$dev>$dev $desi</option>";	
	}
	print "</select><br><br>";
	print "<br><br> <input type=submit value=edition>";
	print "<input type=hidden name=action value=go>";
	print "</form>";
}

;1
