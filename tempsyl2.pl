#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>temp</title>";
require "./src/connect.src";
require "./src/connect.src";

$query="select pr_codebarre from produit where pr_cd_pr<100000000 and (pr_type=1 or pr_type=5) and pr_sup=0 and pr_cd_pr in (select distinct tr_cd_pr from trolley where (tr_code=108 or tr_code=208 or tr_code=308))";
$sth=$dbh2->prepare($query);
$sth->execute();
while (($pr_codebarre)=$sth->fetchrow_array){
    $pr_sup=&get("select pr_sup from produit where pr_cd_pr='$pr_codebarre'");
    if ($pr_sup!=0 && $pr_sup!=3){
   	  &save ("update produit set pr_sup=0 where pr_cd_pr='$pr_codebarre'","aff");
  }	    
 }  
