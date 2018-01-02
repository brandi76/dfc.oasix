#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;

print $html->header;
$neptune=$html->param("neptune");
$desi=$html->param("desi");
$pv=$html->param("pv");
$barre=$html->param("barre");

$action=$html->param("action");
require "./src/connect.src";
print "<form>";
print "$neptune $desi $pv <br>";
print "code barre :<input type=text size=20 name=barre><br>";
print "<input type=hidden name=pv value=$pv>";
print "<input type=hidden name=desi value=$desi>";
print "<input type=hidden name=neptune value=$neptune>";
print "<input type=hidden name=action value=go>";
print "<input type=submit value=go>";

print "</form>";

if ($action eq "go"){
	if (&checkbarre($barre)){
		while ($pv=~s/'//){};
		while ($desi=~s/'//){};
		$pv*=100;
		while ($desi=~s/_/ /){};
		&save("insert into neptune values ('$neptune','$barre','$desi','$pv','')","aff");
	}
	else 
	{ print "<font color=red>code barre invalide";}
}
# -E creation d un code neptune
