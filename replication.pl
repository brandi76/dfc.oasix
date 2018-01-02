#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
$fich=$html->param("fich");
$option=$html->param("option");
$action=$html->param("action");

# @base_client=("camairco","togo","aircotedivoire","formation","tacv","cameshop","dfca");
@base_client=("camairco","togo","aircotedivoire","formation","tacv");

if (($action eq "copie")&&($fich ne "")){
	foreach $client (@base_client){
		if ($option eq "") {
		  print  "cp /var/www/cgi-bin/dfc.oasix/$fich /var/www/cgi-bin/$client.oasix";
		  if (system("cp /var/www/cgi-bin/dfc.oasix/$fich /var/www/cgi-bin/$client.oasix 2>/tmp/log")) {print "<span style=background:pink>erreur</span> ";}
		}
		
		print `diff -q  /var/www/cgi-bin/dfc.oasix/$fich /var/www/cgi-bin/$client.oasix/$fich`;
		print "<br>";
	}
}
if (($action eq "verif")&&($fich ne "")){
	print "<pre>";
	foreach $client (@base_client){
		if ($option eq "") {
		  if (! -f "/var/www/cgi-bin/dfc.oasix/$fich"){print "<p style=background:pink>Fichier introuvable</p>";}
		  print  "diff <span style=color:blue>/var/www/cgi-bin/dfc.oasix/$fich</span> <span style=color:green>/var/www/cgi-bin/$client.oasix</span>";
		  $mess=`/usr/bin/diff /var/www/cgi-bin/dfc.oasix/$fich /var/www/cgi-bin/$client.oasix`;
		  $mess=~s/^</\<span style=color:blue\>/g;
		  $mess=~s/^>/\<span style=color:green\>/g;
		  $mess=~s/$/\<\/span\>/g;
		  print $mess;
		}
		print "<br>";
	}
	print "</pre>";
}
print "<form style=float:left;><input type=text name=fich value=$fich> <input type=submit name=action value=copie> <input type=submit name=action value=verif></form><br>";
print "<div style=clear:both;> </div>";

open(FILE,"ls -t . | head -10 |");
@tab=<FILE>;
foreach (@tab){
	print "<form style=float:left;><input type=hidden name=fich value=$_>$_<input type=hidden name=action value=copie><input type=submit></form> <form style=float:left;><input type=hidden name=fich value=$_><input type=hidden name=action value=verif><input type=submit value=verif></form><br>";
	print "<div style=clear:both;> </div>";
}

