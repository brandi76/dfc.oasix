#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;

open(FILE," ls |");
@line=<FILE>;

foreach $temp (@line){
	print $temp;
	
	open(LISTEFILE,"< $temp");
	@listeline=<LISTEFILE>;
	
	foreach(@listeline){
		if(grep "## NOM ##",$_){
			print "$_";
		}	
		
	}








}

