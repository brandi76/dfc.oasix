#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
require ("./src/connect.src");
$query="select vdu_appro,vdu_cd_pr,vdu_qte,vdu_prix  from vendusql where vdu_appro>=24080 and vdu_appro<=24095  and vdu_cd_pr not in (select distinct tr_cd_pr from trolley where tr_code=14 or tr_code=15)";
	$sth = $dbh->prepare($query);
	$sth->execute;
        while (($vdu_appro,$vdu_cd_pr,$vdu_qte,$vdu_prix)=$sth->fetchrow_array){
	if ($vdu_cd_pr==110){$vdu_cd_pr=130;}
	if ($vdu_cd_pr==0){next;}
  #       print "$vdu_appro,$vdu_cd_pr,$vdu_qte,$vdu_prix<br>";
	$ordre=&get("select ord_ordre from ordre where ord_cd_pr=$vdu_cd_pr");
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$vdu_cd_pr");
	if ($ordre eq ""){ print "erreur $vdu_cd_pr $pr_desi<br>";}
	&save("replace into retoursql values ('$vdu_appro','$ordre','$vdu_cd_pr','$vdu_qte','$vdu_qte','0','0','$vdu_prix','0')","aff");
}
