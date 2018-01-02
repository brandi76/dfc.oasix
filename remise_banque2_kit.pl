print "<title>Gestion des bordereaux de remise en banque</title>";

require "./src/connect.src";
$dev=$html->param("dev");
$no=$html->param("no");
$action=$html->param("action");
$montant=$html->param("montant");
$montantdev=$html->param("montantdev");
$dev=$html->param("dev");
$ref=$html->param("ref");
$ref=~s/'//g;
$date_remise=$html->param("date_remise");
if (grep(/\//,$date_remise)) {
        ($jj,$mm,$aa)=split(/\//,$date_remise);
        $date_remise=$aa."-".$mm."-".$jj;
}
print "<center>";
if ($action eq "go")
{
	$ok=1;
	@tabdevise=("XOF","XAF","USD","EUR");
	$query="select distinct no from bordereau where date_remise='0000-00-00' order by no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$bon=0;

	while (($no)=$sth->fetchrow_array){
		for $dev (@tabdevise) {
			if ($html->param("${no}_${dev}") eq "on"){$bon=1;}
		}
	}
	if ($bon==0){ print "<p class=erreur>Merci de choisir au moins un bordereau</p>";$ok=0;}
	if ($date_remise eq ""){ print "<p class=erreur>Merci de mettre une date</p>";$ok=0;}
	if ($ok==1){
		$query="select distinct(no) from bordereau where date_remise='0000-00-00'  order by no";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$total=0;
		while (($no)=$sth->fetchrow_array){
			for $dev (@tabdevise) {
				if ($html->param("${no}_${dev}") eq "on"){
					$montant=$html->param("mont_${no}_${dev}")+0;
					$lib=$html->param("lib_${no}_${dev}")+0;
					$montantdev=$montant;
					&save("update bordereau set montant='$montant',montantdev='$montantdev',date_remise='$date_remise',ref='$lib' where no='$no' and devise='$dev'");
					print "Bordereau $no pour un montant de $montant $dev Enregistré<br>";
					$total{$dev}+=$montant;
				}
			}
		}
		for $dev (@tabdevise) {
			if ($total{$dev}!=0){
				print "<b>Total:$total{$dev} $dev</b><br>";
			}
		}
	}
	$action="";
}

if ($action eq ""){
	print "<h2>Gestion des remise en banque</h2><br>";
	print "<script>";
	print "function recalcul() {";
	print "var total_selection=0;";
	print "var total_remise=0;";
	print " for (var i=5;i<document.maform.length-4;i=i+4){
		//alert(document.maform.elements[i].checked);
		if (document.maform.elements[i].checked==true){
			total_selection=eval(document.maform.elements[i-1].value)+total_selection;
			total_remise=eval(document.maform.elements[i+1].value)+total_remise;
		}
	}";
	print "document.getElementById('total_remise').innerHTML=total_remise;";
	print "document.getElementById('total_selection').innerHTML=total_selection;";

	print "}";
	print "</script>";
	print "<form name=maform>";
	require ("form_hidden.src");
	$query="select no ,devise from bordereau where date_remise='0000-00-00'  order by no,devise limit 50";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "Choisir les bordereaux concernés</br>";	
	print "<table><tr><th>Bordereau</th><th>Montant</th><th> </th><th> </th><th>Libelle</th></tr>";
	$total=0;
	$total_selection=0;
	$total_remise=0;
	while (($no,$dev)=$sth->fetchrow_array)
	{
		$montant=&montant_bordereau("$no",$dev);
		if ($montant ==0){next;}
		print "<tr><td>$no</td><td>$dev</td><td align=right><input type=hidden name=hid_${no}_${dev} value=$montant >$montant</td><td><input type=checkbox name=${no}_${dev} onchange=recalcul()></td>";
		print "<td><input type=text name=mont_${no}_${dev} value=$montant size=5 onchange=recalcul()></td><td><input type=text name=lib_${no}_${dev} size=20> </td></tr>";	
		$total{$dev}+=$montant;
	}
	print "</table>";
	# print "Reference banque - justificatif  <input type=text name=ref size=20><br>";
	foreach $cle (keys(%total)){
		print "Montant en attente de remise:$total{$cle} $cle<br>";
	}
# 	print "Montant selectionné:<span id=total_selection>$total_selection</span><br>";
# 	print "Total de la remise:<span id=total_remise>$total_remise</span><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date_remise><br>";
	print "<input type=hidden name=action value=go>";
# 	print "<input type=hidden name=dev value='$dev'>";
	print "<br><input type=submit>";
	print "</form>";
}	

sub montant_bordereau{
	my $no=$_[0];
	$query="select ca_code,ca_rot,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	my $total_xof,$total_dol,$total_eur,$total_stim,$total_stim,$total_cb=0;
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
	}
	my $montant=0;
	if ($_[1] eq "XAF") { $montant=$total_xaf;}
	if ($_[1] eq  "XOF") { $montant=$total_xof;}
	if ($_[1] eq "USD") { $montant=$total_dol;}
	if ($_[1] eq "EUR") { $montant=$total_eur;}
	return($montant);
}

;1
