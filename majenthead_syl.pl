#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;

# print $html->header;
require "./src/connect.src";
require "./src/connect.src";

print $html->header();

$query="select es_cd_pr,es_no_do,es_qte_en from enso where es_qte_en!=0 and es_cd_pr >100000000 order by es_no_do";
$sth=$dbh2->prepare($query);
$sth->execute();
while (($es_cd_pr,$es_no_do,$es_qte_en)=$sth->fetchrow_array){

	&save("replace into entbody values ('$es_no_do','$es_cd_pr','$es_qte_en')","aff"); 

}
