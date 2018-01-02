#!/usr/bin/perl
use CGI;
use DBI();
use POSIX qw(floor);
$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;

require "./src/connect.src";

&save("create temporary table produitsyl (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");

$pr_cd_pr=$_[0];
$s=&semaine("");
$an=&get("select year(now())")-1;
$pr_cd_pr=10093764;
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nav_cd_pr,$null)=$sth->fetchrow_array){
 	&save("insert into produitsyl values ('$nav_cd_pr','$i')","af");
	$i++;
}

$query="select distinct nav_cd_pr,tmp_rank from navire2,produitsyl where nav_cd_pr=tmp_cd_pr and nav_type=0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nav_cd_pr,$i)=$sth->fetchrow_array){
	if ($i<=10){$rank="0_10";}
	if (($i>10)&&($i<=20)){$rank="10_10";}
	if (($i>20)&&($i<=30)){$rank="20_10";}
	if (($i>30)&&($i<=60)){$rank="30_30";}
	if (($i>60)&&($i<=20)){$rank="60_30";}
	if (($i>90)&&($i<=120)){$rank="90_30";}
	if ($i>120){$rank="120_500";}
	print "$nav_cd_pr ";
	for ($i=0;$i<4;$i++){
		$jour=$i*7;
		$mois=&get("select month(date_add(now(),INTERVAL $jour DAY))");
		$mois=$mois+($an*100)-200000;
		$max=&get("select qte from maxmois where type=1 and rank='$rank' and mois=$mois-100/maxmois","af");
		if (($max%4)!=0){$max=1+int($max/4);}else{$max=$max/4;}
		$calcul{"s+$i"}=$max;
		print "$max ";
	}
	print "<br>";
}
