#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require "./src/connect.src";

$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
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
print "<b>Ecart entre la fiche de caisse et le montant constaté<br>";
print "<table border=1 cellspacing=0>";
print "<tr><th>Appro</th><th>Date</th><th>No vol</th><th>Destination</th><th>C/c</th><th>Caisse annoncée</th><th>Caisse constatée</th><th>Justificatif</th></tr>";
$query="select v_code,v_vol,v_dest,v_date,ec_appro,ec_rot,ec_annonce,ec_justificatif from ecart_caisse,vol  where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=ec_rot and v_code=ec_appro and v_code >0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_vol,$v_dest,$v_date,$ec_appro,$ec_rot,$ec_annonce,$ec_justificatif)=$sth->fetchrow_array){
	print "<td align=right nowrap>$v_code</td><td align=right nowrap>$v_date</td>";
	print "<td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
	$query="select eq_cc,eq_equipage from equipagesql where eq_code='$v_code' and eq_rot='$ec_rot'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($eq_cc,$eq_tri)=$sth2->fetchrow_array;
	print "<td>$eq_cc</td>";
	$montant_caisse=&get("select sum(ca_total) from caissesql where ca_code='$v_code' and ca_rot=$ec_rot")+0;
	print "<td>$ec_annonce</td><td>$montant_caisse</td><td>$ec_justificatif</td></tr>";
}
print "</table>";

print "<b>Ecart entre le montant tpe et la caisse<br>";
print "<table border=1 cellspacing=0>";
print "<tr><th>Appro</th><th>Date</th><th>No vol</th><th>Destination</th><th>C/c</th><th>Montant Tpe</th><th>Montant Caisse</th><th>Info</th></tr>";
$query="select v_code,v_vol,v_dest,v_date,ca_rot,ca_total from vol,caissesql  where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=ca_rot and v_code=ca_code and v_code >0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_vol,$v_dest,$v_date,$ca_rot,$montant_caisse)=$sth->fetchrow_array){
	$query="select oaa_serial,oaa_date from oasix_appro where oaa_appro=$v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($oaa_serial,$oaa_date)=$sth2->fetchrow_array;
	$rot_file="vente".$ca_rot.".txt";
	$montant_tpe=&get("select sum(oa_col3) from oasix where oa_type='p' and oa_serial='$oaa_serial' and oa_date_import='$oaa_date' and oa_rotation='$rot_file'","af")+0;
	if ($montant_tpe==$montant_caisse){next;}
	print "<td align=right nowrap>$v_code</td><td align=right nowrap>$v_date</td>";
	print "<td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
	$query="select eq_cc,eq_equipage from equipagesql where eq_code='$v_code' and eq_rot='$ca_rot'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($eq_cc,$eq_tri)=$sth2->fetchrow_array;
	print "<td>$eq_cc</td>";
	$comment=&get("select infr_comment from inforetsql where infr_code=$v_code");
	print "<td>$montant_tpe</td><td>$montant_caisse</td><td>$comment</td></tr>";
}
print "</table>";

print "<b>Ecart entre les vendus constatés et la caisse<br>";
print "<table border=1 cellspacing=0>";
print "<tr><th>Appro</th><th>Date</th><th>No vol</th><th>Destination</th><th>C/c</th><th>Montant vendu</th><th>Montant Caisse</th><th>Info</th></tr>";
$query="select v_code,v_vol,v_dest,v_date,infr_caisseth from vol,inforetsql where v_cd_cl='$client' and v_date%10000='$mois' and v_code=infr_code and v_rot=1 and v_code >0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_vol,$v_dest,$v_date,$montant_vendu)=$sth->fetchrow_array){
	$montant_caisse=&get("select sum(ca_total) from caissesql where ca_code='$v_code'","af")+0;
	$ecart=$montant_vendu-$montant_caisse;
	if ($ecart>-10&&$ecart<10){next;}
	print "<td align=right nowrap>$v_code</td><td align=right nowrap>$v_date</td>";
	print "<td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
	$query="select eq_cc from equipagesql where eq_code='$v_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	print "<td>";
	while (($eq_cc)=$sth2->fetchrow_array){
		print "$eq_cc ";
	}
	print "</td>";
	$comment=&get("select infr_comment from inforetsql where infr_code=$v_code");
	print "<td>$montant_vendu</td><td>$montant_caisse</td><td>$comment</td></tr>";
}
print "</table>";
}






=pod











print "<table border=1 cellspacing=0>";
print "<tr><th>Appro</th><th>Date</th><th>No vol</th><th>Destination</th><th>Vendu tpe</th><th>Vendu constaté</th><th>Caisse annoncée</th><th>Caisse constatée</th></tr>";
while (($code)=$sth->fetchrow_array){
	$query="select v_code,v_rot,v_vol,v_date,v_dest from vol where v_code='$code' and v_rot=1";
	$sthb=$dbh->prepare($query);
	$sthb->execute();
	while (($v_code,$v_rot,$v_vol,$v_date,$v_dest)=$sthb->fetchrow_array){
		$montant_tpe=&get("select infr_caissepn from inforetsql where infr_code='$v_code'")+0;
		$montant_fly=&get("select infr_caisseth from inforetsql where infr_code='$v_code'")+0;
		$montant_caisse=&get("select sum(ca_total) from caissesql where ca_code='$v_code'")+0;
		next if ($montant_fly==0);
		print "<tr>";
		print "<td align=right nowrap>$v_code</td><td align=right nowrap>$v_date</td>";
		print "<td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
		print "<td align=right nowrap>$montant_tpe</td><td align=right nowrap>$montant_fly</td><td align=right nowrap>$montant_caisse</td>";

# 
# 		$eq_tri="";
# 		$query="select eq_cc,eq_equipage from equipagesql where eq_code='$v_code' and eq_rot='$v_rot'";
# 		$sth2=$dbh->prepare($query);
# 		$sth2->execute();
# 		($eq_cc,$eq_tri)=$sth2->fetchrow_array;
# 		print "<td><b>$eq_cc</b>$eq_tri</td>";
		print "</tr>";
	}
	
}
		
print "</table>";
}
# -E recap des caisses fly
