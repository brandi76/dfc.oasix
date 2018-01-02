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
	print "<body><center><h1>Recap oasix<br><form>";
	print "<br> Numero de tpe<br>";
	$sth = $dbh->prepare("select oa_num,oa_serial from oasix_tpe");
    	$sth->execute;
   	print "<br><select name=tpe>\n";
    	while (($oa_num,$oa_serial) = $sth->fetchrow_array) {
       		print "<option value=$oa_serial>";
       		print "$oa_num\n";
       	}
    	print "</select><br>\n";
    	print "<br><input type=hidden name=action value=voir><input type=submit value=voir></form></body>";
}
	

if ($action eq "voir"){
	$num=&get("select oa_num from oasix_tpe where oa_serial='$oa_serial'","aff");
	$day=0;
	# recherche du jour du download
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
					print $query;
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
    	$sth = $dbh->prepare("select * from oasix where oa_serial='$oa_serial' and oa_date_import=DATE_SUB(now(),INTERVAL $day DAY)");
    	$sth->execute;
    	while ((@ligne) = $sth->fetchrow_array) {
    		print "@ligne<br>";
=pod
		$oa_cd_pr=&get("select oa_cd_pr from oasix_prod where oa_desi='$ligne[5]'","af");
		if ($ligne[6]>0){
                $enplus=1;}
 		else { 
 			$enplus=-1;
 			$ligne[6]=0-$ligne[6]; 
 		}
 		$total+=$enplus*$ligne[6];
    		$qte=&get("select vdu_qte from vendusql where vdu_appro='$appro' and vdu_tpe='$num' and vdu_cd_pr='$oa_cd_pr'","af")+$enplus;
    		$qte=&save ("replace into vendusql values ('$appro','$num','$oa_cd_pr','$qte','$ligne[6]')","af");
    		print "$appro;$num;$oa_cd_pr,$qte,$ligne[6]<br>";
=cut   		
    	}
    	print "<br><b>Total:$total<bR>";
    	print "<br><a href=http://ibs.oasix.fr/saiapp.php?appro=$appro&action=validtpe>Valider les ventes tpe</a><br>";
     	print "<br><a href=http://ibs.oasix.fr/saiapp.php?appro=$appro&action=page2&option=back>Retour saisie</a>";
 } 	
