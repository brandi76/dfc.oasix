#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$date = `/bin/date '+%d%m%y'`;   
chop($date);  
print $html->header;
#&tete("REPARTITION DES VENTES","");
print "<center><p><b>Gestion des TPE</b></p>";
$count=0;
print "<table border=1>";
require "./src/connect.src";
$query="select * from tpefile";
$sth=$dbh->prepare($query);
$sth->execute();
while (($no,$serie,$diners,$am,$ecran,$imprimante,$typebat,$datebat,$atelier,$etat,$appro)=$sth->fetchrow_array){
	print "<tr><td>$no</td><td>$serie</td><td>$etat</td><td>$appro</td></tr>";}
print "</table>";
$sth->finish;


# -E gestion des tpe