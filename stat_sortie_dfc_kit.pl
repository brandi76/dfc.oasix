print <<EOF;
<style>
.gras {font-weight:bold;}
</style>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
	
$four=$html->param("four");
$famille=$html->param("famille");
$action=$html->param("action");
$marque_choisi=$html->param("marque_choisi");

if ($four eq ""){$four="pr_four";}
if ($famille eq ""){$famille="produit_plus.pr_famille";}
if ($famille ==10){$famille="1 or produit_plus.pr_famille=3";}

print "<center>";
if ($action eq ""){
	print "<div class=titre>Statistique des sorties</div><br>";
	print "<form>";
	require ("form_hidden.src");
    print "<br>Fournisseur<br><select name=four><option value=''></option>";
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
	$sth2->execute;
	while (my @four = $sth2->fetchrow_array) {
		next if $four eq $four[0];
		($four[1])=split(/\*/,$four[1]);
		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
	}
	print "</select>";
	print "<br>Famille<br><select name=famille><option value=''></option>";
	$query="select fa_id,fa_desi from famille where fa_desi not like '' order by fa_id";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (my @famille = $sth2->fetchrow_array) {
		print "<option value=\"$famille[0]\">$famille[1]\n";
	}
	print "</select>";
	print "<br>Marque<br><select name=marque_choisi><option value=''></option>";
	$query="select distinct marque from dfc.produit_desi union select distinct marque from corsica.produit_desi union select distinct marque from cameshop.produit_desi order by marque";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (($marque) = $sth2->fetchrow_array) {
		print "<option value=\"$marque\">$marque\n";
	}
	print "</select>";
	print "<br><br>Premiere date ";
	&select_date("premiere");
	print "<br><br>Derniere date ";
	&select_date("derniere");
	# print "<br><br>Avec les Boutiques <input type=checkbox name=boutique>";
	# print "<br>Groupement par produit <input type=checkbox name=option><br>";
	print "<br><input type=hidden name=action value=go>";
	print "<br><br><button type=\"submit\" class=\"btn btn-info\">Submit</button>";
	print "</form>";
}

if ($action eq "go") {
	$jour=$html->param("premieredatejour");
	$mois=$html->param("premieredatemois");
	$an=$html->param("premieredatean");
	$premiere="$an-$mois-$jour";
	$jour=$html->param("dernieredatejour");
	$mois=$html->param("dernieredatemois");
	$an=$html->param("dernieredatean");
	$derniere="$an-$mois-$jour";
	$add=&get("select fo2_add from fournis where fo2_cd_fo='$four'");
	($add)=split(/\*/,$add);
	print "<div class=titre>Période $premiere au $derniere</div><br>";
	&save("create temporary table if not exists table_entree (`base` varchar(20),`marque` varchar(50),`pr_cd_pr` bigint(16),`pr_desi` varchar(40),`date` varchar(10),`qte` decimal(8,2), primary key (base,marque,pr_cd_pr,date) )","af"	);
	# push(@bases_client,"corsica");
	# push(@bases_client,"cameshop");
	foreach $client (@bases_client) {
		if ($client eq "dfc"){next;}
		$query="select pr_four,produit.pr_cd_pr,pr_desi,DATE_FORMAT( es_dt, '%Y-%m' ) as mois,sum(es_qte)/100 from $client.enso,$client.produit,$client.produit_plus where es_cd_pr=produit.pr_cd_pr and pr_four=$four and (produit_plus.pr_famille=$famille) and produit_plus.pr_cd_pr=produit.pr_cd_pr and es_dt>='$premiere' and es_dt<='$derniere' group by es_cd_pr,mois order by es_cd_pr "; 
		# print $query;
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_four,$pr_cd_pr,$pr_desi,$es_dt,$qte)=$sth->fetchrow_array){
			if (($client eq "corsica")||($client eq "cameshop")){
					$marque=&get("select marque from $client.produit_desi where code='$pr_cd_pr'"); 
			}
			else {
					$marque=&get("select marque from dfc.produit_desi where code='$pr_cd_pr'"); 
			}		
			if (($marque_choisi ne "")&&($marque ne $marque_choisi)){
				next;
			}
			&save("insert into table_entree value ('$client','$marque','$pr_cd_pr',\"$pr_desi\",'$es_dt','$qte')");
		}
	}
	$client="corsica";
	$query="select pr_four,produit.pr_cd_pr,pr_desi, DATE_FORMAT( ticket_date, '%Y-%m' ) as mois ,sum(qte) from $client.panier_caisse,$client.ticket_caisse,$client.produit,$client.produit_plus where ticket_pdv=pdv and pdv like 'Caisse %' and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and pr_four=$four and produit_plus.pr_famille=$famille and ticket_date>='$premiere'  and ticket_date<='$derniere' and ticket_sup=0 and vendeuse!='sylvain' and panier_caisse.code=produit.pr_cd_pr and panier_caisse.code=produit_plus.pr_cd_pr group by pr_cd_pr,mois";
	# print "$query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_four,$pr_cd_pr,$pr_desi,$es_dt,$qte)=$sth->fetchrow_array){
			$marque=&get("select marque from $client.produit_desi where code='$pr_cd_pr'"); 
			if (($marque_choisi ne "")&&($marque ne $marque_choisi)){
				next;
			}
			&save("insert into table_entree value ('$client','$marque','$pr_cd_pr',\"$pr_desi\",'$es_dt','$qte')");
	}
	
	$query="select pr_four,produit.pr_cd_pr,pr_desi, DATE_FORMAT( ic2_date, '%Y-%m' ) as mois ,sum(coc_qte) as mois from $client.comcli,$client.infococ2,$client.produit,$client.produit_plus where ic2_no=coc_no and ic2_fact>0 and coc_cd_pr=produit.pr_cd_pr and ic2_date>='$premiere'  and ic2_date<='$derniere'  and coc_cd_pr=produit_plus.pr_cd_pr  and pr_four=$four and produit_plus.pr_famille=$famille  group by produit.pr_cd_pr,mois";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_four,$pr_cd_pr,$pr_desi,$es_dt,$qte)=$sth->fetchrow_array){
			# print "*";
			$marque=&get("select marque from $client.produit_desi where code='$pr_cd_pr'","af"); 
			if (($marque_choisi ne "")&&($marque ne $marque_choisi)){
				next;
			}
			&save("insert ignore into table_entree value ('$client','$marque','$pr_cd_pr',\"$pr_desi\",'$es_dt','0')");
			&save("update table_entree set qte=qte+$qte where base='$client' and marque='$marque' and pr_cd_pr='$pr_cd_pr' and date='$es_dt'","af");
	}
	$client="cameshop";
	$query="select pr_four,produit.pr_cd_pr,pr_desi, DATE_FORMAT( ticket_date, '%Y-%m' ) as mois ,sum(qte) from $client.panier_caisse,$client.ticket_caisse_js,$client.produit,$client.produit_plus where ticket_pdv=pdv and pdv like 'Caisse %' and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and pr_four=$four and produit_plus.pr_famille=$famille and ticket_date>='$premiere'  and ticket_date<='$derniere' and ticket_sup=0 and vendeuse!='sylvain' and panier_caisse.code=produit.pr_cd_pr and panier_caisse.code=produit_plus.pr_cd_pr group by pr_cd_pr,mois";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_four,$pr_cd_pr,$pr_desi,$es_dt,$qte)=$sth->fetchrow_array){
			$marque=&get("select marque from $client.produit_desi where code='$pr_cd_pr'"); 
			if (($marque_choisi ne "")&&($marque ne $marque_choisi)){
				next;
			}
			&save("insert into table_entree value ('$client','$marque','$pr_cd_pr',\"$pr_desi\",'$es_dt','$qte')");
	}
	
	
	
	
	$query="select base,marque,pr_cd_pr,pr_desi,date,qte from table_entree order by marque,pr_cd_pr"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Marque</th><th>Code</th><th>Designation</th><th>Date</th><th>Base</th><th>Qte</th></tr>";
	print "</tr>";
	print "</thead>";

	$total=0;
	$tamp=0;
	while (($base,$marque,$pr_cd_pr,$pr_desi,$date,$qte,$val)=$sth->fetchrow_array){
		print "<tr><td>$marque</td><td>$pr_cd_pr</td><td>$pr_desi</td><td>$base</td><td>$date</td><td align=right>$qte</td></tr>";
		$total+=$qte;
		$ca+=$val;
	}
	print "<tr class='gras'><td colspan=5>Total</td><td align=right>$total</td><td align=right>$ca</td></tr>";
	print "</table>";	
}
=pod

	else 
	{
		$query="select enh_no,pr_four,produit.pr_cd_pr,pr_desi,enh_date,enb_quantite/100,pr_prac/100 from entbody,produit,enthead,produit_plus where enb_cdpr=produit.pr_cd_pr and enh_no=enb_no and pr_four=$four and (produit_plus.pr_famille=$famille) and produit_plus.pr_cd_pr=produit.pr_cd_pr and enh_date>='$premiere' and enh_date<='$derniere' order by enb_cdpr "; 
		# print $query;
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($no,$pr_four,$pr_cd_pr,$pr_desi,$enh_date,$qte,$prac)=$sth->fetchrow_array){
			  $date=&julian($enh_date);
			  $total=$prac*$qte;
			  $marque=$base_dbh;
			  if ($option ne ""){
				$marque=&get("select marque from dfc.produit_desi where code='$pr_cd_pr'"); 
			  }
			  &save("insert into table_entree value ('$no','$marque','$pr_cd_pr','$pr_desi','$date','$qte','$total')");
		}
	}
	if ($option eq ""){
		$query="select no,base,pr_cd_pr,pr_desi,date,qte,val from table_entree order by pr_cd_pr,no"; 
		# print $query;
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "<table border=1 cellspacing=0>";
		print "<tr><th>no ent</th><th>Base</th><th>Facture</th><th>Date facture</th><th colspan=2>Produit</th><th>Date</th><th>Qte</th><th>Val Achat</th></tr>";
		$total=0;
		$tamp=0;
		while (($no,$base,$pr_cd_pr,$pr_desi,$date,$qte,$val)=$sth->fetchrow_array){
			if (($pr_cd_pr != $tamp)&&($total !=0)){
				print &ligne_tab("","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","<b>Total:</b>","<b>$total</b>","<b>$ca</b>");
				$totalf+=$total;
				$caf+=$ca;
				$ca=0;
				$total=0;
			}
			$qte+=0;
			$query="select livh_facture,livh_date_facture from $base.enthead,dfc.livraison_h where enh_no='$no' and enh_document=livh_id";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($livh_facture,$livh_date_facture)=$sth2->fetchrow_array;
			print &ligne_tab("",$no,$base,$livh_facture,$livh_date_facture,$pr_cd_pr,$pr_desi,$date,$qte,$val);
			$total+=$qte;
			$ca+=$val;
			$tamp=$pr_cd_pr;
		}
		if (($pr_cd_pr != $tamp)&&($total !=0)){
			print &ligne_tab(""," "," "," "," "," "," ","<b>Total:</b>","<b>$total</b>","<b>$ca</b>");
			$totalf+=$total;
			$caf+=$ca;
			
		}

		print "</table>";
		print "Quantité total:$totalf Montant:$caf";
	}
	else{
		$query="select base,pr_cd_pr,pr_desi,sum(qte),sum(val) from table_entree group by base,pr_cd_pr order by base,pr_cd_pr "; 
		# print $query;
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "<table border=1 cellspacing=0>";
		print "<tr><th>Marque</th><th colspan=2>Produit</th><th>Qte</th><th>Val Achat</th></tr>";
		$total=0;
		$tamp=0;
		while (($marque,$pr_cd_pr,$pr_desi,$qte,$val)=$sth->fetchrow_array){
			if (($marque ne $tamp)&&($total !=0)){
				print &ligne_tab("","<b>Total: $tamp</b>","&nbsp;","&nbsp;","<b>$total</b>","<b>$ca</b>");
				$totalf+=$total;
				$caf+=$ca;
				$ca=0;
				$total=0;
			}
			$qte+=0;
			print &ligne_tab("",$marque,$pr_cd_pr,$pr_desi,$qte,$val);
			$total+=$qte;
			$ca+=$val;
			$tamp=$marque;
		}
		if (($marque ne $tamp)&&($total !=0)){
			print &ligne_tab("","<b>Total: $tamp</b>","&nbsp;","&nbsp;","<b>$total</b>","<b>$ca</b>");
			$totalf+=$total;
			$caf+=$ca;
		}
		print "</table>";
		print "Quantité total:$totalf Montant:$caf";
	}
}
=cut

print "</div></div></div>";
;1	
# -E statistique des entrées  06/11	
