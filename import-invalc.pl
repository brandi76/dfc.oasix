#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
print $html->header;
open(FILE1,"inven_alc.csv");
@liste_dat = <FILE1>;

close(FILE1);
foreach (@liste_dat){
	(@tab)=split(/;/,$_);
	$query="SELECT pr_ventil,pr_stre,pr_pdn,pr_deg from produit where pr_cd_pr=$tab[0]";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($val,$pr_stre,$pr_pdn,$pr_deg)=$sth->fetchrow_array;
	$tab[2]*=100;
	$tab[3]*=10;
	$tab[4]*=100;
	$alc_pur=$pr_stre*$pr_deg*$pr_pdn;
	$nalc_pur=$tab[2]*$tab[3]*$tab[4];
	$diff=($alc_pur-$nalc_pur)/1000000000;
	if ($diff>10){print "<font color=red>********</font>"};
	print "$tab[0] $val $pr_stre $tab[2] $pr_pdn $tab[3] $pr_deg $tab[4] $diff<br>";
	$query="update produit set pr_deg=$tab[4],pr_pdn=$tab[3],pr_stre=$tab[2],pr_stanc=$tab[2] where pr_cd_pr=$tab[0]";
	# print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
}

# -E importation de produit