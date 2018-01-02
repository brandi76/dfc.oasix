#!/usr/bin/perl
use CGI; 
require 'manip_table.lib';
require 'outils_perl.lib';
$html=new CGI;
print $html->header;

print "<HTML>\n";

print "<HEAD>\n";
print "</HEAD>\n";
&body();
&tete("Programme momentanément indisponible","","");
print "<P>&nbsp;</P>";

print "Ce programme est momentanément insdisponible en raisons de modifications éffectuées en ce moment même.<BR><BR><DIV ALIGN=RIGHT>Merci de votre compréhension</DIV>\n<BR><BR>N.G.H - Service Informatique (Sylvain & Alexandre)\n";

print "</body></html>";


# -E DISFRA3 : display franchise infos