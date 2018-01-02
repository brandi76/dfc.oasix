#!/usr/bin/perl
# use DBI();
print "Content-Type: text/plain\n";
print "Cache-Control: no-store\n";
print "Access-Control-Allow-Origin: *\n\n";
# require "../oasix/../oasix/outils_perl2.pl";
# require("./src/connect.src");
# &save("update atadsql set dt_no=dt_no+1 where dt_cd_dt=120");
$outp = '{"Name":"moi","City":"paris","Country":"france"}';
$outp .=",".'{"Name":"lui","City":"paris","Country":"ailleurs"}';

$outp ='{"records":['.$outp.']}';
print($outp);




