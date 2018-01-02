#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

require "./src/connect.src";
print $html->header;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
$sth=$dbh->prepare("select pr_cd_pr,pr_desi,pr_codebarre from produit,trolley where pr_cd_pr= tr_cd_pr and tr_code=106 order by tr_ordre");
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_codebarre)=$sth->fetchrow_array){
	$cond=&get("select car_carton from carton where car_cd_pr=$pr_cd_pr");
	print "<font size=-2><br><br>$pr_cd_pr<br>$pr_codebarre<br></font><br><font size=+2><b>$pr_desi</font></b><br>* $cond<br>";
	print "<div id=saut>.</div>";
	
}
