#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
print "<pre>";
system("tail -10 /usr/local/apache2/logs/error_log | cut -d']' -f4");
