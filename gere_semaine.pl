#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>gere semaine</title></head><body>";


require "./src/connect.src";
# $dbh = DBI->connect("DBI:mysql:host=192.168.1.87:database=FLYDEV;","root","",{'RaiseError' => 1});
$navire=$html->param("navire");
$navire_sql=$navire;
$navire_sql=~s/_/ /;
$copie=$html->param("copie");
$copie=~s/_/ /;

$action=$html->param("action");
$coef=$html->param("coef");


if ($action eq "modif"){
	if ($copie ne ""){
		for ($i=1;$i<53;$i++){
			$coef=&get("select se_coef from semaine2 where se_no=$i and se_navire='$copie'");
			&save("replace semaine2 values ('$i','$navire_sql','$coef')","af"); 
		}
	}
	else 
	{
		for ($i=1;$i<53;$i++){
			$coef=$html->param("$i");
			&save("replace semaine2 values ('$i','$navire_sql','$coef')","af"); 
		}
	}
}

print "<table border=2 cellspacing=0><tr><th>Navire</th>";
for ($i=1;$i<53;$i++){
print "<th>$i</th>";
}
print "</tr>";
if ($navire eq "")
{
	$query="select nav_nom from navire";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nav_nom_sql)=$sth->fetchrow_array)
	{
		$nav_nom=$nav_nom_sql;
		$nav_nom=~s/ /_/;
		print "<tr><td><a href=?navire=$nav_nom>$nav_nom</a></td>";
		for ($i=1;$i<53;$i++){
			$coef=&get("select se_coef from semaine2 where se_no=$i and se_navire='$nav_nom_sql'","af");
			if ($coef eq ""){ $coef="vide";}
			# print "<td><input type=text size=3 name=$i value=$coef></td>";                                                                               	
			print "<td";
			if ($coef==0){print " bgcolor=green";}
			print ">$coef</td>";                                                                               	
	
		}
		print "</tr>";
	}
	print "</table>";
}
if ($navire ne "") 
{
	print "<form><tr bgcolor=#efefef><td>$navire</td>";
	for ($i=1;$i<53;$i++){
		$coef=&get("select se_coef from semaine2 where se_no=$i and se_navire='$navire_sql'","af");
		if ($coef eq ""){ $coef="vide";}
		print "<td><input type=text size=3 name=$i value=$coef></td>";                                                                               	
	}
		print "</tr>";
	print "</table><input type=submit><input type=hidden name=action value=modif><input type=hidden name=navire value='$navire'><br>";
	print "copier navire:<input type=text name=copie></form>";
	print "<br><a href=?>retour</a>";
}