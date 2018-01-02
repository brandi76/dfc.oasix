#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$appro=$html->param("appro");

require "./src/connect.src";

print "<h1> suppression d'un bon d'appro </h1>";
print "<form ><input type=text name=appro><br><br><input type=submit value=supprimer></form>";

if ($appro ne ""){

	$query="select ap_cd_pr,ap_qte0 from appro where ap_code='$appro'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$qte)=$sth2->fetchrow_array)
	{
			
		&save("update produit set pr_stvol=pr_stvol-$qte where pr_cd_pr='$pr_cd_pr'");
	}
	&save("delete from appro where ap_code='$appro'");
	&save("delete from sortie where so_appro='$appro'");
	&save("update etatap set at_etat=1 where at_code='$appro'");
	&save("update geslot,etatap set gsl_ind=0 where gsl_nolot=at_nolot and at_code='$appro'");

	print "bon $appro detruit";
}	
	