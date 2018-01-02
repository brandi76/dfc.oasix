#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;

print $html->header;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$appro=$html->param('appro');
$trolley=$html->param('trolley');
$action=$html->param('action');
require "./src/connect.src";

print "<form>appro <input type=text name=appro><br>trolley  <input type=text name=trolley> <input type=hidden name=action value=go><input type=submit></form><br><br>";
if ($action eq "go")
{

	$query="update appro,trolley set ap_qte0=tr_qte where ap_cd_pr=tr_cd_pr and tr_code='$trolley' and ap_code='$appro' ";
	print $query;
	print "<br>";

 $sth=$dbh->prepare($query);
	$sth->execute();

$query="update retoursql,trolley set ret_qte=tr_qte/100,ret_qtepnc=tr_qte/100 where ret_cd_pr=tr_cd_pr and tr_code='$trolley' and ret_code='$appro'";
	print $query;
	print "<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
# $query="update vendusql,retoursql set vdu_qte=ret_qte-ret_retour where vdu_cd_pr=ret_cd_pr and ret_code='$appro' and vdu_appro=ret_code";
#	print $query;
#	print "<br>";
#	$sth=$dbh->prepare($query);
#	$sth->execute();	
	print "c'est fait";
}
	
# programme à l'arrache suite a la perte de donne , la creation des bons et le trolley type du depart qui n'etait pas bon chez cap
# ne marche que si les trolley type ont la emme liste
	