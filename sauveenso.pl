#!/usr/bin/perl    
use CGI;   
use File::Copy;
 
$html=new CGI; 
require 'manip_table.lib';                   
require 'outils_perl.lib';
print $html->header;
print "<h1>LISTING DOUANE</h1>";
$bug=0;
$an_encours=`/bin/date +%Y`; 
chop($an_encours);
# $an_encours--;
if ($html->param("copie") eq "on"){
	&datemodif("/home/var/spool/uucppublic/enso.txt");
	if ($mois <10){$mois="0".$mois;}
	$annee=substr($annee,2,2);
	$enso="enso$annee$mois$jour.txt";
	if (!copy("/home/var/spool/uucppublic/enso.txt","/home/var/spool/uucppublic/douane/$an_encours/$enso"))
	{$bug=1;}
	chmod (444,"/home/var/spool/uucppublic/douane/$an_encours/$enso");
	
	&datemodif("/home/var/spool/uucppublic/suspen.txt");
	if ($mois <10){$mois="0".$mois;}
	$annee=substr($annee,2,2);
	$suspen="suspen$annee$mois$jour.txt";
	if (!copy("/home/var/spool/uucppublic/suspen.txt","/home/var/spool/uucppublic/douane/$an_encours/$suspen"))
	{$bug=1;}
	chmod (444,"/home/var/spool/uucppublic/douane/$an_encours/$suspen");
	
	&datemodif("/home/var/spool/uucppublic/produit.txt");
	if ($mois <10){$mois="0".$mois;}
	$annee=substr($annee,2,2);
	$produit="produit$annee$mois$jour.txt";
	if (!copy("/home/var/spool/uucppublic/produit.txt","/home/var/spool/uucppublic/douane/$an_encours/$produit"))
	{$bug=1;}
	chmod (444,"/home/var/spool/uucppublic/douane/$an_encours/$produit");
	
	&datemodif("/home/var/spool/uucppublic/douable.txt");
	if ($mois <10){$mois="0".$mois;}
	$annee=substr($annee,2,2);
	$douable="douable$annee$mois$jour.txt";
	if (!copy("/home/var/spool/uucppublic/douable.txt","/home/var/spool/uucppublic/douane/$an_encours/$douable"))
	{$bug=1;}
	chmod (444,"/home/var/spool/uucppublic/douane/$an_encours/$douable");
	
	if ($bug==0) {print "<br><b>SAUVEGARDE DES FICHIERS EFFECTUEES</b><br><br>";}
	else{
		print "<font color=red>Erreur dans la copie: Copie existante ou demande non autorisee</font><br>";
		$suspen=$enso=0;
	}
print "<br><br><br>";
}

@liste=stat("/home/var/spool/uucppublic/enso.txt");
($disque,$inode,$droits,$liens,$user,$group,$null,$taille,$acces,$mod,$modinode,$block,$nbblock)=stat("/home/var/spool/uucppublic/enso.txt");
print "<font size=+1><b>Fichiers actuels:</b><br><br>";

print "Fichier mouvement :";
print &datemodif("/home/var/spool/uucppublic/suspen.txt"),"<br>";

print "Fichier des produits sous-douane :";
print &datemodif("/home/var/spool/uucppublic/enso.txt"),"<br>";

opendir (DIR,"/home/var/spool/uucppublic/douane/$an_encours");
while ($fichier= readdir(DIR)){
	if ($fichier=~/^\./){next;}
	push (@rep,$fichier);
}

print "</font><br>";
print "<a href=declaration-accise.pl>Declaration mensuelle accise</a><br>";
print "<a href=declaration-douane.pl>Declaration mensuelle douane</a><br>";
print "<a href=declaration-biere.pl>Declaration mensuelle accise et douane biere</a><br>";
print "<a href=declaration-vin.pl>Declaration mensuelle vin</a><br>";
print "<a href=compta-matiere.pl>Listing douane accise</a><br>";
print "<a href=compta-matiere-vin.pl>Listing douane vin</a><br>";
print "<a href=compta-matiere-biere.pl>Listing douane biere</a><br><br><br>";
print "<a href=inventaire-fiscal.pl>inventaire entrepôt fiscal</a><br>";


# print "</td><td><form action=compta-matiere-vin.pl><input type=submit value=\"Listing douane vin\"></form></td>";
# print "</td><td><form action=suspension-biere.pl><input type=submit value=\"Declaration mensuelle Bière\"></form></td></tr></table>";
# print "</tr></table>";
print "<br><hr><b>Liste des sauvegardes:</b><br><br>";




foreach (sort(@rep)){
	$premier=substr($_,0,2);
	if ($tampon eq ""){$tampon=$premier;}
	
	if ($premier ne $tampon){
		print "<br>";
		$tampon=$premier;
	}
	if (($_ eq $enso)||($_ eq $suspen) || ($_ eq $produit) || ($_ eq $douable)){print "<font color=red>$_ :</font>";}
	else {print "$_ :";}
	
	print &datemodif("/home/var/spool/uucppublic/douane/$an_encours/$_"),"<br>";
}

print "<hr><br>
<form name=sauve action=sauveenso.pl>
<input type=hidden name=copie value=on>
<input type=submit value=\"Cliquez-ici pour faire une sauvegarde des fichiers actuels\">
</form>
";



sub datemodif
{
@liste=stat("$_[0]");
($disque,$inode,$droits,$liens,$user,$group,$null,$taille,$acces,$mod,$modinode,$block,$nbblock)=stat("$_[0]");
($seconde,$minute,$heure,$jour,$mois,$annee,$jour_de_la_semaine,$jour_de_l_annee,$ete) = localtime($mod);     
$annee="20".substr($annee,1,2); 
$mois+=1; 
$jour+=1000; 
#$mois=substr($mois,2,2);
$desimois=&cal($mois); 
$jour=substr($jour,2,2); 
return("<Font color=navy><i>$jour $desimois $annee</i></font>");
}
