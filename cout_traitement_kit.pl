
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
if ($action eq ""){&premiere();}
if ($action eq "cout"){
foreach $base (@bases_client){
  $total=0;
  $total_ca=0;
  $totalpx=0;
  %total=();
  &cout();
}
}
sub premiere{
	print "<center>Recap<br><form>";
	&form_hidden();
	print "Mois (MMAA)( date du vol) :<input type=text name=mois value='$mois'><br>";
	print "Cout de chargement <input type=submit name=action value=cout>";
	print "</form>";	

}


sub cout{
	$query="select v_code,v_vol,v_dest,v_date,v_troltype from $base.vol where v_date%10000='$mois' and v_rot=1 and v_code >0 order by v_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_vol,$v_dest,$v_date,$v_troltype)=$sth->fetchrow_array){
		$ca=&get("select sum(ca_total) from $base.caissesql where ca_code='$v_code'")+0;
		$cout=&get("select lot_cout from $base.lot where lot_nolot='$v_troltype'")+0;
		$color="white";
		if ($cout==0){$color="pink";}
		if ($ca==0){$color="#efefef";}
		
		$v_date_ref=&datemysql($v_date);
		$cout=&get("select lot_cout from $base.lot where lot_nolot=$v_troltype")+0;
		if ($ca!=0){$total{$cout}++;}
		$total_ca+=$ca;
	
	}
	print "<div class=titre style=margin-top:30px>$base</div>";
	print "<table border=1 cellspacing=0>";
	print "<tr><th>Description</th><th>Nombre</th><th>prix total</th></tr>";
	foreach $cle (keys %total){
	  print "<tr><td>Nombre de chargement à $cle Euros</td><td>$total{$cle}</td>";
	  $px_total=$cle*$total{$cle};
	  print "<td align=right>$px_total Euros<br></tr>";
	  $totalpx+=$px_total;
	}
	if ($base eq "togo"){
	  print "<tr><td>Commision sur CA:</td><td>$total_ca Euros</td>";
	  $com=$total_ca/100;
	  print "<td align=right>$com Euros</td></tr>";
	  $totalpx+=$com;
	}
	print "</table>";
	
	print "Total euros:$totalpx euros";
}


;1