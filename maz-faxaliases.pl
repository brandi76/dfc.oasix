#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header; # impression des parametres obligatoires
open(F1,">>/usr/local/etc/mgetty+sendfax/faxaliases");
print F1 $html->param('nom')," ",$html->param('num'),"\n";
close(F1);
print "<hmtl><body text=darkgoldenrod>";
print "<center>L'enregistrement a ete ajoute";
print "</body></html>\n";


# mise a jour du fichier des aliases fax numero
# sylvain le jeu jui 27 09:38:16 CEST 2000
