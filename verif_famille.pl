#!/usr/bin/perl 
use DBI();
use CGI;
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require "/var/www/cgi-bin/dfc.oasix/src/connect.src";
$html=new CGI;
print $html->header();
$base="aircotedivoire";
# $base="camairco";
$base="togo";

$query="select pr_codebarre,pr_famille,pr_desi,produit.pr_cd_pr from $base.produit_plus,$base.produit where produit_plus.pr_cd_pr=produit.pr_cd_pr and pr_codebarre>1000000";
$sth=$dbh->prepare($query);
$sth->execute();
while (($codebarre,$famille_base,$designation,$pr_cd_pr)=$sth->fetchrow_array){
	($famille)=&get("select famille from produit_master,produit_inode where produit_master.inode=produit_inode.inode and code=$codebarre")+0;
	if (($famille !=$famille_base)&&($famille!=0)){
		# print "$codebarre $pr_cd_pr $designation $famille_base $famille<br>";
		# $inode=&get("select inode from produit_inode where code='$codebarre'")+0;
		#&save ("update dfc.produit_master set famille='$famille_base' where inode=$inode","aff");
		# &save ("update $base.produit_plus set pr_famille='$famille' where pr_cd_pr=$pr_cd_pr","aff");
	}
	if ($famille ==14){
		 print "$codebarre $pr_cd_pr $designation $famille_base $famille<br>";
	}

}
