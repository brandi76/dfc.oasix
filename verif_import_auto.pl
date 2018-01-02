#!/usr/bin/perl                  
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/./outils_corsica.pl";

require "./src/connect.src";
print $html->header;

$action=$html->param("action");
$navire=$html->param("navire");
$date=$html->param("date");
$pr_cd_pr=$html->param("pr_cd_pr");
@liste=("MEGA 1","MEGA 2","MEGA 4");

print "<title>$0</title>";

&save("create temporary table liste1 (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
$liste_nav="and (nav_nom='MEGA 1' or nav_nom='MEGA 2' or nav_nom='MEGA 4') ";
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_nav group by nav_cd_pr order by qte desc";
$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
while (($nav_cd_pr,$null)=$sth->fetchrow_array){
	&save("insert into liste1 values ('$nav_cd_pr','$i')","af");
	$i++;
}
&save("create temporary table liste2 (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
$liste_nav="and (nav_nom!='MEGA 1' and nav_nom!='MEGA 2' and nav_nom!='MEGA 4') ";
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_nav group by nav_cd_pr order by qte desc";
$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
while (($nav_cd_pr,$null)=$sth->fetchrow_array){
	&save("insert into liste2 values ('$nav_cd_pr','$i')","af");
	$i++;
}


if ($action eq ""){
	print "<table border=1 cellspacing=0><tr><th>Navire</th>";
	for ($i=7;$i>=0;$i--){
		$date=&get("select date_sub(curdate(), interval $i day)","af");
		print "<td>$date</td>";
	}
	print "</tr>";

	$query="select nav_nom,nav_number from navire where nav_number>0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	while (($nav_nom,$nav_number)=$sth->fetchrow_array){
		print "<tr><th>$nav_nom</th>";
		$total=0;
		for ($i=7;$i>=0;$i--){
			$date=&get("select date_sub(curdate(), interval $i day)","af");
			$qte=&get("select sum(vda_qte) from vendu_corsica_auto,produit where vda_date='$date' and vda_navire=$nav_number and vda_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) ","af");
			print "<td>$qte</td>";
			$total+=$qte;	
		}
		print "<th>$total</th></tr>";
	}
	print "</table>";

}
if ($action eq "go")
{
        $nom=&get("select nav_nom from navire where nav_number=$navire");
	print "<h3> ventes du $date pour le navire $nom</h3><br>";
	print "<br><br><b> Parfums cosmetique </b></br>";
	print "<table border=0><tr><td>&nbsp;</td><td>&nbsp;</td><th>vente</th><th>ranking (-1=aucune vente sur 3 mois)</th></tr>";
	$total=0;
	$query="select vda_cd_pr,vda_qte,pr_desi from vendu_corsica_auto,produit where vda_date='$date' and vda_navire=$navire and vda_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($vda_cd_pr,$vda_qte,$pr_desi)=$sth->fetchrow_array){
		$rank_fam1=&get("select tmp_rank from liste1 where tmp_cd_pr=$vda_cd_pr");
		$rank_fam2=&get("select tmp_rank from liste2 where tmp_cd_pr=$vda_cd_pr");
		if (grep /$nom/,@liste){$info=$rank_fam1;}else{$info=$rank_fam2;}
		if ($info eq ""){$info=-1;}
		print "<tr><td><a href=?action=prod&navire=$navire&date=$date&pr_cd_pr=$vda_cd_pr>$vda_cd_pr</a></td><td>$pr_desi</td><td><b>$vda_qte</td>";
		$check=&get("select sum(tva_qte) from corsica_tva where tva_date='$date' and tva_refour='$vda_cd_pr' and tva_nom='$nom'")+0;
		print "<td>$check</td>";
		print "<td>$info</td></tr>";
		$total+=$vda_qte;
	}
	print "</table>";
	print "total:$total<br>";
	print "<br><br><b>Autres</b><br>";
	print "<table border=0>";
	$query="select vda_cd_pr,vda_qte from vendu_corsica_auto,produit where vda_date='$date' and vda_navire=$navire and vda_cd_pr=pr_cd_pr and (pr_type!=1 and pr_type!=5)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($vda_cd_pr,$vda_qte)=$sth->fetchrow_array){
		($pr_desi)=&get("select pr_desi from produit where pr_cd_pr=$vda_cd_pr");
		print "<tr><td><a href=?action=prod&navire=$nav_number&date=$ti_date&pr_cd_pr=$vda_cd_pr>$vda_cd_pr</a></td><td>$pr_desi</td><td>$vda_qte</td></tr>";
	}
	print "</table>";
}

if ($action eq "prod")
{
	
	$nom=&get("select nav_nom from navire where nav_number=$navire");
	$rank_fam1=&get("select tmp_rank from liste1 where tmp_cd_pr=$pr_cd_pr");
	$rank_fam2=&get("select tmp_rank from liste2 where tmp_cd_pr=$pr_cd_pr");
	if (grep /$nom/,@liste){$info=$rank_fam1;}else{$info=$rank_fam2;}
	if ($info eq ""){$info=-1;}

	$desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
	print "<b>$nom<br>$pr_cd_pr $desi</b><br>";
	for ($i=0;$i<7;$i++){
		$semaine[$i]=&get("select curdate() - interval weekday(curdate()) day + interval $i day");
	}
	$dateinv=&get("select curdate() - interval weekday(curdate()) day - interval 1 day");
	$date_mini=&datesimple($dateinv);	
	print "<table border=1><tr><th>Inventaire</th><th>Lundi</th><th>Mardi</th><th>Mercredi</th><tH>Jeudi</th><th>Vendredi</th><th>Samedi</th><th>Dimanche</th><th>Livraison en cours</th><th>ranking (-1=aucune vente sur 3 mois)</th></tr><tr>";
	print "<td>$dateinv</td>";
	for ($i=0;$i<7;$i++){
		print "<td>$semaine[$i]</td>";
	}
	print "</tr><tr>";
	$qte=&get("select nav_qte from navire2 where nav_nom='$nom' and nav_cd_pr=$pr_cd_pr and nav_type=1 and nav_date='$dateinv'"); 
	print "<td>$qte</td>";
	for ($i=0;$i<7;$i++){
		$qte=&get("select vda_qte from vendu_corsica_auto where vda_date='$semaine[$i]' and vda_navire=$navire and vda_cd_pr='$pr_cd_pr'","af")+0;
		$check=&get("select count(*) from vendu_corsica_auto where vda_date='$semaine[$i]' and vda_navire=$navire","af")+0;
		if ($check==0){print "<td bgcolor=grey>&nbsp;</td>";}
		else {	print "<td>$qte</td>";  }

	}
	$qte=&get("select sum(coc_qte)/100 from comcli,infococ2 where coc_cd_pr=$pr_cd_pr  and coc_no=ic2_no and ic2_com1='$nom' and coc_in_pos=5 and ic2_date>='$date_mini'","af");
	print "<td>$qte</td><td>$info</td>";	
	print "</tr></table>";	
}
