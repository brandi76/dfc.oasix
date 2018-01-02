#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;

# print $html->header;
require "./src/connect.src";
print $html->header();

require "./src/connect.src";
$query="select pr_cd_pr,pr_desi,pr_four,pr_codebarre from produit where pr_desi like 'TESTEUR%' and pr_cd_pr<10000000 and pr_four!=2070 limit 1"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_four,$pr_codebarre)=$sth->fetchrow_array)
{
	print "$pr_cd_pr ";
	$sub= 10**(length($pr_cd_pr)-4)*$pr_four;
	# print length($pr_cd_pr);
	# print " $sub ";
	$prod=$pr_cd_pr-$sub;
	$newprod=$pr_four*10000+$prod;
	print " $newprod ";
	 &save ("update enso set es_cd_pr=$newprod where es_cd_pr=$pr_cd_pr","aff");
	 &save ("update comcli set coc_cd_pr=$newprod where coc_cd_pr=$pr_cd_pr","aff");
	 &save ("update produit set pr_cd_pr=$newprod where pr_cd_pr=$pr_cd_pr","aff");

	print "<br>";	
}
