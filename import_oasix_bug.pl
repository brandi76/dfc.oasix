#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
$action=$html->param("action");
$oa_serial=$html->param("tpe");
$appro=$html->param("appro");

require "./src/connect.src";
print "<title>Importation oasix</title>";
if ($action eq ""){
	print "<body><center><h1>Importation oasix<br><form>";
	print "<br> Numero de tpe<br>";
	$sth = $dbh->prepare("select oa_num,oa_serial from oasix_tpe order by oa_num");
    	$sth->execute;
   	print "<br><select name=tpe>\n";
    	while (($oa_num,$oa_serial) = $sth->fetchrow_array) {
       		print "<option value=$oa_serial>";
       		print "$oa_num\n";
       	}
    	print "</select><br>\n";
    	print " Numero d'appro <input type=text name=appro size=5 value=$appro><bR>\n";
    	print "<br><input type=hidden name=action value=import><input type=submit value=importation></form></body>";
}
	

if ($action eq "import"){
	$num=&get("select oa_num from oasix_tpe where oa_serial='$oa_serial'");
	$day=0;
	$query="select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)";
	if (&get($query)==0){
		$day=1;
		$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)";
		if (&get($query)==0){
			$day=2;
			$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)";
			if (&get($query)==0){
				$day=3;
			        $query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)";
				if (&get($query)==0){
					$day=4;
					$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)";
					if (&get($query)==0){
						$day=5;
				        	$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)";
						if (&get($query)==0){
							$day=6;
						}
					}
				}
			}
		}
	}
    	$sth = $dbh->prepare("select * from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)");
    	$sth->execute;
    	$troltype=&get("select v_troltype from vol where v_code='$appro' and v_rot=1");
    	while ((@ligne) = $sth->fetchrow_array) {
		$oa_cd_pr=&get("select oa_cd_pr from oasix_prod where oa_desi='$ligne[5]'","af");
		
		if ($ligne[6]>0){
                $enplus=1;}
 		else { 
 			$enplus=-1;
 			$ligne[6]=0-$ligne[6]; 
 		}
 		if ($ligne[5] eq "Soda"){$oa_cd_pr=300102;}
 		if ($ligne[5] eq "Perrier"){$oa_cd_pr=300102;}
 		if ($ligne[5] eq "Boisson Froide"){$oa_cd_pr=300102;}
		if ($ligne[5] eq "Boisson Chaude"){$oa_cd_pr=300108;}
		if ($ligne[5] eq "Snack Sucr."){$oa_cd_pr=300113;}
		if ($ligne[5] eq "Snack Sal."){$oa_cd_pr=300129;}
		if ($ligne[5] eq "5 Sandwiches"){$oa_cd_pr=300122;$enplus*=5;$ligne[6]=$ligne[6]/5;}
		if ($ligne[5] eq "5 Eaux"){$oa_cd_pr=300100;$enplus*=5;$ligne[6]=$ligne[6]/5;}
	        if (($troltype!=106)&&($ligne[5] eq "Angel edp 25ml")){$oa_cd_pr=203097;}
	        if (($troltype!=106)&&($ligne[5] eq "Ck one summer ed")){$oa_cd_pr=110980;}
	        if (($troltype!=106)&&($ligne[5] eq "Kouros eau d e")){$oa_cd_pr=180101;}
	        
 		$total+=$enplus*$ligne[6];
    		# $qte=&get("select vdu_qte from vendusql where vdu_appro='$appro' and vdu_tpe='$num' and vdu_cd_pr='$oa_cd_pr'","af")+$enplus;
    		# $qte=&save ("replace into vendusql values ('$appro','$num','$oa_cd_pr','$qte','$ligne[6]')","af");
    		print "$appro;$num;$oa_cd_pr,$enplus,$ligne[6], $total<br>";
    		
    	}
    	# &save ("replace into oasix_appro values ('$oa_serial',DATE_SUB(now(),INTERVAL $day DAY),'$appro')","af");
    	# ajouter le 01/07 pour tracer l importation avec le numero d appro
    	print "<br><b>Total:$total<bR>";
    	print "<br><a href=http://ibs.oasix.fr/saiapp.php?appro=$appro&action=validtpe&caisse1=$total>Valider les ventes tpe</a><br>";
     	print "<br><a href=http://ibs.oasix.fr/saiapp.php?appro=$appro&action=page2&option=back>Retour saisie</a>";

 } 	
