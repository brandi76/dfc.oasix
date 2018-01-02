#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

open(FILE1,"find /mnt/windows/AGENDA.old/ -name \"*.CIB\" |");
@liste_dat = <FILE1>;
close(FILE1);

print $html->header;
require "./src/connect.src";

foreach (@liste_dat){
	# print "$_<br>";
	$fichier=$_;
	$infr_caissepn,$infr_caisseth,$total=0;
	
open(FILE1,"$fichier");
@cib_dat = <FILE1>;
close(FILE1);


foreach (@cib_dat){
	($type,$val1,$val2)=split(/;/,$_);
	if ($type eq "Z"){
		$val1=~s/\///;
		print $val1,";";
		$appro=$val1;
		}
	if ($type eq "4"){
		$val1=~s/\+//;
		print $val1,";";
		}
	}
print "<br>";
if ($appro <10000){next;}
if ($appro >100000){next;}

}

# -E importation du fichier cib trigramme