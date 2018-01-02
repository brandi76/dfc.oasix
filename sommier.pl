#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
$html=new CGI;
print $html->header;

require "./src/connect.src";

$query="select pr_douane,pr_cd_pr,pr_desi,pr_prac/100,sum(coc_qte)/100,pr_stre/100 from comcli,produit,infococ2 where pr_four=1330 and pr_cd_pr=coc_cd_pr and coc_in_pos=5 and coc_no=ic2_no and ic2_date>1050800 and ic2_date<1050901 group by coc_cd_pr order by pr_douane,pr_cd_pr";
$sth = $dbh->prepare($query);
$sth->execute;
print "<table border=1>";
while (($pr_douane,$pr_cd_pr,$pr_desi,$pr_prac,$coc_qte,$pr_stre)= $sth->fetchrow_array) {
	print "<tr><td>$pr_douane</td><td><a href=http://ibs.oasix.fr/cgi-bin/fiche_produit.pl?pr_cd_pr=$pr_cd_pr&recherche=&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td><td>$pr_prac</td><td>$coc_qte</td><td>$pr_stre</td></tr>";
}
print "</table><br><br>";
$query="select pr_douane,pr_cd_pr,pr_desi,pr_prac/100,sum(es_qte)/100,pr_stre/100 from produit,enso where pr_four=1330 and pr_cd_pr=es_cd_pr and es_type=1 group by es_cd_pr  order by pr_douane,pr_cd_pr";
$sth = $dbh->prepare($query);
$sth->execute;
print "<table border=1>";
while (($pr_douane,$pr_cd_pr,$pr_desi,$pr_prac,$coc_qte,$pr_stre)= $sth->fetchrow_array) {
	print "<tr><td>$pr_douane</td><td><a href=http://ibs.oasix.fr/cgi-bin/fiche_produit.pl?pr_cd_pr=$pr_cd_pr&recherche=&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td><td>$pr_prac</td><td>$coc_qte</td><td>$pr_stre</td></tr>";
}
print "</table>";
 