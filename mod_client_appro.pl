#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$appro=$html->param("appro");
$client=$html->param("client");

require "./src/connect.src";

print "<h1> Changement de client sur un vol </h1>";
print "<form>appro <input type=text name=appro><br>nouveau client <input type=text name=client><br><input type=submit value=modifier></form>";

if (($appro ne "")&&($client ne "")){
	&save("update vol set v_cd_cl='$client' where v_code='$appro'");
	print "bon $appro modifié";
}	
	