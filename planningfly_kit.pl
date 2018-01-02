print "<title>planning</title><center>";
print "<div class=titrefixe>Consultation du planning</div>";
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$nbjour=$html->param('nbjour');
$action=$html->param('action');
$vol=$html->param('vol');
$leg=$html->param('leg');
$lot_nolot=$html->param('lot_nolot');
$client=$html->param('client');

$escale=$html->param('escale');
$date=$html->param('date');
if ($html->param('decal') eq "on"){$decal=-7;};
$today=&nb_jour($jour,$mois,$an)+$decal;
$decalheure=0; # heure hivers
if (($today>=12869)&&($today<=13086)){$decalheure=0;}
if (($today>=13233)&&($today<=13450)){$decalheure=0;}   # ETE 2006
if (($today>=13597)&&($today<=13814)){$decalheure=0;}   # ETE 2007
if (($today>=13968)&&($today<=14178)){$decalheure=0;}   # ETE 2008
if (($today>=14332)&&($today<=14542)){$decalheure=0;}   # ETE 2009
if (($today>=14696)&&($today<=14913)){$decalheure=0;}   # ETE 2010
if (($today>=15060)&&($today<=15277)){$decalheure=0;}   # ETE 2011

if ($an<8){$today=$an;}

$datedujour=&nb_jour(`/bin/date '+%d'`+0,`/bin/date '+%m'`+0,"20".`/bin/date '+%y'`+0);

if ($today==-1){$today=$html->param('today');}


$date_sql=&julian($today,"yyyy-mm-dd");

if ($action eq "creation_1"){
  if (($vol eq "")||($leg==0)||($lot_nolot eq "")){print "<span style=background:pink>merci de mettre un numero de vol, un nombre d'equipage, un trolley type</span><br>";$action="creation_0";}else{
    &save("insert ignore into flyhead value ('$today','$vol','$client','$leg','$lot_nolot','0','0','0','0','0','$date_sql')");
    for ($i=1;$i<=$leg;$i++){
      $leg_index=$i*10+1;
      $dep="___";
      $arr="___";
      if ($i==1){$dep="ABJ";}
      # a modifier par base
      &save("insert ignore into flybody value ('$today','$vol','$leg_index','$today','$vol','0','0','$dep','___','0')");
      $leg_index=$i*10+2;
      $dep="___";
      if ($i==$leg){$arr="ABJ";}
      &save("insert ignore into flybody value ('$today','$vol','$leg_index','$today','$vol','0','0','___','$arr','0')");
    }
    $date=$today;
    $action="modif";
  }
}  
    
if ($action eq "creation_0"){
  print "<form>";
  &form_hidden();
  if ($leg==0){$leg=1;}
  print "Code client ? <input type=text name=client value=$base_client_code><br>";
  print "Numero de vol ? <input type=text name=vol value=$vol><br>";
  print "Nombre d'equipage <input type=text name=leg value=$leg><br>";
  $query="select lot_nolot from lot where lot_flag=1";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($lot_nolot)=$sth->fetchrow_array){
    print "$lot_nolot <input type=radio name=lot_nolot value=$lot_nolot><br>";
  }    
  print "<input type=hidden name=action value=creation_1>";
  print "<input type=hidden name=nbjour value='$nbjour'>";
  print "<input type=hidden name=datejour value='$jour'>";
  print "<input type=hidden name=datemois value='$mois'>";
  print "<input type=hidden name=datean value='$an'>";
  print "<input type=submit>";
  print "</form>";
}



if ($action eq "validmodif"){
	$copier=$html->param("copier");
	$sup=$html->param("sup");
	$double=$html->param("double");
	$deplacer=$html->param("deplacer");

	if ($sup eq "on"){
		$query="delete from flyhead where fl_vol='$vol' and fl_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		$query="delete from flybody where flb_vol='$vol' and flb_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		# print "<font color=red> Vol supprimé<br></font>";
		$action="affiche";
	}
	elsif ($double eq "on"){
		$query="select * from flyhead where fl_vol='$vol' and fl_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		(@flyhead)=$sth3->fetchrow_array;
		$flyhead[1].="B"      ; # fl_vol
		$flyhead[7]=0;		# fl_nolot
		$flyhead[9]='';		# fl_apcode
		$query="replace into flyhead values(";
		foreach (@flyhead) {
			$query.="'".$_."',";
		}
		chop $query;
		$query.=")";
		# print "$query<br>";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		
		$query="select * from flybody where flb_vol='$vol' and flb_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while ((@flybody)=$sth3->fetchrow_array){
			$flybody[1].="B";
			$query="replace into flybody values(";
			foreach (@flybody) {
				$query.="'".$_."',";
			}
			chop $query;
			$query.=")";
			# print "$query<br>";
			$sth4=$dbh->prepare($query);
			$sth4->execute();
		}
		print "<font color=red>vol dupliqué</font></br>";
	}

	elsif ($copier eq "on"){
		$decalage=$html->param("decalage");
		$query="select * from flyhead where fl_vol='$vol' and fl_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		(@flyhead)=$sth3->fetchrow_array;
		$flyhead[0]+=$decalage; # fl_date
		$flyhead[10]=&julian($flyhead[0],"yyyy-mm-dd");
		$flyhead[7]=0;		# fl_nolot
		$flyhead[9]='';		# fl_apcode
		$flyhead[8]=1;		# fl_part vol regulier
		$query="insert ignore into flyhead values(";
		foreach (@flyhead) {
			$query.="'".$_."',";
		}
		chop $query;
		$query.=")";
		# print "$query<br>";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		
		$query="select * from flybody where flb_vol='$vol' and flb_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while ((@flybody)=$sth3->fetchrow_array){
			$flybody[0]+=$decalage;
			$flybody[3]+=$decalage;
			$query="insert ignore into flybody values(";
			foreach (@flybody) {
				$query.="'".$_."',";
			}
			chop $query;
			$query.=")";
			# print "$query<br>";
			$sth4=$dbh->prepare($query);
			$sth4->execute();
		}
		print "<font color=red>vol copié</font></br>";
		$date=$date+$decalage;
	}
	elsif ($deplacer eq "on"){
		$decalage=$html->param("decalage");
		$query="select * from flyhead where fl_vol='$vol' and fl_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		(@flyhead)=$sth3->fetchrow_array;
		$flyhead[0]+=$decalage; # fl_date
		$flyhead[10]=&julian($flyhead[0],"yyyy-mm-dd");
		$flyhead[7]=0;		# fl_nolot
		$flyhead[9]='';		# fl_apcode
		$query="insert ignore into flyhead values(";
		foreach (@flyhead) {
			$query.="'".$_."',";
		}
		chop $query;
		$query.=")";
		# print "$query<br>";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		
		$query="select * from flybody where flb_vol='$vol' and flb_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while ((@flybody)=$sth3->fetchrow_array){
			$flybody[0]+=$decalage;
			$flybody[3]+=$decalage;
			$query="insert ignore into flybody values(";
			foreach (@flybody) {
				$query.="'".$_."',";
			}
			chop $query;
			$query.=")";
			# print "$query<br>";
			$sth4=$dbh->prepare($query);
			$sth4->execute();
		}
		$query="delete from flyhead where fl_vol='$vol' and fl_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		$query="delete from flybody where flb_vol='$vol' and flb_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		print "<font color=red>vol deplacé</font></br>";
		$date=$date+$decalage;
	}
	elsif ($html->param("annule") eq "on"){
		&save ("update flyhead set fl_part=2 where fl_vol='$vol' and fl_date=$date");  
		$fl_apcode=&get("select fl_apcode from flyhead where fl_vol='$vol' and fl_date=$date");
		# if ($fl_apcode > 0){&save("update vol set v_zatt='AN' where v_code='$fl_apcode'");}
	}
	elsif ($html->param("rotsup") ne ""){
	# rotation supplementaire
		$tridep=$html->param("tridepsup");
		$depart=$html->param("departsup");
		$depart=~s/\.//;
		$datetr=$html->param("datesup");
		# ($jour_sup,$mois_sup,$annee_sup)=split(/\//,$datetr);
		$datetr=&nb_jour(split(/\//,$datetr));
		$triret=$html->param("triretsup");
		$arrivee=$html->param("arriveesup");
		$arrivee=~s/\.//;
		$query="replace into flybody value ('$date','$vol','".$html->param("rotsup")."','$datetr','".$html->param("volsup")."','$depart','$arrivee','$tridep','$triret',0)";
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "$query<br>";
		$query="select max(floor(flb_rot/10)) from  flybody where flb_date='$date' and flb_vol='$vol'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($maxrot)=$sth->fetchrow_array;
		$query="update flyhead set fl_nbrot='$maxrot' where fl_date='$date' and fl_vol='$vol'";
		print "<font color=red>rotation inserée</font <br>";
		print $query;
	}
	else {
		$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype from flyhead where fl_date=$date and fl_vol='$vol'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype)=$sth->fetchrow_array;
		if ($fl_vol eq "") { exit;}
		$volhead=$html->param('volhead');
		$troltype=$html->param('troltype');

		if ($fl_vol ne $volhead){
			$query="update flyhead set fl_vol='$volhead' where fl_vol='$vol' and fl_date=$date";  
			# print "$query<br>";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			$query="update flybody set flb_vol='$volhead' where flb_vol='$vol' and flb_date=$date";  
			# print "$query<br>";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
# 			$query="update flybody set flb_voltr='$volhead' where flb_vol='$volhead' and flb_date=$date and flb_rot=11";  
 			$query="update flybody set flb_voltr='$volhead' where flb_vol='$volhead' and flb_date=$date ";  

			# print "$query<br>";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			print "<font color=red> No de vol modifié</font></br>";
			$vol=$volhead;
		}
		if ($fl_troltype ne $troltype){
			$query="update flyhead set fl_troltype='$troltype' where fl_vol='$fl_vol' and fl_date=$date";
			# print "$query<br>";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			print "<font color=red>Trolley type modifié<br></font>";
		}
		if ($html->param("tous") eq "on"){
		  $encore=1;
		  $date_run=$date;
		  $nb_tous=0;
		  while ($encore){
			$date_run+=7;
		 	$encore=&get("select count(*) from flyhead where fl_vol='$fl_vol' and fl_date=$date_run and fl_apcode=0");
		  	if ($encore){
			  &save("update flyhead set fl_troltype='$troltype' where fl_vol='$fl_vol' and fl_date=$date_run");
			  $nb_tous++;
			}
		  }
		  print " <font color=red>$nb_tous vol(s) avec le trolley type modifié<br></font>";
		}
	
		$query="select flb_tridep,flb_triret,flb_depart,flb_arrivee,flb_rot,flb_voltr,flb_datetr from flybody where flb_vol='$vol' and flb_date=$date order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($flb_tridep,$flb_triret,$flb_depart,$flb_arrivee,$flb_rot,$flb_voltr,$flb_datetr)=$sth2->fetchrow_array){
			$tridep=$html->param("tridep$flb_rot");
			$depart=$html->param("depart$flb_rot");
			$depart=~s/\.//;
			$datetr=$html->param("datetr$flb_rot");
			($jour_sup,$mois_sup,$annee_sup)=split(/\//,$datetr);
			# $datetr=&nb_jour($jour_sup,$mois_sup,$annee_sup);
			$datetr=&nb_jour(split(/\//,$datetr));
			$triret=$html->param("triret$flb_rot");
			$arrivee=$html->param("arrivee$flb_rot");
			$arrivee=~s/\.//;
			if ($flb_tridep ne $tridep){
				$query="update flybody set flb_tridep='$tridep' where flb_rot=$flb_rot and flb_vol='$vol' and flb_date=$date";
				# print "$query<br>";
				$sth3=$dbh->prepare($query);
				$sth3->execute();
				print "<font color=red>Trigramme depart de la rotation $flb_rot modifié<br></font>";
				}
			if (($flb_depart ne $depart)&&($flb_rot==11)){
				$query="update flybody set flb_depart='$depart' where flb_rot=$flb_rot and flb_vol='$vol' and flb_date=$date";
				# print "$query<br>";
				$sth3=$dbh->prepare($query);
				$sth3->execute();
				print "<font color=red>Heure de depart modifié<br></font>";
			}	
			if ($flb_datetr ne $datetr){
				if (($flb_rot==11)&&($date ne $datetr)){
					print "<font color=red>Date invalide $flb_datetr $datetr</font><br>";
				}
				else {
					$query="update flybody set flb_datetr='$datetr' where flb_rot=$flb_rot and flb_vol='$vol' and flb_date=$date";
					&save("insert ignore into traceur values (now(),\"$query\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
					# print "$query<br>";
					$sth3=$dbh->prepare($query);
					$sth3->execute();
					print "<font color=red>date de la rotation $flb_rot modifiée<br></font>";
				}
			}
		
			if ($flb_triret ne $triret){
				$query="update flybody set flb_triret='$triret' where flb_rot=$flb_rot and flb_vol='$vol' and flb_date=$date";
				# print "$query<br>";
				$sth3=$dbh->prepare($query);
				$sth3->execute();
				print "<font color=red>Trigramme retour de la rotation $flb_rot modifié<br></font>";
			}
			if (($flb_arrivee ne $arrivee)&&($arrivee ne "")){
				$query="update flybody set flb_arrivee='$arrivee' where flb_rot=$flb_rot and flb_vol='$vol' and flb_date=$date";
				# print "$query<br>";
				$sth3=$dbh->prepare($query);
				$sth3->execute();
				print "<font color=red>Heure d'arrivee modifié<br></font>";
			}
		}
	}
if (($action ne "")&&($action ne "affiche")){$action="modif"};	
}

if ($action eq ""){
	print "<center><br>Choix de la date<br><br><form>";
	require ("form_hidden.src");
	&select_date();
	print "  semaine dernière <input type=checkbox name=decal>";
	print "<br><br>nombre de jour:";
	print "<select name=nbjour>"; 
 	for($i=1;$i<=21;$i++) {print "<option value=\"$i\">$i</option>\n";} 
 	print "</select>"; 
  	print " escale uniquement <input type=checkbox name=escale>";
  	print "<input type=hidden name=action value=affiche>";
	print "<br><br><input type=submit></form>	";
        print "<br><br><br></div>";
      	print "<img src=/kit/images/aeroport.gif align=center> <a href=\"aeroport.pl\" target=\"wclose\" onclick=\"window.open('popup.htm','wclose','width=380,height=350,toolbar=no,status=no,left=20,top=30')\">";
	print " aeroport </a>";
}


if ($action eq "affiche")
{
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	print  "<center>";
	for ($i=0;$i<$nbjour;$i++){
		&table($today+$i);
	}
	print "<a href=\"javascript:history.back()\">Retour</a>";
}
if ($action eq "modif")
{
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	print $date;
	&vol($date);
	print "</div><a href=\"javascript:history.back()\">Retour</a>";
}


sub table{
	my $today=$_[0];
	if (($today>=12869)&&($today<=13086)){$decalheure=0;}
	if (($today>=13233)&&($today<=13450)){$decalheure=0;}   # ETE 2006
	if (($today>=13597)&&($today<=13814)){$decalheure=0;}   # ETE 2007
	if (($today>=13968)&&($today<=14178)){$decalheure=0;}   # ETE 2008
	if (($today>=14332)&&($today<=14542)){$decalheure=0;}   # ETE 2009
	if (($today>=14696)&&($today<=14913)){$decalheure=0;}   # ETE 2010
	if (($today>=15060)&&($today<=15277)){$decalheure=0;}   # ETE 2011
	print  "<h3>";
	print  &jour($today);
	print  " ";
	print  &julian($today,"");
	print  "</h3>\n";
	print  "<table id=\"petit\" border=1 cellspacing=0 cellpadding=0><tr bgcolor=#5580ab><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Tronçon</th><th>Validation</th></tr>";
	($datejour,$datemois,$datean)=split(/\//,&julian($today,""));
# 	print "<tr><td><a href=javascript:saisie() ";
 	print "<tr><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=creation_0&nbjour=$nbjour&datejour=$datejour&datemois=$datemois&datean=$datean ";
	
	if ($datedujour>=$today){print " onclick=\"alert(\'Attention Date anterieur à aujourd hui \')\"";}
	print " >Nouveau</a><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
 	if ($escale eq "on"){
		$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_apcode,fl_part,fl_nolot from flyhead,flybody where fl_date=$today and fl_date=flb_date and fl_vol=flb_vol and flb_rot=11 and (flb_tridep='LYS' or flb_tridep='MRS')";
	}
	else {
		$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_apcode,fl_part,fl_nolot from flyhead where fl_date=$today";
	}	
	$sth=$dbh->prepare($query);
	$sth->execute();

	while (($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_apcode,$fl_part,$fl_nolot)=$sth->fetchrow_array){
		$query="select flb_tridep,flb_triret,flb_depart,flb_arrivee,flb_rot,flb_voltr,flb_datetr from flybody where flb_vol='$fl_vol' and flb_date=$fl_date order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		print  "<tr><td><b>";
		if ($fl_apcode >0){
			$v_cd_cl=&get("select v_cd_cl from vol where v_code='$fl_apcode' and v_rot=1");
			if ($v_cd_cl != $fl_cd_cl){
				print "<font color=red>";
				$fl_cd_cl=$v_cd_cl;
			}
		}		
		($cl_nom)=split(/;/,$client_dat{$fl_cd_cl});
			
		print  $cl_nom;
		print "<font size=-2> $fl_cd_cl</font>";
		if ($fl_part==1){print " <img src=../volregulier.jpg>";}
		print  "</td>";
		$query="select lot_conteneur from lot where lot_nolot=$fl_troltype";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($lot_conteneur)=$sth3->fetchrow_array;
		# print  "<td align=center><font size=+2><a href=validapp.pl?vol=$fl_vol&date=$fl_date>$fl_vol</a></td><td align=center>$fl_troltype<br><nobr>$lot_conteneur</td>";
		# validapp procedure servair
		 print  "<td align=center><font size=+2>$fl_vol</td><td align=center>$fl_troltype<br><nobr>$lot_conteneur</td>";

		if ($fl_troltype==8){$nbparis--;}
		if ($fl_troltype==7){$nbparis--;}

		print "<td ";
		 if ($fl_part==2){print "background=http://ibs.oasix.fr/images/annule.gif style=\"filter:alpha(opacity=50); -moz-opacity:0.5; -khtml-opacity: 0.5; opacity: 0.5;background-repeat:no-repeat;background-position:center;\"";}
		print "><table id=\"petit\" border=0 cellspacing=0 width=100%>";
		print "<tr>";
		print "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>Charg LT</td><td>depart LT</td><td>depart UT</td>";
		print "<td>&nbsp;</td><td>Arr LT</td><td>Arr UT</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
		
		
		while (($flb_tridep,$flb_triret,$flb_depart,$flb_arrivee,$flb_rot,$flb_voltr,$flb_datetr)=$sth2->fetchrow_array){
			$query="select aero_type,aerd_desi from aeroport,aerodesi where aero_tri=aerd_trig and aero_tri='$flb_triret' and aero_tri!='CDG' and aero_tri!='ORY'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($aero_type,$aerd_desi)=$sth3->fetchrow_array;
			if ($flb_depart==0){$flb_depart="&nbsp;";}
			else {$flb_depart=&deci($flb_depart/100);}
			if ($flb_arrivee==0){$flb_arrivee="&nbsp;";}
			else {$flb_arrivee=&deci($flb_arrivee/100);}
			$datetr=&julian($flb_datetr);
			
			if (($flb_rot==11)&&($flb_datetr!=$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			if (($flb_rot!=11)&&($flb_datetr<$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			
			print "<tr><td>$flb_rot</td><td>$flb_voltr</td><td>";
			if (($flb_tridep eq "LYS")||($flb_tridep eq "MRS")){print "<Font color=blue size=+1>";}
			print "$flb_tridep</td><td align=right><b>";
			if (($flb_tridep eq "CDG")||($flb_tridep eq "ORY")){$nbparis++;}
			if (($flb_tridep eq "LYS")||($flb_tridep eq "MRS")){$nbescale++;}
			
			print $flb_depart;
			print "<td align=right>".&cal_heure($flb_depart,+1)."</td>";
			print "<td align=right><font color=green>".&cal_heure($flb_depart,1-$decalheure)."</td>";
			print "</td><td align=right>$flb_triret</td><td align=right><b>$flb_arrivee</td>";
			print "<td align=right><font color=green>".&cal_heure($flb_arrivee,0-$decalheure)."</td>";
			print "<td>$datetr</td><td>$aerd_desi</td><td>$aero_type</td></tr>";
		}
	
		print  "</table>\n</td><td>";
#  		print "*$fl_apcode $fl_vol $fl_date*";
		if ($fl_apcode>0){
			$at_etat=&get("select at_etat from etatap where at_code='$fl_apcode'");		
			if ($at_etat>2){print "<img src=http://ibs.oasix.fr/images/camion.gif>";}
			print "<a href=debug_appro.pl?appro=$fl_apcode>$fl_apcode</a><br>lot $fl_nolot<br>";
		}
		print "\n<form>";
		print "<input type=hidden name=onglet value='$onglet'> 
		<input type=hidden name=sous_onglet value='$sous_onglet'> 
		<input type=hidden name=sous_sous_onglet value='$sous_sous_onglet'>";
		print "<input type=hidden name=action value=modif>";
		print "<input type=hidden name=vol value='$fl_vol'>";
		print "<input type=hidden name=date value='$fl_date'>";
		print "<input type=hidden name=nbjour value='$nbjour'>";
		print "<input type=hidden name=datejour value='$jour'>";
		print "<input type=hidden name=datemois value='$mois'>";
		print "<input type=hidden name=datean value='$an'>";
		print "<input type=submit value=modif ";
		if ($fl_apcode != 0){
			print "onclick=\"alert(\'Attention Vol affecté au bon d appro $fl_apcode\')\"";
		}
		print "></form></td>";
		print  "</tr>\n";
	}
	print "<script>
	function saisie(){
		window.open('/saivol.php?datejour=$datejour&datemois=$datemois&datean=$datean&nbjour=$nbjour','','width=900,height=500,toolbar=no,status=no,location=yes,menubar=yes left=20,top=30');
	}	
	</script>";

	($datejour,$datemois,$datean)=split(/\//,&julian($today,""));
=pod
	print "<tr><td><input type=button value=nouveau onclick=\"";
	if ($datedujour>=$today){
		print "alert(\'Attention Date anterieur à aujourd hui continuer malgré tout ?\');";
	}
	print "window.open('/saivol.php?datejour=$datejour&datemois=$datemois&datean=$datean&nbjour=$nbjour','wclose','width=900,height=500,toolbar=no,status=no,left=20,top=30')\"";
	print "</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
=cut	

	print  "</table>\n";
	print "Lome:$nbparis<br>";
	print "escale:$nbescale<br>";
	$nbparis=$nbescale=0;
}

sub vol{
	my $today=$_[0];
	print  "<center><h3>";
	print  &jour($today);
	print  " ";
	print  &julian($today,"");
	print  "</h3>\n";
	print  "<form id='petit'>";
	require("form_hidden.src");
	print "<table id='petit' border=1 cellspacing=0 cellpadding=0><tr bgcolor=#5580ab><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Tronçon</th></tr>";
	$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype from flyhead where fl_date=$date and fl_vol='$vol'";
	$sth=$dbh->prepare($query);
	$sth->execute();

	while (($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype)=$sth->fetchrow_array){
		$query="select flb_tridep,flb_triret,flb_depart,flb_arrivee,flb_rot,flb_voltr,flb_datetr from flybody where flb_vol='$fl_vol' and flb_date=$fl_date order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		print  "<tr><td><b>";
		($cl_nom)=split(/;/,$client_dat{$fl_cd_cl});
		print  $cl_nom;
		print  "</td>";
		print  "<td align=center><input type=text name=volhead value='$fl_vol' size=8></td><td align=center>";
		print "<input type=text name=troltype value='$fl_troltype' size=4><br><span style=font-size:0.7em>maj tous les prochains vols même jour</span><input type=checkbox name=tous></td>";
		print "<td><table border=0 cellspacing=0 width=100%>";
		print "<tr bgcolor=lightblue><td>Leg</td><td>Vol</td><td>Dep</td><td>Heure</td><td>Arr</td><td>Heure</td><td>Date</td></tr>";
		while (($flb_tridep,$flb_triret,$flb_depart,$flb_arrivee,$flb_rot,$flb_voltr,$flb_datetr)=$sth2->fetchrow_array){
			$query="select aero_type,aerd_desi from aeroport,aerodesi where aero_tri=aerd_trig and aero_tri='$flb_triret' and aero_tri!='CDG' and aero_tri!='ORY'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($aero_type,$aerd_desi)=$sth3->fetchrow_array;
			if ($flb_depart==0){$flb_depart="0";}
			else {$flb_depart=&deci($flb_depart/100);}
			if ($flb_arrivee==0){$flb_arrivee="0";}
			else {$flb_arrivee=&deci($flb_arrivee/100);}
			$datetr=&julian($flb_datetr);
			
			# if (($flb_rot==11)&&($flb_datetr!=$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			# if (($flb_rot!=11)&&($flb_datetr<$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			
			print "<tr><td>$flb_rot</td><td>$flb_voltr</td>";
			print "<td><input type=text name=tridep$flb_rot value='$flb_tridep' size=3></td><td align=right>";
			if ($flb_depart ne "&nbsp;"){print "<input type=text name=depart$flb_rot value='$flb_depart' size=5>";}
			else {print "$flb_depart";}
			print "</td><td><input type=text name=triret$flb_rot size=3 value='$flb_triret'></td><td>";
			if ($flb_arrivee ne "&nbsp;"){print "<input type=text name=arrivee$flb_rot value='$flb_arrivee' size=5>";}
			else {print "$flb_arrivee";}
			print "</td><td><input type=text name=datetr$flb_rot value='$datetr' size=10></td>";
			print "<td>$aerd_desi</td><td>$aero_type</td></tr>";
		}
		print "<tr><td><input type=text name=rotsup size=2></td>";
		print "<td><input type=text name=volsup size=6></td>";
		print "<td><input type=text name=tridepsup size=3></td>";
		print "<td><input type=text name=departsup size=5></td>";
		print "<td><input type=text name=triretsup size=3></td>";
		print "<td><input type=text name=arriveesup size=5></td>";
		print "<td><input type=text name=datesup size=10></td>";
		print "<td>Rotation supplémentaire</td></tr>";			
		print  "</table></td>";
		print  "</tr>\n";
	}
	print  "</table><br>";
	print "<input type=submit value=modifier>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Supprimer <Input type=checkbox name=sup>";
	print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Doubler<Input type=checkbox name=double>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Vol Annulé<Input type=checkbox name=annule><br><br>Ajouter <input type=text name=decalage value=7 size=2> jours copier <input type=checkbox name=copier> deplacer <input type=checkbox name=deplacer>";
	print "<input type=hidden name=action value=validmodif>";
	print "<input type=hidden name=date value='$date'>";
	print "<input type=hidden name=vol value='$vol'>";
	print "<input type=hidden name=nbjour value='$nbjour'>";
	print "<input type=hidden name=datejour value='$jour'>";
	print "<input type=hidden name=datemois value='$mois'>";
	print "<input type=hidden name=datean value='$an'>";
	print "</form>\n";
}

# FONCTION : nb_jour(jour,mois,annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : le jour mois annee (yyyy)
# SORTIE : le nombre de seconde

sub nb_jour{
	my ($jour)=$_[0];
	my ($mois)=$_[1];
	my ($annee)=$_[2];

	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}
sub nb_jour_an
{
	my ($annee)=$_[0];
	my ($n)=0;
	for (my($i)=1970; $i<$annee; $i++) {
		$n += 365; 
		if (&bissextile($i)){$n++;}
	}
	return($n);
}

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
}
# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/MM/DD
# SORTIE : la date formatée

sub julian_null {
	my ($val)=$_[0];
	if ($val <8) {return;}
	my ($option)=$_[1];
	$val=$val*60*60*24;
	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime($val);    
	$annee=substr($annee,1,2);
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);

	$option=lc($option);
	if (lc($option) eq "")
	{
		($option = "dd/mm/yyyy");
	}
	$option=~s/mm/$mois/;
	$option=~s/dd/$jour/;
	$option=~s/yyyy/20$annee/;
	$option=~s/yy/$annee/;
 	return($option);
}
# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine);
	if ($var <8){ # vol regulier
		%semaine=(1,"Lundi",2,"Mardi",3,"Mercredi",4,"Jeudi",5,"Vendredi",6,"Samedi",0,"Dimanche");
	}
	else {
		%semaine=(4,"Lundi",5,"Mardi",6,"Mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	}
	
	return $semaine{$var%7};
}
sub select_date
{
 	$date=`/bin/date +%d';'%m';'%Y`;
  	(@dates)=split(/;/, $date, 3); 
  	$select_jour[$dates[0]]="selected"; 
  	$select_mois[$dates[1]]="selected"; 
  	$firstyear=$dates[2];
  	print "<select name=datejour>"; 
 	for($i=1;$i<=31;$i++) {print "<option value=\"$i\" $select_jour[$i]>$i</option>\n";} 
 	print "</select>"; 
  	@cal=("","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  	print "<select name=datemois>";
 	for($i=1;$i<=12;$i++) { print "<option value=\"$i\" $select_mois[$i]>$cal[$i]</option>\n"; } 
  	print "</select> <select name=datean>"; 
	for($i=$firstyear-1;$i<=($firstyear+1);$i++) { 
	  print "<option value=$i ";
	  if ($i==$firstyear){print "selected";}
	  print ">$i</option> ";} 
 	print "</select>"; 
} 
sub cal_heure {
	my ($var)=@_[0];
	if ($var eq ""){return;}
	if ($var eq "&nbsp;"){return;}
	
	my ($dec)=@_[1];
	$var=$var+$dec;
	if ($var>24){$var-=24;}
	if ($var<0){$var+=24;}
	return(&deci($var));
}



;1
