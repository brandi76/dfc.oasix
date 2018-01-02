$pr_cd_pr=$html->param("pr_cd_pr");
$premier=$html->param("premier");

require "./src/connect.src";

print "<form>";
require ("form_hidden.src");
print "<center> produit <input type=text name=pr_cd_pr value=$pr_cd_pr> Premier Bon <input type=text name=premier value=0> <input type=submit></form><center>";


if ($pr_cd_pr ne ""){
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
	print "<div class=titre>$pr_cd_pr $pr_desi</div>";
	print "<center><table border=1><tr><th>Date du vol</th><th>Appro</th><th>Vente</th></tr>";
	$query="select * from rotation where ro_cd_pr='$pr_cd_pr' order by ro_code";
	if ($premier ne ""){$query="select * from rotation where ro_cd_pr='$pr_cd_pr' and ro_code>='$premier' order by ro_code";}
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ro_code,$ro_rot,$ro_cd_pr,$ro_qte)=$sth->fetchrow_array)
	{
		$ro_qte/=100;
	$date=&get("select v_date from vol where v_code='$ro_code' and v_rot='$ro_rot'");
		print "<tr><td>$date</td><td>$ro_code</td><td align=right>$ro_qte</td></tr>";
		$total+=$ro_qte;
	}	
	print "</table>Total:$total</center>";
}
;1