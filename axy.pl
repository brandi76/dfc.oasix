#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

print $html->header;
require "./src/connect.src";

open(FILE,"<axy.csv");
@tab=<FILE>;
foreach (@tab){
	$saut="";
	($date,$vol,$immat,$dep,$hdep,$ar,$har)=split(/;/,$_);
	if (($actif==0)&&($dep eq "CDG")){
		$actif=1;
		$ref=$dep;
		$dep="<font color=red>".$dep."</font>";
	}
	if (($actif==0)&&($dep eq "LYS")){
		$actif=1;
		$ref=$dep;
		$dep="<font color=red>".$dep."</font>";
	}
	if (($actif==0)&&($dep eq "MRS")){
		$actif=1;
		$ref=$dep;
		$dep="<font color=red>".$dep."</font>";
	}
	if (($actif==1)&&($ar eq $ref)){
		$actif=0;
		$ar="<font color=red>".$ar."</font>";
		$saut="<br>";
	}
	print "$date,$vol,$immat,$dep,$hdep,$ar,$har $saut<br>";
}