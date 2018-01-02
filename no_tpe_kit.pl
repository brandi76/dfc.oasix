#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
$query="select distinct serial from tpe";
$sth=$dbh->prepare($query);
$sth->execute();
while(($serial)=$sth->fetchrow_array){
  print "$serial->";
  $nb=0;
  $fin=substr($serial,length($serial)-3,3)+1000;
  $debut=substr($serial,0,4);
  while ($debut >10){
    $nb=0;
    for ($i=length($debut);$i>0;$i--){
	$nb+=substr($serial,$i,1);
    }
    $debut=$nb;
  }
  $nb=$debut*100+$fin;
  if ($nb>1000){
    $nb=substr($nb,1,3);
  }
  print "$nb<br>";
}  