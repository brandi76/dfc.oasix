$date_ref=$html->param("date_ref");
if (grep /\//,$date_ref){
	($j,$m,$a)=split(/\//,$date_ref);
	if ($a ne ""){$date_ref="$a-$m-$j";}
}

if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "Date d'arr�t des comptes:<input type=date name=date_ref id=datepicker>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit>";
	print "</form>";
}
push(@bases_client,"cameshop");
push(@bases_client,"corsica");
push(@bases_client,"corsica loc");
push(@bases_client,"dutyfreeambassade");

if ($action eq "go"){
	print "<table border=1 cellspacing=0 cellpadding=20>";
	print "<tr><th>&nbsp;</th><th>STOCK</th>";
	# <th>Ecart comptage</th>
	# print "<th>CUTT OFF vente</th><th>CUTT OFF Achat</th><th>TOTAL</th></tr>";
	 print "<th>CUTT OFF Achat</th><th>TOTAL</th></tr>";
	
	foreach $client (@bases_client) {
		# if ($client ne "cameshop"){next;}
		$total=$total_gen=0;
		if ($client eq "dfc"){next;}
		# if ($client eq "corsica"){next;}
		# if ($client ne "cameshop"){
			# $query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
			# $sth=$dbh->prepare($query);
			# $sth->execute();
			# while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
			# {
				# %stock=&stock_comptable($pr_cd_pr,'',"quick");
				# $stck=$stock{"pr_stre"};
				# if ($stck <0){next;}
				# if ($stck==0){next;}
				# $sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
				# $entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
				# $stck-=$entree;
				# $stck+=$sortie;
				# $total=$stck*$pr_prac;
				# $total_gen+=$total;
			# }
			$total=&get("select sum(qte*prac) from dfc.stock_mensuel where base='$client' and date='$date_ref'","af")+0;
			$total=&get("select $total+$total*(transport+douane)/100 from dfc.frais where base='$client'"); 
			$total=int($total*100)/100;
			$total_gen+=$total;
		# }
		# if ($client eq "cameshop"){
			# $total=&get("select sum((boutique+reserve)*prac) from $client.stock where date='$date_ref'")+0;
			# $total_gen+=$total;
		# }
		print "<tr><td>$client</td><td align=right><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=detail_stock&date_ref=$date_ref&client=$client>$total_gen</a></td>";
		$cutoff_vente=0;
		$ecart=0;
		if (($client ne "cameshop")&&($client ne "corsica")&&($client ne "corsica loc")&&($client ne "dutyfreeambassade")){
			$query="select v_code,v_date_sql from $client.vol where v_rot=1 and  v_date_sql<='$date_ref' and datediff('$date_ref',v_date_sql)<30";
			# print $query;
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($v_code,$v_date_sql)=$sth2->fetchrow_array){
				$cutoff_vente+=&get("select sum(es_qte*prac)/100 from dfc.stock_mensuel,$client.enso where es_no_do='$v_code' and es_cd_pr=code and base='$client' and date='$date_ref' and es_dt>'$date_ref'","af")+0;
			}
			$ecart=&get("select sum(ecart*prac) from $client.inventaire,dfc.stock_mensuel where inventaire.code=stock_mensuel.code and base='$client' and stock_mensuel.date='$date_ref' and inventaire.date='$date_ref'")+0; 
		}
		$cutoff_vente=&get("select $cutoff_vente+$cutoff_vente*(transport+douane)/100 from dfc.frais where base='$client'"); 
		$cutoff_vente=int($cutoff_vente*100)/100;
		$cutoff_vente=0;
		# modifier le 03/08/17 suite mail daniel https://mail.google.com/mail/u/0/#inbox/15d611bcf1bf5b7d
		$ecart=&get("select $ecart+$ecart*(transport+douane)/100 from dfc.frais where base='$client'"); 
		$ecart=int($ecart*100)/100;

		# print "<td align=right>$ecart</td>";
		# print "<td align=right>$cutoff_vente</td>";
		$total=0;
		 $query="select livh_id,livh_base,livh_facture,livh_date_facture from livraison_h where livh_date_facture<='$date_ref' and livh_base='$client' and datediff('$date_ref',livh_date_facture)<180";
		 $sth=$dbh->prepare($query);
		 $sth->execute();
		 while (($livh_id,$livh_base,$livh_facture,$livh_date_facture)=$sth->fetchrow_array)
		 {
		     # $es_dt=&get("select es_dt from $livh_base.enso,$livh_base.enthead where es_no_do=enh_no and enh_document='$livh_id' and es_dt>'$date_ref' limit 1","af");
			 $check=&get("select count(*) from $livh_base.enthead where enh_document='$livh_id' and FROM_UNIXTIME(enh_date*24*60*60,'%Y-%m-%d')>'$date_ref'")+0;
			 if ($check==0){next;}
			 $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'")+0;
			$montant=&get("select $montant+$montant*(transport+douane)/100 from dfc.frais where base='$client'"); 
			 $montant=int($montant*100)/100;
			 $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
			 $montant+=$frais;
			 $total+=$montant;
		 }
		 print "<td align=right><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=detail_facture&date_ref=$date_ref&client=$client>$total</a></td>";
		 $cutoff_vente=0;
		# $total_ligne=$total+$total_gen+$ecart-$cutoff_vente;
		$total_ligne=$total+$total_gen-$cutoff_vente;
		$cut_off_total+=$total;
		$cut_offv_total+=$cutoff_vente;
		if (! grep(/corsi/,$client)) {$stock_total+=$total_gen;}
		$total_ecart+$ecart;
		if (! grep (/corsi/,$client)) {$total_total+=$total_ligne;}
		print "<td align=right>$total_ligne</td></tr>";
	}
	print "<tr><th>Total (hors corse)</th><th>$stock_total</th>";
	#<th>$total_ecart</th>
	# print "<th>$cut_offv_total</th><th>$cut_off_total</th><th>$total_total</th></tr>";
	 print "<th>$cut_off_total</th><th>$total_total</th></tr>";
	print "</table>";
}

if ($action eq "detail_stock"){
	$client=$html->param("client");
	# $query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
	$query="select distinct(code) from stock_mensuel where base='$client' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "stock comptable $client $date_ref<br>";
	print "<table><tr><th>code</th><th>d�signation</th><th>qte</th><th>prix de revient</th><th>valeur</th><th>Vendu periode</th><th>Vendu post periode</th><th>Entree post periode</th></tr>";
	while (($pr_cd_pr)=$sth->fetchrow_array)
	{
		if ($client ne "dutyfreeambassade"){$pr_desi=&get("select pr_desi from $client.produit");}
		else {$pr_desi=&get("select designation from $client.produit_web where code='$pr_cd_pr'");}
		$query="select qte,prac from stock_mensuel where base='$client' and code='$pr_cd_pr' and date='$date_ref'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($stck,$pr_prac)=$sth2->fetchrow_array;
		$pr_prac+=0;
		$pr_prac=&get("select $pr_prac+$pr_prac*(transport+douane)/100 from dfc.frais where base='$client'","af"); 
		$pr_prac=int($pr_prac*100)/100;
		if ($stck==0){next;}
		$total=$stck*$pr_prac;
		$total_gen+=$total;
		$vendu=&get("select sum(es_qte)/100 from $client.enso where es_cd_pr='$pr_cd_pr' and year(es_dt)=year('$date_ref')")+0;
		$vendu_apres=&get("select sum(es_qte)/100 from $client.enso where es_cd_pr='$pr_cd_pr' and year(es_dt)>year('$date_ref')")+0;
		$entree_apres=&get("select sum(es_qte_en)/100 from $client.enso where es_cd_pr='$pr_cd_pr' and year(es_dt)>year('$date_ref')")+0;
		
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total </td><td align=right>$vendu</td><td align=right>$vendu_apres</td><td align=right>$entree_apres</td></tr>";
			
	}
	print "</table>";
	print "<b>total:$total_gen</b>";
}

if ($action eq "detail_facture"){
	$client=$html->param("client");
	print "cut_off facture $client $date_ref<br>";
	print "<table border=1 cellspacing=0><tr><th>bl</th><th>base</th><th>facture</th><th>date facture</th><th>date entree</th><th>montant</th></tr>";
	$query="select livh_id,livh_base,livh_facture,livh_date_facture from livraison_h where livh_date_facture<='$date_ref' and livh_base='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_facture,$livh_date_facture)=$sth->fetchrow_array)
	{
		$es_dt=&get("select es_dt from $livh_base.enso,$livh_base.enthead where es_no_do=enh_no and enh_document='$livh_id' and es_dt>'$date_ref' limit 1","af");
		if ($es_dt eq ""){next;}
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'")+0;
		# $montant_av=$montant;
		$montant=&get("select $montant+$montant*(transport+douane)/100 from dfc.frais where base='$client'"); 
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		$total+=$montant;
		print "<tr><td>$livh_id</td><td>$livh_base</td><td>$livh_facture</td><td>'$livh_date_facture</td><td>'$es_dt</td><td>$montant</td></tr>";
	}
	if ($total>0){print "<tr><td colspan=5>Total</td><td><strong>$total</strong></td></tr>";}
	print "</table>";
}

sub stock_comptable {
	my($prod)=$_[0];
	my($stock,$non_sai,$pastouch,$max,$pastouch2,$retourdujour,$errdep);
	my(%stock);
	my($query) = "select * from $client.produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	my($produit)=$sth->fetchrow_hashref;
	$stock{"vol"}=$produit->{'pr_stvol'}/100;
	$query = "select sum(erdep_qte) from $client.errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$errdep=$sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	$stock{"pr_stre"}=$stock{"stre"}-$stock{"casse"}+$stock{"diff"}+$stock{"errdep"}; # stock comptable
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100; # entrepot
	return(%stock);
}

sub stock_cameshop_adate()
{
	my($code)=$_[0];
	my($pdv)=$_[1]; # point de vente (caisse)
	my($lieu)=$_[2]; # boutique 
	my($date_ref)=$_[3]; 
	$query="select date,qte from $client.inventaire_manu where pdv='$lieu' and code='$code' and date>'2016-04-01' and date(date)<='$date_ref' order by date desc limit 1";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($max_date,$inventaire)=$sth->fetchrow_array;
	if ($max_date eq ""){$max_date='2016-04-01';}
	$inventaire_bo=$inventaire+0;
	($date_inv,$heure_inv)=split(/ /,$max_date);
	$date_inv=$max_date;
	$vendu=&get("select sum(qte) from $client.panier_caisse,$client.ticket_caisse_js where pdv like '$pdv%' and code='$code' and ticket_pdv=pdv and date=ticket_date and ticket_vendeuse=vendeuse and no_cde=ticket_no and addtime(ticket_date,ticket_heure)>='$date_inv' and date(ticket_date)<='$date_ref'  and ticket_sup=0 and vendeuse!='sylvain' ","af")+0;
	$mouvement_bo=&get("select sum(qte) from $client.mouvement_b,$client.mouvement_h where code='$code' and livb_no=livh_id and livh_etat=2 and livh_date_in>='$date_inv' and date(livh_date_in)<='$date_ref' and livh_in='$lieu'","af")+0;
	$mouvement_bo-=&get("select sum(qte) from $client.mouvement_b,$client.mouvement_h where code='$code' and livb_no=livh_id and livh_etat=2 and livh_date_out>='$date_inv' and date(livh_date_out)<='$date_ref' and livh_out='$lieu'","af")+0;
	$date_inv_bo=$date_inv;
	$stock_bo=$inventaire_bo-$vendu+$mouvement_bo;
	
	$query="select date,qte from $client.inventaire_manu where pdv like 'Reserve%' and code='$code' and date>'2016-04-01' and date(date)<='$date_ref' order by date desc limit 1";
	# print "$query<br>";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($max_date,$inventaire)=$sth->fetchrow_array;
	if ($max_date eq ""){$max_date='2016-04-01';}
	$inventaire_de=$inventaire+0;
	($date_inv,$heure_inv)=split(/ /,$max_date);
	$entree=&get("select sum(es_qte_en)/100 from $client.enso where es_cd_pr='$code' and es_dt>='$date_inv' and es_dt<='$date_ref' and es_type=10","af")+0;
	$sortie=&get("select sum(es_qte)/100 from $client.enso where es_cd_pr='$code' and es_dt>='$date_inv' and es_dt<='$date_ref' and es_type=5","af")+0;
	$mouvement_de=&get("select sum(qte) from $client.mouvement_b,$client.mouvement_h where code='$code' and livb_no=livh_id and livh_etat>0 and livh_date_out>='$date_inv' and date(livh_date_out)<='$date_ref' and livh_out like 'Reserve%'","aff	")+0;
	$mouvement_de-=&get("select sum(qte) from $client.mouvement_b,$client.mouvement_h where code='$code' and livb_no=livh_id and livh_etat>0 and livh_date_in>='$date_inv' and date(livh_date_in)<='$date_ref' and livh_in like 'Reserve%'","af")+0;
	$date_inv_de=$date_inv;
	$stock_de=$inventaire_de-$mouvement_de+$entree-$sortie;
	# print "$inventaire_de $mouvement_de $entree $sortie";
} 

sub prac_cameshop()
{
	my($code)=$_[0];
	my($prac)=0;
	my($four)=0;
	my($valeur)=0;
	my($sth)=$dbh->prepare("select pr_prac,pr_four from $client.produit where pr_cd_pr=$code");
	$sth->execute();
	($prac,$four)=$sth->fetchrow_array;
	$prac=($prac+0)/100;
	$pr_prac=&get("select $pr_prac+$pr_prac*(transport+douane)/100 from dfc.frais where base='$client'"); 
	$pr_prac=int($pr_prac*100)/100;
		
	my($query)="select valeur from $client.remise_four where four='$four' order by rang";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	while (($valeur)=$sth->fetchrow_array){
		$prac=$prac-$valeur*$prac/100;
	}
    $prac=int($prac*100)/100;	
	return($prac);
}

;1
