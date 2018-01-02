#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
require "./src/connect.src";

$query="select v_code from vol where v_rot=2 and v_date_jl<100";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code)=$sth->fetchrow_array){
      $query="select v_date,v_date_jl from vol where v_code='$v_code' and v_rot=1";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      ($v_date,$v_date_jl)=$sth2->fetchrow_array;
      &save("update vol set v_date='$v_date',v_date_jl='$v_date_jl' where v_code='$v_code' and v_rot=1","aff");
 }
