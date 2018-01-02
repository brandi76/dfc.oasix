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
$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where pr_prac>0 and pr_prac<30000 order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();

print "stock comptable <br>";
print "<table><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
{
		%stock=&stock($pr_cd_pr,'',"quick");
		$stck=$stock{"pr_stre"};
		# if ($stck <0){next;}
		if ($stck==0){next;}
		
# 		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
# 		$sth3=$dbh->prepare($query2);
# 		$sth3->execute();
# 		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
	        $pr_prac=&prac($pr_cd_pr);
	
		$total=$stck*$pr_prac;
		$total_gen+=$total;
		
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
}
print "</table>";
print "<b>total:$total_gen</b>";
