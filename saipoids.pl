#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
$pr_cd_pr=$html->param("pr_cd_pr");
$poids=$html->param("poids");
print $html->header;
require "./src/connect.src";

if ($pr_cd_pr ne ""){
&save ("update produit set pr_pdb=$poids where pr_cd_pr=$pr_cd_pr","aff");
}
print "<form><input type=text name=pr_cd_pr><input type=text name=poids><input type=submit></form>";

