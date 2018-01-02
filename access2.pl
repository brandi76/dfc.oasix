#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;

$code = $html->param('code');

open(PASS,"< ocde.csv");
@passwords = <PASS>;
close(PASS);

$trouver = 0;

$i=0;
$k=0;
foreach $le_pass (@passwords){
	@liste = split (/;/,$le_pass);	

if($html->param('code') eq @liste[0] ){
	$trouver=1;
	$k = $i;
	last;
}
	$i = $i + 1;
}

print "<HTML>\n";
print "<BODY text=darkgoldenrod>\n";
print "<center><h2>Bienvenue <i>@liste[1]</i></h2>";

print "Voici les informations qui concernent votre derniere commande . . .<p>";

print "<table cellpadding=4>\n";
print "<tr>\n";
print "<td align=center><b><i><font color=black>Code Produit</td>\n";
print "<td align=center><b><i><font color=black>Désignation</td>\n";

print "<td align=center><b><i><font color=black>QT demandé</td>\n";
print "<td align=center><b><i><font color=black>Prix Vente</td>\n";
print "<td align=center><b><i><font color=black>TT ligne</td>\n";

print "<td align=center><b><i><font color=black>TT Commande</td>\n";
print "<td align=center><b><i><font color=black>QT Livré</td>\n";
print "<td align=center><b><i><font color=black>QT Attente</td>\n";
print "</tr>\n";

$line_fic = $#passwords;

@liste = split (/;/,@passwords[$k]);
$tmp=@liste[0];
$j=$k;	
while(@liste[0] eq $tmp){
	print "<tr>\n";
	print "<td>@liste[3]</td>\n";
	print "<td>@liste[4]</td>\n";
	print "<td>@liste[6]</td>\n";
	print "<td>@liste[5]</td>\n";
	print "<td>@liste[7]</td>\n";
	print "<td>@liste[8]</td>\n";
	print "<td>@liste[9]</td>\n";
	print "<td>@liste[10]</td>\n";
	print "</tr>\n";		
$j++;
@liste = split (/;/,@passwords[$j]);			
}
	
print "</table>\n";

print "</BODY></HTML>\n";

# -E Affichage de la commande en cours de preparation pour OCDE