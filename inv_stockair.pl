#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";

print $html->header;

$action=$html->param("action");
$produit=$html->param("produit");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>Inv en l'air</title></head>";
print "<body link=black>";


require "./src/connect.src";
$desi=&get("select pr_desi from produit where pr_cd_pr=$produit");
print "$produit $desi<br>";
$query="select so_appro,so_qte/100 from sortie where so_cd_pr=$produit";
$sth=$dbh->prepare($query);
$sth->execute();
while (($appro,$qte)=$sth->fetchrow_array){
	$qte+=0;
	print "appro:$appro qte:$qte <br>";
	$total+=$qte;
}
print "total:$total";
