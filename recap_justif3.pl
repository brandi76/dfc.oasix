#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require "./src/connect.src";

$mois=$html->param("mois");
$mois2=$html->param("mois2"); # pour avoir sur un an ( a mettre a la main)
$client=$html->param("client");
$action=$html->param("action");
if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
if ($mois2 eq ""){$mois2=$mois;}
if ($action eq ""){&premiere();}
if ($action eq "go"){&go();}
if ($action eq "client"){&clien();}

sub premiere{

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";	

}


sub clien{
	$query="select distinct cl_cd_cl,cl_nom from client,trolley where floor(tr_code/10)=cl_cd_cl order by cl_cd_cl";
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
print "<b>Ecart produit<br>";
print "<table border=1 cellspacing=0>";
print "<tr><th>Appro</th><th>Date</th><th>No vol</th><th>Destination</th><th>C/c</th><th>Ecart produit</th></tr>";
$query="select v_code,v_vol,v_dest,v_date from vol  where v_cd_cl='$client' and v_date%10000>='$mois' and v_date%10000<='$mois2' and v_rot=1 and v_code >0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_vol,$v_dest,$v_date,$ec_appro,$ec_rot,$ec_annonce,$ec_justificatif)=$sth->fetchrow_array){
	if (&get("select infr_caisseth from inforetsql where infr_code=$v_code")+0==0){next;}
	print "<tr><td>$v_code</td><td>$v_date</td><td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
	$query="select eq_cc,eq_equipage from equipagesql where eq_code='$v_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	print "<td>";
	while (($eq_cc,$eq_tri)=$sth2->fetchrow_array){
	print "$eq_cc";
	}
	print "</td><td>";
	$passe=0;
	$query="select ret_cd_pr,pr_desi,ret_qte,ret_retour,ret_retourpnc,ret_prix from retoursql,produit where ret_code='$v_code' and ret_cd_pr=pr_cd_pr";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($ret_cd_pr,$pr_desi,$ret_qte,$ret_retour,$ret_retourpnc,$ret_prix)=$sth2->fetchrow_array){
        	if (($ret_retour>$ret_qte)||($ret_retourpnc!=$ret_retour)){
        		if ($ret_retour >$ret_qte){$ecart=$ret_retour-$ret_qte;$color="black"}
        		else {$ecart=$ret_retour-$ret_retourpnc;$color="black"}
        		print "<font color=$color>$ret_cd_pr;$pr_desi;$ecart;$ret_prix</font><br>";
        		$passe++;
        	}
        }
        if ($passe==0){print "<b>Pas d'ecart</b>";}
	print "</td></tr>";
}
print "</table>";
}
# -E recap des caisses fly
