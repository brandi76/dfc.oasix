#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
print "<table>";
$query="select pr_cd_pr,pr_deg,pr_pdn,pr_stock from gaston where pr_flag=1";
$sth = $dbh->prepare($query);
$sth->execute;
while (($pr_cd_pr,$pr_deg,$pr_pdn,$stock)= $sth->fetchrow_array) {
	$pr_stock*=100;
	
	&save("update gaston set pr_deg=$pr_stock,pr_pdn=$pr_deg,pr_stock=$pr_pdn where pr_cd_pr='$pr_cd_pr'");
	
}

