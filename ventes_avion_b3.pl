#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";

print "<title> bilan 2008</title>";
$achat{'MEGA 1'}=93437;
$achat{'MEGA 2'}=94865;
$achat{'MEGA 3'}=29854;
$achat{'MEGA 4'}=60400;
$achat{'VICTORIA'}=30800;
$achat{'SERENA II'}=6837;
$achat{'SMERALDA'}=17689;
$achat{'REGINA'}=48972;
$achat{'MARINA'}=79565;
$achat{'EXPRESS 2'}=0;


$inventaire{'MEGA 1'}='2008-10-08';
$inventaire{'MEGA 2'}='2008-10-09';
$inventaire{'MEGA 3'}=0;
$inventaire{'MEGA 4'}='2008-10-07';
$inventaire{'VICTORIA'}=0;
$inventaire{'SERENA II'}=0;
$inventaire{'SMERALDA'}='2008-10-08';
$inventaire{'REGINA'}='2008-10-17';
$inventaire{'MARINA'}='2008-10-05';
$inventaire{'EXPRESS 2'}=0;



$liv{'MEGA 1'}=11544;
$liv{'MEGA 2'}=11545;
$liv{'MEGA 3'}=11546;
$liv{'MEGA 4'}=11547;
$liv{'VICTORIA'}=0;
$liv{'SERENA II'}=0;
$liv{'SMERALDA'}=11549;
$liv{'REGINA'}="11548:11657";
$liv{'MARINA'}=0;
$liv{'EXPRESS 2'}=0;


$stock{'MEGA 1'}=33236;
$stock{'MEGA 2'}=37713;
$stock{'MEGA 3'}=79891;
$stock{'MEGA 4'}=50683;
$stock{'VICTORIA'}=36975;
$stock{'SERENA II'}=0;
$stock{'SMERALDA'}=0;
$stock{'REGINA'}=0;
$stock{'MARINA'}=0;
$stock{'EXPRESS 2'}=0;

print "stock aerien:47218 variation:-17021<br>";
print "stock du fond:299175 variation:-6992<br>";
print "stock maritime:244097 variation:-35198<br>";

$query="select distinct tva_nom from corsica_tva where tva_nom='SMERALDA'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nom)=$sth->fetchrow_array){
	push (@navire,$nom);
}	
$date_min="2008-01-01";
$date_minven="2008-09-30";
$date_max="2008-09-30";                
$debut=1080101;
$fin=1080930;

print "<table border=1>";
print "<tr><th></th>";
foreach $navire (@navire){
	print "<th>$navire</th>";
}
print "</tr>";
print "<tr><th>Vente</th>";
foreach $navire (@navire){
	$val=0;	
	$query="select tva_refour,sum(tva_qte),tva_prac from corsica_tva  where tva_nom='$navire' and tva_date >='$date_min' and tva_date<='$date_max' and tva_ssfamille not like 'magaz%' and tva_ssfamille not like 'journaux%' and tva_desi not like 'carte% jeux%' and tva_refour!=3473941280003 and tva_famille='PARFUMS' group by tva_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tva_refour,$tva_qte,$tva_prac)=$sth->fetchrow_array){
# 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$tva_refour");
# 			if (($pr_type!=1) and ($pr_type!=5)){next;}
		
			$prac=&prac($tva_refour)+0;
# 			if ($tva_refour==3145891244601){
#                          	print "$prac<br>";
#                          }
# 	 		 print "$tva_refour;$tva_qte;$pr_type<br>";
			if ($prac==0){$prac=$tva_prac;}
			$val+=$tva_qte*$prac;
	}
	
	print "<td>".int($val)."</td>";
	$vente{"$navire"}=$val;
}
print "</tr>";

print "<tr><th>Livraison dieppe</th>";
foreach $navire (@navire){
	$val=0;
	$query="select coc_cd_pr,sum(coc_qte)/100 from infococ2,comcli where ic2_cd_cl=500 and coc_in_pos=5 and coc_no=ic2_no and ic2_date>=$debut and ic2_date<=$fin and ic2_com1='$navire' and coc_cd_pr!=8003080040135 and coc_cd_pr!=8003080026221 and coc_cd_pr!=3473941280003 and coc_cd_pr!=2001841 group by coc_cd_pr"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
 			$pr_type=&get("select pr_type from produit where pr_cd_pr=$pr_cd_pr");
 			if (($pr_type!=1) and ($pr_type!=5)){next;}
			$prac=&prac($pr_cd_pr)+0;
			if ($prac==0){next;}
	#  		print "$pr_cd_pr;$qte;*<br>";
			$val+=$qte*$prac;
	}
	
	print "<td>".int($val)."</td>";
	$marge{"$navire"}=int($val);
}
print "</tr>";
print "<tr><th>Livraison corse</th>";
foreach $navire (@navire){
	print "<td>".$achat{"$navire"}."</td>";
	$marge{"$navire"}+=$achat{"$navire"};

}
print "</tr>";

print "<tr><th>variation stock</th>";
foreach $navire (@navire){
	$val=0;
	$total=0;
	# inventaire
	$date=$inventaire{"$navire"};
	print "<td>";
	if ($date!=0){
		$query="select nav_cd_pr,nav_qte from navire2 where nav_date='$date' and nav_type=1 and nav_nom='$navire'" ;
# 		print "$query";
		$sth = $dbh->prepare("$query" );
		
		$sth->execute;
		while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
		{
			$pr_prac=&prac($nav_cd_pr);
			$val=$pr_prac*$nav_qte;	
			if ($pr_prac==0){
				$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'")+0;
				$val=$pr_prac*$nav_qte;	
			}
			$total+=$val;
		}
#  		print "$total<br>";
		# -livraison
		($cde1,$cde2)=split(/:/,$liv{"$navire"});
		if ($cde1>0 ){
			$sth = $dbh->prepare("select coc_cd_pr,coc_qte/100 from comcli where coc_no=$cde1" );
			$sth->execute;
			while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
			{
				$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
				$pr_prac=&prac($nav_cd_pr);
				$val=$pr_prac*$nav_qte;	
 				$total-=$val;
			}
		}
		if ($cde2>0 ){
			$sth = $dbh->prepare("select coc_cd_pr,coc_qte/100 from comcli where coc_no=$cde2" );
			$sth->execute;
			while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
			{
				$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
				$pr_prac=&prac($nav_cd_pr);
				$val=$pr_prac*$nav_qte;	
 				$total-=$val;
			}
		}

#  		print "$total<br>";

		# +vendu
		
		$query="select tva_refour,tva_qte from corsica_tva where tva_nom='$navire' and tva_date >'$date_minven' and tva_date <'$date'";
# 		print "$query";
		$sth = $dbh->prepare("$query");
		$sth->execute;
		while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
		{
			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
			$pr_prac=&prac($nav_cd_pr);
			$val=$pr_prac*$nav_qte;	
 			$total+=$val;
		}
#         		print "$total<br>";
        }
        # stock depart
        $total-=$stock{"$navire"};
	print int($total)."</td>";
 	$marge{"$navire"}-=int($total);
}
print "</tr>";


print "<tr><th>Ca</th>";
foreach $navire (@navire){
	$val=0;	
	$query="select sum(tva_prixv) from corsica_tva  where tva_nom='$navire' and tva_date >='$date_min' and tva_date<='$date_max' and tva_ssfamille not like 'magaz%' and tva_ssfamille not like 'journaux%' and tva_desi not like 'carte% jeux%' and tva_refour!=3473941280003";
	$sth=$dbh->prepare($query);
	$sth->execute();
 	$tva_prixv=$sth->fetchrow_array;
	print "<td>".int($tva_prixv)."</td>";
	$ca{"$navire"}=$tva_prixv;
	$marge{"$navire"}=($tva_prixv-$marge{"$navire"})/$tva_prixv;
	
}
print "</tr>";
print "<tr><th>Marge compta</th>";
foreach $navire (@navire){
	print "<td>".int($marge{"$navire"}*100)."</td>";
	
}
print "</tr>";

print "<tr><th>Marge achat consommé</th>";
foreach $navire (@navire){
	$marge=($ca{"$navire"}-$vente{"$navire"})/$ca{"$navire"};
	print "<td>".int($marge*100)."</td>";
	
}
print "</tr>";

print "</table>";

# $val=0;	
# $date_min="2008-01-01";
# $date_max="2008-09-30";                
# $query="select tva_refour,sum(tva_qte),tva_prac from corsica_tva  where tva_date >='$date_min' and tva_date<='$date_max' and (tva_ssfamille like 'magaz%' or tva_ssfamille like 'journaux%')group by tva_refour";
# $sth=$dbh->prepare($query);
# $sth->execute();
# while (($tva_refour,$tva_qte,$tva_prac)=$sth->fetchrow_array){
# 		$prac=&prac($tva_refour)+0;
# 		 print "$tva_refour;$tva_qte<br>";
# 		if ($prac==0){$prac=$tva_prac;}
# 		$val+=$tva_qte*$prac;
# }
# print "<br>journaux:$val";
