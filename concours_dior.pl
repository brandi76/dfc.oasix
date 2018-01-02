#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$four=$html->param("four");
$premier=$html->param("premier");
$dernier=$html->param("dernier");
$client=$html->param("client");
$action=$html->param("action");

require "./src/connect.src";
if ($action eq "go"){&go();}
else {
print "<center>Concours<br><form>Premiere date (MMAA):<input type=text name=premier> Dermiere date (MMAA):<input type=text name=dernier><br>";
print " Code client:<input type=text name=client> Fournisseur:<input type=text name=four><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";	

}
sub go{
$query="select v_code,v_date,v_vol,v_cd_cl from vol,rotation,produit where v_date%1000>=$premier  and v_date%1000<$dernier and ro_cd_pr=pr_cd_pr and pr_four=$four and v_cd_cl=$client and ro_code=v_code group by v_code ";
print $query;
$sth=$dbh->prepare($query);
$sth->execute();
$query="select cl_nom from client where cl_cd_cl=$client";
$sth3=$dbh->prepare($query);
$sth3->execute();
($cl_nom)=$sth3->fetchrow_array;
$query="select fo2_add from fournis where fo2_cd_fo=$four";
$sth3=$dbh->prepare($query);
$sth3->execute();
($fo_nom)=$sth3->fetchrow_array;
($fo_nom)=split(/\*/,$fo_nom);
print "<h3><font color=navy>Concours $fo_nom du $premier au $dernier</h3></font><br><br>";
while (($v_code,$v_date,$v_vol,$v_cd_cl)=$sth->fetchrow_array){
	$first=1;
	$total=0;
	$query="select ro_cd_pr,pr_desi,floor(ro_qte/100) from rotation,produit where ro_cd_pr=pr_cd_pr and pr_four=$four and ro_code=$v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$pr_desi,$qte)=$sth2->fetchrow_array){
		if ($first){&titre();}
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td></tr>";
		$total+=$qte;
	}
	if ($total>0){print "<tr><th colspan=2>TOTAL</th><th align=right>$total</th></table><br>";}
}
}
sub titre {
	print "<b>$cl_nom Vol:$v_vol du $v_date bon appro No:$v_code<br><table border=1 width=500>";
	$first=0;
}	
