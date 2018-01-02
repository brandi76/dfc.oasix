#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; # impression des parametres obligatoires
print "<html>\n";
print "<body>\n";
print "<center><font size=5>PRODUIT INTROUVABLE</font>\n";
print "<br><br><br>\n";
print "<form name=code_produit action=../cgi-bin/disp-produit-sanssh.pl>\n";
print "<input type=hidden value=",$html->param('lien')," name=lien>\n";
print "<input name=devise type=hidden value=",$html->param('devise'),">\n";
print "<b>Code du produit : </b><input type=text name=code>\n";
print "</form>\n";
print "</body>\n";
print "</html>\n";
