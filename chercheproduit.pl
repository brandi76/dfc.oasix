#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; 
require 'outils_perl.lib';
$rep="/home/var/spool/uucppublic/";
$fichier=$html->param('fichier');
$lien="";
print "<html>\n";
print "<LINK rel=\"stylesheet\" href=\"/intranet.css\" type=\"text/css\">\n";
&body();
&tete("Rechercher un Produit","/home/var/spool/uucppublic/produit.txt","");
if ($#ARGV >= 0) {
	$fichier =@ARGV[0]; # non du fichier sur lequel va se faire la recherche
	$lien=@ARGV[2];  # lien pour le prochain programme
	$crit=@ARGV[3];  # colonne correspondant au critere de recherche
	${val."$crit"}=@ARGV[1]; # valeur du critere de recherche
	 		}
open (FILE,"$rep$fichier.dsc");
@data=<FILE>;
close(FILE);
@data_item=split(/;/,@data[0]); # Recuperation des intutiles de colonne

#print "<br><font size=5 color=red>Déselectionner les </font><br>";
print "<br><br>";
print "<table border=0>";
print "<tr><td colspan=2><b>Désélectionner les infos à ne pas afficher :</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br>&nbsp;</td><td><b>Critères de Recherche<br>&nbsp;</b></td></tr>";
print "<form action=http://ibs.oasix.fr/cgi-bin/cherche-fich.pl>";
for($i=0;$i<=$#data_item;$i++)
{
	if (length(@data_item[$i]) > 2)	{
		$check="";
		if (($i==1)||($i==9)){$check="checked";}
		print "<tr><td>@data_item[$i]</td><td><input type=checkbox name=check$i $check></td>
		<td><input type=texte size=20  name=critere$i value=",${val."$i"},"></td></tr>"; #astuce
        }
}
print "<input type=hidden name=nbelement value=$#data_item>";
print "<input type=hidden name=fichier value=$fichier>";
print "<input type=hidden name=lien value=$lien>";
print "<tr><td>&nbsp;<br><input type=submit value=\"Lancer la recherche\"></td></tr>";
print "</form></table>";
print "</body></html>";
# -E choix des colonnes pour la recherche
