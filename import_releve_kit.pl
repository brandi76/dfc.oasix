$premiere=$html->param("premiere");
$derniere=$html->param("derniere");
$option=$html->param("option");
$nb_champ=$html->param("nb_champ");

if (grep(/\//,$premiere)) {
        ($jj,$mm,$aa)=split(/\//,$premiere);
        $premiere=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$derniere)) {
        ($jj,$mm,$aa)=split(/\//,$derniere);
        $derniere=$aa."-".$mm."-".$jj;
}
if ($action eq "Confirmer"){
  &save("insert ignore into releve_bq select id,montant,dev,date,ref,libelle from mouvement_tmp");
  $nb=&get("select count(*) from mouvement_tmp")+0;
  print "$nb lignes importées<br>";
  $action="";
}  

if ($action eq "maj"){
  $ref=$html->param("ref");
  $no=$html->param("no");
  $devise=$html->param("devise");
  &save("update bordereau set ref=\"$ref\" where no='$no' and devise='$devise'","af");
  $action="recherche";
}
if ($action eq "sup"){
    $date=$html->param("date");
    $id=$html->param("id");
    $montant=$html->param("montant");
    &save("delete from releve_bq where id='$id' and date='$date' and montant='$montant' limit 1","af");
    print "Ligne Supprimée";
    $action="visualiser";
}

if ($action eq "recherche"){
    $date=$html->param("date");
    $id=$html->param("id");
    $montant=$html->param("montant");
    $query="select * from releve_bq where id='$id' and date='$date' and montant='$montant'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array;
    print "Recherche de<br><strong>$date $montant $dev <span style=color:red>$ref</span> $desi</strong><br>";
    $ref_cherche=$ref;
    print "<table cellspacing=0 border=1>";
    print "<tr><th>Bordereau</th><th>Devise</th><th>Date creation</th><th>Date remise</th><th>Ref</th><th>Montant</th><th>Montant XOF</th></tr>";
    $query="select * from bordereau where datediff(date_remise,'$date')<3 and datediff(date_remise,'$date')>-3";
    $sth=$dbh->prepare($query);
    $sth->execute();
    $total_int=0;
    while (($no,$devise,$date_creation,$date_remise,$ref,$montant2,$montantdev)=$sth->fetchrow_array){
      $cash=&get("select montant from cash where bordereau='$no' and devise='$dev'")+0;
      $montant2-=$cash;
      if (($date_remise ne $date_tamp)&&($total_int!=0)){
	print "<tr><td>$total_int</td></tr>";
	$total_int=0;
      }
      if ($date_remise ne $date_tamp){
      	$date_tamp=$date_remise;
      }
      print "<tr><td>$no</td><td>$devise</td><td>$date_creation</td><td>$date_remise</td><td>";
      print "<form>";
      &form_hidden();
      print "<input type=hidden name=date value=$date>";
      print "<input type=hidden name=id value=$id>";
      print "<input type=hidden name=montant value=$montant>";
      print "<input type=hidden name=no value=$no>";
      print "<input type=hidden name=devise value=$devise>";
      print "<input type=hidden name=premiere value=$premiere>";
      print "<input type=hidden name=derniere value=$derniere>";
      print "<input type=hidden name=action value=maj>";
      if ($ref eq "0"){print "*";$ref=$ref_cherche;}
      print "<input type=text name=ref value='$ref'>";
      print "<input type=submit value=maj></form>";
      print "</td><td>$montant2</td><td>$montantdev</td><tr>";
      $total_int+=$montant2;
    }
    print "</table>";
    print "<form>";
    &form_hidden();
    print "<input type=hidden name=premiere value=$premiere>";
    print "<input type=hidden name=derniere value=$derniere>";
    print "<input type=hidden name=action value=visualiser>";
    if ($total_int==$montant){print "<strong>";}
    print "Total:$total_int";
    print "<br><input type=submit value=retour>";
    print "</form>";
}

if ($action eq ""){
	$derniere=&get("select max(date) from releve_bq");
	$premiere=&get("select date_sub('$derniere', interval 1 month)");
	print "<center><h1>Importation du relevé de banque</h1><br>";
	print "<form  method=POST enctype=multipart/form-data>";
	&form_hidden();
	print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<input type=file name=fichier accept=text/* maxlength=2097152>";
       	print " <input type=hidden name=action value=upload>";
       	print "<br>Nombre champ 10<input type=radio name=nb_champ value=10 checked> 8<input type=radio name=nb_champ value=8> <br>";
	print "<br> <input type=submit></form>";
	print "Visualiser<br>";
	print "<form>";
	form_hidden();
	print "Premiere date <input type=text name=premiere id=datepicker value=$premiere><br>";
	print "Derniere date <input type=text name=derniere id=datepicker2 value=$derniere><br>";
	print "<input type=submit name=action value=visualiser>";
	print "</form>";
	
}
if ($action eq "upload"){
	$fic=$html->param("fichier");
 	# print $fic;
 	while (read($fic, $data, 2096)){
 		$texte=$texte.$data;
 	}
	$action="import";
}

# print "<style>";
# print "tr:nth-child(odd) { background-color: #efefef; }";
# print "</style>";


if ($action eq "import"){
	print "Extrait ...<br>";
	print "la colonne en orange doit correspondre à celle en bleue<br>";
	&save("truncate table mouvement_tmp ");
	(@tab)=split(/\n/,$texte);
	$ok=0;
	foreach $ligne (@tab){
 	      ($Classification,$Account_number,$Statement,$Amount,$Ccy,$Book_Day,$Value_Day,$Type,$Reference,$Description)=split(/\t/,$ligne);
 	      if ($nb_champ==8){
		($Classification,$Account_number,$Amount,$Ccy,$Value_Day,$Type,$Reference,$Description)=split(/\t/,$ligne);
# 		print "<pre>$ligne</pre>";
		$Statement++;
 	      }
 	      if (grep /Classification/,$ligne){
	     	print "<table border=1 cellspacing=0 cellpadding=0>";
 	     	if ($nb_champ==8){
		  print "<tr bgcolor=orange><td>Classification</td><td>Account_number</td><td>Amount</td><td>Ccy</td><td>Book_Day</td><td>Type</td><td>Reference</td><td>Description</td></tr>";
		  print "<tr bgcolor=lightblue><td>$Classification</td><td>$Account_number</td><td>$Amount</td><td>$Ccy</td><td>$Value_Day</td><td>$Type</td><td>$Reference</td><td>$Description</td></tr>";
		}
 	     	else
 	     	{
		  print "<tr bgcolor=orange><td>Classification</td><td>Account_number</td><td>Statement</td><td>Amount</td><td>Ccy</td><td>Book_Day</td><td>Value_Day</td><td>Type</td><td>Reference</td><td>Description</td></tr>";
		  print "<tr bgcolor=lightblue><td>$Classification</td><td>$Account_number</td><td>$Statement</td><td>$Amount</td><td>$Ccy</td><td>$Book_Day</td><td>$Value_Day</td><td>$Type</td><td>$Reference</td><td>$Description</td></tr>";
		}
 	     	$ok=1;
	      }
	      else{
		if (($nb++<4)&&($ok)){
		  if ($nb_champ==8){
		    print "<tr><td>$Classification</td><td>$Account_number</td><td>$Amount</td><td>$Ccy</td><td>$Value_Day</td><td>$Type</td><td>$Reference</td><td>$Description</td></tr>";
		  }
		  else
		  {
        	 	print "<tr><td>$Classification</td><td>$Account_number</td><td>$Statement</td><td>$Amount</td><td>$Ccy</td><td>$Book_Day</td><td>$Value_Day</td><td>$Type</td><td>$Reference</td><td>$Description</td></tr>";
		  }
		}  
        	&save("insert into mouvement_tmp values ('$Statement','$Value_Day','$Ccy','$Amount',\"$Reference\",\"$Description\")","af"); 
	      }
	
#  	      print "$Classification,$Account,$number,$Statement,$Amount,$Ccy,$Book_Day,$Value_Day,$Type,$Reference,$Description<br>";
#  		print "$Ccy<br>";
# 
# 		$montant=$Amount;
# 		$dev=$Ccy;
# 		$date=$Book_Day;
# 		$date_val=$Value_Day;
# 		$ref=$Reference;
# 		$desi=$Description;
# 		while ($desi=~s/'//){};
# 		$ref=~s/'//g;
# # 		&save("insert ignore into releve_bq values ('$id','$montant','$dev','$date','$ref','$desi')","af");
#    		$id++;
# 		print "<tr><td align=right>$date</td>";
# 		$debit=0;
# 		$credit=0;
# 		($montant >0)? $credit=$montant:$debit=$montant;
# 		$debit=$debit*-1;
# 		print "<td align=right>$debit</td><td align=right>$credit</td>";
# 		print "<td align=right>$ref</td><td align=right>$desi</td></tr>";
	}
 	if ($ok==0){print "<p style=background:pink> Ligne d'entete non trouvé</p>";}else {print "</table>";}
 	print "<br><form>";
 	&form_hidden();
 	print "<input type=submit name=action value=Confirmer>";
 	print "<br>Si les entetes de colonne ne correpondent pas, il faut refaire l'importation en changeant le nombre de champ ";
 	print "</form>";
 	print "<br>";
	print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>Retour</a>";

}



if (($action eq "visualiser")&&($option eq "")){
#   &save("create temporary table releve_tmp like releve_bq");
#   &save("insert into releve_tmp select * from releve_bq where date>='$premiere' and date<='$derniere'");
#   &save("insert into releve_tmp select no,montantdev,devise,date_remise,'bordereau',ref from bordereau where date_remise>='$premiere' and date_remise<='$derniere'","af");
#   print "<form>";
#   &form_hidden();
#   print "<input type=hidden name=premiere value=$premiere>";
#   print "<input type=hidden name=derniere value=$derniere>";
#   print "<input type=hidden name=option value=trie>";
#   print "<input type=hidden name=action value=visualiser>";
#   print "<input type=submit value=trier>";
#   print "</form><br>";
  print "<table border=1 cellspacing=0 cellpadding=0><tr><th>Date</th><th>Dev</th><th>Debit</th><th>Credit</th><th>Reference</th><th>Libelle</th><th><span style=color:red>Bordereau</span></th><th><span style=color:red>Ecart</span></th></tr>";
  $query="select * from releve_bq where date>='$premiere' and date<='$derniere' and montant>0 order by date";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array){
#     $cash=0;
#     if ($ref eq "bordereau"){
#       next;
#       $ref="Remise en banque";
#       $cash=&get("select montant from cash where bordereau='$id' and devise='$dev'")+0;
#       $montant-=$cash;
#       print "<tr style=color:red>";
#     }
#     else {print "<tr>";}
    print "<tr><td align=right>$date</td><td>$dev</td>";
    $debit=0;
    $credit=0;
    ($montant >0)? $credit=$montant:$debit=$montant;
    $debit=$debit*-1;
    print "<td align=right>$debit</td><td align=right>$credit</td>";
    print "<td align=right>$ref</td><td align=right>$desi</td>";
#     $ref2=" ";
#     if (($ref eq "Remise en banque")&&(grep /^A/,$desi)){($ref2,$null)=split(/\//,$desi);}
#     if (($ref ne "bordereau")&&(grep /^A/,$ref)){$ref2=$ref;}
#     print "<td>$ref2</td>";
    # if ((grep /^E[0-9]/,$ref)||(grep /^D[0-9]/,$ref)||(grep /^A[0-9]/,$ref)||(grep /^F[0-9]/,$ref)){
    if (grep /^[A-Z][0-9]/,$ref){
 
      print "<td>";
      $query="select * from bordereau where ref like '%$ref%'";
	  $sth2=$dbh->prepare($query);
      $sth2->execute();
      $montant_bor=0;
      while (($no,$devise,$date_creation,$date_remise,$ref,$montant,$montantdev)=$sth2->fetchrow_array){
  	# print "$no,$devise,$date_creation,$date_remise,$ref,$montant,$montantdev";
	  $cash=&get("select montant from cash where bordereau='$no' and devise='$devise'","af")+0;
	  $montantdev-=$cash;
 	  if ($cash!=0){print "cash:$cash<br>";}
	  $montant_bor+=$montantdev;
      }
      $ecart=$credit-$montant_bor;
      if (($montant_bor==$credit)||($ecart==-100)){
	print "<img src=/images/check.png>";
      }
      else
      {
	print "$montant_bor";
      }
      print "</td>";
      print "<td align=right>";
      if ($ecart==$credit){print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=recherche&id=$id&date=$date&montant=$credit&premiere=$premiere&derniere=$derniere>$ecart</a>";}
      else {
      $ecart=int($ecart*100)/100;
      if ($ecart==0){print "&nbsp;";}else {print "$ecart";}}
      print "</td>";
    }
    else
    {
      print "<td>&nbsp;</td><td>&nbsp;</td>";
    }
    print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&id=$id&date=$date&montant=$credit&premiere=$premiere&derniere=$derniere onclick=\"return confirm('Etes vous sur de vouloir supprimer')\"><img border=0 src=../../images/b_drop.png title='Supprimer'></a></td>";
    print "</tr>";
  }
  $query="select * from releve_bq where date>='$premiere' and date<='$derniere' and montant<0 order by desi,date";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array){
    print "<tr><td align=right>$date</td><td>$dev</td>";
    $debit=0;
    $credit=0;
    ($montant >0)? $credit=$montant:$debit=$montant;
    $debit=$debit*-1;
    print "<td align=right>$debit</td><td align=right>$credit</td>";
    print "<td align=right>$ref</td><td align=right>$desi</td>";
    print "<td align=right>&nbsp;</td><td align=right>&nbsp;</td>";
    print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&id=$id&date=$date&montant=$credit&premiere=$premiere&derniere=$derniere onclick=\"return confirm('Etes vous sur de vouloir supprimer')\"><img border=0 src=../../images/b_drop.png title='Supprimer'></a></td>";
     print "</tr>";
  }
  print "</table>";
} 
if (($action eq "visualiser")&&($option eq "trie")){
  $total_banque=$total=$total_banque_inter=$total_remise=0;
  &save("create temporary table releve_tmp like releve_bq");
  &save("insert into releve_tmp select * from releve_bq where date>='$premiere' and date<='$derniere'");
  &save("insert into releve_tmp select no,montantdev,devise,date_remise,'bordereau',ref from bordereau where date_remise>='$premiere' and date_remise<='$derniere'","af");
  
  print "<h3>Credit</h3><table border=1 cellspacing=0 cellpadding=0><tr><th>Date</th><th>Dev</th><th>Debit</th><th>Credit</th><th>Reference</th><th>Libelle</th></tr>";
  $query="select * from releve_tmp where montant>0 order by date";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array){
    if ($ref eq "bordereau"){
      $ref="Remise en banque";
      print "<tr style=color:red>";
      $total_remise+=$montant;
    }
    else {print "<tr>";}
    print "<td align=right>$date</td><td>$dev</td>";
    $debit=0;
    $credit=0;
    ($montant >0)? $credit=$montant:$debit=$montant;
    $debit=$debit*-1;
    $total_banque+=$montant;
    print "<td align=right>$debit</td><td align=right>$credit</td>";
    print "<td align=right>$ref</td><td align=right>$desi</td>";
    # if ((grep /^E[0-9]/,$ref)||(grep /^D[0-9]/,$ref)||(grep /^A[0-9]/,$ref)){
	if (grep /^[A-Z][0-9]/,$ref){
	
      print "<td>";
      $query="select * from bordereau where ref like '%$ref%'";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      while (($no,$devise,$date_creation,$date_remise,$ref,$montant,$montantdev)=$sth2->fetchrow_array){
	print "$no,$devise,$date_creation,$date_remise,$ref,$montant,$montantdev";
      }
      print "</td>";
    }
    else
    {
      print "<td>&nbsp;</td>";
    }
    print "</tr>";
  }
  print "</table>";
  print "Total credit Banque:$total_banque <br>";
  print "Total credit Remise:$total_remise <br>";
  $ecart=$total_banque-$total_remise;
  print "Ecart:$ecart<br>";
  print "<hr></hr>";
 
  $total_banque=$total=$total_banque_inter=$total_remise=0;
  print "<h3>Debit</h3><table border=1 cellspacing=0 cellpadding=0><tr><th>Date</th><th>Dev</th><th>Debit</th><th>Credit</th><th>Reference</th><th>Libelle</th></tr>";
  $query="select * from releve_tmp where montant<0 and ref!='bordereau' order by desi,date";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array){
    $desi_tronq=$desi;
    $desi_tronq=~s/[0-9]//g;
    if ($desi_tronq ne $desi_tronq_tamp){
      $desi_tronq_tamp=$desi_tronq;
      if ($total_banque_inter!=0){
	print "<tr class=gras><td colspan=2>Sous-total</td><td align=right>$total_banque_inter</td></tr>";
	$total_banque_inter=0;
      } 
    }
    if ($ref eq "bordereau"){
      $ref="Remise en banque";
      print "<tr style=color:red>";
      $total_remise+=$montant;
    }
    else {print "<tr>";}
    print "<td align=right>$date</td><td>$dev</td>";
    $debit=0;
    $credit=0;
    ($montant >0)? $credit=$montant:$debit=$montant;
    $debit=$debit*-1;
    $total_banque+=$debit;
    $total_banque_inter+=$debit;
    print "<td align=right>$debit</td><td align=right>$credit</td>";
    print "<td align=right>$ref</td><td align=right>$desi</td></tr>";
  }
  if ($total_banque_inter!=0){
    print "<tr class=gras><td colspan=2>Sous-total</td><td align=right>$total_banque_inter</td></tr>";
    $total_banque_inter=0;
  } 
  print "</table>";
  print "Total debit Banque:$total_banque <br>";
 $total_banque=$total=$total_banque_inter=$total_remise=0;
  print "<h3>Debit</h3><table border=1 cellspacing=0 cellpadding=0><tr><th>Date</th><th>Dev</th><th>Debit</th><th>Credit</th><th>Reference</th><th>Libelle</th></tr>";
  $query="select * from releve_tmp where montant<0 and ref='bordereau' order by desi,date";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array){
    if ($ref eq "bordereau"){
      $ref="Remise en banque";
      print "<tr style=color:red>";
      $total_remise+=$montant;
    }
    else {print "<tr>";}
    print "<td align=right>$date</td><td>$dev</td>";
    $debit=0;
    $credit=0;
    ($montant >0)? $credit=$montant:$debit=$montant;
    $debit=$debit*-1;
    $total_banque+=$debit;
    $total_banque_inter+=$debit;
    print "<td align=right>$debit</td><td align=right>$credit</td>";
    print "<td align=right>$ref</td><td align=right>$desi</td></tr>";
  }
  print "</table>";
  print "Total debit:$total_banque <br>";
} 

;1