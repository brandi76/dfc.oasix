#!/usr/bin/perl
require "../oasix/outils_perl2.lib";

use CGI;
use DBI();

$html=new CGI;
$date=`/bin/date +%d';'%m';'%Y`;
print $html->header;

require "./src/connect.src";


print "coucou\n";
open (STDOUT,">/tmp/asylvain");

print "coucou\n";
print "coucou\n";
close (STDOUT);
