#!/usr/bin/perl                  
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/./outils_corsica.pl";

require "./src/connect.src";
print $html->header;

$query="select vda_date,sum(vda_qte) from vendu_corsica_auto,produit where  vda_navire=1 and vda_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) group by vda_date order by vda_date";

$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
while (($vda_date,$qte)=$sth->fetchrow_array){
# 	print "$vda_date,$qte <br>";
}
print "<hr>";
$query="select tva_date,sum(tva_qte) from corsica_tva,produit where  tva_nom='MEGA 2' and tva_refour=pr_cd_pr and (pr_type=1 or pr_type=5) and tva_date>='2008-07-06' group by tva_date order by tva_date";

$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
while (($vda_date,$qte)=$sth->fetchrow_array){
	if ($nb==0){
		$cumqte=$qte;
	}
	if ($nb==1){
		$cumqte+=$qte;
		print "d$vda_date,$cumqte <br>"; 
	}
	if (($nb!=1)&&($nb!=0)){
		$cum2qte+=$qte;
		}
	
	$nb++;
	if ($nb==7){$nb=0;print "*$cum2qte<br>";$cum2qte=0;}
}
