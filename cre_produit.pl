#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;

open(FILE1,"/tmp/produit.txt");
@liste_dat = <FILE1>;
close(FILE1);
foreach (@liste_dat){
	# ($prod,$pr_desi,$pv,$prac)=split(/;/,$_);
	($prod,$prix)=split(/;/,$_);
        $prix=~s/,//;
	# $prac=int($prac*100);
	# $pv=int($pv*100);
	# &save("insert ignore into produit values('$prod','$pr_desi','0','0','0','','0','0','0','$pv','0','0','0','$prac','0','0','0','0','0','0','0','','0','0','','0')","aff");
	# &save("update produit set pr_desi='$pr_desi', pr_prx_vte='$pv',pr_prac='$prac' where pr_cd_pr=$prod and pr_desi=''","aff");
	&save("update produit set pr_prac='$prix' where pr_cd_pr=$prod","aff");
	
}
# -E importation d'une commande corsica
