#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; # impression des parametres obligatoires


$fich_catal = "cata20.csv";	# fichier catalogue


@nom = $html->param('param');
@valeur = $html->param('valeur');
print "@nom<br>\n";
print "@valeur<br>\n";
print @ENV{'QUERY_STRING'},"<br>\n";

$i=0;

foreach(@nom){
	print "$_<br>\n";
	
	$i += 1;
}




