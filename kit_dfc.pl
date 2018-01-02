#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
require "../oasix/../oasix/outils_corsica.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
$ip =$ENV{"REMOTE_ADDR"};
$server_name=$ENV{"SERVER_NAME"};
$user=$ENV{"REMOTE_USER"};
$query_string=$ENV{"QUERY_STRING"};
$CGI::LIST_CONTEXT_WARN=0;
$onglet=$html->param("onglet");
$sous_onglet=$html->param("sous_onglet");
$sous_sous_onglet=$html->param("sous_sous_onglet");
$module=$html->param("module");
$action=$html->param("action");
$iframe=$html->param("iframe");
$mess_index=$html->param("mess_index");
require("../oasix/jquery_marron.pl");
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
	if (grep (/#/,$_)){next;}
	if (! grep (/^\t/,$_)){$index++;}
	if (($index == $onglet) && (grep (/^\t/,$_))&&(! grep (/^\t\t/,$_))){
		$sous_index++;
		if ($sous_onglet eq ""){
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			$prg=$_;
			while($prg=~s/\t//){};
			while($prg=~s/\n//){};
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
print "<tr><td><br><br><br>";
# <form>";
# @arg=$html->param;
# foreach (@arg){
  # if ($_ eq "iframe"){next;}
  # print "<input type=hidden name=$_ value=";
  # print scalar $html->param("$_");
  # print ">";
# }
# print "<input type=texte name=iframe> <input type=submit value=incruste>";
# print "</form>";
# print "<form action=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?$ENV{'QUERY_STRING'}><input type=submit ></form>";
print "<a href=# onclick=\"window.open('message.pl?action=go&adresse=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?$ENV{'QUERY_STRING'}','wclose','width=580,height=350,toolbar=no,status=no,left=20,top=30')\" style=color:black>bug</a>";
	  
open(FIC,"./src/html_part2_2.src");
while (<FIC>){print;}	        
close(FIC);
chop ($module);
if (($module ne "")&&($ancien eq "")) {
print "<title>$module</title>";	
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
print "<ul>";
print "<li><a href=http://togo.oasix.fr target=_blank>Togo</a></li>";
print "<li><a href=http://camairco.oasix.fr target=_blank>Cameroun</a></li>"; 
print "<li><a href=http://aircotedivoire.oasix.fr target=_blank>Cote d'ivoire</a></li>"; 
print "<li><a href=http://tacv.oasix.fr target=_blank>Cap vert</a></li>"; 
print "<li><a href=http://dfca.oasix.fr target=_blank>Corsica</a></li>"; 
print "<li><a href=http://cameshop.oasix.fr target=_blank>Boutique Cameroun</a></li>"; 
print "<li><a href=http://aircotedivoireshop.oasix.fr/ target=_blank>Boutique en ligne Cote d'ivoire</a></li>"; 
print "<li><a href=http://www.dutyfreeambassade.com target=_blank>Boutique en ligne Duty Free Ambassade</a></li>"; 
print "<li><a href=http://www.dutyfreeambassade.com/cgi-bin/kit.pl target=_blank>Duty Free Ambassade</a></li>"; 

print "</ul>";
	print "<div style=text-align:left><pre>";
	foreach (@data){
		print $_;
	}
	print "</pre></div>";

}
open(FIC,"./src/html_part3.src");
while (<FIC>){print;}	        
close(FIC);
if ($iframe ne ""){
  print "<iframe src=http://$iframe width=100% height=400 style=position:fixed;top:450px;></iframe> ";
}
__DATA__
Fichier
	Produit
		Consultation;fiche_produit_kit_dfc.pl
		Referencement;referencement_kit.pl
		Expertise;expertise_kit.pl
		Valeur;valeur_base_kit.pl
		Statistique;statvente_kit_dfc.pl
		Audit produit;audit_produit_kit.pl
		Famille;fiche_famille_kit.pl
		Stock mort;stock_mort_kit.pl
		Stat Stock;stat_stock_kit.pl
		Doublons;doublon_kit.pl
		Verification des prix achats;verif_prac_kit.pl
		Creation;nouveaute_kit_dfc.pl #
		Importation info;upload_info_excel.pl;1
		Importation prix;upload_prix_excel.pl;1
		Fiche;fiche_produit_com_kit.pl
		Ecart stock corsica;verif_mvt_kit.pl
	Fournisseur 
		Consultation;fiche_four_kit_dfc.pl
		Stock alerte;stock_alertenew.pl;1 #
		Commande;commande.pl;1 #
		Audit four;audit_four_kit.pl
		Mailing;mailing_four_kit.pl
		Facture distrimarq aerien;facture_distrimarq_kit.pl
		Facture distrimarq backwall;backwall_distrimarq_kit.pl
		Facture distrimarq Boutique;boutique_distrimarq_kit.pl #
	Trolley 
		Trolley actif;actif_trol_kit.pl
		Produit Commun;commun_trol_kit.pl
	Mag
		Facture;facture_kit_dfc.pl
		Ca pub;ca_facture_pub_kit.pl
	Devise
		Cours;devise_kit.pl
	Procedure
		Procedure;procedure_kit.pl
	Sephora
		Sephora;sephora_kit.pl
		Codification Sephora corse;codification_sephora_kit.pl
		Codification Sephora cameshop;codification_sephora2_kit.pl
		Ecart prix;ecart_sephora_kit.pl
		Ecart prix importation;upload_prix_vente.pl;1
	Faq
		faq;faq_kit.pl
Achat
	Commande #
		Commande;commande_kit.pl #
		Adresse Livraison;fiche_adresse_liv_kit.pl #
	Suivi fournisseur #
		suivi fournisseur;suivi_four_kit.pl #
	Commande	
		Document livraison;entree_kit.pl
		Commande;commande_kit_dfc.pl
		Statistique;stat_entree_dfc_kit.pl
		Lta;lta_kit.pl
		Cde à faire;cde_afaire_kit.pl
		Note de detail entree;nd_entree_kit.pl
		Facture Corsica;facture_corsica_kit.pl
		Suivi reglement Corsica;liste_facture_dfca.pl;1
		Debug;debug_cde_kit.pl
	Stock alerte 
		stock alerte;stock_alerte_kit.pl #
		daemon;fiche_daemon_dfc.pl
	Coef
		coef;import_liste_kit_dfc.pl
Compta 
	Compta
		Suivi des encaissements finaero;suivi_finaero_kit.pl
		Situation;situation_kit_dfc.pl
		Suivi tresorie;suivi_treso_kit.pl
		Suivi commande;suivi_commande_kit.pl
		Suivi exploitation corse;suivi_exploitation_corse_kit.pl
		Cut off facture;cut_off_facture_kit.pl
		Stock à date;valeur_stockcomptable_kit.pl
		Cut off 2015;cut_off_kit_2015.pl
		Rotation stock à date;rotation_stock_adate_kit.pl
		Etat stock de cloture;cut_off_kit.pl
		Liste facture;liste_facture.pl;1
		Liste facture mensuelle;liste_facture_mens_kit.pl
		Trésorerie;tresorerie_kit_dfc.pl
		Liste facture corsica;liste_facture_corsica_kit.pl
		Sit;sit_kit.pl
		Ca DFA;suivi_exploitation_dfa_kit.pl
		Suivi des encaissements;suivi_encaissement_v1_kit.pl
Vente
	CA Aerien
		Ca moyen;ca_moyen_kit.pl
		Ca moyen semaine;ca_moyen2_kit.pl
		Ca versus manquant;ca_moyen_manquant_kit.pl
	Statistique	
		Vente;stat_sortie_dfc_kit.pl
Admin
	Mot de passe
		mdp;lienmdp_kit.pl
	Recherche source
		recherche;grep_kit.pl
	Log	
		log;error_log_kit.pl
	Integrite	
		integrite cde;integrite_cde_kit.pl
	Describe	
		describe;describe_kit.pl
		form;from_kit.pl
	Bascule 
		bascule produit;switch_kit_dfc.pl
		bascule commande;switch_cde_kit_dfc.pl
	Copier coller
		copier;copier-coller_kit.pl
	Iteration
		iteration;iteration_kit.pl
	Requete sql
		requete;requete_sql_kit.pl
----
	faq
	Syncronisation des bases #
		Syncro;syncro_kit.pl #
