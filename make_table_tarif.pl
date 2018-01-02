#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; # impression des parametres obligatoires


open(FILE,"< /home/var/spool/uucppublic/produit.txt");
@file_line=<FILE>;

foreach $temp (@file_line){
	@tmp = split(/;/,$temp);
	print "@tmp[1];@tmp[21];@tmp[22];@tmp[23];@tmp[24];\n";
}

