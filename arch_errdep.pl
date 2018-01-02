#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
require "./src/connect.src";
$query="select errdep.* from errdep,produit where erdep_cd_pr=pr_cd_pr and pr_ventil!=6 and pr_ventil!=15 and pr_ventil!=8";
$sth=$dbh->prepare($query);
$sth->execute();

while (($pr_cd_pr,$erdep_depart,$erdep_code,$erdep_qte)=$sth->fetchrow_array)
{
	&save("update produit set pr_stre=pr_stre+($erdep_qte*100) where pr_cd_pr='$pr_cd_pr'","aff");
	&save("update produit set pr_stanc=pr_stanc+($erdep_qte*100) where pr_cd_pr='$pr_cd_pr'","aff");
	&save("replace into errdep_arch values ('$pr_cd_pr','$erdep_depart','$erdep_code','$erdep_qte')","aff");
	&save("delete from errdep where erdep_cd_pr='$pr_cd_pr' and erdep_depart='$erdep_depart' and erdep_code='$erdep_code' and erdep_qte='$erdep_qte'","aff");
}
