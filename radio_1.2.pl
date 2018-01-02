#!/usr/bin/perl
use DBI();

require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$a=time();
 &save("delete from radio");
while (1)
{
 $b=time();
 if ($b >$a+10) {last;}
 $etiq=`radio`;
 (@tab)=split(/\n/,$etiq);
 foreach (@tab) {
 &save("insert ignore into radio values ('$_')","aff");
 }
}




# -E boucle lecture radio
