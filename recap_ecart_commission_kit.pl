
$client=$base_client;
$action=$html->param("action");
$firstdate=$html->param("firstdate");
$lastdate=$html->param("lastdate");
if (grep(/\//,$firstdate)) {
	($jj,$mm,$aa)=split(/\//,$firstdate);
	$firstdate=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$lastdate)) {
	($jj,$mm,$aa)=split(/\//,$lastdate);
	$lastdate=$aa."-".$mm."-".$jj;
}
print "<title>Commission</title>";                                                                                                                  

if ($action eq ""){
  print "Ecart sur caisse<br><form>";
  &form_hidden();
  print "<br>Premiere date <input id=\"datepicker\" type=text name=firstdate size=12>";
  print "<br>Derniere date <input id=\"datepicker2\" type=text name=lastdate size=12>";
  print "<br><input type=submit>"; 
  print "<input type=hidden name=action value=go>";
  print "</form>";	
}

if ($action eq "go"){
  $query="select cl_nom,cl_com2/100 from client where cl_cd_cl='$client'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($cl_nom,$cl_com2)=$sth->fetchrow_array;
  if ($cl_com2 eq ""){$cl_com2=10000;}

  print "Periode du ";
  print &date_iso($firstdate);
  print " Au ";
  print &date_iso($lastdate);
  print " Client:$cl_nom <br>";
  $query="select v_code,v_rot from vol,ecart_commision where v_cd_cl='$client' and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and v_code >0  and v_code=ecc_code and v_rot=ecc_rot";
#   print $query;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code,$rot)=$sth->fetchrow_array){
	  $ca_recettes="";
	  $query="select ca_total,ca_papi from caissesql where ca_code='$code' and ca_rot='$rot'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  ($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
	  if ($ca_recettes eq ""){
		  $query="select ca_recettes/100,ca_cheque/100 from caisse where ca_code='$code' and ca_rot='$rot'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  ($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
	  }
	  if (($ca_recettes eq "")or($ca_recettes==0)){next;}
	  $eq_tri=$eq_cc="";
	  $query="select eq_cc,eq_equipage from equipagesql where eq_code='$code' and eq_rot='$rot'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  ($eq_cc,$eq_tri)=$sth2->fetchrow_array;
	  if ($eq_tri eq ""){
		  $query="select eq_nom from equip where eq_code='$code' and eq_rot='$rot'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  while (($nom)=$sth2->fetchrow_array){$eq_tri=$eq_tri.";".$nom;}
	  }
	  if (($eq_cc>100)&&($eq_cc<999)){
		  $query="select hot_tri from hotesse where hot_mat='$eq_cc' and hot_cd_cl='$client'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  ($eq_cc)=$sth2->fetchrow_array;
		  if ($eq_cc eq ""){$eq_cc="<font color=red>NULL</font>";}
	  }

	  
	  $eq_tri=$eq_cc.$eq_tri;
	  (@liste)=split(/;/,$eq_tri);
	  foreach (@liste){
		  if ($_ ne ""){$listepnc{$_.";".$code.";".$rot}="true";}
	  }
  }
  print "<table border=1 cellspacing=0>";
  @index= sort (keys(%listepnc));
  foreach (@index){
	  ($nom,$code,$rot)=split(/;/,$_);
	  if ($nom ne $nomtampon){
		  $query="select hot_nom,hot_mat from hotesse where (hot_tri='$nom' or hot_mat='$nom') and hot_cd_cl='$client'";
		  $sthb=$dbh->prepare($query);
		  $sthb->execute();
		  ($hot_nom,$hot_mat)=$sthb->fetchrow_array;
		  if ($hot_nom eq ""){$hot_nom=" NON REFERENCE";}
		  print "<tr><td colspan=7><b>$nom $hot_nom $hot_mat</td></tr>";
		  print "<tr><th>Appro</th><th>Vol</th><th>Rotation</th><th>Date</th><th>Equipage</th><th>Recettes</th><th>Ecart</th><th>Nb pnc</th><th>Part ecart</th></tr>";
	  
		  $nomtampon=$nom;
	  }
	  $query="select v_code,v_rot,v_vol,v_date,v_dest from vol where v_code='$code' and v_rot='$rot'";
	  $sthb=$dbh->prepare($query);
	  $sthb->execute();
	  ($v_code,$v_rot,$v_vol,$v_date,$v_dest)=$sthb->fetchrow_array;
	  print "<tr><td>$v_code</td><td>$v_vol</td><td>$v_rot</td><td>$v_date</td> " ;
	  $eq_tri=$eq_cc="";
	  $query="select eq_cc,eq_equipage from equipagesql where eq_code='$code' and eq_rot='$rot'";
	  $sth2=$dbh->prepare($query);
	    $sth2->execute();
	  ($eq_cc,$eq_tri)=$sth2->fetchrow_array;
	  if ($eq_tri eq ""){
		  $query="select eq_nom from equip where eq_code='$code' and eq_rot='$rot'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  while (($nom)=$sth2->fetchrow_array){$eq_tri=$eq_tri.";".$nom;}
	  }
	  if (($eq_cc>100)&&($eq_cc<999)){
		  $query="select hot_tri from hotesse where hot_mat='$eq_cc' and hot_cd_cl='$client'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  ($eq_cc)=$sth2->fetchrow_array;
		  if ($eq_cc eq ""){$eq_cc="<font color=red>NULL</font>";}
	  }

	  $eq_tri=$eq_cc.$eq_tri;
	  (@liste)=split(/;/,$eq_tri);
	  $nb=0;
	  print "<td>";
	  foreach (@liste){
		  if ($_ ne ""){ print "$_ ";$nb++;}
	  }
	  print "</td>";
	  $query="select ca_total,ca_papi from caissesql where ca_code='$code' and ca_rot='$rot'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  ($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
	  if ($ca_recettes eq ""){
		  $query="select ca_recettes/100,ca_cheque/100 from caisse where ca_code='$code' and ca_rot='$rot'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  ($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
	  }
	  
	  $ca_recettes-=$ca_papi;
	  # fond de caisse
	  $fondcaisse=&get("select ap_qte0*ap_prix/10000 from appro where ap_code='$code' and ap_cd_pr=800205","af")+0;
	  $ca_recettes-=$fondcaisse;
	  $ecart_force=&get("select ecc_montant from ecart_commision where ecc_code='$code' and ecc_rot='$rot'");
	  $ca_recettes-=$ecart_force;
	  print "<td align=right>";
	  print &deci($ca_recettes);
	  $ecart=&get("select  ecc_montant from ecart_commision where ecc_code='$code' and ecc_rot='$rot'")+0;
	  print "</td><td align=right>$ecart";
	  print "</td><td align=right>$nb</td><td align=right>";
	  $com=($ecart/$nb);
	  print &deci($com);
	  print "</td></tr>";
	  
	  $recap{$nomtampon}+=$com;
	  $recapnb{$nomtampon}+=1;

	  # print "<tr><td>$recap{$nom} *$nomtampon*</td></tr>";
  }
  print "</table><br>";

  &save("create temporary table com_tmp (trig char(3),val decimal (8,2) , nb decimal (8,2))");
  @index= sort (keys(%recap));
  foreach (@index){
	  $nom=$_;
	  $val=$recap{$nom};
	  $nb=$recapnb{$nom};
	  $moy=int($val*100/$nb)/100;
	  &save("insert into com_tmp values ('$nom','$val','$moy')");
  }	    
  $query="select * from com_tmp order by nb desc";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  	$total=0;
  print "<b>Recapitulatif</b><br> <table border=1 cellspacing=0><tr><th>Pnc</th><th>Valeur</th><th>Moyenne</th></tr>";
  while (($nom,$val,$nb)=$sth2->fetchrow_array){
	  $query="select hot_nom,hot_mat from hotesse where (hot_tri='$nom' or hot_mat='$nom') and hot_cd_cl='$client'";
	  $sthb=$dbh->prepare($query);
	  $sthb->execute();
	  ($hot_nom,$hot_mat)=$sthb->fetchrow_array;
	  if ($hot_nom eq ""){$hot_nom=" NON REFERENCE";}
	  print "<tr><td>$nom $hot_nom</td><td align=right>";
	  print $val;
	  $total+=$val;
	  print "</td><td align=right>";
	  print $nb;
	  print "</td></tr>";
	  }
print "<tr><td><strong>Total</strong></td><td align=right><strong>$total</strong></td><td>&nbsp;</td></tr></table>";
}
;1