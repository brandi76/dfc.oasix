#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;

print $html->header;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$appro=$html->param('appro');
$produit=$html->param('produit');
$qte=$html->param('qte');
$action=$html->param('action');
require "./src/connect.src";
$qte+=0;


if ($action eq "go")
{
	print "<form>";
	$qte=&get("select ap_qte0/100 from appro where ap_cd_pr='$produit' and ap_code='$appro' ");
	$desi=&get("select pr_desi from produit where pr_cd_pr='$produit' ");
	print "$pr_desi ancienne quantite depart $qte nouvelle quantite <input type=text name=qte ><bR>";
	print "<input type=hidden name=action value=go2>";
	print "<input type=hidden name=appro value='$appro'>";
	print "<input type=hidden name=produit value='$produit'>";
	print "<input type=submit value='modifier'>";
	print "</form>";
}
if ($action eq "go2")
{
	$query="update appro set ap_qte0='$qte'*100 where ap_cd_pr='$produit' and ap_code='$appro' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$query="update retoursql set ret_qte='$qte',ret_qtepnc='$qte' where ret_cd_pr='$produit' and ret_code='$appro'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "c'est fait";
}
if ($action ne "go"){
    print "<form>appro <input type=text name=appro><br>code produit  <input type=text name=produit> <input type=hidden name=action value=go><input type=submit></form><br><br>";
}
	
	