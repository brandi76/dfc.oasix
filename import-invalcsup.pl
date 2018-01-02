#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
print $html->header;
open(FILE1,"inv_alcoolsup.csv");
@liste_dat = <FILE1>;

close(FILE1);
$prod=198000;
$query="select * from produit where pr_cd_pr=120185";
$sth=$dbh->prepare($query);
$sth->execute();
while ((@table)=$sth->fetchrow_array){
	foreach (@liste_dat){
		(@tab)=split(/;/,$_);
		$table[0]=$prod;
		$table[1]=$tab[1];
		
		 $query="replace into produit values(";
		 for ($i=0;$i<=$#table;$i++)
		{
			$query.="'$table[$i]',";
		}
		chop($query);
		$query.=")";
		print "$query<br>";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$tab[0]*=100;
		$tab[2]*=100;
		$tab[3]*=10;
		$query="update produit set pr_casse=0,pr_prx_rev=0,pr_prac=0,pr_diff=0,pr_four=0,pr_qte_comp=0,pr_pdb=$tab[3],pr_stre=$tab[0],pr_stanc=$tab[0],pr_deg=$tab[2],pr_pdn=$tab[3] where pr_cd_pr=$prod";
		print "$query<br>";
		
		$sth2=$dbh->prepare($query);
		$sth2->execute();
	
		$prod++;			
	}
}

# -E importation de produit