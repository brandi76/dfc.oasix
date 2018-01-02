#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
require "./src/connect.src";

print $html->header;
# &save("update produit set pr_casse=0,pr_stre=0,pr_diff=0,pr_stvol=0,pr_stanc=0,pr_deg=0,pr_pdn=0 where pr_ventil=6","aff");

# $query="select pr_cd_pr,pr_casse,pr_stre,pr_diff,pr_stvol,pr_stanc,pr_deg,pr_pdn from produit where pr_ventil=6";
# $sth=$dbh2->prepare($query);
# $sth->execute();
# while (($pr_cd_pr,$pr_casse,$pr_stre,$pr_diff,$pr_stvol,$pr_stanc,$pr_deg,$pr_pdn)=$sth->fetchrow_array){
# 	&save("update produit set pr_casse=$pr_casse,pr_stre=$pr_stre,pr_diff=$pr_diff,pr_stvol=$pr_stvol,pr_stanc=$pr_stanc,pr_deg=$pr_deg,pr_pdn=$pr_pdn where pr_cd_pr=$pr_cd_pr","aff");
# }
	
 $query="select pr_cd_pr,pr_sup from produit";
 $sth=$dbh2->prepare($query);
 $sth->execute();
 while (($pr_cd_pr,$pr_sup)=$sth->fetchrow_array){
 	&save("update produit set pr_sup=$pr_sup where pr_cd_pr=$pr_cd_pr","aff");
}
print "fin";
