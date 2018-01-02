#!/usr/bin/perl

use CGI;
$html = new CGI;
print $html->header;
$fichier=$html->param('fichier');     # fichier a ouvrir
$lien=$html->param('lien');
$nbelement=$html->param('nbelement'); # nb de colonne dans le fichier

require "../oasix/outils_perl.lib";

# receperation des colonnes a traiter
for ($i=0;$i<=$nbelement;$i++)
{
        if ($html->param("check$i") eq "on")
        {
        	push(@col_selection,$i);  # table des colonnes selectionnées
        }
}	

# recuperation des criteres saisies

for($i=0;$i<=$#col_selection;$i++)
{       
	
	@critere[$i]=$html->param("critere@col_selection[$i]"); # table critere conteient les criteres correspondant a chaque collonne du fichier
}

# ouverture des fichiers data et description

open (FILE,"/home/var/spool/uucppublic/$fichier.txt");
@data=<FILE>;
close (FILE);
open (FILE,"/home/var/spool/uucppublic/$fichier.dsc");
@desc=<FILE>;
close (FILE);


#   BEGIN 

print "<html>";
&body();
&tete("Recherche Commande Client","/home/var/spool/uucppublic/$fichier.txt","");
print "<br><br>\n";
print "<table width=100% border=1 cellspacing=0 cellpadding=3 bordercolordark=darkgoldenrod bordercolorlight=orange rules=none>";
print "<tr>";

# affichage des entetes de colonne

@desc_item=split(/;/,@desc[3]);
#for($i=0;$i<=$#col_selection;$i++)
#{
#	print "<td><font size=2>&nbsp;$desc_item[$col_selection[$i]]</td>";
#}
print "<td align=center><b>N° de commande</b></td>\n";
print "<td align=center><b>Code Client</b></td>\n";
print "<td align=center><b>Nom</b></td>\n";
print "<td align=center><b>Date de réception</b></td><td>&nbsp;</td>\n";
print "</tr>";


# gestion des variable pour la demande suivante

print "<form name=recherche action=../cgi-bin/cherche-ocde.pl>";
print "<input type=hidden name=lien value=$lien>";
print "<tr>";

 for($i=0;$i<=$nbelement;$i++)
{
	if ($html->param("check$i") eq "on")
        {
        	print "<td align=center><font size=2><input type=texte size=10 name=critere$i value=",$html->param("critere$i"),"></td>";
                print "<input type=hidden name=check$i value=on>";
	}
}
print "<td><font size=2><input type=submit value=\"Chercher\"></td></tr>";
print "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n";
print "<input type=hidden name=fichier value=$fichier>";
print "<input type=hidden name=nbelement value=$nbelement>";
print "</form>";

# pour les elements du fichier on test si les criteres correspondent afin de d'alimenter @TAB 

foreach $data_var (@data)
{ 
	@data_item=split(/;/,$data_var);
	$true=1;
	for ($i=0;$i<=$#critere;$i++)
	{
		while ($critere[$i] =~ s/  / /g){};
		
		if (($critere[$i] ne "indifferent")  && (length($critere[$i]) >= 1))
		{
			$comp=uc($critere[$i]);
			if (! grep  /$comp/,uc($data_item[$col_selection[$i]]))
			{
				$true=0;
			}
		}
			
				
	}
	if ($true){
		push (@TAB,$data_var);
	}
}
$color = "#E8E8E8";

# une fois la table cree on affiche les lignes du tableau
	if($#TAB == -1){
		print "<tr><td colspan=6 align=center><font color=red><i><b>Aucun résultat pour cette requête.<p>&nbsp;</p></td></tr>\n";
	}
	else{


if ($#TAB < 10000){
foreach(@TAB)
{
	@data_item=split(/;/,$_);
	print "<tr>";
		for($i=0;$i<=$#col_selection;$i++)
        {
		print "<td bgcolor=$color><font size=2>&nbsp;@data_item[@col_selection[$i]]</td>";
        }
        if ($lien ne ""){
        	($nul,$lien_en_clair)=split(/cgi-bin\//,$lien);
        	($lien_en_clair)=split(/\./,$lien_en_clair);
        	print "<td><font size=2><a href=$lien@data_item[@col_selection[0]]>$lien_en_clair</a></td>";
        }
        print "<td bgcolor=$color>&nbsp;</td></tr>\n";
	if($color eq "#E8E8E8"){
		$color = "white";
	}else{
		$color="#E8E8E8";
	}

}
}
else
{
		print "<tr><td><font size=5>$#TAB elements sélectionnés , risque de saturation </font></td></tr>";
}
}
print "</table>\n";

print "<p>&nbsp;</p>\n";
print "<p>&nbsp;</p>\n";
print "</center>\n";
print "<hr>\n";
print "<font size=-2>\n";
print "<i>\n";
print "Pour information utilisez le <a href=\"mailto:sylvain\@ibs.dom;alex\@ibs.dom\">MAIL</a>\n";
print "</body></html>";


# -E recherche dans un fichier

