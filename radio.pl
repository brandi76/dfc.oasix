#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
print <<eof
<a href=radio_2.1.pl>verification etiquette</a><br>
<a href=radio_2.0.pl>lecture </a><br>
<a href=radio_produit.pl>affectation etiquette->produit </a><br>
<a href=radio_tiroir.pl>affectation etiquette->tiroir </a><br>
<a href=radio_check.pl>check depart</a><br>

eof

# -E test de l'antenne radio
