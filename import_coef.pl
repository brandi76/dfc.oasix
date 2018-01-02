#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
open(FILE1,"coef.csv");
@liste_dat = <FILE1>;

close(FILE1);
$navire="EXPRESS 3";
$i=0;
&save("delete from semaine2 where se_navire='$navire'");
foreach (@liste_dat){
	chop($_);
	$i++;
	$_=~s/,/\./;
	&save("replace into semaine2 values('$i','$navire','$_')","aff");
}