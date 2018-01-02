#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
#$action="go";
#$client=123;
#$mois=604;

if ($action eq ""){&premiere();}
if ($action eq "go"){&go();}

sub premiere{

print "<center>Miniature<br><form>Mois (MMAA):<input type=text name=mois><br>";
print "Trolley type<input type=text name=client><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";	

}


sub go{
$query="select cl_nom from client where cl_cd_cl=floor($client/10)";
$sth=$dbh->prepare($query);
$sth->execute();
($cl_nom)=$sth->fetchrow_array;
print "Mois:$mois   Client:$cl_nom <br>";

$query="select v_code,v_date,v_vol from vol,etatap where v_troltype='$client' and v_date%10000='$mois' and at_code=v_code and at_etat>0 group by v_code";

$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_date,$v_vol)=$sth->fetchrow_array){
	print "<b>Vol:$v_vol du $v_date bon appro No:$v_code<br><table border=0 width=500>";
	$query="select ro_cd_pr,pr_desi,floor(ro_qte/100) from rotation,produit where ro_cd_pr=pr_cd_pr and (pr_type=15 or pr_type=203) and ro_code=$v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	if ($client==3384){
		$query="select ap_cd_pr,pr_desi,floor(ap_qte0/100) from appro,produit where ap_cd_pr=pr_cd_pr and (pr_type=15 or pr_type=203) and ap_code=$v_code and ap_qte0>0";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
	}		
	$total=0;
	while (($pr_cd_pr,$pr_desi,$qte)=$sth2->fetchrow_array){
		if ($qte<0) {next;}
		$prix=0;
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td>";
		if (($pr_cd_pr==120536)||($pr_cd_pr==120535)||($pr_cd_pr==120050)){$prix=1.75;}
		if (($pr_cd_pr==122069)){$prix=6.95;}
		if (($pr_cd_pr==122072)){$prix=6.95;}
		if (($pr_cd_pr==122073)){$prix=6.95;}
		if (($pr_cd_pr==120053)){$prix=24.60;}
		if (($pr_cd_pr==122071)){$prix=3.35;}

		if (($pr_cd_pr==122069)&&($client==338)){$prix=3.00;}
		if (($pr_cd_pr==160180)){$prix=0.49;}
		if (($pr_cd_pr==120571)){$prix=1.85;}
		if (($pr_cd_pr==120452)){$prix=1.85;}
		if (($pr_cd_pr==120450)){$prix=1.85;}
		if (($pr_cd_pr==122070)){$prix=10.45;}
		if (($pr_cd_pr==120693)||($pr_cd_pr==120455)||($pr_cd_pr==120692)||($pr_cd_pr==121100)||($pr_cd_pr==120051)){$prix=2.25;}
		if (($pr_cd_pr==120572)||($pr_cd_pr==120570)||($pr_cd_pr==120682)||($pr_cd_pr==120556)||($pr_cd_pr==120620)||($pr_cd_pr==120400)){$prix=1.85;}
		if (($pr_cd_pr==120673)||($pr_cd_pr==120676)||($pr_cd_pr==120660)||($pr_cd_pr==135300)){$prix=2.05;}
		if ($pr_cd_pr==120052){$prix=16;}
		$mont=$prix*$qte;
		$total+=$mont;
		print "<td align=right>$prix</td><td align=right>$mont</td></tr>";
	}
	if ($client!=3384){
		print "<tr><td>&nbsp;</td><td>Prestation</td><td align=right>1</td><td align=right>13</td><td align=right>13</td></tr>";
		$total+=13;
	}
	print "<tr><th colspan=4>TOTAL</th><th align=right>$total</th></table>";
	$totalgen+=$total;
}
print "Total à facturer:$totalgen";
}