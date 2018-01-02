#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;

require "./src/connect.src";

&save("create temporary table liste1 (four int(10) NOT NULL,sem int(2) NOT NULL,val int(10), PRIMARY KEY (`four`,`sem`))");

$query="select distinct enh_no,weekofyear(from_unixtime(enh_date*24*60*60,'%Y-%m-%d')) from enthead where enh_date >13879";
$sth=$dbh->prepare($query);
$sth->execute();
while (($no,$sem)=$sth->fetchrow_array)
	{
	$four=&get("select pr_four from produit,entbody where enb_no='$no' and enb_cdpr=pr_cd_pr limit 1 ");
	$val=&get("select floor(sum(pr_prac*enb_quantite/100)/100)_four from produit,entbody where enb_no='$no' and enb_cdpr=pr_cd_pr and (pr_type=1 or pr_type=5) ");
	$val+=&get("select val from liste1 where sem='$sem' and four='$four'","af")+0;
	
	&save("replace into liste1 values ('$four','$sem','$val')","af");
}
print "<table border=2 cellspacing=0>
<tr><td>&nbsp</td><td colspan=4><b>Juin</td><td colspan=5><b>juillet</td><td colspan=4><b>aout</td></tr>
<tr><th>Four</th>";
for ($i=23;$i<=35;$i++){
	print "<th>";
	if ($i==$sem){print "<font color=red>";}
	print "$i</th>";
}
print "<td>delai maxi</td></tr>";
$query="select distinct four,fo2_add from liste1,fournis where four=fo2_cd_fo and val>=1000 and (sem>=23 and sem<=35)order by four";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_four,$fo2_desi)=$sth->fetchrow_array)
{
	$j=1;
	$max=0;
	print "<tr><td>$pr_four $fo2_desi</td>";
	for ($i=23;$i<=35;$i++){
		$val=&get("select val from liste1 where sem=$i and four=$pr_four","af")+0;
		if ($val<=1000){
			print "<td>&nbsp;</td>";
			$j++;	
			if ($j>$max){$max=$j;}

		}
		else
		{
			print "<td>X</td>";
			if ($j>$max){$max=$j;}
			$j=1;	
		}
	}
	print "<td>$max</td></tr>";
}
print "</table>";
