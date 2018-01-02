#!/usr/bin/perl

use CGI;
$html = new CGI;
print $html->header;
$fichier=$html->param('fichier');     # fichier a ouvrir
$lien=$html->param('lien');
$nbelement=$html->param('nbelement'); # nb de colonne dans le fichier

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
close(FILE);
open (FILE,"/home/var/spool/uucppublic/$fichier.dsc");
@desc=<FILE>;
close(FILE);
open(SAUV,"> ../public_html/selection.csv");  # fichier pour telechargement     


#   BEGIN 

print "<html><body><a href=http://192.168.1.186><img src=http://ibs.oasix.fr/home.jpg align=right border=0></a><br>";
print "<font size=5 color=red >$fichier</font><br>";
print "<table width=100% border=1>";
print "<tr>";

# affichage des entetes de colonne

@desc_item=split(/;/,$desc[0]);
for($i=0;$i<=$#col_selection;$i++)
{
	print "<td><font size=2>&nbsp;$desc_item[$col_selection[$i]]</td>";
}
print "</tr>";


# gestion des variable pour la demande suivante

print "<form name=recherche action=../cgi-bin/cherche-fich.pl>";
print "<input type=hidden name=lien value=$lien>";
print "<tr>";

 for($i=0;$i<=$nbelement;$i++)
{
	if ($html->param("check$i") eq "on")
        {
        	print "<td><font size=2><input type=texte size=10 name=critere$i value='",$html->param("critere$i"),"'></td>";
                print "<input type=hidden name=check$i value=on>";
	}
}
print "<td><font size=2><input type=submit value=go></td></tr>";
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
		#$true=0;
		#
if($critere[$i] !~ /^[<,>]/	&& $critere[$i] ne "indifferent" && (length($critere[$i]) > 0)){
	$critere[$i] =~ s/[<,>]//g;	
	if (($critere[$i] ne "indifferent")  && (length($critere[$i]) > 0) ){
		$comp=uc($critere[$i]);
		if($comp!~/[a-z]/i){ #tester en numerique, le critère est unnombre
			if ($comp != $data_item[$col_selection[$i]]){
				$true=0;
			}
		}else{#le critère est un mot
			if (! grep  /$comp/,uc($data_item[$col_selection[$i]])){
				$true=0;
			}
		}
	}
}else{
	if($critere[$i] =~ /^[>]/){
		$comp=uc($critere[$i]);
		$comp =~ s/^[>]//g;
		if ($comp > $data_item[$col_selection[$i]]){
			$true=0;
		}
	}
	
	if($critere[$i] =~ /^[<]/){
		$comp=uc($critere[$i]);
		$comp =~ s/^[<]//g;
		if ($comp < $data_item[$col_selection[$i]] || $data_item[$col_selection[$i]]==0){
			$true=0;
		}
	}
}
			
				
	}
	if ($true)
	{
		push (@TAB,$data_var);
		}
}

# une fois la table cree on affiche les lignes du tableau

foreach(@TAB)
{
	@data_item=split(/;/,$_);
	print "<tr>";
		for($i=0;$i<=$#col_selection;$i++)
        {
		print "<td><font size=2>&nbsp;@data_item[@col_selection[$i]]</td>";
		print SAUV "@data_item[@col_selection[$i]];";

        }
        if ($lien ne ""){
        	($nul,$lien_en_clair)=split(/cgi-bin\//,$lien);
        	($lien_en_clair)=split(/\./,$lien_en_clair);
        	print "<td><font size=2><a href=$lien@data_item[@col_selection[0]]>$lien_en_clair</a></td>";
        	}
        print "</tr>\n";
        print SAUV "\n";

}

print "</table>";
print "<a href=http://ibs.oasix.fr/selection.csv>Telecharcher</a>";
print "</body></html>";
close (SAUV);
# -E recherche dans un fichier

