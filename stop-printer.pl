#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
print "<title>arret de l'imprimante 2</title>";
print "<pre>";
print `ps -eaf | grep cat`;
print `sudo killall cat 2>/tmp/error.log`;
