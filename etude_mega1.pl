#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>livraison</title></head><body>";


require "./src/connect.src";
# $dbh = DBI->connect("DBI:mysql:host=192.168.1.87:database=FLYDEV;","root","",{'RaiseError' => 1});

$action=$html->param("action");
$produit=$html->param("produit");
print "<table border=1 cellspacing=0><tr><th>&nbsp;</th><th>&nbsp;</th><th>ventes</th><th>livrer</th><th>retour</th>";                
$query="select nav_cd_pr,pr_desi,pr_sup from navire2,produit where nav_nom='MEGA 1' and nav_type=0 and nav_cd_pr=pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nav_cd_pr,$pr_desi,$pr_sup)=$sth->fetchrow_array)
{
		%calcul=&table_navire("MEGA 1",$nav_cd_pr);
                if ($calcul{'stock_entrepot'}<2 && (($pr_sup==7)||($pr_sup==1))){next; } # produit deliste
		$qtevendu=0+&get("select nav_qte from navire2 where nav_type=7 and nav_nom='MEGA 1' and nav_cd_pr=$nav_cd_pr");
		$qtelivre=0+&get("select sum(coc_qte/100) from comcli,infococ2 where coc_no=ic2_no and coc_cd_pr=$nav_cd_pr and ic2_cd_cl=500 and coc_qte >0 and ic2_date>1060101 and ic2_date <1061231 and ic2_com1='MEGA 1'");
		$qteretour=0+&get("select 0-sum(coc_qte/100) from comcli,infococ2 where coc_no=ic2_no and coc_cd_pr=$nav_cd_pr and ic2_cd_cl=500 and coc_qte <0 and ic2_date>1060101 and ic2_date <1061231 and ic2_com1='MEGA 1'");
		print "<tr ";
		if (($qtevendu==0)&&($qtelivre>0)){
			print "bgcolor=lightgreen";
		}	
		print "><td>$nav_cd_pr</td><td>$pr_desi</td>";
		print "<td>$qtevendu</td>";
		print "<td>$qtelivre</td>";
		print "<td>$qteretour</td>";
		print "</tr>";
	}
	print "</table>";
		
		
# -E etude livraison sortie vente du mega 1
