#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
print $html->header;
open(FILE1,"produit.csv");
# ndp,code four,designation,packing,prix public,prix achat bateau,prix de vente bateau,prix achat avion,prix de vente avion
# 0     1           2          3          4         5                     6                  7                 8
@liste_dat = <FILE1>;

close(FILE1);
$four=2165;
foreach (@liste_dat){
	(@tab)=split(/;/,$_);
	print "@tab<br>";
	$tab[3]*=100;
	$tab[5]*=100;

	while ($tab[0]=~s/ //){};
	# cosmetique
	$query="replace into produit values ('$tab[0]','$tab[2]','0','0','0','330491000000Y','21','0','5','$tab[5]','0','0','0','$tab[3]','0','0','0','0','0','0','1','12','UNIT','$four','$tab[1]','$tab[0]')";
	# parfum
	# $query="replace into produit values ('$tab[0]','$tab[2]','0','0','0','330300900000J','20','0','1','$tab[5]','0','0','0','$tab[3]','0','0','0','0','0','0','1','12','UNIT','$four','$tab[1]','$tab[0]')";
	print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if ($tab[4]>0){
		$query="replace into carton values ('$tab[0]','$tab[3]','0')";
		print "$query<br>";
		$sth=$dbh->prepare($query);
		$sth->execute();
	}
	$query="replace into prixpr values ('$tab[0]','$tab[4]','$tab[6]','$tab[8]','$tab[5]','$tab[7]')";
	print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
}

# -E importation de produit