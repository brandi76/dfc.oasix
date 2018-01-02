if ($action eq "go"){
  $lta=$html->param("lta");
  $lta_date=$html->param("lta");
  if (grep(/\//,$lta_date)) {
        ($jj,$mm,$aa)=split(/\//,$lta_date);
        $lta_date=$aa."-".$mm."-".$jj;
  }
if (($lta eq "")||(grep / /,$lta)){$mess="Aucun numero de lta saisie ou numero invalide";}
  else {
    $rien=1;
    $query="select livh_id from livraison_h where livh_lta=''";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($livh_id)=$sth->fetchrow_array){
      if ($html->param("$livh_id") eq "on"){
	&save("update livraison_h set livh_lta='$lta',livh_date_lta='$lta_date' where livh_id='$livh_id'");
	$livh_base=&get("select livh_base from livraison_h where livh_lta='$lta'");
   	$query="select distinct com2_no from $livh_base.commande where com2_no_liv='$livh_id'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($com2_no)=$sth2->fetchrow_array){&save("update $livh_base.commande_info set etat=3 where com_no='$com2_no' and etat<3");}
	$rien=0;
      }
    }
    if ($rien){$mess="Aucun Bl de selectionné";}
    else {
      $client=&get("select livh_base from livraison_h where livh_lta='$lta'");
      $fichier1=$html->param("fichier1");
      $fichier2=$html->param("fichier2");
      $fichier3=$html->param("fichier3");
      if ($fichier1 ne ""){
	$file="/var/www/$client.oasix/doc/lta_".$lta."_fact_fo.pdf";
	open(FILE,">$file");
	while (read($fichier1, $data, 2096)){
		print FILE $texte.$data;
	}
	close(FILE);
	print "$fichier1 enregistré<br>";
      }
      if ($fichier2 ne ""){
	$file="/var/www/$client.oasix/doc/lta_".$lta."_fact_tr.pdf";
	open(FILE,">$file");
	while (read($fichier2, $data, 2096)){
		print FILE $texte.$data;
	}
	close(FILE);
	print "$fichier2 enregistré<br>";
      }
      if ($fichier3 ne ""){
	$file="/var/www/$client.oasix/doc/lta_".$lta.".pdf";
	open(FILE,">$file");
	while (read($fichier3, $data, 2096)){
		print FILE $texte.$data;
	}
	close(FILE);
	print "$fichier3 enregistré<br>";
      }
    }
  }
  if ($mess ne ""){print "<mark> $mess </mark><br>";}
  $action="";
}

if ($action eq "liste"){
	print "<div class=titre>Liste des lta créées</div>";
	print "<table border=1 cellspacing=0 cellpadding=0><tr>";
	print "<th>Base</th>";
	print "<th>No</th><th>Date</th><th>Fournisseur</th><th>Montant</th><th>Facture</th><th>Cde</th><th>Lta</th></tr>";
	$query="select * from dfc.livraison_h where livh_lta not like '' order by livh_base,livh_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_date_reglement)=$sth->fetchrow_array){
	  if ($livh_base ne $run){&switch_color($livh_base);}
	  print "<tr bgcolor=$color>";
	  $fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	  ($fo_nom)=split(/\*/,$fo_add);
	  $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	  $montant=int($montant*100)/100;
	  $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
	  $montant+=$frais;
	  if ($livh_facture eq ""){$livh_facture="&nbsp;";}
	  print "<td style=font-size:0.8em>$livh_base</td>";
	  print "<td>$livh_id</td><td style=font-size:0.8em>$livh_date</td><td style=font-size:0.6em>$fo_nom</td><td align=right>$montant</td><td align=right>$livh_facture</td>";
	  print "<td>&nbsp;";
	  $query="select distinct com2_no from $livh_base.commande where com2_no_liv='$livh_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  if ($sth2->rows){
	    while (($com2_no)=$sth2->fetchrow_array){
		$etat=&get("select etat from $livh_base.commande_info where com_no='$com2_no'");
		print "$com2_no $etat<br>";}
	  }
	  $query="select distinct com2_no from $livh_base.commandearch where com2_no_liv='$livh_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  if ($sth2->rows){
	    while (($com2_no)=$sth2->fetchrow_array){
		$etat=&get("select etat from $livh_base.commande_info where com_no='$com2_no'");
		print "$com2_no $etat<br>";}
	  }
	  
	  print "</td>";
	  print "<td>$livh_lta</td>";
	 print "</tr>";
	}
	print "</table>";
}	

if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "<input type=hidden name=action value=liste>";
	print "<input type=submit value='Voir la liste'>";
	print "</form>";
	print "<form  method=POST enctype=multipart/form-data>";
  	print "<div class=titre>Creation des groupements Aeriens</div><br>";
	print "<br><br> Liste des bons de livraisons en attente<br>";
	print "<table border=1 cellspacing=0 cellpadding=0><tr>";
	print "<th>Base</th>";
	print "<th>No</th><th>Date</th><th>Fournisseur</th><th>Montant</th><th>Facture</th><th>Cde</th><th colspan=4>Action</th></tr>";
	$query="select * from dfc.livraison_h where livh_lta='' order by livh_base,livh_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_date_reglement)=$sth->fetchrow_array){
	  $check=&get("select enh_no from $base.enthead where enh_document='$livh_id'")+0;
	  if ($check >0){next;}
	  $query="select distinct com2_no from $livh_base.commandearch where com2_no_liv='$livh_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  if ($sth2->rows){next;}
	  if ($livh_base ne $run){&switch_color($livh_base);}
	  print "<tr bgcolor=$color>";
	  $fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	  ($fo_nom)=split(/\*/,$fo_add);
	  $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	  $montant=int($montant*100)/100;
	  $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
	  $montant+=$frais;
	  if ($livh_facture eq ""){$livh_facture="&nbsp;";}
	  print "<td style=font-size:0.8em>$livh_base</td>";
	  print "<td>$livh_id</td><td style=font-size:0.8em>$livh_date</td><td style=font-size:0.6em>$fo_nom</td><td align=right>$montant</td><td align=right>$livh_facture</td>";
	  print "<td>&nbsp;";
	  $query="select distinct com2_no from $livh_base.commande where com2_no_liv='$livh_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  if ($sth2->rows){
	    while (($com2_no)=$sth2->fetchrow_array){print "$com2_no<br>";}
	  }
	  print "</td>";
	  print "<td><input type=checkbox name=$livh_id></td>";
	 print "</tr>";
	}
	print "</table>";
	print "<br>Numero de LTA <input type=text name=lta><br>";
	print "Date livraison <input type=text id=datepicker name=lta_date><br>";
	&form_hidden();
	print "<input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "Fichier factures fournisseurs <input type=file name=fichier1 accept=application/pdf maxlength=2097152><br>";
	print "Fichier facture transitaire <input type=file name=fichier2 accept=application/pdf maxlength=2097152><br>";
	print "Fichier LTA <input type=file name=fichier3 accept=application/pdf maxlength=2097152><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit></form>";
  
}

;1