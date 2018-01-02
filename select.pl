#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

print $html->header;
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body>\n";
$fichier=$html->param('fichier');
$action=$html->param('action');

require "./src/connect.src";
if ($fichier eq ""){
	print "<form>";
	print "fichier <input type=text name=fichier>";
	print "<input type=submit value=go name=action>";
	print "</form>";
}
elsif ($action eq "go"){
	print "<h1>$fichier</h1>";
	$query="show columns from $fichier";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form><table><tr><th>champ</th><th>Selection</th><th>Critere</th></tr>";
	while ((@liste)=$sth->fetchrow_array){
		print "<tR><td>$liste[0]</td><td><input type=checkbox name=c$liste[0]></td><td><input type=text name=cr$liste[0]></td></tr>";
		push (@table,$liste[0]);
	}
	print "</table><input type=hidden name=fichier value=$fichier><input type=submit name=action value=voir></form>";
	foreach (@table){
 		print "\$".$_.",";
		}
	print "<br>";
}	
	
elsif ($action eq "voir"){
	print "<h1>$fichier</h1>";
	$query="show columns from $fichier";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$query="select ";
	while ((@liste)=$sth->fetchrow_array){
		if ($html->param("c$liste[0]") eq "on"){
			$query.=$liste[0].",";
		}
		if ($html->param("cr$liste[0]") ne ""){
			$critere.=$liste[0].$html->param("cr$liste[0]")." and ";
		}


	}
	chop($query);
	$query.=" from $fichier";
	if ($critere ne ""){
		chop($critere);
		chop($critere);
		chop($critere);
		chop($critere);
		$query.=" where ".$critere;}
	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table>";
	while ((@liste)=$sth->fetchrow_array){
		print "<tR>";
		foreach (@liste){
			print "<td>$_</td>";
		}
		print "</tr>";
	}
	print "</table>";	
}