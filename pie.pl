#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$action=$html->param('action');
$src=$html->param('src');
$dest=$html->param('dest');
$message=$html->param('message');
$nb=$html->param('nb');
$index=$html->param('index');

print $html->header;

print "<form><input type=texte name=action><input type=submit></form>";

	
	print "<img src=\"http://ibs.oasix.fr/Artichow-php5/examples/pie-009.php?a+1=1&f+2=2&c+3=3&d=5&g+2=2&l+2=2";
