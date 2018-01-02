#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$texte=$html->param('texte');

require "./src/connect.src";

if ($action eq ""){
	print "<body><center><h1>IMPORTATION DESARMEMENT</h1><br>";
	print "<br> creation du fichier corsica  a partir de code produit designation qte<br>un produit peut apparaitre deux fois<br>";
	print "<form method=post>";
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";

    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form></body>";
}
	

if ($action eq "import"){
	&save("delete from corsica");
	(@tab)=split(/\n/,$texte);
	foreach (@tab){
		while ($texte=~s/\t\t/\t/){};
		($pr_cd_pr,$pr_desi,$qte)=split(/\t/,$_);
		$qte=0-$qte;
		$qte+=&get("select cor_qte_pre  from corsica where cor_cd_pr='$pr_cd_pr'","aff")+0;
		&save("replace into corsica values ('10001','$pr_cd_pr','1','$qte')","aff");
	}
}

# -E creation du fichier corsica par copier coller en vue de son importation par commande_client.pl  (qte negative) via les commandes  06/09