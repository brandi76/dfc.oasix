#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);
print $html->header;



require "./src/connect.src";
@sem=(0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,8,9,9,9,9,10,10,10,10,10,11,11,11,11,12,12,12,12,12);
@famille1=("MEGA 1","MEGA 2","MEGA 4");
@famille2=("REGINA","MEGA 3","VICTORIA","MARINA");

$semaine=&semaine("");
$mois=@sem[$semaine];
#$query="select distinct se_navire from semaine2 where se_no>$semaine+3 and se_no<$semaine+6 and se_coef>0 and se_navire!='AUTRES' and se_navire!='MEGA'";
$query="select distinct se_navire from semaine2 where se_no>$semaine+3 and se_no<$semaine+9 and se_coef>0 and se_navire!='AUTRES' and se_navire!='MEGA'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire)=$sth->fetchrow_array){
	push (@liste,$navire);
	# print "$navire<br>";
}
$moisp5=@sem[$semaine+5];
$refmois=600+$moisp5;

for $navire (@famille1){
	$liste.="vdu_navire='$navire' or ";
}	
chop($liste);
chop($liste);
chop($liste);

$query="select vdu_navire,sum(vdu_qte) as qte from vendu_corsica_mois where vdu_mois=$refmois and vdu_famille='PARFUMS' and vdu_cd_pr>1000000000 and ($liste) group by vdu_navire order by qte desc limit 1";
$sth=$dbh->prepare($query);
$sth->execute();
($navire,$qte)=$sth->fetchrow_array;


for ($i=0;$i<=30;$i=$i+10){
	$topf1[$i]=&get("select sum(vdu_qte) as qte from vendu_corsica_mois where vdu_mois=$refmois and vdu_famille='PARFUMS' and vdu_cd_pr>1000000000 and vdu_navire='$navire' group by vdu_cd_pr order by qte desc limit $i,1","af")+0;
	# print "$i $topf1[$i]<br>";
}
for ($i=60;$i<=90;$i=$i+30){
	$topf1[$i]=&get("select sum(vdu_qte) as qte from vendu_corsica_mois where vdu_mois=$refmois and vdu_famille='PARFUMS' and vdu_cd_pr>1000000000 and vdu_navire='$navire' group by vdu_cd_pr order by qte desc limit $i,1")+0;
	# print "$i $topf1[$i]<br>";
}

$liste="";
for $navire (@famille2){
	$liste.="vdu_navire='$navire' or ";
}	
chop($liste);
chop($liste);
chop($liste);
$query="select vdu_navire,sum(vdu_qte) as qte from vendu_corsica_mois where vdu_mois=$refmois and vdu_famille='PARFUMS' and vdu_cd_pr>1000000000 and ($liste) group by vdu_navire order by qte desc limit 1";
$sth=$dbh->prepare($query);
$sth->execute();
($navire,$qte)=$sth->fetchrow_array;

$topf2[0]=&get("select sum(vdu_qte) as qte from vendu_corsica_mois where vdu_mois=$refmois and vdu_famille='PARFUMS' and vdu_cd_pr>1000000000 and vdu_navire='$navire' group by vdu_cd_pr order by qte desc limit 0,1","af")+0;
$topf2[30]=&get("select sum(vdu_qte) as qte from vendu_corsica_mois where vdu_mois=$refmois and vdu_famille='PARFUMS' and vdu_cd_pr>1000000000 and vdu_navire='$navire' group by vdu_cd_pr order by qte desc limit 30,1")+0;

print "<table border=1 cellspacing=0><tr><th>famille</th><th>fournisseur</th><th>produit</th><th>designation</th><th>stock dieppe</th><th>stock navire</th><th>qte surplus</th><th>prix achat</th><th>packing</th></tr>";

@top=();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup=0 or pr_sup=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH)  group by nav_cd_pr order by qte desc limit 0,10";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){push (@top,$pr_cd_pr);}
$topfa1=$topf1[0];
$topfa2=$topf2[0];
&go("0-10");

@top=();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup=0 or pr_sup=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH)  group by nav_cd_pr order by qte desc limit 10,10";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){push (@top,$pr_cd_pr);}
$topfa1=$topf1[10];
$topfa2=$topf2[0];
&go("11-20");

@top=();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup=0 or pr_sup=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH)   group by nav_cd_pr order by qte desc limit 20,10";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){push (@top,$pr_cd_pr);}
$topfa1=$topf1[20];
$topfa2=$topf2[0];
&go("21-30");

@top=();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup=0 or pr_sup=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH)  group by nav_cd_pr order by qte desc limit 30,30";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){push (@top,$pr_cd_pr);}
$topfa1=$topf1[30];
$topfa2=$topf2[30];
&go("31-60");

@top=();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup=0 or pr_sup=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH)  group by nav_cd_pr order by qte desc limit 60,30";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){push (@top,$pr_cd_pr);}
$topfa1=$topf1[60];
$topfa2=3;
&go("61-90");

@top=();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup=0 or pr_sup=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH)  group by nav_cd_pr order by qte desc limit 90,30";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){push (@top,$pr_cd_pr);}
$topfa1=$topf1[90];
$topfa2=3;
&go("91-120");

@top=();
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup=0 or pr_sup=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH)  group by nav_cd_pr order by qte desc limit 120,1000";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){push (@top,$pr_cd_pr);}
$topfa1=3;
$topfa2=3;
&go("120-~");



# print "produits deslités<br>";
$query="select pr_cd_pr,pr_desi,pr_prac/100 from navire2,produit where nav_cd_pr=pr_cd_pr and nav_cd_pr>1000000000 and (pr_sup!=0 and pr_sup!=3) and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 24 MONTH) group by nav_cd_pr ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array){
		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot 
		if ($pr_stre <=0){next;}
		$carton=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'");
		print "</tr><td>Delisté</td><td>$pr_four</td> <td>$pr_cd_pr</td><td>$pr_desi</td><td>$pr_stre</td><td>&nbsp;</td><td>$pr_stre</td><td>$pr_prac</td><td>$carton</td></tr>";

}
print "</table>";




sub go{
	# print "top $_[0] qte max famille 1:$topfa1 qte max famille 2:$topfa2 <br>";
	$topfa1=3 if ($topfa1<3);
	$topfa2=3 if ($topfa2<3);
	foreach $pr_cd_pr (@top){
		$total=0;
		$stock_navire=0;
		foreach $navire (@famille1){
			if (! grep/$navire/,@liste){next;}
			$surplus=0;
			$besoin=0;
			%calcul=&table_navire($navire,$pr_cd_pr);
			$stock_navire+=$calcul{"stock_navire"};
			if ($calcul{"stock_navire"}>$topfa1){
				$surplus=($calcul{"stock_navire"}-$topfa1);
			}
			# $besoin=int($topfa1/2)-$surplus;
			$besoin=int($topfa1*2)-$surplus;
			$besoin=0 if ($besoin <0);
			$total+=$besoin;
		}
		foreach $navire (@famille2){
			if (! grep/$navire/,@liste){next;}
			$surplus=0;
			$besoin=0;
			%calcul=&table_navire($navire,$pr_cd_pr);
			$stock_navire+=$calcul{"stock_navire"};
			if ($calcul{"stock_navire"}>$topfa2){
				$surplus=($calcul{"stock_navire"}-$topfa2);
			}
			# $besoin=int($topfa2/2)-$surplus;
			$besoin=int($topfa2*2)-$surplus;
			$besoin=0 if ($besoin <0);
			$total+=$besoin;
		}
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
		$pr_four=&get("select pr_four from produit where pr_cd_pr='$pr_cd_pr'");
		$pr_prac=&get("select pr_prac/100 from produit where pr_cd_pr='$pr_cd_pr'");
	
		%stock=&stock($pr_cd_pr,'','quick');
		$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot 
		$surplusd=$pr_stre-$total;
		
		$acommander=$total-$pr_stre;
		$carton=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'");

		&paneg("acommander");
		&paneg("surplusd");
		if ($surplusd >0){
 			print "</tr><TD>$_[0]</TD><td>$pr_four</td><td>$pr_cd_pr</td><td>$pr_desi</td><td>$pr_stre</td><td>$stock_navire</td><td>$surplusd</td><td>$pr_prac</td><td>$carton</td></tr>";
 		}
	}
}
# -E stock alerte
