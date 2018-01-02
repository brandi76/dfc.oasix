#!/usr/bin/perl
use CGI;
use DBI();
       
$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
$action=$html->param('action');
$appro=$html->param('appro');
require "./src/connect.src";
print "<center><h1>$appro</h1>";
print "<table border=1 cellspacing=0>";
print "<tr bgcolor=#FFFF66><td>&nbsp;</td><td>&nbsp;</td>";
print "<th>Depart</th></tr>";
$query = "select ret_cd_pr,ret_qte-ret_retour from retoursql where ret_retour!=ret_qte and ret_code='$appro' order by ret_ordre";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
	$pr_desi = &get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
	print "<tr><td>$pr_cd_pr<td>$pr_desi</td><td>$qte</td></tr>";
}
print "</table>";

