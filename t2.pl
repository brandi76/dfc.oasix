#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; # impression des parametres obligatoires

foreach(@html){
	$char=$char+"&";
}

print "<html><body>";
print "<a href=temp.pl?$char>go</a>";
print "</html></body>";




