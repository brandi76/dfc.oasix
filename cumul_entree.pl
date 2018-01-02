#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";
$query="select enb_cdpr,pr_desi,sum(enb_quantite/100),pr_prac/100,pr_prx_rev/100,pr_codebarre from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and (pr_type=1 or pr_type=5) and pr_sup!=5 and enh_date>13877 and enh_date<14153 and pr_desi not like 'teste%' group by enb_cdpr"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$qte,$prac,$pr_rem,$pr_codebarre)=$sth->fetchrow_array){
	print "$pr_cd_pr,$pr_desi,$qte<br>";
	$prac=&prac($pr_cd_pr);
	$val+=$qte*$prac;
}
print $val;
	

