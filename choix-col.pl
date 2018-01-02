#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; 
$rep="/home/var/spool/uucppublic/";
$fichier=$html->param('fichier');
$lien="";
print "<html><body alink=white vlink=white lonk=white><a href=http://intranet.dom/><img src=/home.jpg align=right></a><br>";
if ($#ARGV >= 0) {
	$fichier =@ARGV[0]; # non du fichier sur lequel va se faire la recherche
	$lien=@ARGV[2];  # lien pour le prochain programme
	$crit=@ARGV[3];  # colonne correspondant au critere de recherche
	${val."$crit"}=@ARGV[1]; # valeur du critere de reccherche
	 		}
open (FILE,"$rep$fichier.dsc");
@data=<FILE>;
close <FILE>;
@data_item=split(/;/,@data[0]); # Recuperation des intutiles de colonne

print "<font size=5 color=red>Recherche</font><br>";
print "<table>";
print "<tr><td colspan=2>Affiche les infos suivantes</td><td>Critère de Recherche</td></tr>";
print "<form action=http://intranet.dom/cgi-bin/cherche-fich.pl>";
for($i=0;$i<=$#data_item;$i++)
{
	if (length(@data_item[$i]) > 2)
	{
		print "<tr><td>@data_item[$i]</td><td><input type=checkbox name=check$i checked></td><td><input type=texte size=12  name=critere$i value=",${val."$i"},"></td></tr>"; #astuce
        }
                	

}
print "<input type=hidden name=nbelement value=$#data_item>";
print "<input type=hidden name=fichier value=$fichier>";
print "<input type=hidden name=lien value=$lien>";
print "<tr><td><input type=submit value=go></td></tr>";
print "</form></table>";
print "</body></html>";
# -E choix des colonnes pour la recherche
