#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;

print "<title>achat mensuel</title>";
require "./src/connect.src";

$query="select pr_cd_pr from produit";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr)=$sth->fetchrow_array){
	$pr_prac=&prac($pr_cd_pr);
	$existe=&get("select count(*) from produit2 where prb_cd_pr='$pr_cd_pr'")+0;
	if ($existe >0){
		&save("update produit2 set pr2_prac='$pr_prac' where prb_cd_pr='$pr_cd_pr'");
	}
		else
	{
		&save("insert into produit2 values ('$pr_cd_pr','','','$pr_prac')","af");
	}
}



print "<table>";
print "<tr><th>&nbsp;</th>";
for ($i=1;$i<13;$i++){
	print "<th>";
	print &cal($i);
	print "</th>"
}
print "</tr>";
$query="select distinct pr_four from  enthead,entbody,produit where enb_no=enh_no and enb_cdpr=pr_cd_pr and enh_date >13879 ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($four)=$sth->fetchrow_array)
{
	($desi)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$four'"));
	print "<tr><td><b>$desi</td>";
	for ($i=1;$i<13;$i++){
 		$val=&get("select sum(enb_quantite/100*pr2_prac) from  enthead,entbody,produit,produit2 where enb_no=enh_no and enb_cdpr=pr_cd_pr and prb_cd_pr=enb_cdpr and enh_date >13879 and month(from_unixtime(enh_date*24*60*60,'%Y-%m-%d'))=$i and pr_four='$four'")+0;
 		$val=int($val);
 		print "<td align=right>$val</td>";
#  		$val=&get("select sum(coc_qte/100*pr2_prac) from  infococ2,comcli,produit,produit2 where ic2_cd_cl=500 and coc_no=ic2_no and prb_cd_pr=coc_cd_pr and coc_cd_pr=pr_cd_pr and ic2_date >1080000 and ic2_date <1090000 and floor((ic2_date-1080000)/100)=$i and pr_four='$four'")+0;
#  		$val=int($val);
#  		print "<td align=right>$val</td>";
	
	}
	print "</tr>";
}
print "</table>";
