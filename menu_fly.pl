#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";

print $html->header;
require "./src/connect.src";
$action=$html->param('action');
$index=$html->param('index');

if ($action eq "lu"){
	&save("update message set mes_lu=1 where mes_index=$index");
}

print "<html>
<head>
<meta http-equiv=\"Pragma\" content=\"no-cache\">
<style>
<!--
A:hover {  text-decoration: none ;color:#FF6600}
.popper
{
position : absolute;
visibility : hidden;
}
//-->
</style>
</head>


<body background=http://ibs.oasix.fr/kenzo.jpg link=navy>
<DIV ID=\"topdeck\" CLASS=\"popper\"> </DIV>
<SCRIPT>
var nav = (document.layers); 
var iex = (document.all);
var skn = (nav) ? document.topdeck : topdeck.style;
if (nav) document.captureEvents(Event.MOUSEMOVE);
document.onmousemove = get_mouse;

function pop(msg,bak) {
var content =\"<TABLE WIDTH=130 BORDER=0 CELLPADDING=2 CELLSPACING=0 BGCOLOR=#000080><TR><TD><TABLE WIDTH=100% BORDER=0 CELLPADDING=0 CELLSPACING=0><TR><TD><CENTER><FONT COLOR=#FFFFFF SIZE=2><B>Information</B></FONT></CENTER></TD></TR></TABLE><TABLE WIDTH=100% BORDER=0 CELLPADDING=2 CELLSPACING=0 BGCOLOR=\"+bak+\"><TR><TD><FONT COLOR=#000000 SIZE=2><CENTER>\"+msg+\"</CENTER></FONT></TD></TR></TABLE></TD></TR></TABLE>\";
if (nav) { 
skn.document.write(content); 
skn.document.close();
skn.visibility = \"visible\";
}
else if (iex) 
{
document.all(\"topdeck\").innerHTML = content;
skn.visibility = \"visible\";  
}
}

function get_mouse(e) 
{
var x = (nav) ? e.pageX : event.x+document.body.scrollLeft; 
var y = (nav) ? e.pageY : event.y+document.body.scrollTop;
skn.left = x - 60;
skn.top  = y+20;
}

function kill() 
{
skn.visibility = \"hidden\";
}
</SCRIPT>
<!-- <center><img src=http://ibs.oasix.fr/allez.jpg></center>  -->
<table border=0 width=800><tr><td width=40%><font size=+3 color=navy>Menu IBS FRANCE</font></td><td bgcolor=#efefef>";
	$query="select * from message where mes_fin>=now() and mes_lu!=1 and (mes_dest='sylvain'or mes_dest='carole' or mes_dest='marie') order by mes_dest";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($index,$src,$dest,$date,$message)=$sth->fetchrow_array)
	{
		print "<table border=1 cellspacing=0><tr bgcolor=lightblue><td>de la part de $src pour <b>$dest</b></td><td>Date de validite:$date</td></tr>";
		print "<tr><td><font color=red>$message</td><td><a href=?action=lu&index='$index'>lu</a></td></tr>";
		print "</table><br>";
	}
print "</td></tr></table><br>
<center><table border=3 bordercolor=navy cellspacing=10>
<tr><th  bgcolor=#efefef>Preparation VAB</th><th  bgcolor=#efefef>Client</th><th bgcolor=#efefef>Commande fournisseur</th><th bgcolor=#efefef>Logistique</th><th bgcolor=#efefef>Administration</th><th bgcolor=#efefef>Douanes</th></tr>
<tr><td bgcolor=#efefef><font size=+0>
<a href=http://ibs.oasix.fr/cgi-bin/avisret.pl onmouseover=\"pop('Edition de l avis de retour pour la douane','lightyellow')\"; onmouseout=\"kill()\">Avis de retour</a><br><br>

<a href=http://ibs.oasix.fr/saiapp.php onmouseover=\"pop('Saisie retour des bons d appro et consultation','lightyellow')\"; onmouseout=\"kill()\">Saisie des retours</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/planningfly.pl onmouseover=\"pop('Verification et saisie du planning','lightyellow')\"; onmouseout=\"kill()\">Gestion du planning</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/preparation.pl onmouseover=\"pop('Preparation des ventes à bord, creation des bon d appro,etiquette, avis de depart , saisie des écarts','lightyellow')\"; onmouseout=\"kill()\">Preparation</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/bordliv.pl onmouseover=\"pop('Bordereau de livraison et feuille de travail des pistes','lightyellow')\"; onmouseout=\"kill()\">Bordereau de livraison </a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/livraison.pl onmouseover=\"pop('Bordereau de livraison inouvelle formule','lightyellow')\"; onmouseout=\"kill()\">Bordereau de livraison <font color=red>new</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/pastouche.pl onmouseover=\"pop('Reafectation d un pas touche pour un client different','lightyellow')\"; onmouseout=\"kill()\">Pas touché </a><br><br>

</td>
<!-- client -->
<td bgcolor=#efefef><font size=+0>
<a href=http://ibs.oasix.fr/menu_corsica.html onmouseover=\"pop('Menu special corsica','lightyellow')\"; onmouseout=\"kill()\">Menu corsica</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/commande_client.pl onmouseover=\"pop('Creation des commandes clients, bon de livraison, facture','lightyellow')\"; onmouseout=\"kill()\">Gestion_des_commandes</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/equipage.pl onmouseover=\"pop('Saisie des equipages','lightyellow')\"; onmouseout=\"kill()\">Saisie des equipages</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/ventemini.pl onmouseover=\"pop('Edition des ventes de miniatures','lightyellow')\"; onmouseout=\"kill()\">Ventes miniatures</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/recap.pl onmouseover=\"pop('Recap de caisses','lightyellow')\"; onmouseout=\"kill()\">Recap de caisse</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/commission.pl onmouseover=\"pop('Edition des commissions ventes à bord','lightyellow')\"; onmouseout=\"kill()\">Commissions</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/meilleurs_caisse.pl onmouseover=\"pop('Edition des meilleurs caisses','lightyellow')\"; onmouseout=\"kill()\">Meilleurs caisses</a><br><br>

<a href=http://ibs.oasix.fr/cgi-bin/saiappauto.pl onmouseover=\"pop('Edition des bons d appro, écriture compta matière','lightyellow')\"; onmouseout=\"kill()\">Saiappauto</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/saicaisse.pl onmouseover=\"pop('Saisie des caisses','lightyellow')\"; onmouseout=\"kill()\">Saisie des caisses</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/mod_client_appro.pl onmouseover=\"pop('Modification du code client sur un vol','lightyellow')\"; onmouseout=\"kill()\">Modif code client</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/facture.pl onmouseover=\"pop('facture client','lightyellow')\"; onmouseout=\"kill()\">Facture client</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/saisie.pl onmouseover=\"pop('note de detail ','lightyellow')\"; onmouseout=\"kill()\">Note de detail</a><br><br>


</td>
<td bgcolor=#efefef><font size=+0>
<a href=http://ibs.oasix.fr/cgi-bin/commande.pl onmouseover=\"pop('Creation et gestion des commandes fournisseur, saisie des entrées','lightyellow')\"; onmouseout=\"kill()\">Commande</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/stock_alerte.pl onmouseover=\"pop('Gestion du stock','lightyellow')\"; onmouseout=\"kill()\">Stock alerte</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/statvente_fly2005.pl onmouseover=\"pop('Statistique de vente 2005','lightyellow')\"; onmouseout=\"kill()\">Statistique de vente 2005</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/statvente_fly2006.pl onmouseover=\"pop('Statistique de vente 2006','lightyellow')\"; onmouseout=\"kill()\">Statistique de vente 2006</a><br><br>
</td>

<td bgcolor=#efefef><font size=+0>
<a href=http://ibs.oasix.fr/inv.php onmouseover=\"pop('Stock d un produit','lightyellow')\"; onmouseout=\"kill()\">Inventaire</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/lot.pl onmouseover=\"pop('Gestion des lots, creation , saisie des plombs','lightyellow')\"; onmouseout=\"kill()\">Gestion des lots</a></br></br>
<a href=http://ibs.oasix.fr/cgi-bin/gestrolley.pl onmouseover=\"pop('Composition des trolleys types','lightyellow')\"; onmouseout=\"kill()\">Trolley type</a></br></br>
<a href=http://ibs.oasix.fr/cgi-bin/fiche_produit.pl onmouseover=\"pop('Gestion des produits, creation , modification','lightyellow')\"; onmouseout=\"kill()\">Gestion des produits</a></br></br>
<a href=http://ibs.oasix.fr/cgi-bin/fiche_fournisseur.pl onmouseover=\"pop('Gestion des fournisseurs, creation , modification','lightyellow')\"; onmouseout=\"kill()\">Gestion des fournisseurs</a></br></br>
<a href=http://ibs.oasix.fr/cgi-bin/fiche_hotesse.pl onmouseover=\"pop('Gestion des hotesse, creation , modification','lightyellow')\"; onmouseout=\"kill()\">Gestion_des_hotesses</a></br></br>
<a href=http://ibs.oasix.fr/cgi-bin/saiappautom.pl onmouseover=\"pop('Reedition des bons d appro pour la douane','lightyellow')\"; onmouseout=\"kill()\">Reedition Saiappauto</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/fiche_client.pl onmouseover=\"pop('Mise à jour des informations clients, commissions, adresses ..','lightyellow')\"; onmouseout=\"kill()\">Gestion des clients</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/bascule_stock.pl onmouseover=\"pop('Bascule d un stock navire vers un stock avion','lightyellow')\"; onmouseout=\"kill()\">Bascule de stock</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/debascule_stock.pl onmouseover=\"pop('Bascule d un stock avion vers un stock navire','lightyellow')\"; onmouseout=\"kill()\">Debascule de stock</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/valeur_stockcomptable.pl onmouseover=\"pop('valeur comptable du stock','lightyellow')\"; onmouseout=\"kill()\">Valeur du stock</a><br><br>
<a href=http://ibs.oasix.fr/dlv.html onmouseover=\"pop('etiquette dlv','lightyellow')\"; onmouseout=\"kill()\">etiquette dlv</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/formation.pl onmouseover=\"pop('Edition des bons d appro pour les formations','lightyellow')\"; onmouseout=\"kill()\">Formation</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/auxigaf_semhtml.pl onmouseover=\"pop('Inventaire auxiga ','lightyellow')\"; onmouseout=\"kill()\">auxiga</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/fiche_ordre.pl onmouseover=\"pop('Ordre des produits','lightyellow')\"; onmouseout=\"kill()\">Ordre des produits</a><br><br>

</td>

<td bgcolor=#efefef><font size=+0>
<a href=http://ibs.oasix.fr/cgi-bin/kit.pl onmouseover=\"pop('Nouveau menu','lightyellow')\"; onmouseout=\"kill()\">Nouveau menu <font color=red>new</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/messagerie.pl onmouseover=\"pop('Messagerie interne','lightyellow')\"; onmouseout=\"kill()\">Messagerie</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/integrite.pl onmouseover=\"pop('Verification de l intégrité des données','lightyellow')\"; onmouseout=\"kill()\">Integrite</a><br>
<a href=http://sql.dom/cgi-bin/myadmin2.pl?database=FLY&username=root&password=&host=192.168.1.87&sql_interface=Sql+Interface onmouseover=\"pop('Base de données','lightyellow')\"; onmouseout=\"kill()\">Sql</a><br>
<a href=http://ibs.oasix.fr/phpMyAdmin-2.9.1.1-all-languages/index.php>Sql php</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/errorlog.pl onmouseover=\"pop('debug','lightyellow')\"; onmouseout=\"kill()\">Debug</a><br>
<a href=http://192.168.1.83/cgi-bin/select.pl onmouseover=\"pop('','lightyellow')\"; onmouseout=\"kill()\">Select</a><br>
<a href=http://ibs.oasix.fr/sql.html onmouseover=\"pop('Archive requete sql','lightyellow')\"; onmouseout=\"kill()\">Archive sql</a><br>
<a href=http://ibs.oasix.fr/menu.html onmouseover=\"pop('Ancien menu','lightyellow')\"; onmouseout=\"kill()\">Menu</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/recapadmin.pl onmouseover=\"pop('Recap administrateur','lightyellow')\"; onmouseout=\"kill()\">Administration Recap de caisse</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/ls.pl?rep=/home/intranet/cgi-bin&option=short onmouseover=\"pop('liste des programmes perl','lightyellow')\"; onmouseout=\"kill()\">Programme perl</a><br>
<a href=http://ibs.oasix.fr/import-file-fly.php onmouseover=\"pop('importation d un fichier csv pour tout fichier sql','lightyellow')\"; onmouseout=\"kill()\">Importation d'un fichier</a><br>
<a href=http://www.yahoo.fr onmouseover=\"pop('mail login:flydieppe mot de passe:flyint','lightyellow')\"; onmouseout=\"kill()\">Mail</a><br>
<a href=http://www.google.fr onmouseover=\"pop('recherche','lightyellow')\"; onmouseout=\"kill()\">Google</a><br>
<a href=http://intranet.dom/cgi-bin/gateway.pl?user=sylvain onmouseover=\"pop('menu bis','lightyellow')\"; onmouseout=\"kill()\">Menu bis</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/calendrier.pl onmouseover=\"pop('programme regulier','lightyellow')\"; onmouseout=\"kill()\">Vol regulier</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/snif_aero_new3.pl onmouseover=\"pop('sniffeur planning','lightyellow')\"; onmouseout=\"kill()\">Sniffeur de planning</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/sup_appro.pl onmouseover=\"pop('suppression d un bon d appro suite à un bug','lightyellow')\"; onmouseout=\"kill()\">Suppression d'un bon d'appro</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/debug_appro.pl onmouseover=\"pop('toute les infos sur un bon','lightyellow')\"; onmouseout=\"kill()\">debug appro</a><br>
<a href=http://ibs.oasix.fr/cgi-bin/trace_ecart.pl onmouseover=\"pop('infos sur les ecarts','lightyellow')\"; onmouseout=\"kill()\">debug ecart</a><br>

</td>

<td bgcolor=#efefef><font size=+0>
<a href=dcg.htm onmouseover=\"pop('Memo sur la dcg','lightyellow')\"; onmouseout=\"kill()\">Declaration complementaire globale</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/list_compta2.pl onmouseover=\"pop('Edition de la comptabilité matière','lightyellow')\"; onmouseout=\"kill()\">Compta matiere</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/dcg.pl onmouseover=\"pop('Edition de la dcg','lightyellow')\"; onmouseout=\"kill()\">Recap mensuelle</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/dcgdouane.pl onmouseover=\"pop('Edition de la dcg','lightyellow')\"; onmouseout=\"kill()\">Recap mensuelle en detail (inventaire)</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/dcg_douane.pl onmouseover=\"pop('Edition de la dcg','lightyellow')\"; onmouseout=\"kill()\">Recap mensuelle douanier</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/reg_vente2.pl onmouseover=\"pop('Edition de la recap mensuelle','lightyellow')\"; onmouseout=\"kill()\">edition des dcg</a><br><br>
<a href=http://ibs.oasix.fr/cgi-bin/majstan.pl onmouseover=\"pop('Mise à jour du stock ancien et remise à zéro de enso','lightyellow')\"; onmouseout=\"kill()\">remise à zéro de enso</a><br><br>
</td>

</tr></table>


</body>
</html>";
