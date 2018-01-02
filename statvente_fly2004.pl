#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "<body><center><h1>2004</h1>";


require "./src/connect.src";

$query="select pr_four,fo2_add from produit,ordre,fournis where fo2_cd_fo=pr_four and pr_cd_pr=ord_cd_pr  group by pr_four order by pr_four";
$sth3=$dbh->prepare($query);
$sth3->execute();
while (($pr_four,$fo_nom)=$sth3->fetchrow_array){
	$query="select floor(sum(ro_qte)/100) from rotation,vol,produit where ro_code=v_code and floor(v_date%100)=4 and ro_cd_pr=pr_cd_pr and pr_four='$pr_four'" ;
	$sth=$dbh->prepare($query);
	$sth->execute();
	($qte)=$sth->fetchrow_array;
	$qte+=0;
	if ($qte==0){next;}
	$totalf=0;
	print "<h3>$pr_four $fo_nom</h3><br>";
	print "<table cellspacing=0 border=1>";
	print "<tr bgcolor=#efefef><th>&nbsp;</th><th>Janvier</th><th>Février</th><th>Mars</th><th>Avril</th><th>Mai</th><th>Juin</th><th>Juillet</th><th>Août</th><th>Septembre</th><th>Octobre</th><th>Novembre</th><th>Décembre</th></tr>\n";
	
	$query="select pr_cd_pr,pr_desi from produit,ordre where pr_cd_pr=ord_cd_pr and pr_sup=0 and pr_four='$pr_four'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	
	while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array){
		print "<tr><td width=30%>$pr_cd_pr $pr_desi</td>";
		$total=0;
		$totalgen=0;
		for ($i=104;$i<1304;$i=$i+100){
			$query="select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and floor(v_date%10000)=$i and ro_cd_pr=$pr_cd_pr" ;
			$sth=$dbh->prepare($query);
			$sth->execute();
			($qte)=$sth->fetchrow_array;
			$qte+=0;
			print "<td align=right>$qte</td>";
			$total+=$qte;
		}
		print "<td align=right>$total</td></tr>";
		$totalf+=$total;
	}
	print "<tr><td colspan=13>Total pieces</td><td align=right><b>$totalf</td></tr>";
	$totalg+=$totalf;
	print "</table>";
}
print "<b>Total pieces:$totalg";