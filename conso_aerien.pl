#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
$four=$html->param("four");
$premier=$html->param("premier");
$dernier=$html->param("dernier");
$action=$html->param("action");
require "./src/connect.src";
# $query="select ro_qte/100,pr_prac/100,pr_prx_rev/100 from vol,rotation,produit where v_date%10=7 and v_date%1000>=107  and v_date%1000<=907 and ro_cd_pr=pr_cd_pr and ro_code=v_code and (pr_type=1 or pr_type=5)";
$query="select ro_code,ro_qte/100,pr_prac/100,pr_prx_rev/100 from vol,rotation,produit where v_date%10=7 and v_date%1000>=107  and v_date%1000<=907 and ro_cd_pr=pr_cd_pr and ro_code=v_code and v_rot=1 and pr_type!=15 order by ro_code";

$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$qte,$pr_prac,$pr_rem)=$sth->fetchrow_array){
	
	if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}
	$val=$pr_prac*$qte;	
	# print "$code $pr_prac $qte<br>";
	$total+=$val;
	$sum{$code}+=$val;
}	
print "$total<br>";
foreach $cle (keys(%sum)){
print "$cle;$sum{$cle};";
$caisse=&get("select ca_total from caissesql where ca_code='$cle'","ff");
print "$caisse<br>";
$total1+=$sum{$cle};
$total2+=$caisse;
}
print "<br>$total1 $total2 <br>";