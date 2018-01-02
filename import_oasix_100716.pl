#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
$action=$html->param("action");
$oa_serial=$html->param("tpe");
$appro=$html->param("appro");
$ecart=$html->param("ecart");
require("./src/connect.src");
print "<title>Importation oasix</title>";
if ($action eq ""){
	print "<body><center><h1>Importation oasix<br><form>";
	print "<br> Numero de tpe<br></h1>";
	$sth = $dbh->prepare("select oa_num,oa_serial from oasix_tpe order by oa_num");
    	$sth->execute;
   	print "<br><select name=tpe>\n";
    	while (($oa_num,$oa_serial) = $sth->fetchrow_array) {
       		print "<option value=$oa_serial>";
       		print "$oa_num ($oa_serial)\n";
       	}
    	print "</select><br><br>\n";
	$date=&get("select v_date from vol where v_rot=1 and v_code=$appro");
	$an=$date%100+2000;
	$mois=($date/100)%100;
	if ($mois <10){$mois="0".$mois;}
	$jour=int($date/10000);
	if ($jour <10){$jour="0".$jour;}
	$date=$an."-".$mois."-".$jour;
	$query="select v_vol,v_date from vol where v_code='$appro' and v_rot=1";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
        ($v_vol,$v_date)=$sth2->fetchrow_array;
	print "$v_vol,$v_date<br>";
	$query="select oa_serial,oa_col2,oa_date_import,oa_rotation from oasix where oa_date_import >='$date' and oa_date_import <=adddate('$date',interval 2 day) and oa_col2 like \"vol%\"";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
        while (($oa_serial,$oa_col2,$oa_date_import,$oa_rotation)=$sth2->fetchrow_array)
{
	print "$oa_serial $oa_date_import $oa_col2 $oa_rotation<br>";
	$ecart=&get("select datediff(now(),'$oa_date_import')","af");
}
	print "<input type=hidden name=ecart value=$ecart>";
    	print "<br><h1> Numero de reference <input type=text name=appro size=5 value=$appro><bR>\n";
    	print "<br><input type=hidden name=action value=import><input type=submit value=importation></form></body>";
}
	


if ($action eq "import"){
	print "<center><div class=titre>Rotations disponibles</div><br>";
	print "<form>";
  	print "<br>Choisir les rotations à importer<br><br>\n";
	$query="select distinct oa_rotation from oasix where  oa_serial='$oa_serial' and oa_date_import='$oa_date' order by oa_rotation";
	$sth = $dbh->prepare($query);
    	if ($sth->execute >0){
	    while (($oa_rotation) = $sth->fetchrow_array) {
		    print "$oa_rotation <input type=checkbox name=$oa_rotation checked><br>";
	    }
	    print "<input type=hidden name=appro value='$appro'>";
	    print "<br><input type=hidden name=tpe value=$oa_serial>";
	    print "<br><input type=hidden name=date value=$oa_date>";
	    print "<br><input type=hidden name=action value=go><input type=submit value=submit></form>";
	}
	else 
	{ 
	    print "<font color=red> Aucune donnée ne correspond à votre demande</font><br>";
	    $action="";
	}
}
if ($action eq "import"){
	$num=&get("select oa_num from oasix_tpe where oa_serial='$oa_serial'");
	&save ("delete from vendusql where vdu_appro='$appro' and vdu_tpe='$num'");
	$day=0;
	$query="select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)";
	if (&get($query)==0){
		$day=1;
		$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)";
		if (&get($query)==0){
			$day=2;
			$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)";
			if (&get($query)==0){
				$day=3;
			        $query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)";
				if (&get($query)==0){
					$day=4;
					$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)";
					if (&get($query)==0){
						$day=5;
				        	$query= "select count(*) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)";
						if (&get($query)==0){
							$day=6;
						}
					}
				}
			}
		}
	}
	$day=$ecart;
	$query="select distinct oa_rotation from oasix where  oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) order by oa_rotation";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (($rotation) = $sth2->fetchrow_array) {
	    $total=0;
	    ($null,$rot)=split(/vente/,$rotation);
	    ($rot,$null)=split(/\.txt/,$rot);
	    $sth = $dbh->prepare("select * from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'");
	    $sth->execute;
	    while ((@ligne) = $sth->fetchrow_array) {
		    $oa_cd_pr=&get("select oa_cd_pr from oasix_prod where oa_desi='$ligne[5]'","af");
		    $oa_desi=&get("select oa_desi from oasix_prod where oa_desi='$ligne[5]'","af");
		    if ($oa_cd_pr ==0){
				print "<font color=red>*$ligne[5]* produit inconnu<br></font>";
				}
		    if ($ligne[6]>0){
		    $enplus=1;}
		    else { 
			    $enplus=-1;
			    $ligne[6]=0-$ligne[6]; 
		    }
		    $ligne[6]/=100;
		    
		    $total+=$enplus*$ligne[6];
# 		    print "$oa_desi $enplus $ligne[6] <br>";
		    $qte=&get("select vdu_qte from vendusql where vdu_appro='$appro' and vdu_tpe='$num' and vdu_cd_pr='$oa_cd_pr'","af")+$enplus;
		    # enregitrement du produit vendu
		    &save ("replace into vendusql values ('$appro','$num','$oa_cd_pr','$qte','$ligne[6]')","af");
	    }
	    print "Appro:$appro rotation no:$rot montant intégré:$total <br>";
	    $totalg+=$total;
	    # mise a jour des info de caisse
	    $esp=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=0 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'","af");
	    $cb=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=1 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'","af");
	    $diners=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=2 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'");
	    $am=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=3 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'");
	    $gratuite=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=4 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'","af");
	    $voucher=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=5 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'");
	    $master=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=6 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'");
	    
	    $esp/=100;
	    $cb/=100;
	    $diners/=100;
	    $am/=100;
	    $gratuite/=100;
	    $voucher/=100;
	    $master/=100;
	    
	    &save ("replace into oasix_caisse values ('$appro','$num','$rot','$esp','$cb','$diners','$am','$gratuite','$voucher','$master')","af");
	    
	    
	    # mise à jour des infos pnc
	    print "equipage:";
	    $eq_cc="";
	    $eq_equipage="";
	    $sth = $dbh->prepare("select * from oasix where oa_type='h' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation='$rotation'");
	    $sth->execute;
	    while ((@ligne) = $sth->fetchrow_array) {
	    
		    if (! grep (/vol:/,$ligne[5]))
		    {
			    print "$ligne[5] ";
			    if ($eq_cc eq ""){
			    $eq_cc=$ligne[5];
			}
			else
			{
			    $eq_equipage=$eq_equipage.";".$ligne[5];
			}
		    }
	    }
 	    if ($eq_equipage ne ""){
 		    $eq_equipage=substr($eq_equipage,1,length($eq_equipage));
 	    }
	    &save ("replace into equipagesql values ('$appro','$rot','$eq_cc','$eq_equipage')","af");
	    print "<br>";
	    }
	    &save("update retoursql set ret_retourpnc=ret_qte,ret_retour=ret_qte where ret_code='$appro'");
	    $query="select vdu_cd_pr,sum(vdu_qte) from vendusql where vdu_appro=$appro group by vdu_cd_pr";
	    #     print $query;
	    $sth2=$dbh->prepare($query);
	    $sth2->execute();
	    while (($pr_cd_pr,$capr)=$sth2->fetchrow_array){
			&save("update retoursql set ret_retourpnc=ret_qte-$capr where ret_code='$appro' and ret_cd_pr='$pr_cd_pr'");
			&save("update retoursql set ret_retour=ret_qte-$capr where ret_code='$appro' and ret_cd_pr='$pr_cd_pr'");

	    }
   	&save ("replace into oasix_appro values ('$oa_serial',DATE_SUB(curdate(),INTERVAL $day DAY),'$appro')","af");
 
	print "<br><b>Total intégré pour la tpe $num:$totalg<bR>";
=pod	
	$sth = $dbh->prepare("select * from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)");
    	$sth->execute;
    	while ((@ligne) = $sth->fetchrow_array) {
		$oa_cd_pr=&get("select oa_cd_pr from oasix_prod where oa_desi='$ligne[5]'","af");
		$oa_desi=&get("select oa_desi from oasix_prod where oa_desi='$ligne[5]'","af");
		
		if ($ligne[6]>0){
                $enplus=1;}
 		else { 
 			$enplus=-1;
 			$ligne[6]=0-$ligne[6]; 
 		}
 	        $ligne[6]/=100;
    		
 		$total+=$enplus*$ligne[6];
		print "$oa_desi $enplus $ligne[6] <br>";
		$qte=&get("select vdu_qte from vendusql where vdu_appro='$appro' and vdu_tpe='$num' and vdu_cd_pr='$oa_cd_pr'","af")+$enplus;
   		&save ("replace into vendusql values ('$appro','$num','$oa_cd_pr','$qte','$ligne[6]')","af");
    		
    	}
    	&save ("replace into oasix_appro values ('$oa_serial',DATE_SUB(curdate(),INTERVAL $day DAY),'$appro')","af");
    	# ajouter le 01/07 pour tracer l importation avec le numero d appro
    	$esp=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=0 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)","af");
    	$cb=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=1 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)","af");
    	$diners=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=2 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)");
    	$am=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=3 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)");
    	$gratuite=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=4 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)","af");
    	$voucher=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=5 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)");
    	$master=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=6 and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY)");
    	
    	$esp/=100;
    	$cb/=100;
    	$diners/=100;
    	$am/=100;
    	$gratuite/=100;
    	$voucher/=100;
    	$master/=100;
    	
    	&save ("replace into oasix_caisse values ('$appro','$num','1','$esp','$cb','$diners','$am','$gratuite','$voucher','$master')","af");
	$eq_cc="";
	$eq_equipage="";
    	$sth = $dbh->prepare("select * from oasix where oa_type='h' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation like 'vente1.txt'");
    	$sth->execute;
    	while ((@ligne) = $sth->fetchrow_array) {
	
		if (grep (/vol:/,$ligne[5]))
		{
			$eq_cc=$ligne[5];
		}
		else
		{
			$eq_equipage=$eq_equipage.";".$ligne[5];
		}
	}
	if ($eq_equipage ne ""){
		$eq_equipage=substr($eq_equipage,1,length($eq_equipage));
	}
	
	&save ("replace into equipagesql values ('$appro','1','$eq_cc','$eq_equipage')","af");
	
	$eq_cc="";
	$eq_equipage="";
    	$sth = $dbh->prepare("select * from oasix where oa_type='h' and oa_serial='$oa_serial' and oa_date_import=DATE_SUB(curdate(),INTERVAL $day DAY) and oa_rotation not like 'vente1.txt'");
    	$sth->execute;
    	while ((@ligne) = $sth->fetchrow_array) {
		if (grep (/vol:/,$ligne[5]))
		{
			$eq_cc=$ligne[5];
		}
		else
		{
			$eq_equipage=$eq_equipage.";".$ligne[5];
		}
	}
	if ($eq_equipage ne ""){
		$eq_equipage=substr($eq_equipage,1,length($eq_equipage));
	}
	&save ("replace into equipagesql values ('$appro','2','$eq_cc','$eq_equipage')","af");
    	print "<br><b>Total:$total<bR>";
    	print "<br><a href=http://lat.oasix.fr/saiapp.php?appro=$appro&action=validtpe&caisse1=$total>Valider les ventes tpe</a><br>";
=cut
  print "<br><a href=http://lat.oasix.fr/saiapp.php?appro=$appro&action=page2&option=backtpe>Retour saisie</a>";
 } 	
