
if ($action eq ""){
  &save("create temporary table cde_tmp (base varchar(20),cde int(8),four int(8),four_desi varchar(80),date_cde date,date_echeance date,montant decimal (8,2),etat int(2),facture varchar(30),livh_date_reglement date,accuse date,primary key (base,cde))");
  foreach $client (@bases_client){
  if ($client eq "dfc"){next;}
	&save_liste();
  }

  print "<style>";
  print "#com tr:nth-child(even){background:lavender;}";
  print "#com a{color:black;text-decoration:none;}";
  print "</style>";
  print "<table cellspacing=0 border=1 id=com><tr>";
  print "<th >Base</th>";
  print "<th >No cde</th>";
  print "<th >Fournisseur</th>";
  print "<th >Date cde</th>";
  print "<th >Echeance</th>";
  print "<th >Date entree</th>";
	print "<th >Montant</th>";
 	print "</tr>";
  $query="select * from cde_tmp order by four,base,date_cde";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($client,$com2_no,$fo_cd_fo,$fo_nom,$com2_date,$date_echeance,$montant,$etat,$livh_facture,$livh_date_reglement,$date_entree)=$sth->fetchrow_array){
	  print "<tr><td>$client</td><td onMouseOver=this.style.background='lightgreen' onMouseOut=this.style.background=''>";
	  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&com_no=$com2_no&client=$client style=color:black;text-decoration:none >$com2_no</a>";
	  print "</td>";
	  print "<td style=font-size:0.7em;>$fo_cd_fo $fo_nom";
	  print "</td>";
	  print "<td";
	  if (($etat==0)&&($accuse eq "0000-00-00")){print " bgcolor=pink";}
	  print ">";
	  $com2_date=&get("select com2_date from $client.commande where com2_no='$com2_no'","af");
	  if ($com2_date eq ""){ $com2_date=&get("select com2_date from $client.commandearch where com2_no='$com2_no'");}
	  # mail daniel du 30/04/2015
	  print $com2_date;
	  print "</td>";
	  $color="white";
	  if (&get("select datediff('$date_entree','$date_echeance')")>0){$color="pink";}
	  print "<td bgcolor=$color>";
	  print "$date_echeance";
	  print "</td>";
	  print "<td align=center>";
	  print $date_entree;
	  print "</td>";
	  print "<td align=right>";
	  print $montant;
	  print "</td>";
	  print "</tr>";
	  $total+=$montant
  }
  print "</table>";
}


sub save_liste(){
	
	$query="select distinct com2_no,com2_cd_fo,com2_date,com2_no_liv from $client.commandearch where com2_no_liv!=0 and year(com2_date)=year(curdate())";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com2_date,$com2_no_liv)=$sth->fetchrow_array){
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo'"));
		# $query="select livh_facture,livh_lta,livh_date_facture,livh_date_reglement,livh_date from livraison_h where livh_id='$com2_no_liv'";
		# $sth2=$dbh->prepare($query);
		# $sth2->execute();
		# ($livh_facture,$livh_lta,$livh_date_facture,$livh_date_reglement,$livh_date)=$sth2->fetchrow_array;
 		# if (($livh_date_facture ne "0000-00-00")&&($livh_date_facture ne "")){$com2_date=$livh_date_facture;}
 		# if ($com2_date eq "0000-00-00"){$com2_date=$livh_date;}
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b,$client.commandearch where livb_id='$com2_no_liv' and livb_code=com2_cd_pr and com2_no='$com2_no'");
		$montant=int($montant*100)/100;
		# $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$com2_no_liv'")+0;
		# $montant+=$frais;
		$fo_delai_pai=&get("select fo_delai_pai from fournis where fo2_cd_fo='$com2_cd_fo'","af")+0;
		$date_echeance=&get("select '$com2_date' + interval $fo_delai_pai day","af");
		$date_entree=&julian(&get("select enh_date from $client.enthead where enh_document='$com2_no_liv'"),"yyyy-mm-dd");
		&save("insert ignore into cde_tmp values('$client','$com2_no','$com2_cd_fo','$fo_nom','$com2_date','$date_echeance','$montant','$etat','$livh_facture','$livh_date_reglement','$date_entree')");
	}
}


;1
