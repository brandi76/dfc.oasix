#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;

require "./src/connect.src";
&save("delete from maxmois where mois >800 and mois <900");

@liste2=("MARINA","MEGA 3","REGINA","VICTORIA","VERA","SMERALDA");



  &groupe1(0,10);
  &groupe1(10,10);
  &groupe1(20,10);
 &groupe1(30,30);
  &groupe1(60,30);
  &groupe1(90,30);
  &groupe1(120,500);
   &groupe2(0,30);
  &groupe2(30,30);
  &groupe2(60,500);


sub groupe1()
{
$deb=$_[0];
$fin=$_[1];

for ($i=810;$i<813;$i++){
	$max=0;
	$max_n=&get("select sum(vdu_qte) as qte from vendu_corsica_mois,produit where vdu_mois=$i and vdu_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_sup!=5 and pr_sup!=6 and vdu_navire='MEGA 1' group by vdu_cd_pr order by qte desc limit $deb,1");
	if ($max_n>$max){$max=$max_n;}
	$max_n=&get("select sum(vdu_qte) as qte from vendu_corsica_mois,produit where vdu_mois=$i and vdu_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_sup!=5 and pr_sup!=6 and vdu_navire='MEGA 2' group by vdu_cd_pr order by qte desc limit $deb,1");
	if ($max_n>$max){$max=$max_n;}
	$max_n=&get("select sum(vdu_qte) as qte from vendu_corsica_mois,produit where vdu_mois=$i and vdu_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_sup!=5 and pr_sup!=6 and vdu_navire='MEGA 4' group by vdu_cd_pr order by qte desc limit $deb,1");
	if ($max_n>$max){$max=$max_n;}
	$rank=$deb."_".$fin;
  	&save("insert into maxmois values ('1','$rank','$i','$max')","af");
 	print "$rank $i $max <br>";
}
}

sub groupe2()
{
$deb=$_[0];
$fin=$_[1];
for ($i=810;$i<813;$i++){
	$max=0;
	foreach $navire (@liste2) {
		$max_n=&get("select sum(vdu_qte) as qte from vendu_corsica_mois,produit where vdu_mois=$i and vdu_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_sup!=5 and pr_sup!=6 and vdu_navire='$navire' group by vdu_cd_pr order by qte desc limit $deb,1");
		if ($max_n>$max){$max=$max_n;}
        }
	$rank=$deb."_".$fin;
  	&save("insert into maxmois values ('2','$rank','$i','$max')","af");
 	print "$rank $i $max <br>"; 
}
}

