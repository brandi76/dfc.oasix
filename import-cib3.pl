#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

open(FILE1,"find /mnt/windows/AGENDA1/013/ -name \"*.CIB\" |");
@liste_dat = <FILE1>;
close(FILE1);

print $html->header;
require "./src/connect.src";

foreach (@liste_dat){
	print "<b>$_</b><br>";
	$fichier=$_;
	open(FILE1,"$fichier");
	@cib_dat = <FILE1>;
	close(FILE1);
	foreach (@cib_dat){
		($type,$val1,$val2)=split(/;/,$_);
		if ($type eq "6"){
			$query="select pr_cd_pr,pr_desi from produit,barre where (pr_cd_pr=$val1 or ba_code=$val1) and pr_cd_pr=ba_cd_pr";
			$sth=$dbh->prepare($query);
			$sth->execute();
			($pr_cd_pr,$pr_desi)=$sth->fetchrow_array;
			print "$pr_cd_pr $pr_desi $val2<br>";
		}
	}
}
# -E importation du fichier cib