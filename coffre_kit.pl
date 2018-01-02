print "<script>";
	print "function recalcul()
	{	
	      l_10000.innerHTML=eval(document.fiche.nb_10000.value)*10000+0;
	      l_5000.innerHTML=eval(document.fiche.nb_5000.value)*5000+0;
	      l_2000.innerHTML=eval(document.fiche.nb_2000.value)*2000+0;
	      l_1000.innerHTML=eval(document.fiche.nb_1000.value)*1000+0;
	      l_500.innerHTML=eval(document.fiche.nb_500.value)*500+0;
	      l_100.innerHTML=eval(document.fiche.nb_100.value)*100+0;
	      l_50.innerHTML=eval(document.fiche.nb_50.value)*50+0;
	      l_20.innerHTML=eval(document.fiche.nb_20.value)*20+0;
	      l_10.innerHTML=eval(document.fiche.nb_10.value)*10+0;
	      l_5.innerHTML=eval(document.fiche.nb_5.value)*5+0;
	      l_2.innerHTML=eval(document.fiche.nb_2.value)*2+0;
	      l_1.innerHTML=eval(document.fiche.nb_1.value)*1+0;
	      document.fiche.montant.value=eval(document.fiche.nb_10000.value)*10000+eval(document.fiche.nb_5000.value)*5000+eval(document.fiche.nb_2000.value)*2000+eval(document.fiche.nb_1000.value)*1000+eval(document.fiche.nb_500.value)*500+eval(document.fiche.nb_1000.value)*100+eval(document.fiche.nb_50.value)*50+eval(document.fiche.nb_20.value)*20+eval(document.fiche.nb_10.value)*10+eval(document.fiche.nb_5.value)*5+eval(document.fiche.nb_2.value)*2+eval(document.fiche.nb_1.value);
	     
	 
	}";

print "</script>";
	
require "./src/connect.src";
$date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
$date_ref="2013-06-30";
$action=$html->param("action");
$montant=$html->param("montant");
$devise=$html->param("devise");
$date=$html->param("date");
if (grep(/\//,$date)) {
        ($jj,$mm,$aa)=split(/\//,$date);
        $date=$aa."-".$mm."-".$jj;
}

if ($action eq "justif"){
  $justif=&addslashes($html->param("justif"));
  &save("update coffre set justificatif='$justif' where date='$date' and devise='$devise'");
  $action="";
}

if ($action eq "go")
{
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
		

	}
	$val_anc=&get("select montant from encaissement where date='$date_ref' and devise='$devise'","af")+0;
	$val_ent=$total{"$devise"};
	$val_sor=&get("select sum(montant) from bordereau where date_remise >'$date_ref' and date_creation>'$date_ref' and devise='$devise'")+0;
	$val_res=$val_anc-$val_sor+$val_ent;
	$ecart=$montant-$val_res;
	if ($ecart!=0){
	  print "<p class=erreur>$devise Ecart $ecart $devise </p>";
	  print "<form>";
	  &form_hidden();
	  print "Justificatif ?<input type=text name=justif> <input type=submit><input type=hidden name=action value=justif><input type=hidden name=devise value=$devise><input type=hidden name=date value=$date></form>";
	}
	&save("replace into coffre value ('$date','$devise','$montant','$ecart','')");
	$action="";
}

if ($action eq ""){
	print "<h2>Saisie du coffre</h2><br>";
	print "<form name=fiche>";
	&form_hidden();
	$query="select distinct devise from bordereau where date_remise='0000-00-00' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<br>Choisir une devise <select name=devise>";
	while (($dev,$desi)=$sth->fetchrow_array)
	{
	  print "<option value=$dev>$dev $desi</option>";	
	}
	print "</select><br><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date value=$date_du_jour><br>";
	print "
		<table border=1>
			<tr><th>Nombre</th><th>Billet</th><th>Total</th></tr>
			<tr><td align=center ><input type=text value=0 name=nb_10000 size=4  Onchange=recalcul();></td><td align=center >10000</td> <td align=center ><div id=l_10000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_5000 size=4 Onchange=\"recalcul();\"></td><td align=center >5000</td> <td align=center ><div id=l_5000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_2000 size=4 Onchange=\"recalcul();\"></td><td align=center >2000</td> <td align=center ><div id=l_2000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_1000 size=4 Onchange=\"recalcul();\"></td><td align=center >1000</td> <td align=center ><div id=l_1000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_500 size=4 Onchange=\"recalcul();\"></td><td align=center >500</td> <td align=center ><div id=l_500>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_100 size=4 Onchange=\"recalcul();\"></td><td align=center >100</td> <td align=center ><div id=l_100>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_50 size=4 Onchange=\"recalcul();\"></td><td align=center >50</td> <td align=center ><div id=l_50>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_20 size=4 Onchange=\"recalcul();\"></td><td align=center >20</td> <td align=center ><div id=l_20>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_10 size=4 Onchange=\"recalcul();\"></td><td align=center >10</td> <td align=center ><div id=l_10>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_5 size=4 Onchange=\"recalcul();\"></td><td align=center >5</td> <td align=center ><div id=l_5>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_2 size=4 Onchange=\"recalcul();\"></td><td align=center >2</td> <td align=center ><div id=l_2>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_1 size=4 Onchange=\"recalcul();\"></td><td align=center >1</td> <td align=center ><div id=l_1>0</div></td></tr>
		</table>	
	";
	print "Montant <input type=text name=montant><br>";
	print "<input type=hidden name=action value=go>";
	print "<br><input type=submit>";
	print "</form>";
	print "<br>Dernières saisies<br>";
	$max_date=&get("select max(date) from coffre");
	$query="select * from coffre where date='$max_date'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($date,$devise,$montant,$ecart,$justif)=$sth->fetchrow_array){
	    print "$date $devise $montant $ecart $justif<br>";
	}
	
}	


;1
