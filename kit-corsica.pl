#!/usr/bin/perl
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

use CGI;
use DBI();
$html=new CGI;
$ip = $ENV{"REMOTE_ADDR"};
print $html->header;
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
open(FIC,"../public_html/kit-corsica/html_part1_af.src");
while (<FIC>){print;}	        
close(FIC);
require("onglet.src");
open(FIC,"../public_html/kit-corsica/html_part2_1.src");
while (<FIC>){print;}	        
close(FIC);
# menu gauche
$index=-1;
$sous_index=-1;
$sous_sous_index=-1;
require "./src/connect.src";
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
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit-corsica/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index>$_</a>";
			print "</td></tr><tr><td><img src=\"/kit-corsica/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";
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
							$ancien="".$mod;
						}
						else{
							$ancien="http://ibs.oasix.fr/".$mod;
						}
				        }
				}		
				else{$module=$mod;$ancien="";}
			}
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit-corsica/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index&sous_sous_onglet=$sous_sous_index>$desi </a>";
			print "</td></tr><tr><td><img src=\"/kit-corsica/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";

		}

	}
}
open(FIC,"../public_html/kit-corsica/html_part2_2.src");
while (<FIC>){print;}	        
close(FIC);
chop ($module);
if (($module ne "")&&($ancien eq "")) {
require ($module);}
if ($ancien ne "") {
	 # print "<center><a href=$ancien target=\"$ancien\" onclick=\"window.open('popup.htm','$ancien','width=800,height=600,toolbar=yes,location=yes,directories=yes,status=yes,adress=yess,scrollbars=yes,left=20,top=30')\">$ancien</a>";
	  ($ancien,$info)=split(/,/,$ancien);
	  print "<center><a href=$ancien target=_blank>$ancien</a><br>$info";
	  print "<title>$ancien</title>";

}
if (($onglet eq "")&&($sous_onglet eq "")){ 
require ("acces_rapide_cor.src");
}
if (($onglet eq "")&&($sous_onglet eq "")){ print "<title>oasix</title>";require ("accueil.src");}

open(FIC,"../public_html/kit-corsica/html_part3.src");
while (<FIC>){print;}	        
close(FIC);
__DATA__
Fichier
	Produit
		Consultation;fiche_produit_kit.pl
		Inventaire;inv.php;1
		Testeur;inventaire_testeur.pl;1
		Rangement;ordre_inventaire_kit.pl
		Trace ecart;trace_ecart_kit.pl
		Consultation;fiche_client.pl;1
		Listing prix;listing_prix.pl;1
		Ranking produit mensuel;ranking_mois.pl;1
		Listing des produits à bord par bateau;listing_navirenew.pl;1
		Mouvement produit;http://ibs.oasix.fr/cgi-bin/mouvement_corsica.pl;1
		Marge 2008;http://ibs.oasix.fr/cgi-bin/corsica_marge2008.pl;1
		Marge 2009;http://ibs.oasix.fr/cgi-bin/corsica_marge2009.pl;1
		Surtock;http://ibs.oasix.fr/cgi-bin/surstock.pl;1
	Fournisseur
		Consultation;fiche_fournisseur.pl;1
		Stock alerte;stock_alertenew.pl;1
		Commande;commande.pl;1
	Administration
		Tableau de bord;tableau_de_bord.pl;1
		Sql navire;http://ibs.oasix.fr/cgi-bin/sql_navire.pl;1
Planning
	Horaire
		Consultation;horaire_corsica.pl;1
	Calendrier Arret reprise
		Consultation;arret_reprise.pl;1
	Gestion des coefs
		Coef;http://ibs.oasix.fr/cgi-bin/gere_semaine.pl;1
Achat
	Commande
		Commande;commande.pl;1
	stock alerte
		stock alerte;stock_alertenew.pl;1
	suivi fournisseur
		suivi fournisseur;suivi_four_kit.pl
	historique entrée
		Historique;histo_entree_kit.pl
	tva
		tva italienne;corsica_tva.pl;1
		tva italienne consommation;corsica_tva_consommation.pl;1
		tva française;corsica_tva_f.pl;1
Depart
	Commande
		Saisie;commande_client.pl;1
		Besoin navire;historique_navire_new.pl;1
		Creation;corsica.pl;1
		Camion;camion.pl;1
	mail	
		Avis navire;http://192.168.1.4/cgi-bin/avis_navire.pl;1
Importation
	Vendu
		Vendu pour tva;import-detail_tva.pl,import-detail_tvab.pl pour un fichier dans cgi-bin;1
		Vendu via tva;import-detail_vts.pl;1
		Vendu via cloture;import-detail_vts_oasix.pl;1
		Maj du fichier pour la marge;maj_vendu_viatva.pl;1
	Inventaire
		Inventaire douchette;import_inv_douche.pl;1
		Inventaire excel;import_inv_ecxel.pl;1
		Inventaire desarmement;import_inv_desarmement.pl;1
		Importation desarmement;import-desarmement.pl;1
	Horaire
		Horaire;import_horaire_corsica.pl;1
	Neptune
		Neptune;import-neptune2.pl;1
	Commande testeur
		Testeur;import-commande.pl;1	
Autres
	Messagerie
		Messagerie;messagerie.pl;1
	Google
		Google;http://www.google.fr;1
	Ancien menu
		Ancien menu;../menu_corsica.html;1		