#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";
require "./src/connect.src";
print $html->header;

$client=$html->param('client');
$tri=$html->param('tri');
$type=$html->param('type');
$nom=$html->param('nom');
$action=$html->param('action');

if ($action eq ""){ &premiere();}
if ($action eq "client"){ &clien();}
if (($action eq "sup")&&($tri ne "")&&($client ne "")){
	$query="delete from hotesse where hot_cd_cl='$client' and hot_tri='$tri'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<br><font color=red>Hotesse supprimée<br></font>";
	$action="go";
}
if (($action eq "ajouter")&&($tri ne "")&&($client ne "")&&($nom ne "")){
	$query="replace into hotesse values ('$client','$tri','$type','$nom','$client')";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<br><font color=red>Hotesse ajoutée<br></font>";
	$action="go";
}
if (($action eq "go")&&($client ne "")){ &go();}

sub premiere{
	&tetehtml();
	print "<center><form>";
	print " <a href=fiche_hotesse.pl?action=client>Code client:</a><input type=text name=client><br><br>"; 	
	print " <input type=submit class=bouton>"; 
	print "<input type=hidden name=action value=go>";
	print "</form>";
}

sub go {
	&tetehtml();
	$query="select cl_nom from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($cl_nom)= $sth->fetchrow_array;
	print "<body><h2>$cl_nom</h2>";
	print "<form><table border=1 cellspacing=0>";
	print "<tr bgcolor=yellow><th>Trigramme</th><th>Nom</th><th>Type 1->CC 2->Hot</th><th>Matricule</th><th>&nbsp</th></tr>";
	$query="select * from hotesse where hot_cd_cl='$client' order by hot_tri";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($hot_cd_cl,$hot_tri,$hot_type,$hot_nom,$hot_mat)= $sth->fetchrow_array) {
		print "<tr><td>$hot_tri</td><td>$hot_nom</td><td>$hot_type</td><td>$hot_mat</td><td></div><a href=?action=sup&client=$client&tri=$hot_tri>Sup</a></div></td></tr>";
	}
	print "</table><br>";
	print "<input type=hidden name=client value=$client><br>";
	print "Trigramme <input type=text name=tri size=3><br>";
	print "Type <input type=text name=type value=2 size=1><br>";
	print "Nom <input type=text name=nom size=30><br><br>";
	print "<input type=submit class=bouton value=ajouter name=action></form>";
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

	print "<body background=../fond2.jpg link=white alink=white vlink=white><center><div class=ombre><font size=+5>Gestion des hotesses</font>";
}
sub clien{
	&tetehtml();
	print "<br><br></div>";
	$query="select distinct cl_cd_cl,cl_nom from client,trolley where floor(tr_code/10)=cl_cd_cl order by cl_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
		print "<a href=?action=go&client=$cl_cd_cl>$cl_cd_cl $cl_nom</a> <br>";
		
}
}
