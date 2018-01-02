#!/usr/bin/perl
use DBI();

require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
&save("delete from radio","aff");
$etiq=`radio`;
(@tab)=split(/\n/,$etiq);
foreach (@tab) {
 	&save("insert ignore into radio values ('$_')","aff");
}




# -E lecture rapide
