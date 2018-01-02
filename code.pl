#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$html=new CGI;
print $html->header;
$action=$html->param("action");
$titre=$html->param("titre");
$code=$html->param("code");

if ($action eq "save"){
  $check=&get("select count(*) from code where titre='$titre'")+0;
  if ($check){
    &save("update into code set code=\"$code\" where titre=\"$titre\" ");
  }
  else{
    &save("insert into code (titre,code) values (\"$titre\",\"$code\")");
  }  
}
print "<form>";
print "titre <input name=texte><br>";
print "<textarea name=code></textarea>";
print "<input type=hidden name=action value=save>";
print "<input type=submit>";
print "</form>";

$query="select titre,code from code order by code_id";
$sth=$dbh->prepare($query);
$sth->execute();
while (($titre,$code)=$sth->fetchrow_array){
  print "<strong>$titre</strong><br>";
  print "<textarea cols=120 style=background:lightgray>";
  print $code;
  print "</textarea>"
}


