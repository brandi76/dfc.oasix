#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;

# print $html->header;
require "./src/connect.src";
print $html->header();

print "<title>inventaire testeur</title>";
require "./src/connect.src";
print "<center> Inventaire testeur du ";
print `date`;
print "<table border=1 cellspacing=0>";
$query="select pr_cd_pr,pr_desi,pr_four from produit where pr_desi like 'TESTEUR%' and pr_stre!=0 order by pr_four,pr_cd_pr"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_four)=$sth->fetchrow_array)
{
	$prod=substr(substr($pr_cd_pr,4,4)+10000,1,4);
	if ($pr_four==2070){
		$prod=substr(substr($pr_cd_pr,4,5)+100000,1,5);
	}
	print "<tr><td>$pr_cd_pr</td><td><b>$prod</b></td><td>$pr_desi</td>";
	%stock=&stock($pr_cd_pr);
	$pr_stre=$stock{"stock"};
	print "<td>$pr_stre</td></tr>";
}
print "</table>";
