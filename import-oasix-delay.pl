#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
$action=$html->param("action");
$oa_serial=$html->param("tpe");
$oa_date=$html->param("date");
$appro=$html->param("appro");

require("./src/connect.src");
$num=&get("select oa_num from oasix_tpe where oa_serial='$oa_serial'");
print "<title>Importation oasix delay</title>";
if (($action ne "") && ($appro eq "") && ($action ne "choixdate")) {
        print "<center>saisie invalide <br>";
	exit;    
	}
if ($action eq ""){
	print "<body><center><h1>Importation oasix<br><form>";
	print "<br> proposition<br></h1>";
	$date=&get("select v_date from vol where v_code='$appro'");
	$vol=&get("select v_vol from vol where v_code='$appro'");
	$an=$date%100+2000;
	$mois=($date/100)%100;
	if ($mois<10){$mois="0".$mois};
	$jour=(($date/10000)+1000)%100;
	if ($jour<10){$jour="0".$jour};
	$date=$an."-".$mois."-".$jour;
	print "date du vol $date numero de vol:$vol<br>" ;
	$sth = $dbh->prepare("select distinct oa_serial,oa_date_import from oasix where datediff(oa_date_import,'$date')>=0 and datediff(oa_date_import,'$date')<=4 order by oa_date_import");
    	$sth->execute;
        print "<table border=1><tr><th>No de serie</th><th>no</th><th>Date importation</th><th>vol</th></tr>";
    	while (($oa_serial,$oa_date_import) = $sth->fetchrow_array) {
		$oa_num=&get("select oa_num from oasix_tpe where oa_serial='$oa_serial'");
		$query="select distinct oa_col2 from oasix where  oa_serial='$oa_serial' and oa_date_import='$oa_date_import' and oa_col2 like 'vol%'";
		$sth2= $dbh->prepare("$query");
    		$sth2->execute;
		$vol_dispo="";
    		while (($oa_vol) = $sth2->fetchrow_array) {
			$vol_dispo=$vol_dispo." ".$oa_vol;
		}
       		print "<tr><td><a href=?tpe=$oa_serial&date=$oa_date_import&action=import&appro=$appro>$oa_serial </a></td><td>$oa_num</td><td>$oa_date_import</td><td>$vol_dispo</td></tr>\n";
       	}
	print "</table>";
    	print "<br><input type=hidden name=action value=choixdate><input type=submit></form></body>";
}


if ($action eq "import"){
	print "<center><div class=titre>Rotations disponibles</div><br>";
	print "<form>";
  	print "<br>Choisir les rotations à importer<br><br>\n";
	$query="select distinct oa_rotation from oasix where  oa_serial='$oa_serial' and oa_date_import='$oa_date' order by oa_rotation";
	$sth = $dbh->prepare($query);
    	if ($sth->execute >0){
	    while (($oa_rotation) = $sth->fetchrow_array) {
		$infovol=&get("select distinct oa_col2 from oasix where  oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$oa_rotation' and oa_col2 like 'vol%'");
		if ($infovol eq "") { $infovol="vol non renseigné";}
		print "$oa_rotation $infovol <input type=checkbox name=$oa_rotation checked><br>";
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

if ($action eq "go"){
    print "<center>";
    &save ("delete from vendusql where vdu_appro='$appro' and vdu_tpe='$num'");
    $query="select distinct oa_rotation from oasix where  oa_serial='$oa_serial' and oa_date_import='$oa_date' order by oa_rotation";
    $sth2 = $dbh->prepare($query);
    $sth2->execute;
    while (($rotation) = $sth2->fetchrow_array) {
	if ($html->param("$rotation") eq "on"){
	# pour chaque rotation de la tpe selectionné
	    $total=0;
	    ($null,$rot)=split(/vente/,$rotation);
	    ($rot,$null)=split(/\.txt/,$rot);
	    $query="select * from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'";
	    $sth = $dbh->prepare($query);
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
# 		    print "$oa_desi $enplus $ligne[6] <br>";
		    $qte=&get("select vdu_qte from vendusql where vdu_appro='$appro' and vdu_tpe='$num' and vdu_cd_pr='$oa_cd_pr'","af")+$enplus;
		    # enregitrement du produit vendu
			$oa_cd_pr+=0;
		    if ($oa_cd_pr ==0){
				print "<font color=red>*$ligne[5]* produit inconnu<br></font>";
				}
			&save ("replace into vendusql values ('$appro','$num','$oa_cd_pr','$qte','$ligne[6]')","af");
	    }
	    print "Appro:$appro rotation no:$rot montant intégré:$total <br>";
	    $totalg+=$total;
	    # mise a jour des info de caisse
	    $esp=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=0 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'","af");
	    $cb=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=1 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'","af");
	    $diners=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=2 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'");
	    $am=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=3 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'");
	    $gratuite=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=4 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'","af");
	    $voucher=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=5 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'");
	    $master=0+&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=6 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'");
	    
	    $esp/=100;
	    $cb/=100;
	    $diners/=100;
	    $am/=100;
	    $gratuite/=100;
	    $voucher/=100;
	    $master/=100;
	    
	    &save ("replace into oasix_caisse values ('$appro','$num','$rot','$esp','$cb','$diners','$am','$gratuite','$voucher','$master')","af");
	    &save ("replace into oasix_appro values ('$oa_serial','$oa_date','$appro')");
	    
	    
	    # mise à jour des infos pnc
	    print "equipage:";
	    $eq_cc="";
	    $eq_equipage="";
	    $sth = $dbh->prepare("select * from oasix where oa_type='h' and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rotation'");
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
    }
    # &save("update retoursql set ret_retourpnc=ret_qte where ret_code='$appro'");
    $query="select vdu_cd_pr,sum(vdu_qte) from vendusql where vdu_appro=$appro group by vdu_cd_pr";
#     print $query;
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($pr_cd_pr,$capr)=$sth2->fetchrow_array){
		# &save("update retoursql set ret_retourpnc=ret_qte-$capr where ret_code='$appro' and ret_cd_pr='$pr_cd_pr'");
    }
    print "<br><b>Total intégré pour la tpe $num:$totalg<bR>";
} 

