#!/usr/bin/perl
require "../oasix/outils_perl2.pl";
require "outils_dutyfree.pl";

use CGI;
use DBI();
use HTML::Entities;
use Encode;
# use CGI qw/:standard/;
# use warnings;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;
use Digest::MD5 qw(md5);
use PDF::API2;

$html=new CGI;
print $html->header();
# print "<title>academie tempsdanse</title>";
$ip =$ENV{"REMOTE_ADDR"};
$server_name=$ENV{"SERVER_NAME"};
$user=$ENV{"REMOTE_USER"};
$onglet=$html->param("onglet");
$sous_onglet=$html->param("sous_onglet");
$sous_sous_onglet=$html->param("sous_sous_onglet");
$onglet=~s/'//g;
$sous_onglet=~s/'//g;
$sous_sous_onglet=~s/'//g;

$module=$html->param("module");
$action=$html->param("action");
$mess_index=$html->param("mess_index");
$admin=0;
if (($user eq "sylvain")||($user eq "daniel")){$admin=1;}
require("../oasix/jquery_marron.pl");
print "
<style type=\"text/css\">
#saut { page-break-after : right }         
	.marque
	{
		background-color:#efefef;
		font-size:1.2em;
	}
	.categorie
	{
		font-size:1.1em;
	}
	.designation
	{
		font-weight:bold;
	}

	.ligne_produit
	{
		clear:both;
		height:40px;
		border-top:1px solid gray;
		border-bottom:1px solid gray;
		padding_bottom:2px;
	
	}
	.code
	{
		float:left;
		width:100px;
	}
	.sous_categorie
	{
		float:left;
		width:150px;
	}
	.prix
	{
		float:left;
		width:100px;
		font-weight:bold;
		text-align:right;
	}
	.contenance
	{
		float:left;
		width:150px;
	}
	.flacon_degree
	{
		float:left;
		width:150px;
	}
	.modifier
	{
		background-image:url('/images/b_edit.png');
		background-repeat:no-repeat;
		border:0;
		cursor:pointer;
	}
	.supprimer
	{
		background-image:url('/images/b_drop.png');
		background-repeat:no-repeat;
		border:0;
		cursor:pointer;
	}
	.lienprod:hover
	{
		background-color:#5580AB;
	}
	.lienprod:link
	{
	  color:black;
	  text-decoration:none;
	}
	.lienprod:visited
	{
	  color:black;
	  text-decoration:none;
	}
	input[type=\"submit\"]{
	  cursor:pointer;
	  border-radius:3px;
	}
	input[type=\"submit\"]:hover{
	  background-color:yellow;
	  }
	.astuce
	{
	  position:absolute;
	  top:200px;
	  left:50px;
	  width:300px;
	  height:100px;
	  background-color:lightblue;
	  margin:5px;
	  padding:2px;
	  border:1px dashed black;
	 }

</style>";


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
$admin=1;
$date_du_jour=&get("select curdate()");
if ($user ne "sylvain"){
	# print "insert ignore into trace_click value (curdate(),'$onglet','$sous_onglet','$sous_sous_onglet')";
	      $sous_onglet_trace=$sous_onglet;
	      $sous_sous_onglet_trace=$sous_sous_onglet;
		if ($sous_onglet eq ""){$sous_onglet_trace=-1;}
		if ($sous_sous_onglet eq ""){$sous_sous_onglet_trace=-1;}
		&save("insert ignore into trace_click value ('$user',now(),'$onglet','$sous_onglet_trace','$sous_sous_onglet_trace')","af");
}
foreach (@data)
{
	if ((grep (/#/,$_)) && ($admin==0)){next;}
	$_=~s/ #//;
	if (! grep (/^\t/,$_)){$index++;}
	if (($index == $onglet) && (grep (/^\t/,$_))&&(! grep (/^\t\t/,$_))){
		$sous_index++;
		if ($sous_onglet eq ""){
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index>$_ </a>";
			$pop=&get("select pop from menu where onglet='$onglet' and sous_onglet='$sous_index' and sous_sous_onglet='-1'");
			if ($pop >10){print "<img src=\"/kit/images/etoile.jpg\">";}
			if ($pop >100){print "<img src=\"/kit/images/etoile.jpg\">";}
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
					$ancien_mod=$mod;
					if (!grep /http/,$mod){
						if (grep /\.pl/,$mod){
							$ancien_mod="http://$server_name/cgi-bin/".$mod;
						}
						else{
							$ancien_mod="http://$server_name/".$mod;
						}
				        }
				}		
				else{$module=$mod;$ancien_mod="";}
			}
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			$pop=0;
			# $pop=&get("select pop from menu where onglet='$onglet' and sous_onglet='$sous_index' and sous_sous_onglet='$sous_sous_index'");
			if (($pop==-1)||($pop eq "")) {print "<span style=color:#efefef>$desi</span>";}
			else
			{
				print "<a href=?onglet=$onglet&sous_onglet=$sous_index&sous_sous_onglet=$sous_sous_index>$desi </a>";
			}
			if ($pop >10){print "<img src=\"/kit/images/etoile.jpg\">";}
			if ($pop >100){print "<img src=\"/kit/images/etoile.jpg\">";}
			print "</td></tr><tr><td><img src=\"/kit/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";

		}

	}
}
# if ($admin ==1){
# 	$param=$ENV{"QUERY_STRING"};
# 	$param=~s/mark\.pl?//;
# 	print "<tr><td><br><br><br><a href=mark.pl?".$param."&mark=push><img src=\"/images/push.png\" width=\"40\" height=40 border=0 alt=\"marquer cette page\"></a><br><a href=mark.pl alt=p><img src=\"/images/pop.png\" width=\"40\" height=40 border=0 alt=\"revenir a la page marquee\"></a></td></tr>";
# }
print "<tr><td><br><br><br><img src=\"/images/post_it.jpg\" width=\"40\" height=40 border=0 alt=\"Indiquer un probleme\" onclick=window.open(\"http://www.dutyfreeambassade.com/cgi-bin/post_it.pl\",\"_blank\",\"width=250,height=280,left=500\")><img src=\"/images/printer.jpg\" width=\"40\" height=40 border=0 alt=\"Imprimer\" onclick=window.print()></td></tr>";

open(FIC,"./src/html_part2_2.src");
while (<FIC>){print;}	        
close(FIC);
chop ($module);
if (($module ne "")&&($ancien_mod eq "")) {
print "<title>$module</title>";	
	require ($module);
}
if ($ancien_mod ne "") {
	 # print "<center><a href=$ancien_mod target=\"$ancien_mod\" onclick=\"window.open('popup.htm','$ancien_mod','width=800,height=600,toolbar=yes,location=yes,directories=yes,status=yes,adress=yess,scrollbars=yes,left=20,top=30')\">$ancien_mod</a>";
	  print "<center><a href=$ancien_mod target=_blank>$ancien_mod</a>";
	  print "<title>$ancien_mod</title>";

}
# print "*$user**";
if (($onglet eq "")&&($sous_onglet eq "")){ 
# uire ("./src/acces_rapide.src");
}

#if (($onglet eq "")&&($sous_onglet eq "")){ 
# require ("./src/accueil.src");}
open(FIC,"./src/html_part3.src");
while (<FIC>){print;}	        
close(FIC);

__DATA__
Fichier
	Produit
		Consultation;fiche_produit_kit.pl
		Inventaire parfum;inv_parf_kit.pl
		Inventaire cosmetique;inv_cosmetique_kit.pl
		Inventaire alcool;inv_alc_kit.pl
		Inventaire T1;inv_t1_kit.pl
		Inventaire alcool en RS;inv_alc_rs_kit.pl
		Inventaire vin;inv_vin_kit.pl
		Inventaire autre;inv_aut_kit.pl
		Inventaire gastronomie;inv_gastro_kit.pl
		Inventaire accessoire;inv_access_kit.pl
		Inventaire bijouterie;inv_bijou_kit.pl
		Inventaire cigarette;inv_cig_kit.pl
		Inventaire tabac;inv_tab_kit.pl
		Code libre;code_libre_kit.pl
		Produit Ibs Fly;fiche_produit_ibs_kit.pl
		Produit divalto;fiche_produit_div_kit.pl
		A creer;acree_kit.pl
		Prix achat;tarif_prac_kit.pl
		Valeur comptable;valeur_comptable_kit.pl
		Ecart;gere_ecart_kit.pl
	Fournisseur
		Consultation;fiche_four_kit.pl
		Stock alerte;stock_alerte_kit.pl;1
		Commande;commande_kit.pl
		Maj prac;maj_prac_kit.pl
		Liste;liste_categorie_kit.pl
		Mailing;mailing_four_kit.pl
		Facture;facture_four_kit.pl
		Selection pour stock alerte;selection_four_kit.pl
	Douane
		Inventaire;dcg_kit.pl
		Déclaration Dcg;dcgnew2_kit.pl
		verification;dcg_verif_kit.pl
		Dae;import_dae_kit.pl
		Dae html;import_daehtml_kit.pl
		Compare;compare_dae_kit.pl
		Compare liste;compare_dael_kit.pl
		Compta matiere produit;compta_matiere_kit.pl
		Compta matiere 2;compta_matiere2_kit.pl
		Compta matiere full;compta_matiere_full_kit.pl
		Verif enso;verif_enso_kit.pl
		dae->cde;dae_cde_kit.pl
		annule dae;annule_dae_kit.pl
		Compta matiere dae;compta_matiere_dae_kit.pl
		Verif entree;verif_entree_kit.pl
		Verif sortie;verif_sortie_kit.pl
		Chapitre douane;fiche_chapitre_kit.pl
	Client 
		Fiche client;fiche_client_kit.pl
		Mailing;gestion_mailing_kit.pl
		Envoi Mailing;mailing_client_kit.pl
		Facture;facture_client_kit.pl
		Mail;fiche_mail_kit.pl
	Famille
		Gestion;fiche_famille_kit.pl
	Facture
		Gestion;facture_kit.pl
		Impression;edite_facture_kit.pl
	Franchise
		Gestion;franchise_kit.pl
		Saisie;saisie_franchise_kit.pl
		Groupement;group_franchise_kit.pl
		Imputation;imputation_kit.pl
		Imputation liste;imputation_liste_kit.pl
	Liste
		Gestion;in_liste_kit.pl
	Tarif
		Traif A B C D;tarif_speciaux.pl;1
	Mag	
		Mag;mag_kit.pl
		Catalogue format csv;cata_csv.pl;1
		Catalogue format excel;cata_excel_kit.pl
		Catalogue format pdf;cata_pdf_kit.pl
	Statistique	
		Statistique;statistique_kit.pl
	Devise
		Devise;devise_kit.pl
Achat
	Commande
		Commande;commande_kit.pl
	Stock alerte
		stock alerte;stock_alerte_kit.pl
		stock alertedev;stock_alerte_dev_kit.pl
	En_cours
		en_cours;en_cours_kit.pl
	Suivi fournisseur
		suivi fournisseur;suivi_four_kit.pl
	Historique entree
		Historique;histo_entree_kit.pl
	Chiffre d'affaire
		Ca;ca_kit.pl
		Ca achat;ca_achat_kit.pl
Depart
	Camion
		Camion;camion_kit.pl
		Preparation;preparation_kit.pl
Retour
	Saisie
		Saisie;saiapp.php;1
		Tpe;import_oasix_kit.pl
	Avis de retour
		Avis de retour;avisret.pl;1
		Liste des retours;info_ret_kit.pl
Commande
	Edition
		Liste;liste_commande_kit.pl
		Franco;liste_commande_franco_kit.pl
		Dev;liste_commande_dev.pl
		Impression;impression_cde_kit.pl
		Reserver;reserve_cde_kit.pl
	En attente
		Liste;cde_attente_kit.pl
Autres
	mail
		mail;mail_kit.pl
	saisie
		cata;cata_kit.pl
		gaefers;saisie_kit.pl
	etiquette
		etiquette;etiquettage_kit.pl
	admin
		message;fiche_message_kit.pl
		log;error_log_kit.pl
		recherche;grep_kit.pl
		batch;batch_kit.pl
