
$mois=$html->param("mois");
$an=$mois%100;
$client=$html->param("client");
$action=$html->param("action");
if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
if ($action eq ""){&premiere();}
if ($action eq "remise"){&go();}
if ($action eq "client"){&clien();}
if ($action eq "cout"){&cout();}

sub premiere{
	print "<center>Compta Chargement<br><form>";
	&form_hidden();
	print "Mois (MMAA)( date du vol) :<input type=text name=mois value='$mois'><br>";
	print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=$base_client><br><br>"; 	
	print "Cout de chargement <input type=submit name=action value=cout>";
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

sub cout{
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	print "Mois:$mois   Client:$cl_nom <br>";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Appro</th><th>No vol</th><th>Date du vol</th><th>Ca</th><Th>Trolley</th><th>Cout</th></tr>";
	$query="select v_code,v_vol,v_dest,v_date,v_troltype from vol  where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 and v_code >0 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_dest,$v_date,$v_troltype)=$sth->fetchrow_array){
		$ca=&get("select sum(ca_total) from caissesql where ca_code='$v_code'")+0;
		$cout=&get("select lot_cout from lot where lot_nolot='$v_troltype'")+0;
		$color="white";
		if ($cout==0){$color="pink";}
		if ($ca==0){$color="#efefef";}
		
		print "<tr bgcolor=$color>";
		print "<td align=right nowrap>$v_code</td><td align=right nowrap>$v_vol</td>";
		$v_date_ref=&datemysql($v_date);
		print "<td align=right nowrap>";
		print &date_iso($v_date_ref);
		print "</td>";
		print "<td align=right>$ca";
		print "</td>";
		print "<td align=right>$v_troltype";
		print "</td>";
		$cout=&get("select lot_cout from lot where lot_nolot=$v_troltype")+0;
		print "<td align=right>$cout";
		if ($ca!=0){$total{$cout}++;}
		print "</td>";
		$total_ca+=$ca;
		print "</tr>";

	}
	print "</table>";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Description</th><th>Nombre</th><th>prix total</th></tr>";
	foreach $cle (keys %total){
	  print "<tr><td>Nombre de chargement à $cle Euros</td><td>$total{$cle}</td>";
	  $px_total=$cle*$total{$cle};
	  print "<td align=right>$px_total Euros<br></tr>";
	  $totalpx+=$px_total;
	}
	$com=0;
	if ($base_dbh eq "togo"){$com=2;}
	if (($base_dbh eq "togo")&&($an==14)){$com=1;}
	if ($base_dbh eq "camairco"){$com=1;}
	if ($com!=0){
	  print "<tr><td>Commision sur CA:$com%</td><td>$total_ca Euros</td>";
	  $com=$com*$total_ca/100;
	  print "<td align=right>$com Euros</td></tr>";
	  $totalpx+=$com;
	}
	print "</table>";
	
	print "Total euros:$totalpx euros";
}


;1