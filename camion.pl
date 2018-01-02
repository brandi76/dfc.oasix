#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
$action=$html->param("action");
$prem=$html->param("prem");
$dern=$html->param("dern");
$dateprem=$html->param("dateprem");
$datedern=$html->param("datedern");
$option=$html->param("option");

$cam_no=$html->param("cam_no");

print "<title> Regroupement commande</title>";
# print "*** $retour $action ****";
require "./src/connect.src";


if ($action eq ""){
	print "<form>
	Premiere commande <input type=text name=prem> ou Premiere date ex(1090810)<input type=text name=dateprem><br>
	Derniere commande <input type=text name=dern> ou Derniere date <input type=text name=datedern><br>
	Camion <input type=text name=cam_no><br>
        <br>option <input type=text name=option>
	<input type=hidden name=action value=creation>
	<input type=submit>
	</form>";
}
if (($action eq "creation")&&($prem ne "")){
	$query="select distinct ic2_com1 from infococ2 where ic2_no>=$prem and ic2_no<=$dern and ic2_cd_cl=500";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ic2_com1)=$sth->fetchrow_array){push (@navire,"$ic2_com1");}
	foreach $nav (@navire) {
		print "$nav <br>";
		$query="select ic2_no,ic2_fact from infococ2 where ic2_no>=$prem and ic2_no<=$dern and ic2_cd_cl=500 and ic2_com1='$nav' order by ic2_no";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($ic2_no,$no_fact)=$sth->fetchrow_array){
# 		 	if ($ic2_no ne ""){$no_cde=$ic2_no.";".$no_cde;}
# 		 	else {$no_cde=$ic2_no;}
# 		 }	
		$val=&get("select sum(coc_qte*coc_puni)/10000 from comcli where coc_no=$ic2_no and coc_in_pos!=6")+0;
		if ($option eq "miss") { $val=&get("select sum(coc_qte*coc_puni)/10000 from comcli where coc_no=$ic2_no and coc_in_pos=6 ")+0;}
		
$check=&get("select count(*) from comcli,produit where coc_no=$ic2_no and coc_puni=0 and coc_cd_pr=pr_cd_pr and pr_desi not like 'TEST%'");
                if ($check !=0){print "<font color=red> Prix à zéro </font>";}
		print "$no_cde ";
		$no_fact+=0;
		$no_fact=substr($no_fact,4,4);
	$total+=$val;		
		
	$lien= "<a href=http://ibs.oasix.fr/html2pdf_v3.18/exemples/facture_corsica.php?no_cde=$ic2_no&no_fact=$no_fact>commande:$ic2_no facture:$no_fact valeur:$val</a><br>";
		if ($option eq "miss"){
	  	$no_fact=&get("select ic2_com3 from infococ2 where ic2_no=$ic2_no","af");
$no_fact=substr($no_fact,4,4);
			       
$lien="<a href=http://ibs.oasix.fr/html2pdf_v3.18/exemples/facture_corsica.php?no_cde=$ic2_no&no_fact=$no_fact&option=miss>commande:$ic2_no valeur:$val</a><br>";
	       }
		    print $lien;
if ($cam_no ne ""){&save("replace into camion values ($cam_no,$ic2_no)","af");}

		}
	}
print "<br><b>total:$total ht</b></br>"
}

if (($action eq "creation")&&($prem eq "")&&($dern eq "")&& ($dateprem eq "")){
	$query="select distinct ic2_com1 from infococ2,camion where ic2_no=ca_no_cde and ca_no=$cam_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ic2_com1)=$sth->fetchrow_array){push (@navire,"$ic2_com1");}
	foreach $nav (@navire) {
		print "$nav <br>";
		$query="select ic2_no,ic2_fact from infococ2,camion where ic2_no=ca_no_cde and ca_no=$cam_no and ic2_com1='$nav' order by ic2_no";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($ic2_no,$no_fact)=$sth->fetchrow_array){
# 		 	if ($ic2_no ne ""){$no_cde=$ic2_no.";".$no_cde;}
# 		 	else {$no_cde=$ic2_no;}
# 		 }	
		$val=&get("select sum(coc_qte*coc_puni)/10000 from comcli where coc_no=$ic2_no and coc_in_pos!=6")+0;
		if ($option eq "miss") { $val=&get("select sum(coc_qte*coc_puni)/10000 from comcli where coc_no=$ic2_no and coc_in_pos=6 ")+0;}

$check=&get("select count(*) from comcli,produit where coc_no=$ic2_no and coc_puni=0 and coc_cd_pr=pr_cd_pr and pr_desi not like 'TEST%'");
                if ($check !=0){print "<font color=red> Prix à zéro </font>";}
				
print "$no_cde ";
		$no_fact+=0;
		$no_fact=substr($no_fact,4,4);
		print "<a href=http://ibs.oasix.fr/html2pdf_v3.18/exemples/facture_corsica.php?no_cde=$ic2_no&no_fact=$no_fact>commande:$ic2_no valeur:$val</a><br>";
		$total+=$val;		
		}
	}
print "<br><b>total:$total ht</b></br>"
}
if (($action eq "creation")&&($prem eq "")&&($dateprem ne "")){
	$query="select distinct ic2_com1 from infococ2 where ic2_date>='$dateprem' and ic2_date<='$datedern' and ic2_cd_cl=500";
# 	  print "$query";
$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ic2_com1)=$sth->fetchrow_array){push (@navire,"$ic2_com1");}
	foreach $nav (@navire) {
		print "$nav <br>";
		$query="select ic2_no,ic2_fact from infococ2 where ic2_date>=$dateprem and ic2_date<=$datedern and ic2_cd_cl=500 and ic2_com1='$nav' order by ic2_no";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($ic2_no,$no_fact)=$sth->fetchrow_array){
# 		 	if ($ic2_no ne ""){$no_cde=$ic2_no.";".$no_cde;}
# 		 	else {$no_cde=$ic2_no;}
# 		 }	
		$val=&get("select sum(coc_qte*coc_puni)/10000 from comcli where coc_no=$ic2_no and coc_in_pos!=6")+0;
		if ($option eq "miss") { $val=&get("select sum(coc_qte*coc_puni)/10000 from comcli where coc_no=$ic2_no and coc_in_pos=6 ")+0;}

$check=&get("select count(*) from comcli,produit where coc_no=$ic2_no and coc_puni=0 and coc_cd_pr=pr_cd_pr and pr_desi not like 'TEST%'");
                if ($check !=0){print "<font color=red> Prix à zéro </font>";}
				
print "$no_cde ";
		$no_fact+=0;
		$no_fact=substr($no_fact,4,4);
		print "<a href=http://ibs.oasix.fr/html2pdf_v3.18/exemples/facture_corsica.php?no_cde=$ic2_no&no_fact=$no_fact>commande:$ic2_no valeur:$val</a><br>";
		$total+=$val;		
		if ($cam_no ne ""){&save("replace into camion values ($cam_no,$ic2_no)","af");}

		}
	}
print "<br><b>total:$total ht</b></br>"
}
