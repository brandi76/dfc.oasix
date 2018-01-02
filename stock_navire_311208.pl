#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";

print "<title> bilan 2008</title>";

$query="select distinct nav_nom from navire2 where nav_date='2008-12-31' and nav_type=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire)=$sth->fetchrow_array)
{
	push (@navire,$navire);
}

foreach $navire (@navire){
	$val=0;
	$total=0;
	$parf=0;
	$autre=0;
	$query="select nav_cd_pr,nav_qte from navire2 where nav_date='2008-12-31' and nav_type=1 and nav_nom='$navire'" ;
	$sth = $dbh->prepare("$query" );
	$sth->execute;
	while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
	{
		$query="select pr_type,pr_sup from produit where pr_cd_pr='$nav_cd_pr'";
		$sth2 = $dbh->prepare("$query");
		$sth2->execute;
		($pr_type,$pr_sup)=$sth2->fetchrow_array;
	       	if (($pr_type==1 || $pr_type==5) && $pr_sup!=5 && $pr_sup!=6){$pr_prac=&prac($nav_cd_pr);$type=1;}
		else {
			$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'")+0;
			$type=0;
		}
		$val=$pr_prac*$nav_qte;	
		$total+=$val;
		if (($pr_type==1 || $pr_type==5) && $pr_sup!=5 && $pr_sup!=6){$parf+=$val;}
		else {$autre+=$val;}
		$desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
		print "$type;$navire;$nav_cd_pr;$desi;$nav_qte;$pr_prac<br>";
		
		
	}
	# print "$navire;$total;$parf;$autre<br>";
}