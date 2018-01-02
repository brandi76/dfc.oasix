#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
print $html->header;

require "./src/connect.src";


$query="select pr_cd_pr from produit where pr_cd_pr>10000000 order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute;

while (($pr_cd_pr)=$sth->fetchrow_array){
  push (@produit,$pr_cd_pr);
}

$query="select ic2_com1 from infococ2 where ic2_no>7877 and ic2_cd_cl=500 group by ic2_com1";
$sth=$dbh->prepare($query);
$sth->execute;

while (($ic2_com1)=$sth->fetchrow_array){
  push (@navire,$ic2_com1);
}

print "<table border=1 cellspacing=0><tr bgcolor=yellow><th>";
foreach $navire (@navire){
		print "<th>$navire</th>";
		}
print "<th>Stock</th></tr>";

foreach $pr_cd_pr (@produit){
		$query="select pr_desi,pr_stre/100 from produit where pr_cd_pr=$pr_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute;
		($pr_desi,$pr_stre)=$sth->fetchrow_array;
		print "<tr><td>$pr_cd_pr $pr_desi</td>";
		foreach $navire (@navire){
			$query="select sum(coc_qte/100) from comcli,infococ2 where coc_no=ic2_no and ic2_com1='$navire' and coc_cd_pr=$pr_cd_pr and coc_in_pos=5";
			$sth2=$dbh->prepare($query);
			$sth2->execute;
			($coc_qte)=$sth2->fetchrow_array+0;
			print "<td align=right>$coc_qte</td>";
			}
		print "<td align=right>$pr_stre</td></tr>";
}
print "</table>";		


