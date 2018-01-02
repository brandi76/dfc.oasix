#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
print "<title>lot</title>";
require "./src/connect.src";
$action=$html->param("action");
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
		&save ("insert into lot values ('$lot_nolot','$lot_desi','$lot_conteneur','$lot_nbplomb','$lot_nbcont','$lot_poids','$lot_flag','$lot_cout')"); 
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
	print "<form><table border=1 cellspacing=0>";
	print "<tr><th>client</th><th>No lot</th><th>Designation</th><th>Conteneur</th><th>Nb de conteneur</th><th>Nb de plomb</th><th>Poids</th></tr>";
	
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
		print "><td>$cl_nom</td><td><a href=?action=visu&lot_nolot=$lot_nolot>$lot_nolot</a></td><td>";
		if ($lot_flag==0){print "<font color=gray>";}
		print "$lot_desi</td><td>$lot_conteneur</td><td>$lot_nbcont</td><td>$lot_nbplomb</td><td>$lot_poids</td><td><input type=checkbox name=$lot_nolot></td></tr>";
	}
	print "<tr><td>Nouveau</td><td><input type=text size=3 name=newtype></td><td>copie du lot <input type=text size=3 name=copie></td></tr></table><br>";
	print "<input class=bouton type=submit name=action value=edite></form>";
	print "</body></html>";

}



if ($action eq "edite"){
	print "<form><font size=+2>";
	$query="select lot.* from lot order by lot_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($lot_nolot,$lot_desi,$lot_conteneur,$lot_nbplomb,$lot_nbcont,$lot_poids,$lot_flag,$lot_cout)= $sth->fetchrow_array) {
		if ($html->param("$lot_nolot") eq "on"){
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
			last;
		}
	}
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

	print "</form><br><a href=lot.pl>retour</a>";
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
	$query="select * from geslot where floor(gsl_nolot/100)=$lot_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table border=1 cellspacing=0><tr><th>No de lot</th><th>Index</th><th>no de vol</th><th>Plomb1</th><th>Plomb2</th><th>Plomb3</th><th>Plomb4</th><th>Plomb5</th><th>Plomb6</th><th>Plomb7</th><th>Appro</th></tr>";
	while ($geslot = $sth->fetchrow_hashref) {
		 print "<tr><td>$geslot->{gsl_nolot}</td><td>$geslot->{gsl_ind}</td><td>$geslot->{gsl_novol}</td><td>$geslot->{gsl_pb1}</td><td>$geslot->{gsl_pb2}</td><td>$geslot->{gsl_pb3}</td><td>$geslot->{gsl_pb4}</td><td>$geslot->{gsl_pb5}</td><td>$geslot->{gsl_pb6}</td><td>$geslot->{gsl_pb7}</td><td>$geslot->{gsl_apcode}</td><td><input type=checkbox name=$geslot->{gsl_nolot}></td>";
		 if ($geslot->{gsl_ind}==0 || $geslot->{gsl_ind}==6 || $geslot->{gsl_ind}==99 ){
		 	print "<td><a href=http://ibs.oasix.fr/cgi-bin/lot.pl?action=sup&gsl_nolot=$geslot->{gsl_nolot}>sup</a></td>";
		}
	}
	print "</tr><tr><td colspan=12><a href=http://ibs.oasix.fr/cgi-bin/lot.pl?action=nouveau&lot_nolot=$lot_nolot>Nouveau</a></td></tr></table>";
	print "<input type=hidden name=lot_nolot value=$lot_nolot><br><br>";
	print "<input type=hidden name=action value=modiflot>";
	print "<input type=submit class=bouton value=\"modification du lot selectionné\">";
	print "</form><br><a href=http://ibs.oasix.fr/cgi-bin/lot.pl>retour</a>";
	print "</body></html>";
}

if ($action eq "visusup"){
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
if ($action eq "visumodif"){
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

	if (($produit ne "")&&($qte>0)){
		$query="select ord_ordre,ord_prix1 from ordre where ord_cd_pr='$produit'";
		$sth=$dbh->prepare($query);
		$sth->execute;
		($ord_ordre,$ord_prix)=$sth->fetchrow_array;
		if ($ord_ordre eq ""){print "<br><font color=red>Produit inconnu du fichier ordre </font></br>";}
		else{
			$query="replace into trolley values('$lot_nolot','$ord_ordre','$produit','$qte','$ord_prix','$tr_tiroir','')";
			print "$query<br>";  #ici
			$sth=$dbh->prepare($query);
			$sth->execute;
			print "<br><font color=red>Produit ajouté</font></br>";
		}
	}
	$action="visu";
}

if ($action eq "visu"){
	print "<center><h2>$lot_nolot</h2><br><form method=POST><a href=http://ibs.oasix.fr/cgi-bin/lot.pl>retour</a><font size=+2>";
	$query="select pr_cd_pr,pr_desi,tr_qte/100,tr_prix/100,pr_pdn,tr_tiroir from trolley,produit where tr_cd_pr=pr_cd_pr and tr_code='$lot_nolot' order by tr_ordre";
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>qte</th><th>Prix</th><th>Tiroir</th></tr>";
	while (($pr_cd_pr,$pr_desi,$tr_qte,$tr_prix,$pr_poids,$tr_tiroir)=$sth->fetchrow_array) {
		 print "<tr><td>$pr_cd_pr $pr_desi <font size=-1>($pr_poids)</font></td><td><input type=text name=qte$pr_cd_pr value=$tr_qte size=4></td><td><input type=text name=prix$pr_cd_pr value=$tr_prix size=4></td><td><input type=text name=tir$pr_cd_pr value=$tr_tiroir size=4></td><td><a href=?action=visusup&lot_nolot=$lot_nolot&produit=$pr_cd_pr>Sup</a></tr>";
	}
	print "<tr><td><input type=text name=produit size=6></td><td><input type=text name=qte size=4></td><td><input type=text name=prix size=4></td><td><input type=text name=tiroir size=4></td></tr>";
	print "</table>";
	print "<input type=hidden name=lot_nolot value=$lot_nolot>";
	print "<input type=hidden name=action value=visumodif>";
	print "<br></font>Parfums femmes:";
	print &get("select sum(tr_qte/100) from trolley where tr_code=$lot_nolot and tr_ordre <180");
	print "<br>Parfums hommes:";
	print &get("select sum(tr_qte/100) from trolley where tr_code=$lot_nolot and tr_ordre >=180 and tr_ordre<1000");
	print "<br>Cosmetiques:";
	print &get("select sum(tr_qte/100) from trolley,produit where tr_code=$lot_nolot and tr_ordre >=180 and tr_ordre>1000 and tr_cd_pr=pr_cd_pr and pr_type=5");
  	print "<br>";      
        $query="select sum(tr_qte/100),sum(tr_qte*pr_pdn)/100,tr_tiroir from trolley,produit where tr_code=$lot_nolot and tr_cd_pr=pr_cd_pr group by tr_tiroir order by tr_tiroir";
        $sth=$dbh->prepare($query);
	$sth->execute;
	while (($qte,$poids,$tiroir)=$sth->fetchrow_array) {
		 print "tiroir:$tiroir qte:$qte poids:".int($poids)." grs<bR>";
	}
	print "<br><input type=submit class=bouton value=modif>";
	print "</form><br><a href=http://ibs.oasix.fr/cgi-bin/lot.pl>retour</a>";
	print "</body></html>";

}

sub execute {
        # print "$query<br>";
	$dbh->do("insert into query values ('',QUOTE(\"$query\"),'$0','$ENV{'REMOTE_ADDR'}',now())");
	my($sth2)=$dbh->prepare($query);
	return($sth2->execute());
}
