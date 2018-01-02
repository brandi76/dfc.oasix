#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>corsica poids</title>";
require "./src/connect.src";
$date="1".`/bin/date +%y%m%d`;
$max=&get("select max(ic2_fact) from infococ2 where ic2_cd_cl=500 and ic2_date=$date");
$max-=15;
$query="select distinct ic2_no,ic2_com1 from infococ2 where ic2_cd_cl=500 and ic2_fact>=$max";
$sth=$dbh->prepare($query);
$sth->execute();
while (($no,$navire)=$sth->fetchrow_array)
	{
		$nbparf=&get("select sum(coc_qte)/100 from comcli,produit where coc_no='$no' and coc_cd_pr=pr_cd_pr and pr_type=1","af");
		$nbcosm=&get("select sum(coc_qte)/100 from comcli,produit where coc_no='$no' and coc_cd_pr=pr_cd_pr and pr_type=5","af");
                $poids=$nbparf*0.250+$nbcosm*0.170;
		print "$no $navire $nbparf $nbcosm $poids<br>";
		$total+=$poids;
}
	
	print "total:$total";