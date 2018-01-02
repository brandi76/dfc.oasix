#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
$html=new CGI;
print $html->header;
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>inventaire</title></head><body>";

require "../oasix/outils_perl2.lib";
require "./src/connect.src";

$navire="MARINA";
$date="2007-10-07";
print "<table border=1 cellspacing=0>";
$query="select nav_cd_pr,nav_qte from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nav_cd_pr,$qte)=$sth->fetchrow_array){
	if ($qte==0){next;}
	$sth2=$dbh->prepare("select pr_desi,pr_prac/100,pr_sup from produit where pr_cd_pr='$nav_cd_pr'");
	$sth2->execute();
	($pr_desi,$prac,$pr_sup)=$sth2->fetchrow_array;
	if ($pr_desi eq ""){
		$query="select nep_desi,nep_prac,nep_prx_vte from neptune where nep_codebarre='$nav_cd_pr'";			 
		$sth2=$dbh->prepare($query);
		$sth2->execute;
		($pr_desi,$prac,$nep_prx_vte)=$sth2->fetchrow_array;
		if ($pr_desi ne "") {
			while ($pr_desi=~s/'/ /){};
			&save("insert ignore into produit value ('$nav_cd_pr','$pr_desi','0','0','0','0','0','0','0','$nep_prx_vte','0','5','0','$prac','0','0','0','0','0','0','0','0','12','0','0','$pr_codebarre')","aff");
			$prac=$prac/100;
		}
		else
		{
		  	$pr_desi="Inconnu";
		}
	}
	$prac2=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'");
	if ($pr_desi eq "Inconnu"){
		 print "<tr><td>$nav_cd_pr</td><td>$qte</td></tr>";
	}
        else {
        	if ($pr_sup!=0 and $pr_sup!=2 and $pr_sup!=3){$prac=$prac2;}
        	if ($prac<=0){
			print "<tr bgcolor=red><td>$nav_cd_pr</td><td>$pr_desi</td><td>$pr_sup</td><td>$prac</td></tr>";
		}
		else {
			# print "<tr><td>$nav_cd_pr</td><td>$pr_desi</td><td>$qte</td><td>$prac</td></tr>";
                }
	}
}

print "</table>";