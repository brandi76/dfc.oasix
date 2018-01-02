#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
open(FILE1,"adresse.txt");
@liste_dat = <FILE1>;


close(FILE1);

print "<table>";
foreach (@liste_dat){
	chop($_);
	# ($null,$ad)=split(/\</,$_);
	# ($ad)=split(/\>/,$ad);
 $ad=$_;	
	$query="insert ignore into contact values ('$ad')";
        print "$query<br>";
                      &save($query);
 
        }
