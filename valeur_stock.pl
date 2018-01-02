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
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where pr_sup=0 and (pr_type=1 or pr_type=5) order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();

print "stock physique entrepot <br>";
print "<table><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
{
		%stock=&stock($pr_cd_pr,'',"");
		# $stck=$stock{"pr_stre"};
		$stck=$stock{"stock"};
	
		if ($stck==0){next;}
		$total=$stck*$pr_prac;
		$total_gen+=$total;
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
}
print "</table>";
print "<b>total:$total_gen</b>";
