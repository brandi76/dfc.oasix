#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
$action=$html->param('action');

require "./src/connect.src";
foreach $base (@bases_client){
	if ($base eq "dfc"){next;}
	&save ("insert ignore into dfc.livraison (liv_no,liv_code) select distinct com2_no_liv,com2_no from $base.commande where com2_no_liv!=0","aff");
	&save ("insert ignore into dfc.livraison (liv_no,liv_code) select distinct com2_no_liv,com2_no from $base.commandearch where com2_no_liv!=0","aff");
}	
;1 

