
$mois=$html->param("mois")+0;
$mois2=$html->param("mois2")+0;
$client=$html->param("client");
$action=$html->param("action");
if ($action eq ""){&premiere();}
if ($action eq "go"){&go();}
if ($action eq "client"){&clien();}
# if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
print "<title>Commission</title>";                                                                                                                  
sub premiere{
  print "Recap<br><form>";
  &form_hidden();
  print "Mois (MMAA):<input type=text name=mois value=$mois><br>";
  print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=$base_client><br><br>"; 	
  print " <input type=submit>"; 
  print "<input type=hidden name=action value=go>";
  print "<br><br>dernier mois (facultatif) <input type=text name=mois2 value=$mois2>";
  print "</form>";	
}

sub clien{
  $query="select distinct cl_cd_cl,cl_nom from client,trolley where floor(tr_code/10)=cl_cd_cl order by cl_cd_cl";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
	  print "$cl_cd_cl $cl_nom <br>";
  }
}

sub go{
  $query="select cl_nom,cl_com2/100 from client where cl_cd_cl='$client'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($cl_nom,$cl_com2)=$sth->fetchrow_array;
  if ($cl_com2 eq ""){$cl_com2=10000;}

  print "Mois:$mois  $mois2  Client:$cl_nom <br>";
  if ($mois2>0){
	  if (($mois%100) != ($mois2%100)){
		  $fin=int($mois/100)*100+12;
		  $debut=int($mois2/100)*100+1;
		  $query="select v_code,v_rot from vol where v_cd_cl='$client' and v_code >0 and ((v_date%10000>='$mois' and v_date%10000<='$fin') or (v_date%10000>='$debut' and v_date%10000<='$mois2')) ";
	  }
	  else
	  {
		  $query="select v_code,v_rot from vol where v_cd_cl='$client' and v_date%10000>='$mois' and v_date%10000<='$mois2' and v_code >0";
	  }
  }
  if ($mois2==0)
  {
  $query="select v_code,v_rot from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_code >0";
  }
  # print $query;
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
	  if ($eq_cc ne ""){
		  $query="select hot_tri from hotesse where hot_mat='$eq_cc' and hot_cd_cl='$client'";
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  ($hot_tri)=$sth2->fetchrow_array;
		  if ($hot_tri eq ""){$eq_cc="<font color=red>$eq_cc</font>";}else{$eq_cc=$hot_tri;}
	  
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
		  $cl_com2+=0;
		  print "<tr><th>Appro</th><th>Vol</th><th>Rotation</th><th>Date</th><th>Equipage</th><th>Recettes</th><th>Nb pnc</th><th>Commissions $cl_com2%</th></tr>";
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
	  if ($eq_cc ne ""){
		  $query="select hot_tri from hotesse where hot_mat='$eq_cc' and hot_cd_cl='$client'";
		  
		  $sth2=$dbh->prepare($query);
		  $sth2->execute();
		  ($hot_tri)=$sth2->fetchrow_array;
		  if ($hot_tri eq ""){$eq_cc="<font color=red>$eq_cc</font>";}else{$eq_cc=$hot_tri;}
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
	  $ecart_force=&get("select ecc_montant from ecart_commision where ecc_code='$code' and ecc_rot='$rot'");
	  # $ca_recettes-=$ecart_force;
	  print "<td align=right>";
	  $ca_aff=int($ca_recettes);
# 	  print &deci($ca_recettes);
	  print "$ca_aff";
	  print "</td><td align=right>$nb</td><td align=right>";
	  $com=($ca_recettes*$cl_com2)/($nb*100) - $ecart_force/$nb;
	  print &deci($com);
	  print "</td></tr>";
	  $recap{$nomtampon}+=$com;
	  $recapnb{$nomtampon}+=1;
  }
  print "</table><br>";

  print "<b>Recapitulatif</b><br> <table border=1 cellspacing=0>";
  @index= sort (keys(%recap));

  foreach (@index){
	  $nom=$_;
	  $query="select hot_nom,hot_mat from hotesse where (hot_tri='$nom' or hot_mat='$nom') and hot_cd_cl='$client'";
	  $sthb=$dbh->prepare($query);
	  $sthb->execute();
	  ($hot_nom,$hot_mat)=$sthb->fetchrow_array;
	  if ($hot_nom eq ""){$hot_nom=" NON REFERENCE";}
	  print "<tr><td>$nom $hot_nom $hot_mat</td><td align=right>";
	  print &deci($recap{$nom});
	  # pour faire la moyenne
	  # print "</td><td align=right>";
	  # print &deci2($recapnb{$nom});
	  print "</td></tr>";
	  $total+=&deci($recap{$nom});
	  }
  print "<tr><th>Total</th><th align=right>";
  print &deci($total);
  print "</td></tr></table>";

}
;1