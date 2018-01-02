#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

print $html->header;
require "./src/connect.src";
$action=$html->param("action");
$pastouch=$html->param("pastouch");
$repart=$html->param("repart");

if ($action eq ""){

	print "procedure<br>mettre le dossier du pas touché sur le bureau de saisie avec un pos-it pas touche<br>";
	print "saisir les elements ci_dessous<br>";	
	print "s'il y a lieu creer le vol menu->gestion du planning<br>";	
	print "creer un depart menu->preparation->choix du jour<br>";	
	print "cliquez sur pas touché puis bon appro puis etiquette<br><br>";	
	print "<form>No de Lot pas touché 6 digit <input type=text name=pastouch><br>";
	print "Trolley type qui repart 4 digit <input type=text name=repart><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit value=envoie></form>";
	print "<br><br><h3><a href=?action=liste>Liste des pas touchés</a>";
}
if ($action eq "go"){
	$query="select gsl_nolot,gsl_apcode from geslot where gsl_nolot='$pastouch' and (gsl_ind=3 or gsl_ind=5 or gsl_ind=10)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($gsl_nolot,$gsl_apcode)=$sth->fetchrow_array;
	print "$query $gsl_apcode<br>";
	if ($gsl_nolot eq ""){ 
		print "lot $pastouch invalide";
		exit;
	}
	$query="select gsl_nolot from geslot where floor(gsl_nolot/100)='$repart' and gsl_ind=0 limit 1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "$query<br>";
	($gsl_nolot)=$sth->fetchrow_array;
	if ($gsl_nolot eq ""){ 
		print "pas de lot trolley type $repart disponible";
		exit;
	}
	$query="update geslot set gsl_apcode='$gsl_apcode',gsl_ind=10 where gsl_nolot='$gsl_nolot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "$query<br>";
	$query="update geslot set gsl_ind=0,gsl_pb1=0,gsl_pb2=0,gsl_pb3=0 where gsl_nolot='$pastouch'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "$gsl_nolot operation effectuée avec succés";
}
if ($action eq "liste"){
	print "Pas touché en attente<br><table border=1 cellspacing=0><tr><th>No de lot</th><th>Désignation</th><th>Appro</th></tr>";
	$query="select gsl_nolot,gsl_apcode,gsl_desi,gsl_troltype from geslot where gsl_ind=10 order by gsl_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	# print "$query<br>";
	while (($gsl_nolot,$gsl_apcode,$gsl_desi,$gsl_troltype)=$sth->fetchrow_array){
		print "<tr><td>$gsl_nolot</td><td>$gsl_desi</td><td>$gsl_apcode</td><td>$gsl_troltype</td></tr>";
	}
	print "</table>";
	print "<br><br>Pas touché prévu pour le départ d'aujourd'hui<br><table  border=1 cellspacing=0><tr><th>No de lot</th><th>Désignation</th><th>Appro</th></tr>";
	$query="select gsl_nolot,gsl_apcode,gsl_desi from geslot where gsl_ind=11 order by gsl_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "$query<br>";
	while (($gsl_nolot,$gsl_apcode,$gsl_desi)=$sth->fetchrow_array){
		print "<tr><td>$gsl_nolot</td><td>$gsl_desi</td><td>$gsl_apcode</td></tr>";
	}
	print "</table>";
}