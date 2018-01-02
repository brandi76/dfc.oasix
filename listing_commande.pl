#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";


print "<HTML>\n";
print "<HEAD>\n";
print "<STYLE TYPE='text/css'>
font.FOURN { color: red; font-family:\"Vedana\"; font-size:12Px; font-weight:bold;} 
font.FOURN1 { color: red; font-family:\"Vedana\"; font-size:9Px; font-weight:bold;} 
font.PROD { color: black; font-family:\"Vedana\"; font-size:10Px; font-style: italic;}
A { color: black; font-family:\"Verdana\"; font-size:12Px; font-weight:bold;} 
</STYLE></head>";
print "</HEAD>\n";

print "<BODY>\n";

&tete('Listing Commandes','','');
print "<P>&nbsp;</P>\n";
print "<CENTER>\n";
print "<a href='lipz2.pl'>1er listing (parfum)</A> ";
datemod('/home/var/spool/uucppublic/lipz2.txt');
print "<BR><BR>\n";
print "<a href='lipjimnew.pl'>2eme listing</A> ";
datemod('/home/var/spool/uucppublic/lipjim.txt');
print "<BR><BR>\n";
print "<a href='red-alerte.pl'>3eme listing</A> ";
datemod('/home/var/spool/uucppublic/red-ale.txt');
print "<BR><BR>\n";

# -E Listing 3 Commande du Matin