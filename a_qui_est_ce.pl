#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$appro=$html->param("appro");
print "<form><input name=appro><input type=submit></form>";

if ($appro ne ""){
	foreach $base (@bases_client){
		if ($base eq "dfc"){next;}
		print "$base ";
		$date=&get("select v_date_sql from $base.vol where v_code='$appro' and v_rot=1");
		print "$date <br>";
	}
}
