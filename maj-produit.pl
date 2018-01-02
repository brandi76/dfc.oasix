#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; 
require 'outils_perl.lib';
print "<html>";
&body();
&tete("MAJ-PRODUIT","/home/intranet/cgi-bin/prod-a-mettre-a-jour.txt","");

print "<center>Cette liste a pour but de mettre à jour le fichier produit<br>";
print "Ces produits ne sont pas au catalogue, ne sont pas gerés par la douane, leur stock est à zéro , aucune difference de stock n'a été enregistrée<br>";
print "Merci de decocher les produits à conserver, n'oubliez pas de valider pour prendre en compte vos modifications<br>";
print "La suppression réel ne sera éffective qu'aprés votre accord<br>";
print "<font color=red> les produits qui seront supprimés sont en rouge</font><br><br>";
print "</center>"; 
$gap=100;

$premier = $html->param("premier");
$dernier = $html->param("dernier");
$nb_element = $html->param("nb_element");
if ($premier eq ""){$premier=0;}
if ($dernier eq "") {$dernier=$gap-1;}
$modif = $html->param("modif");				

if ($modif eq "ok"){
open(FIL1,"/home/intranet/cgi-bin/prod-a-mettre-a-jour.txt");
@tab=<FIL1>;
close(FIL1);
open(FIL1,">/home/intranet/cgi-bin/prod-a-mettre-a-jour.txt");
for ($i=0;$i<$nb_element;$i++){
	($code,$designation,$famille,$sup)=split (/;/,@tab[$i]);
	if (($i>=$premier) && ($i<=$dernier)){$sup=$html->param("cs$i");}
	print FIL1 ($code.";".$designation.";".$famille.";".$sup.";\n");
	}
close (FIL1);
}
open(FILE,"/home/intranet/cgi-bin/prod-a-mettre-a-jour.txt");
@tab=<FILE>;
if ($dernier >$#tab) {$dernier=$#tab;}
if ($premier <0) {$premier=0;}



if ($premier!=0){
print "<a href=maj-produit.pl?premier=0&$dernier=";
print $gap-1;
print "><img src=http://intranet.dom/arrow_beg.gif border=0></a>";
print "<a href=maj-produit.pl?premier=";
print $premier-$gap;
print "&dernier=";
print $premier-1;
print "><img src=http://intranet.dom/arrow_prev.gif border=0></a>";
}
else{
print "<img src=http://intranet.dom/arrow_beg_dis.gif border=0><img src=http://intranet.dom/arrow_prev_dis.gif border=0>";
}

print $premier+1,"-",$dernier+1 ," de ",$#tab+1;
if ($dernier<$#tab){
print "<a href=maj-produit.pl?premier=";
print $dernier+1;
print "&dernier=";
print $dernier+$gap;
print "><img src=http://intranet.dom/arrow_next.gif border=0></a>";
print "<a href=maj-produit.pl?premier=";
print $#tab-($#tab%$gap);
print "&dernier=";
print $#tab;
print "><img src=http://intranet.dom/arrow_end.gif border=0></a>";
}
else {
print "<img src=http://intranet.dom/arrow_next_dis.gif border=0><img src=http://intranet.dom/arrow_end_dis.gif border=0>";
}


print "<table border=1 width=100% cellspacing=0>\n<form name=valide action=maj-produit.pl>";
print "<tr><td>Code produit</td><td>Désignation</td><td>Famille</td><td>A supprimer</td></tr>"; 
for ($i=$premier;$i<=$dernier;$i++){
        # print "<tr><td>**$_**</td></tr>";	
        if ($tab[$i] ne " "){
	($code,$designation,$famille,$sup)=split (/;/,$tab[$i]);
	if ($sup eq "on"){
		$color="red";}
	else {
		$color="black";}
	print "<tr><td><font color=$color>$code</td>
	<td><font color=$color>$designation</td>
	<td><font color=$color>$famille</td>";
	print "<td align=center><input type=checkbox name=cs$i ";
        if ($sup eq "on"){print "checked";}
        print "></td></tr>";
        
	}
}

print "</table>";
print "<input type=hidden name=modif value=ok";
print ">\n";
print "<input type=hidden name=premier value=";
print $premier;
print ">\n";
print "<input type=hidden name=dernier value=";
print $dernier;
print ">\n";
print "<input type=hidden name=nb_element value=";
print $#tab;
print ">\n";
if ($premier!=0){
print "<a href=maj-produit.pl?premier=0&$dernier=";
print $gap-1;
print "><img src=http://intranet.dom/arrow_beg.gif border=0></a>";
print "<a href=maj-produit.pl?premier=";
print $premier-$gap;
print "&dernier=";
print $premier-1;
print "><img src=http://intranet.dom/arrow_prev.gif border=0></a>";
}
else{
print "<img src=http://intranet.dom/arrow_beg_dis.gif border=0><img src=http://intranet.dom/arrow_prev_dis.gif border=0>";
}

print $premier+1,"-",$dernier+1 ," de ",$#tab+1;
if ($dernier<$#tab){
print "<a href=maj-produit.pl?premier=";
print $dernier+1;
print "&dernier=";
print $dernier+$gap;
print "><img src=http://intranet.dom/arrow_next.gif border=0></a>";
print "<a href=maj-produit.pl?premier=";
print $#tab-($#tab%$gap);
print "&dernier=";
print $#tab;
print "><img src=http://intranet.dom/arrow_end.gif border=0></a>";
}
else {
print "<img src=http://intranet.dom/arrow_next_dis.gif border=0><img src=http://intranet.dom/arrow_end_dis.gif border=0>";
}

print "<br><center><input type=submit value=valider>";
print "</form></body></html>";
# -E Mise a jour du fichier produit
