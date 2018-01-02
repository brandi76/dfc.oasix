#!/usr/bin//perl
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
	
	$query="select v_code,v_vol,v_date,v_dest,ret_cd_pr,ret_qte,ret_qtepnc-ret_retour,ret_prix from retoursql,vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 and v_code=ret_code group by v_code,ret_cd_pr order by v_code,ret_cd_pr";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 bordercolor=black cellspacing=0 style=\"border: solid;\"><tr><th> No ref</td><th>no de Vol</th><th>Dest</th><th>date</th><th>Produit</th><th>prix de vente</th><th>Qte départ</th><th>Qte vente</th><th>Ca </th></tr>";
	while (($v_code,$v_vol,$v_date,$v_dest,$pr_cd_pr,$qtedep,$qtevdu,$prix)=$sth->fetchrow_array){
		if (($v_code ne $tampon)&&($tampon ne "")){
			print "<tr><th colspan=7>Total $vol $date</th><th>$total</th></tr>";
			$total=0;
		}
		$tampon=$v_code;
		$vol=$v_vol;
		$date=$v_date;
		
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'","af");
		$ca=$prix*$qtevdu;
		$total+=$ca;
		print "<tr><td>$v_code</td><td>$v_vol</td><td>$v_dest</td><td>$v_date</td><td>$pr_desi</td><td>$prix</td><td>$qtedep</td><td>$qtevdu</td><td>$ca</td></tr>";
	}
	if ($tampon ne ""){
		print "<tr><th colspan=8>Total $vol $date</th><th>$total</th></tr>";
		$total=0;
	}
	
	print "</table>";
}
