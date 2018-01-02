#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;

$a=time();
while (1)
{
 $b=time();
 if ($b >$a+10) {last;}
 $etiq=`radio`;
 (@tab)=split(/\n/,$etiq);
 print "<h2>";
 foreach (@tab) {
	 print "$_<br>\n";
 &save("replace into radio values ('$_')","aff");
 }
}




# -E test de l'antenne radio
