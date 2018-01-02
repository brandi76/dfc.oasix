#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";

	print $html->header;
	print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
	<!--
	#saut { page-break-after : right }
	-->
	</style></head><body>";

require "./src/connect.src";
$trolley=307;
# trolley de reference
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_prac>0 and pr_prac<30000) and pr_cd_pr in (select nav_cd_pr from navire2,produit where nav_nom='MEGA 2' and nav_type=0 and (pr_type=1 or pr_type=5)) order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
print "stock maritime fiable <br>";
print "<table border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
&go();
print "</table>";

$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_prac>0 and pr_prac<30000) and pr_cd_pr in (select tr_cd_pr from trolley where tr_code=$trolley)";
$sth=$dbh->prepare($query);
$sth->execute();
print "stock aerien fiable <br>";
print "<table  border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
&go();
print "</table>";

$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_prac>0 and pr_prac<30000) and  pr_cd_pr not in (select tr_cd_pr from trolley where tr_code=$trolley) and pr_cd_pr not in (select nav_cd_pr from navire2,produit where nav_nom='MEGA 2' and nav_type=0 and (pr_type=1 or pr_type=5))";
$sth=$dbh->prepare($query);
$sth->execute();

print "stock mort fiable<br>";
print "<table  border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
&go();
print "</table>";
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_prac<0 or pr_prac>30000) order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();

print "stock mort sujet à caution<br>";
print "<table border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
&go();
print "</table>";
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_prac<0 or pr_prac>30000) order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
print "produit erroné <br>";
print "<table border=1 cellspacing=0><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
&go();
print "</table>";


sub go()
{
$total_gen=0;
while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_ventil)=$sth->fetchrow_array)
{
		%stock=&stock($pr_cd_pr,'',"quick");
		$stck=$stock{"pr_stre"};
		if ($stck <=0){next;}
		$prac=&prac($pr_prac);
		$total=$stck*$pr_prac;
		$total_gen+=$total;
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
}
print "<tr><td>total:".int($total_gen)."</td></tr>";
}
