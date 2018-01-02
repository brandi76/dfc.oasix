#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;

require "./src/connect.src";
               
               
# programme temporaire pour mettre l'info sous famille dans le fichier corsica_tva
                
$query="select distinct vdu_cd_pr,vdu_sous_famille from vendu_corsica_mois where vdu_sous_famille not like";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$sfamille)=$sth->fetchrow_array)
{
	&save ("update corsica_tva set tva_sfamille='$sfamille' where tva_refour=$pr_cd_pr","aff");
 }
