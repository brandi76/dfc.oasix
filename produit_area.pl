#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";


$html=new CGI;
print $html->header;
$action=$html->param("action");
$texte=$html->param('texte');

require "./src/connect.src";

if ($action eq ""){
	print "<body><center><h1>Traitement d une liste produit</h1><br>";
	print "<form method=post>";
	print "<br><textarea name=texte cols=80 rows=20>";
	print "</textarea>";
    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form><a href=#haut>haut</a></body>";
}
	

if ($action eq "import"){
	(@tab)=split(/\n/,$texte);
	$ok=0;
	print "<table border=1cellspacing=0>";
	foreach $ligne (@tab){
	 	
		$query="select pr_desi,pr_sup,pr_codebarre from produit where pr_cd_pr='$ligne'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($pr_desi,$pr_sup,$pr_codebarre)=$sth->fetchrow_array;
		@option=("actif","supprimé","delisté","new","déstockage","suivi par paul","délisté par paul","délisté par le fournisseur");

		$desi_sup=$option[$pr_sup];

		$color="black";
		if ($pr_desi eq "") {$color="red";}
		%stock=&stock($pr_codebarre,0,"quick");
        	$qte_commande=&get("select floor(sum(com2_qte)/100) from commande where com2_cd_pr='$pr_codebarre'")+0;
		print "<tr><td><font color=$color>$ligne $pr_desi</td><td>$desi_sup</td><td>$stock{'stock'}</td><td> $qte_commande</td></tr>";
	}
print "</table>";
}	
		