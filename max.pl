#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
$html=new CGI;
print $html->header;
require "./src/connect.src";
print "<b>bonjour</b>";
$toto=&get("select cl_nom from client where cl_cd_cl=234");
print $toto;


