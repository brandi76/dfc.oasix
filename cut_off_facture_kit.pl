print "Date de facture est antérieure à la date de l'arrêt des comptes, et la date d'entrée postérieure à la date d'arrêt des comptes<br>";
$date_ref=$html->param("date_ref");
($j,$m,$a)=split(/\//,$date_ref);
if ($a ne ""){$date_ref="$a-$m-$j";}
print "<form>";
&form_hidden();
print "Date d'arrêt des comptes:<input type=date name=date_ref id=datepicker>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";
$total=0;
if ($date_ref ne ""){
	print "<table border=1 cellspacing=0><tr><th>bl</th><th>base</th><th>facture</th><th>date facture</th><th>date entree</th><th>montant</th></tr>";
	$query="select livh_id,livh_base,livh_facture,livh_date_facture from livraison_h where livh_date_facture<='$date_ref' order by livh_base";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_facture,$livh_date_facture)=$sth->fetchrow_array)
	{
		if (($livh_base ne $base)&&($total>0)){
			print "<tr><td colspan=5>Total</td><td><strong>$total</strong></td></tr>";
			$total=0;
		}
		$es_dt=&get("select es_dt from $livh_base.enso,$livh_base.enthead where es_no_do=enh_no and enh_document='$livh_id' and es_dt>'$date_ref' limit 1","af");
		if ($es_dt eq ""){next;}
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		if ($total==0){
				$base=$livh_base;
		}
		$total+=$montant;
		print "<tr><td>$livh_id</td><td>$livh_base</td><td>$livh_facture</td><td>'$livh_date_facture</td><td>'$es_dt</td><td>$montant</td></tr>";
	}
	if ($total>0){print "<tr><td colspan=5>Total</td><td><strong>$total</strong></td></tr>";}
	print "</table>";
}
;1
