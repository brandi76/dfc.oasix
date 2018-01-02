#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";

print $html->header;

$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$nbjour=$html->param('nbjour');
$action=$html->param('action');
$vol=$html->param('vol');
$date=$html->param('date');
if ($html->param('decal') eq "on"){$decal=-7;};
$today=&nb_jour($jour,$mois,$an)+$decal;
$decalheure=1; # heure hivers
if (($today>=12869)&&($today<=13086)){$decalheure=2;}
if (($today>=13233)&&($today<=13450)){$decalheure=1;}


$datedujour=&nb_jour(`/bin/date '+%d'`+0,`/bin/date '+%m'`+0,"20".`/bin/date '+%y'`+0);

if ($today==-1){$today=$html->param('today');}
require "./src/connect.src";

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
			$flybody[0]+=$decalage;
			$flybody[3]+=$decalage;
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
			$flybody[0]+=$decalage;
			$flybody[3]+=$decalage;
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
		$query="delete from flyhead where fl_vol='$vol' and fl_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		$query="delete from flybody where flb_vol='$vol' and flb_date=$date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		print "<font color=red>vol deplacé</font></br>";
		$date=$date+$decalage;
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
			$query="update flybody set flb_voltr='$volhead' where flb_vol='$volhead' and flb_date=$date and flb_rot=11";  
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
	&tetehtml();
	print "<br><br><form>";
	&select_date();
	print "  semaine dernière <input type=checkbox name=decal>";
	print "<br><br>nombre de jour:";
	print "<select name=nbjour>"; 
 	for($i=1;$i<=7;$i++) {print "<option value=\"$i\">$i</option>\n";} 
 	print "</select>"; 
  	print "<input type=hidden name=action value=affiche>";
	print "<br><br><input type=submit class=bouton></form>	";
        print "<br><br><br></div><a href=http://ibs.oasix.fr/cgi-bin/aeroport.pl>Aeroport</a></body>";
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
	&tetehtml();
	print  "<center><h2></div><a href=http://ibs.oasix.fr/cgi-bin/planningfly.pl>Date</a><div class=ombre> </h1>";
	for ($i=0;$i<$nbjour;$i++){
		&table($today+$i);
	}
	print  "</body>";
}
if ($action eq "modif")
{
	&tetehtml();
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	&vol($date);
	print "</div><a href=planningfly.pl?action=affiche&nbjour=$nbjour&datejour=$jour&datemois=$mois&datean=$an>retour</a>";
	print  "</body>";
}


sub table{
	my $today=$_[0];
	print  "<h1>";
	print  &jour($today);
	print  " ";
	print  &julian($today,"");
	print  "</h1></div>\n";
	print  "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=yellow><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Tronçon</th><th>Validation</th></tr>";
	$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_apcode from flyhead where fl_date=$today";
	# print "<font color=red>$query</font>";
	$sth=$dbh->prepare($query);
	$sth->execute();

	while (($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_apcode)=$sth->fetchrow_array){
		$query="select flb_tridep,flb_triret,flb_depart,flb_arrivee,flb_rot,flb_voltr,flb_datetr from flybody where flb_vol='$fl_vol' and flb_date=$fl_date order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		print  "<tr><td><div class=ombre><b>";
		($cl_nom)=split(/;/,$client_dat{$fl_cd_cl});
		print  $cl_nom;
		print  "</td>";
		$query="select lot_conteneur from lot where lot_nolot=$fl_troltype";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($lot_conteneur)=$sth3->fetchrow_array;
		print  "<td align=center><div class=ombre>$fl_vol</td><td align=center><div class=ombre>$fl_troltype<br><nobr>$lot_conteneur</td><td><div class=ombre><table border=0 cellspacing=0 width=100%>";
		print "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td><font size=-1>Charg LT</td><td><font size=-1>depart LT</td><td><font size=-1>depart UT</td>";
		print "<td>&nbsp;</td><td><font size=-1>Arr LT</td><td><font size=-1>Arr UT</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
		
		
		while (($flb_tridep,$flb_triret,$flb_depart,$flb_arrivee,$flb_rot,$flb_voltr,$flb_datetr)=$sth2->fetchrow_array){
			$query="select aero_type,aerd_desi from aeroport,aerodesi where aero_tri=aerd_trig and aero_tri='$flb_triret' and aero_tri!='CDG' and aero_tri!='ORY'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($aero_type,$aerd_desi)=$sth3->fetchrow_array;
			if ($flb_depart==0){$flb_depart="&nbsp;";}
			else {$flb_depart=&deci2($flb_depart/100);}
			if ($flb_arrivee==0){$flb_arrivee="&nbsp;";}
			else {$flb_arrivee=&deci2($flb_arrivee/100);}
			$datetr=&julian($flb_datetr);
			
			if (($flb_rot==11)&&($flb_datetr!=$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			if (($flb_rot!=11)&&($flb_datetr<$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			
			print "<tr><td>$flb_rot</td><td>$flb_voltr</td><td>$flb_tridep</td><td align=right><b>";
			print $flb_depart;
			print "<td align=right>".&cal_heure($flb_depart,+1)."</td>";
			print "<td align=right><font color=lightgreen>".&cal_heure($flb_depart,1-$decalheure)."</td>";
			print "</td><td align=right>$flb_triret</td><td align=right><b>$flb_arrivee</td>";
			print "<td align=right><font color=lightgreen>".&cal_heure($flb_arrivee,0-$decalheure)."</td>";
			print "<td>$datetr</td><td>$aerd_desi</td><td>$aero_type</td></tr>";
		}
	
		print  "</table>\n</td><td>$fl_apcode <input type=button class=bouton value=modif onclick=\"";
		if ($fl_apcode != 0){
			print "verif(\'Attention Vol affecté au bon d appro $fl_apcode , Continuer malgré tout ?\',";
			print "\'?action=modif&vol=$fl_vol&date=$fl_date&nbjour=$nbjour&datejour=$jour&datemois=$mois&datean=$an\')\"></td>";
		
		}
		else
		{
			print "document.location.href=";
			print "\'?action=modif&vol=$fl_vol&date=$fl_date&nbjour=$nbjour&datejour=$jour&datemois=$mois&datean=$an\'\"></td>";
		
		}
		print  "</tr>\n";
	}
	($datejour,$datemois,$datean)=split(/\//,&julian($today,""));
	print "<tr><td><input type=button class=bouton value=nouveau onclick=\"";
	if ($datedujour>=$today){
		print "verif(\'Attention Date anterieur à aujourd hui continuer malgré tout\ ?\',";
		print "\'http://ibs.oasix.fr/saivol.php?datejour=$datejour&datemois=$datemois&datean=$datean&nbjour=$nbjour\')\"></td></tr>";
	}
	else{
		print "document.location.href=";
		print "\'http://ibs.oasix.fr/saivol.php?datejour=$datejour&datemois=$datemois&datean=$datean&nbjour=$nbjour\'\"></td></tr>";
	}
	
	print  "</table>\n";
}

sub vol{
	my $today=$_[0];
	print  "<h1>";
	print  &jour($today);
	print  " ";
	print  &julian($today,"");
	print  "</h1>\n";
	print  "<form><table border=1 cellspacing=0 cellpadding=0><tr bgcolor=yellow><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Tronçon</th></tr>";
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
		print  "<td align=center><input type=text name=volhead value=$fl_vol size=8></td><td align=center><input type=text name=troltype value=$fl_troltype size=4></td><td><table border=0 cellspacing=0 width=100%>";
		
		while (($flb_tridep,$flb_triret,$flb_depart,$flb_arrivee,$flb_rot,$flb_voltr,$flb_datetr)=$sth2->fetchrow_array){
			$query="select aero_type,aerd_desi from aeroport,aerodesi where aero_tri=aerd_trig and aero_tri='$flb_triret' and aero_tri!='CDG' and aero_tri!='ORY'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($aero_type,$aerd_desi)=$sth3->fetchrow_array;
			if ($flb_depart==0){$flb_depart="&nbsp;";}
			else {$flb_depart=&deci2($flb_depart/100);}
			if ($flb_arrivee==0){$flb_arrivee="&nbsp;";}
			else {$flb_arrivee=&deci2($flb_arrivee/100);}
			$datetr=&julian($flb_datetr);
			
			# if (($flb_rot==11)&&($flb_datetr!=$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			# if (($flb_rot!=11)&&($flb_datetr<$fl_date)){$datetr="<font color=red><b>".$datetr."</b></font>";}
			
			print "<tr><td>$flb_rot</td><td>$flb_voltr</td>";
			print "<td><input type=text name=tridep$flb_rot value=$flb_tridep size=3></td><td align=right>";
			if ($flb_depart ne "&nbsp;"){print "<input type=text name=depart$flb_rot value=$flb_depart size=5>";}
			else {print "$flb_depart";}
			print "</td><td><input type=text name=triret$flb_rot size=3 value=$flb_triret></td><td>";
			if ($flb_arrivee ne "&nbsp;"){print "<input type=text name=arrivee$flb_rot value=$flb_arrivee size=5>";}
			else {print "$flb_arrivee";}
			print "</td><td><input type=text name=datetr$flb_rot value=$datetr size=10></td>";
			print "<td>$aerd_desi</td><td>$aero_type</td></tr>";
		}
		print "<tr><td><input type=text name=rotsup size=2></td><td><input type=text name=volsup size=6></td><td><input type=text name=tridepsup size=3></td><td><input type=text name=departsup size=5></td><td><input type=text name=triretsup size=3></td><td><input type=text name=arriveesup size=5></td><td><input type=text name=datesup size=10></td><td>Rotation supplémentaire</td></tr>";			
		print  "</table></td>";
		print  "</tr>\n";
	}
	print  "</table><br>";
	print "<input type=submit class=bouton value=modifier>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Supprimer <Input type=checkbox name=sup>";
	print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Doubler<Input type=checkbox name=double><br><br>Ajouter <input type=text name=decalage value=7 size=2> jours copier <input type=checkbox name=copier> deplacer <input type=checkbox name=deplacer>";
	print "<input type=hidden name=action value=validmodif>";
	print "<input type=hidden name=date value=$date>";
	print "<input type=hidden name=vol value=$vol>";
	print "<input type=hidden name=nbjour value=$nbjour>";
	print "<input type=hidden name=datejour value=$jour>";
	print "<input type=hidden name=datemois value=$mois>";
	print "<input type=hidden name=datean value=$an>";
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

sub julian {
	my ($val)=$_[0];
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
# FONCTION : deci2(variable)
# DESCRIPTION : retourne un chiffre avec2 chiffres apres la virgule 
# ENTREE : le nom de la variable 
# SORTIE : 
sub deci2 {
	my ($var)=@_[0];
	my ($chaine,$deci,$ent,$dec);
	# ${$var}=${$var}/100 ;
	${$var} = "".${$var};
	($ent,$dec) = split(/\./,${$var});
	$deci = ("0.".$dec)+0;
	$deci = int($deci*100);
	
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	${$var}=int(${$var});
	${$var}=${$var}.".".$deci;
}
# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine)=(4,"Lundi",5,"Mardi",6,"Mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	return "$semaine{$var%7}";
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
	for($i=$firstyear;$i<=($firstyear+1);$i++) { print "<option value=$i>$i</option> ";} 
 	print "</select>"; 
} 
# FONCTION : deci2(nombre)
# DESCRIPTION : retourne un chiffre avec2 chiffres apres la virgule 
# ENTREE : Un nombre 
# SORTIE : Un chaine
sub deci2 {
	my ($var)=@_[0];
	my ($chaine,$deci);
	$var = "".$var;
	($ENT,$DEC) = split(/\./,$var);
	#$deci = $var-int($var);
	$deci = ("0.".$DEC)+0;
	$deci = int($deci*100);
	
	#$deci=int(($var-int($var))*100);
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	$var=int($var);
	$chaine=$var.".".$deci;
	return($chaine);
}
sub cal_heure {
	my ($var)=@_[0];
	if ($var eq ""){return;}
	if ($var eq "&nbsp;"){return;}
	
	my ($dec)=@_[1];
	$var=$var+$dec;
	if ($var>24){$var-=24;}
	if ($var<0){$var+=24;}
	return(&deci2($var));
}

sub tetehtml{
	print "<html><head><style type=\"text/css\">
	body {color=white;}
	td {font-weight:bold;text-align:center;font-size:larger;}
	th {font-weight:bold;text-align:center;color=black;}
	.gauche {
		td {font-weight:bold;text-align:left;}
	}
	
	<!--
	.ombre {
	filter:shadow(color=black, direction=120 , strength=2);
	width:80%;}
	.ombre2 {
	filter:shadow(color=white, direction=120 , strength=3);
	width:80%;}
		
	.bouton {border-width=3pt;color:black;background-color:white;font-weight:bold;}
	-->
	</style></head>";
	print "<script>
	function verif(message,lien){
		if (confirm(message)){document.location.href=lien;}
	}
	</script>";
	print "<body background=../fond2.jpg link=white alink=white vlink=white><center><div class=ombre><font size=+5>Gestion du Planning</font>";
}

# -E verification du planning