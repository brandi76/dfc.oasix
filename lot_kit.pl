
$lot_nolot=$html->param("lot_nolot");
if (($action eq "sup")&&($html->param("lot_nolot") ne "")){
	&save("delete from lot where lot_nolot=$lot_nolot","aff");
	&save("delete from trolley where tr_code=$lot_nolot","aff");
}        		 

if (($action eq "modif")&&($html->param("lot_nolot") ne "")){
	$lot_desi=$html->param("lot_desi");
	$lot_conteneur=$html->param("lot_conteneur");
	$lot_nbcont=$html->param("lot_nbcont");
	$lot_nbplomb=$html->param("lot_nbplomb");
	$lot_poids=$html->param("lot_poids");
	$lot_flag=$html->param("lot_flag");
	$lot_cout=$html->param("lot_cout");

	$query="update lot set lot_desi='$lot_desi',lot_conteneur='$lot_conteneur',lot_nbplomb='$lot_nbplomb',lot_nbcont='$lot_nbcont',lot_poids='$lot_poids',lot_flag='$lot_flag',lot_cout='$lot_cout' where lot_nolot='$lot_nolot'";
	# $sth=$dbh->prepare($query);
	# $nb=$sth->execute;
	if ($dbh->do($query) ne "0E0"){
		print "<br><font color=red>$nb Lot $lot_nolot modifié<br></font>";
	}
	
	$query="select distinct tr_tiroir from trolley where tr_code='$lot_nolot' order by tr_tiroir";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($tr_tiroir)=$sth->fetchrow_array) {
		$desi=$html->param("desitiroir_$tr_tiroir");		
		&save("replace into tiroir values ('$lot_nolot','$tr_tiroir','$desi')","af");
	}
	

	$action="edite";
}

if (($html->param("newtype")ne"")&&($html->param("copie")ne"")){
	
	$lot_nolot=$html->param("newtype");
	$lot_copie=$html->param("copie");

	$verif=&get("select count(*) from lot where lot_nolot='$lot_nolot'","af")+0;
	if ($verif >0){ 	
		print "<b><font size=+3 color=red>lot existant</font></b><br>";
		}
	else {
		$query="select lot.* from lot where lot_nolot='$lot_copie'";
		$sth=$dbh->prepare($query);
		$sth->execute;
		($null,$lot_desi,$lot_conteneur,$lot_nbplomb,$lot_nbcont,$lot_poids,$lot_flag,$lot_cout)= $sth->fetchrow_array;
		&save ("insert into lot values ('$lot_nolot','$lot_desi','$lot_conteneur','$lot_nbplomb','$lot_nbcont','$lot_poids','$lot_flag','$lot_cout','créé avec lot_kit',curdate(),'')"); 
		$query="select * from trolley where tr_code='$lot_copie'";
		$sth=$dbh->prepare($query);
		$sth->execute;
		while (($null,$tr_ordre,$tr_cd_pr,$tr_qte,$tr_prix,$tr_tiroir)= $sth->fetchrow_array){
			&save ("insert into trolley values ('$lot_nolot','$tr_ordre','$tr_cd_pr','$tr_qte','$tr_prix','$tr_tiroir','')"); 
		}

	}
	$action="";
}

if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "<table border=1 cellspacing=0>";
	print "<tr><th>client</th><th>No lot</th><th>Designation</th><th>Conteneur</th><th>Nb de conteneur</th><th>Nb de plomb</th><th>Poids</th><th>Cout</th><th>Derniere utilisation</th><th><img src=/images/b_edit.png></th></tr>";
	
	$query="select lot.* from lot where lot_flag=1 or lot_flag=0 order by lot_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($lot_nolot,$lot_desi,$lot_conteneur,$lot_nbplomb,$lot_nbcont,$lot_poids,$lot_flag,$lot_cout)= $sth->fetchrow_array) {
		$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot and gsl_ind=3";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($nb3)=$sth2->fetchrow_array;
		$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($nb)=$sth2->fetchrow_array;
		$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot and gsl_ind=0";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($nb0)=$sth2->fetchrow_array;
		$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot and gsl_ind=10";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($nb10)=$sth2->fetchrow_array;
		print "<tr ";
		if ($lot_flag !=1) { print "bgcolor=#efefef";}
		print "><td>$cl_nom</td><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&lot_nolot=$lot_nolot>$lot_nolot</a></td><td>";
		if ($lot_flag==0){print "<font color=gray>";}
		print "$lot_desi</td><td>$lot_conteneur</td><td>$lot_nbcont</td><td>$lot_nbplomb</td><td>$lot_poids</td><td>$lot_cout</td>";
		$date=&get("select max(v_date_sql) from vol where v_troltype=$lot_nolot");
		print "<td>$date</date>";
		$check=&get("select datediff(curdate(),'$date')")+0;
		if ($check>60){&save("update lot set lot_flag=0 where lot_nolot='$lot_nolot'");}
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=edite&lot_nolot=$lot_nolot><img src=/images/b_edit.png></a></td></tr>";
	}
	print "<tr><td>Nouveau</td><td><input type=text size=3 name=newtype></td><td>copie du lot <input type=text size=3 name=copie></td></tr></table><br>";
 	print "<input class=bouton type=submit></form>";
	print "</body></html>";

}



if ($action eq "edite"){
	print "<form>";
	&form_hidden();
	print "<font size=+2>";
	$query="select lot.* from lot where lot_nolot='$lot_nolot'";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($lot_nolot,$lot_desi,$lot_conteneur,$lot_nbplomb,$lot_nbcont,$lot_poids,$lot_flag,$lot_cout)= $sth->fetchrow_array;
	$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot and gsl_ind=3";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	($nb3)=$sth2->fetchrow_array;
	$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	($nb)=$sth2->fetchrow_array;
	$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot and gsl_ind=0";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	($nb0)=$sth2->fetchrow_array;
	$query="select count(*) from geslot where floor(gsl_nolot/100)=$lot_nolot and gsl_ind=10";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	($nb10)=$sth2->fetchrow_array;
	print "Trolley type $lot_nolot <br>";
	print "<table border=0><tr ";
	print "><td class=gauche>Designation <input type=text size=80 name=lot_desi value=\"$lot_desi\"><br>";
	print "Conteneur <input type=text size=20 name=lot_conteneur value=\"$lot_conteneur\"><br>";
	print "Nombre de plomb <input type=text size=3 name=lot_nbplomb value=$lot_nbplomb><br>";
	print "Nombre de conteneur <input type=text size=3 name=lot_nbcont value=$lot_nbcont><br>";
	print "Poids <input type=text size=3 name=lot_poids value=$lot_poids><bR>";
	print "Flag (1 actif 0 inactif 2 inutile) <input type=text size=3 name=lot_flag value=$lot_flag><br>";
	print "Cout de traitement <input type=text size=3 name=lot_cout value=$lot_cout></td>";
	print "</tr></table><br><br>";
	print "<input type=hidden name=$lot_nolot value=on>";	
	# designation par tiroir
	$query="select distinct tr_tiroir from trolley where tr_code='$lot_nolot' order by tr_tiroir";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table border=1>";
	print "<tr><tr><th>tiroir</th><th>Désignation</th></tr>";
	
	while (($tr_tiroir)=$sth->fetchrow_array) {
		print "<tr><td>$tr_tiroir</td>";
		$desi=&get("select ti_desi from tiroir where ti_code='$lot_nolot' and ti_tiroir='$tr_tiroir'");
		print "<td><input type=text name=desitiroir_".$tr_tiroir." value='$desi'></td></tr>";	
	}
	print "</table><br>";	
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "<input class=bouton type=submit name=action value=modif>";

	print "</form><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet>retour</a>";
	print "</body></html>";
}

if ($action eq "saiplomb"){
	$gsl_nolot=$html->param("gsl_nolot");
	$pb1=$html->param("pb1")+0;
	$pb2=$html->param("pb2")+0;
	$pb3=$html->param("pb3")+0;
	$pb4=$html->param("pb4")+0;
	$pb5=$html->param("pb5")+0;
	$pb6=$html->param("pb6")+0;
	$pb7=$html->param("pb7")+0;
	if (($pb1>0)&&($gsl_nolot>0)){
		$query="update geslot set gsl_pb1=$pb1,gsl_pb2=$pb2,gsl_pb3=$pb3,gsl_pb4=$pb4,gsl_pb5=$pb5,gsl_pb6=$pb6,gsl_pb7=$pb7 where gsl_nolot=$gsl_nolot";
		$sth=$dbh->prepare($query);
		if ($sth->execute){print "<br><font color=red>Plombs du lot $gsl_nolot modifiés</font><br>";}
	}
	$lot_nolot=int($gsl_nolot/100);
	$action="detail";
}	

if ($action eq "nouveau"){
	$query="select * from geslot where gsl_nolot>$lot_nolot*100 and gsl_nolot<($lot_nolot*100)+99 order by gsl_nolot desc limit 1";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_poids)=$sth->fetchrow_array;
	$gsl_nolot++;
	$gsl_pb1=$gsl_pb2=$gsl_pb3=$gsl_pb4=$gsl_pb5=$gsl_pb6=$gsl_pb7=0;
	$gsl_ind=0;
	$gsl_apcode="";
	$gsl_novol="";
	$query="replace into geslot values('$gsl_nolot','$gsl_ind','$gsl_dtret','$gsl_novol','$gsl_dtvol','$gsl_troltype','$gsl_pb1','$gsl_pb2','$gsl_pb3','$gsl_pb4','$gsl_pb5','$gsl_pb6','$gsl_pb7','$gsl_hrret','$gsl_triret','$gsl_apcode','$gsl_nb_cont','$gsl_desi','$gsl_trajet','$gsl_alc','$gsl_tab','$gsl_nodep','$gsl_noret','$gsl_nbpb','$gsl_poids')";
	&execute();
	$action="detail";
}	

if ($action eq "modiflot"){
	$query="select gsl_nolot from geslot where floor(gsl_nolot/100)=$lot_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$gsl_nolot="null";
	while ($geslot = $sth->fetchrow_array) {
		if ($html->param("$geslot") eq "on"){
			$gsl_nolot=$geslot;
			last;
		}
	}
	if ($gsl_nolot eq "null"){ 
		$action="detail";
	}
	else{	
		$query="select * from geslot where gsl_nolot=$gsl_nolot";
		$sth=$dbh->prepare($query);
		$sth->execute;
		($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_poids)=$sth->fetchrow_array;
		print "<br><b>$gsl_nolot</b><br>";
		print "<form><font size=+2>";
		&form_hidden();
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$val="gsl_pb"+$i;
			print "plomb$i <input type=text name=pb$i value=${$val}><br>";
		}
		print "<input type=hidden name=gsl_nolot value=$gsl_nolot>";
		print "<input type=hidden name=action value=saiplomb>";
		print "<br><br><input type=submit class=bouton value=validation></form>";
		print "</body></html>";
	}
}
if ($action eq "sup"){
	$gsl_nolot=$html->param("gsl_nolot");
	$query="delete from geslot where gsl_nolot='$gsl_nolot'";
	&execute($query);
	print "<br><font color=red>lot $gsl_nolot supprimé</br>";
	$action="detail";
	$lot_nolot=int($gsl_nolot/100);

}

if ($action eq "detail"){
	print "<form><font size=+2>";
	&form_hidden();
	$query="select * from geslot where floor(gsl_nolot/100)=$lot_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table border=1 cellspacing=0><tr><th>No de lot</th><th>Index</th><th>no de vol</th><th>Plomb1</th><th>Plomb2</th><th>Plomb3</th><th>Plomb4</th><th>Plomb5</th><th>Plomb6</th><th>Plomb7</th><th>Appro</th></tr>";
	while ($geslot = $sth->fetchrow_hashref) {
		 print "<tr><td>$geslot->{gsl_nolot}</td><td>$geslot->{gsl_ind}</td><td>$geslot->{gsl_novol}</td><td>$geslot->{gsl_pb1}</td><td>$geslot->{gsl_pb2}</td><td>$geslot->{gsl_pb3}</td><td>$geslot->{gsl_pb4}</td><td>$geslot->{gsl_pb5}</td><td>$geslot->{gsl_pb6}</td><td>$geslot->{gsl_pb7}</td><td>$geslot->{gsl_apcode}</td><td><input type=checkbox name=$geslot->{gsl_nolot}></td>";
		 if ($geslot->{gsl_ind}==0 || $geslot->{gsl_ind}==6 || $geslot->{gsl_ind}==99 ){
		 	print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&gsl_nolot=$geslot->{gsl_nolot}>sup</a></td>";
		}
	}
	print "</tr><tr><td colspan=12><a href=onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=nouveau&lot_nolot=$lot_nolot>Nouveau</a></td></tr></table>";
	print "<input type=hidden name=lot_nolot value=$lot_nolot><br><br>";
	print "<input type=hidden name=action value=modiflot>";
	print "<input type=submit class=bouton value=\"modification du lot selectionné\">";
	print "</form><br>";
	print "</body></html>";
}

if ($action eq "sup_prod"){
	$produit=$html->param("produit");
	$check=&get("select count(*) from sortie,vol where so_cd_pr='$produit' and so_appro=v_code and v_rot=1 and v_troltype='$lot_nolot'","af")+0;
	if ($check==0){
	  $query="delete from trolley where tr_cd_pr='$produit' and tr_code='$lot_nolot'";
	  $sth=$dbh->prepare($query);
	  $sth->execute;
	  print "<br><font color=red>Ligne supprimée</font><br>";
	}
	else {print "<br><font color=red>Impossible Produit referencé dans un vol non rentré</font>";}
	$action="visu";
}
if ($action eq "modif_prod"){
	$produit=$html->param("produit");
	$position=$html->param("position");
	$qte=$html->param("qte")*100;
	$tiroir=$html->param("tiroir");
	$prix=$html->param("prix")*100;
	$check=&get("select count(*) from trolley where tr_cd_pr!='$produit' and tr_code='$lot_nolot' and tr_ordre='$position'")+0;
	if ($check==0){
	  &save("update trolley set tr_ordre='$position',tr_prix='$prix',tr_qte='$qte',tr_tiroir='$tiroir' where tr_cd_pr='$produit' and tr_code='$lot_nolot'");
	}
	else {print "<br><font color=red>Impossible Position déjà prise</font>";}
	$action="visu";
}

if ($action eq "ajout_prod"){
	$produit=$html->param("produit");
	$position=$html->param("position");
	$qte=$html->param("qte")*100;
	$tiroir=$html->param("tiroir");
	$prix=$html->param("prix")*100;
	$check=&get("select count(*) from trolley where tr_code='$lot_nolot' and tr_ordre='$position'")+0;
	if ($check==0){
	  $check=&get("select count(*) from trolley where tr_code='$lot_nolot' and tr_cd_pr='$produit'")+0;
	  if ($check==0){
	    &save("insert into trolley values ('$lot_nolot','$position','$produit','$qte','$prix','$tiroir','')","af");
	    print "<br>produit ajouté<br>";
	  }
	  else {print "<br><font color=red>Impossible Produit déjà existant</font>";}
	  
	}
	else {print "<br><font color=red>Impossible Position déjà prise</font>";}
	$action="visu";
}

if ($action eq "visumodif"){
	$produit=$html->param("produit");
	$query="select tr_ordre,pr_cd_pr,pr_desi,tr_qte,tr_prix,tr_tiroir from trolley,produit where tr_cd_pr='$produit' and tr_code='$lot_nolot' and tr_cd_pr=pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($position,$pr_cd_pr,$pr_desi,$tr_qte,$tr_prix,$tr_tiroir)=$sth->fetchrow_array;
	$tr_qte=int($tr_qte/100);
	$tr_prix=int($tr_prix/100);
	print "$pr_cd_pr $pr_desi<br>";
	print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
 	&form_hidden();
	print "<div style=float:left;width:150px;>Position</div> <input type=text name=position value=\"$position\"><br />";
	print "<div style=float:left;width:150px;>Qte</div> <input type=text name=qte value=\"$tr_qte\"><br />";
	print "<div style=float:left;width:150px;>Prix</div> <input type=text name=prix value=\"$tr_prix\"><br />";
	print "<div style=float:left;width:150px;>Tiroir</div> <input type=text name=tiroir value='$tr_tiroir'><br />";
	print "<br><input type=hidden name=action value=modif_prod>";
	print "<br><input type=submit value=modif class=bouton>";
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "<input type=hidden name=produit value=$produit>";
	print "</form>";
	print "<br /><form >";
 	&form_hidden();
	print "<input type=hidden name=action value=sup_prod><input type=submit value=supprimer style=background-color:pink; onclick=\"return confirm('Etes vous sur de vouloir supprimer?')\">";
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "<input type=hidden name=produit value=$produit>";
	print "</form>";
}
if ($action eq "visuajout"){
	print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
 	&form_hidden();
	print "<div style=float:left;width:150px;>Code produit</div> <input type=text name=produit ><br />";
	print "<div style=float:left;width:150px;>Position</div> <input type=text name=position ><br />";
	print "<div style=float:left;width:150px;>Qte</div> <input type=text name=qte ><br />";
	print "<div style=float:left;width:150px;>Prix</div> <input type=text name=prix ><br />";
	print "<div style=float:left;width:150px;>Tiroir</div> <input type=text name=tiroir value=0><br />";
	print "<br><input type=hidden name=action value=ajout_prod>";
	print "<br><input type=submit value=modif class=bouton>";
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "</form>";
}


if ($action eq "#visumodif"){
	$query="select pr_cd_pr,pr_desi,tr_qte,tr_prix,tr_tiroir from trolley,produit where tr_cd_pr=pr_cd_pr and tr_code='$lot_nolot'";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	while (($pr_cd_pr,$pr_desi,$tr_qte,$tr_prix,$tr_tiroir)=$sth2->fetchrow_array) {
		$produit=$html->param("$pr_cd_pr");
		$qte=$html->param("qte$pr_cd_pr")*100;
		$prix=$html->param("prix$pr_cd_pr")*100;
		$tiroir=$html->param("tir$pr_cd_pr");

		if ($qte!=$tr_qte){
			$query="update trolley set tr_qte=$qte where tr_cd_pr='$pr_cd_pr' and tr_code='$lot_nolot'";

&save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
			$sth=$dbh->prepare($query);
			$sth->execute;
			print "<br><font color=red>$pr_desi quantité modifiée</font><br>";
		}
		if ($prix!=$tr_prix){
			$query="update trolley set tr_prix=$prix where tr_cd_pr='$pr_cd_pr' and tr_code='$lot_nolot'";
&save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
			$sth=$dbh->prepare($query);
			$sth->execute;
			print "<br><font color=red>$pr_desi prix modifié</font><br>";
		}
		if ($tiroir!=$tr_tiroir){
			$query="update trolley set tr_tiroir=$tiroir where tr_cd_pr='$pr_cd_pr' and tr_code='$lot_nolot'";
			$sth=$dbh->prepare($query);
			$sth->execute;
			print "<br><font color=red>$pr_desi tiroir modifié</font><br>";
		}
			
	}
	$produit=$html->param("produit");
	$qte=$html->param("qte")*100;
	$tiroir=$html->param("tiroir");

	# insertion d'un produit
	if (($produit ne "")&&($qte>0)){
		$ord_ordre=&get("select tr_ordre from trolley where tr_cd_pr='$produit' and tr_code='$lot_nolot'");
		if ($ord_ordre eq ""){
			$ord_ordre=&get("select max(tr_ordre) from trolley where tr_code='$lot_nolot'")+1;
		}
		$ord_prix=0;
		$query="replace into trolley values('$lot_nolot','$ord_ordre','$produit','$qte','$ord_prix','$tr_tiroir','')";
		print "$query<br>";  #ici
		$sth=$dbh->prepare($query);
		$sth->execute;
		print "<br><font color=red>Produit ajouté</font></br>";
	}
	$action="visu";
}

if ($action eq "visu"){
	print "<div style=background:greenyellow;padding:20px>Les modifications d'un trolley pour un départ doit se faire dans onglet->depart->preparation->modification du trolley type</div>";
	print "<center><h2>$lot_nolot</h2>";
	$query="select tr_ordre,pr_cd_pr,pr_desi,tr_qte/100,tr_prix/100,pr_pdn,tr_tiroir from trolley,produit where tr_cd_pr=pr_cd_pr and tr_code='$lot_nolot' order by tr_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table border=1 cellspacing=0><tr><th>Position</th><th>Code produit</th><th>qte</th><th>Prix</th><th>Tiroir</th><th >Action</th></tr>";
	while (($ordre,$pr_cd_pr,$pr_desi,$tr_qte,$tr_prix,$pr_poids,$tr_tiroir)=$sth->fetchrow_array) {
		 $tr_qte=int($tr_qte);
		 $tr_prix=int($tr_prix);
		 print "<tr><td>$ordre</td><td>$pr_cd_pr $pr_desi</td><td align=right>$tr_qte</td><td align=right>$tr_prix</td><td align=right>$tr_tiroir</td>";
# 		 print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visusup&lot_nolot=$lot_nolot&produit=$pr_cd_pr><img src=/images/b_drop.png></a></td>";
		 print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visumodif&lot_nolot=$lot_nolot&produit=$pr_cd_pr><img src=/images/b_edit.png></a></td>";
		 print "</tr>";
		 $val+=$tr_prix*$tr_qte;
	}
# 	print "<tr><td><input type=text name=produit size=6></td><td><input type=text name=qte size=4></td><td><input type=text name=prix size=4></td><td><input type=text name=tiroir size=4></td></tr>";
	print "</table>";
	print "Valeur :$val<br>";
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "<input type=hidden name=action value=visuajout>";
# 	print "<br></font>Parfums femmes:";
# 	print &get("select sum(tr_qte/100) from trolley where tr_code=$lot_nolot and tr_ordre <180");
# 	print "<br>Parfums hommes:";
# 	print &get("select sum(tr_qte/100) from trolley where tr_code=$lot_nolot and tr_ordre >=180 and tr_ordre<1000");
# 	print "<br>Cosmetiques:";
# 	print &get("select sum(tr_qte/100) from trolley,produit where tr_code=$lot_nolot and tr_ordre >=180 and tr_ordre>1000 and tr_cd_pr=pr_cd_pr and pr_type=5");
#   	print "<br>";      
        print "<div style=text-align:left>";
        $query="select sum(tr_qte/100),sum(tr_qte*pr_pdn)/100,tr_tiroir from trolley,produit where tr_code=$lot_nolot and tr_cd_pr=pr_cd_pr group by tr_tiroir order by tr_tiroir";
        $sth=$dbh->prepare($query);
	$sth->execute;
	while (($qte,$poids,$tiroir)=$sth->fetchrow_array) {
		$qte=int($qte);
		 print "tiroir:$tiroir qte:$qte <bR>";
	}
	print "</div>";
	print "<form>";
	&form_hidden();
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "<input type=hidden name=action value=visuajout>";
	print "<input type=submit value=Ajout>";
	print "</form><br><br>";
	print "<form>";
	&form_hidden();
	print "Magazine <select name=mag>";
	$query="select distinct mag from mag";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($mag)=$sth->fetchrow_array) {
	    print "<option value=$mag>$mag</option>";
	}
	print "</select><br>";
	print "Eur <input type=radio name=devise value=eur checked> $base_dev1 <input type=radio name=devise value=xof> <bR>";
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "<input type=hidden name=action value=verifprix>";
	print "<input type=submit value='Verifier les prix'>";
	print "</form>";
}

if ($action eq "verifprix"){
	$pass=0;
	$mag=$html->param("mag");
	$devise=$html->param("devise");
	$query="select tr_cd_pr,tr_prix/100 from trolley where tr_code=$lot_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($tr_cd_pr,$tr_prix)=$sth->fetchrow_array) {
	    $prix_mag=&get("select prix from mag where mag='$mag' and code='$tr_cd_pr'")+0;
	    if ($devise ne "eur"){$prix_mag=&get("select prix_xof from mag where mag='$mag' and code='$tr_cd_pr'")+0;}
	    if ($prix_mag ==0){next;}
	    if ($prix_mag!=$tr_prix){
	      $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$tr_cd_pr'");
	      print "$tr_cd_pr $pr_desi prix mag:$prix_mag prix trolley:$tr_prix<br>";
	      $pass=1;
	    }
	}    
	if ($pass==0){
	print "<p style=background:lavender>Tous les prix sont conformes avec le magazine:$mag>";
	}
	print "<br><br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&lot_nolot=$lot_nolot>Retour</a>";
}	    

sub execute {
        # print "$query<br>";
	$dbh->do("insert into query values ('',QUOTE(\"$query\"),'$0','$ENV{'REMOTE_ADDR'}',now())");
	my($sth2)=$dbh->prepare($query);
	return($sth2->execute());
}
;1