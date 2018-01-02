#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";

require("./src/connect.src");
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
print "<title>CA par famille</title>";
if ($mois eq ""){
	($null,$null,$null,$null,$mois,$annee,$null,$null,$null) = localtime(time);    
	$mois=$mois*100+$annee;
}	
if ($action eq ""){&premiere();}
if ($action eq "go"){
	&go();
}

if ($action eq "client"){&clien();}
sub premiere{

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=10><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";

}

sub clien{
	$query="select distinct cl_cd_cl,cl_nom from vol,client where v_cd_cl=cl_cd_cl order by v_cd_cl";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
		print "$cl_cd_cl $cl_nom <br>";
	}
}
sub go{
	$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;
	
	print "Mois:$mois   Client:$cl_nom <br>";
	
	$query="select ret_cd_pr,sum(ret_qte),sum(ret_qte-ret_retourpnc) from retoursql,vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 and v_code=ret_code group by ret_cd_pr order by ret_cd_pr";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 bordercolor=black cellspacing=0 style=\"border: solid;\"><tr><th>Produit</th><th>prix de vente</th><th>Qte départ</th><th>Qte vente</th><th>Ca </th></tr>";
	while (($pr_cd_pr,$qtedep,$qtevdu)=$sth->fetchrow_array){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'","af");
		$prix=&get("select ret_prix from retoursql,vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 and v_code=ret_code and ret_cd_pr='$pr_cd_pr'");
		$ca=$prix*$qtevdu;
		print "<tr><td>$pr_desi</td><td>$prix</td><td>$qtedep</td><td>$qtevdu</td><td>$ca</td></tr>";
	}
	print "</table>";
}
