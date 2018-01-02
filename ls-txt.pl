#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; 
$rep="/home/var/spool/uucppublic/";
print "<body><html>";
print "<font color=red>$rep</font><br>";
print "<table border=1>";
print "<tr><td>table</td><td>description</td><td>Nb d'enregistrement</td><td>date de modification</td></tr>";


ls();
print "</table></body></html>";

sub ls(){
open(LISTE,"ls -l $rep*.txt|");
@ls=<LISTE>;

foreach (@ls)
{
while ($_=~ s/  / /g){}; # suppression des doubles espaces
@ligne=split(/ /,$_); # separation des champs de ls-l
$ligne[8] =~ s/$rep//;
$fichier = substr ($ligne[8],0,length($ligne[8])-5); 
$lien="../cgi-bin/choix-col.pl?fichier=$fichier";
$date = $ligne[6]." ".$ligne[5]." ".$ligne[7];
 print "<tr><td><a href=$lien>$fichier</a></td>";
 open (FILE,"$rep$fichier.dsc");
@data=<FILE>;
close <FILE>;
print "<td>@data[1]</td>";
$nbligne=`wc -l $rep$fichier.txt`;
while ($nbligne=~ s/  / /g){};
@nbligne=split(/ /,$nbligne);
print "<td align=right>$nbligne[1]</td><td align=middle>$date</td>";
print "</tr>\n";
}
}

# -E liste des fichiers de données
