#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
$id=$html->param("id");
$host=$html->param("host");

print "Set-Cookie: session=$id; domain=.$host; path=/\n";
print "Location: http://ibs.oasix.fr/cgi-bin/kit2.pl\n\n";
