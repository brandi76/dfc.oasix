#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;

$action=$html->param("action");
$produit=$html->param("produit");
$option=$html->param("option");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>Livraison a venir</title></head>";
print "<body link=black>";


require "./src/connect.src";
print "<center><h1>Besoin s+2 s+3 <br><br>";
print "<form>";
print "<br>Code produit<br><input type=text name=produit><bR>";
print "<br><input type=hidden name=action value=go><input type=submit value='envoie'></form><br>"; 
$process=$$;

&save("create temporary table liste1$process (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
$liste_nav="and (nav_nom='MEGA 1' or nav_nom='MEGA 2' or nav_nom='MEGA 4') ";
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_navire group by nav_cd_pr order by qte desc";
$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
while (($nav_cd_pr,$null)=$sth->fetchrow_array){
	&save("insert into liste1$process values ('$nav_cd_pr','$i')","af");
	$i++;
}
&save("create temporary table liste2$process (tmp_cd_pr bigint(20) NOT NULL,tmp_rank int(5) NOT NULL,PRIMARY KEY (tmp_cd_pr))");
$liste_nav="and (nav_nom!='MEGA 1' and nav_nom!='MEGA 2' and nav_nom!='MEGA 4') ";
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) $liste_navire group by nav_cd_pr order by qte desc";
$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
while (($nav_cd_pr,$null)=$sth->fetchrow_array){
	&save("insert into liste2$process values ('$nav_cd_pr','$i')","af");
	$i++;
}
if ($action eq "go"){
	$semaine=&semaine("")+1;
	$query="select nav_nom from navire,semaine2 where nav_nom=se_navire and se_no>=$semaine and se_no<=$semaine+4 and se_coef!=0 group by nav_nom order by nav_nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nom)=$sth->fetchrow_array){
		push (@navire,"$nom");
	}
	print "<form><table border=1 cellspacing=0 width=100%><tr><td colspan=2>&nbsp;</td>";
	foreach $nom (@navire) {
		print "<th";
		print "><font size=-1>";
		for ($i=0;$i<length($nom);$i++){
			$digit=substr($nom,$i,1);
	 		print "$digit<br>";
		}
	}
	print "</font></th>";
	print "</tr>";
	$nbnavire=$#navire+1;
	$query="select pr_cd_pr,pr_desi from produit where pr_cd_pr='$produit'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$rank_fam1=&get("select tmp_rank from liste1$process where tmp_cd_pr=$pr_cd_pr");
		$rank_fam2=&get("select tmp_rank from liste2$process where tmp_cd_pr=$pr_cd_pr");
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
		foreach $navire (@navire) {
			print "<td align=right>";
			$besoin=0;
			$stock_navire=&stock_navire($pr_cd_pr,"$navire")+0;
			%res=&tablenew_navire($pr_cd_pr,$rank_fam1,$rank_fam2,"$navire");          
			$stock_navire=$stock_navire-$res{"s+0"}-$res{"s+1"};
			if ($stock_navire<0){$stock_navire=0;}
			$besoin=($res{"s+2"}+$res{"s+3"})-$stock_navire;
			$flag=&get("select count(*) from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_type=0")+0;
			if ($flag==0){$besoin=0;}  # produit non reference sur le bateau
			if ($besoin<0){$besoin=0;}
			$total+=$besoin;
#  			print $res{"s+1"};
			print " $besoin</td>";
		}
		print "<td align=right><b>$total</td>";
		print "</tr>";
	}
	print "</table>";
}	


# -E Livraison a venir detail