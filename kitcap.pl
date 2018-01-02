#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
require "../oasix/../oasix/outils_corsica.pl";

use CGI;
use DBI();
$html=new CGI;
print $html->header();
print "<title>oasix cap</title>";
$ip =$ENV{"REMOTE_ADDR"};
$server_name=$ENV{"SERVER_NAME"};
$onglet=$html->param("onglet");
$sous_onglet=$html->param("sous_onglet");
$sous_sous_onglet=$html->param("sous_sous_onglet");
$module=$html->param("module");
$action=$html->param("action");
$mess_index=$html->param("mess_index");

print "<script>
function verif(message,lien){
	if (confirm(message)){document.location.href=lien;}
}
</script>";

@data=<DATA>;
open(FIC,"./src/html_part1_af.src");
while (<FIC>){print;}	        
close(FIC);
require("./src/onglet.src");
open(FIC,"./src/html_part2_1.src");
while (<FIC>){print;}	        
close(FIC);
# menu gauche
$index=-1;
$sous_index=-1;
$sous_sous_index=-1;
require("./src/connect.src");
if ($action eq "mess_lu"){
	&save("update message set mes_lu=1 where mes_index=$mess_index","af");
}

$query="select * from message where mes_fin>=now() and mes_lu!=1 and (mes_dest='sylvain'or mes_dest='carole' or mes_dest='marie') order by mes_dest";
$sth=$dbh->prepare($query);
if ($sth->execute()>0){
print "<div class=message>";
	while (($mess_index,$mess_src,$mess_dest,$mess_date,$mess_message)=$sth->fetchrow_array)
	{
		print "de la part de <b>$mess_src</b> pour <b>$mess_dest</b><br>";
		print "Date de validite:$mess_date<br>";
		print "$mess_message <br> <a href=?action=mess_lu&mess_index='$mess_index'&onglet=0&sous_onglet=0&sous_sous_onglet=0>lu</a>";
	}
 print "</div>";
}
$sth->finish;
require "./src/connect.src";

foreach (@data)
{
	if (! grep (/^\t/,$_)){$index++;}
	if (($index == $onglet) && (grep (/^\t/,$_))&&(! grep (/^\t\t/,$_))){
		$sous_index++;
		if ($sous_onglet eq ""){
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index>$_</a>";
			print "</td></tr><tr><td><img src=\"/kit/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";
		}
        }
        if ($sous_onglet ne ""){
		if (($index == $onglet) && ($sous_index == $sous_onglet) &&( grep (/^\t\t/,$_))){
			$sous_sous_index++;
			($desi,$mod,$option)=split(/;/,$_);
			if (($sous_sous_index==0)||($sous_sous_index==$sous_sous_onglet)){
				# print "*$sous_sous_index*$sous_sous_onglet*$_*$option";
				if ($option==1){
					$ancien=$mod;
					if (!grep /http/,$mod){
						if (grep /\.pl/,$mod){
							$ancien="http://$server_name/cgi-bin/".$mod;
						}
						else{
							$ancien="http://$server_name/".$mod;
						}
				        }
				}		
				else{$module=$mod;$ancien="";}
			}
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index&sous_sous_onglet=$sous_sous_index>$desi</a>";
			print "</td></tr><tr><td><img src=\"/kit/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";

		}

	}
}
open(FIC,"./src/html_part2_2.src");
while (<FIC>){print;}	        
close(FIC);
chop ($module);
if (($module ne "")&&($ancien eq "")) {
require ($module);}
if ($ancien ne "") {
	 # print "<center><a href=$ancien target=\"$ancien\" onclick=\"window.open('popup.htm','$ancien','width=800,height=600,toolbar=yes,location=yes,directories=yes,status=yes,adress=yess,scrollbars=yes,left=20,top=30')\">$ancien</a>";
	  print "<center><a href=$ancien target=_blank>$ancien</a>";
	  print "<title>$ancien</title>";

}
if (($onglet eq "")&&($sous_onglet eq "")){ 
# uire ("./src/acces_rapide.src");
}
if (($onglet eq "")&&($sous_onglet eq "")){ 
$dernier=&get("select max(oa_date_import) from oasix");
print "<center>Date du dernier déchargement front-office:$dernier</center>";
require ("./src/accueil.src");}

open(FIC,"./src/html_part3.src");
while (<FIC>){print;}	        
close(FIC);
__DATA__
Fichier
	Produit
		Consultation;fiche_produit_kit.pl
	Trolley
		Gestion des lots;lot.pl;1
		Trolley type;gestrolley_kit.pl
		Ordre;fiche_ordre.pl;1
	Admin
		Debug;debug_appro.pl;1
		Affectation d une tpe;import-oasix-cor.pl;1
		Tpe virtuel;virtuel.pl;1
		Suppression d'un bon;sup_appro.pl;1
Planning
	Consultation
		Consultation;planningfly_kit.pl
	Importation
		Importation;snif_aero_excel.pl
Caisse
	Etat
		CA par vol;recap.pl;1
		CA par famille;recapcafamille.pl;1
		CA par produit;recappdp.pl;1
		Demarque;recapdemarque.pl;1 
		Detail;dumptpe.pl;1
		Gratuité;recapgratuite.pl;1
Retour
	Saisie
		Saisie;saiapp.php;1
		Tpe;import_oasix_kit.pl
-----
-----
