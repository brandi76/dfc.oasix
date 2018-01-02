#!/usr/bin/perl

use CGI;
use DBI();
require "../oasix/outils_perl2.pl";


$html=new CGI;
print $html->header;
$appro=$html->param("appro");
$action=$html->param("action");
require "./src/connect.src";


print "<form>
<input type=text name=appro>
<input type=submit>
</form>";

if ($appro ne ""){
print "ecart entre vendusql et retoursql<br>";
 	
	$total=&get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro='$appro'");
	$total2=&get("select sum((ret_qte-ret_retourpnc)*ret_prix)  from retoursql where ret_code='$appro'");
	print "global vendusql:$total retoursql:$total2 <br>";
	$total=$total2=0;

	$query="select vdu_cd_pr,sum(vdu_qte),sum(vdu_qte*vdu_prix) as prix from vendusql where vdu_appro='$appro' group by vdu_cd_pr";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($vdu_cd_pr,$qte,$prix) = $sth->fetchrow_array) {
		$check=0+&get("select ret_qte-ret_retourpnc from retoursql where ret_code='$appro' and ret_cd_pr=$vdu_cd_pr");
		$prix2=0+&get("select (ret_qte-ret_retourpnc)*ret_prix from retoursql where ret_code='$appro' and ret_cd_pr=$vdu_cd_pr");
		if ($qte!=$check){
			$desi=&get("select pr_desi from produit where pr_cd_pr='$vdu_cd_pr'");
			print "$vdu_cd_pr $desi vdu_cd_pr:$qte retoursql:$check <br>";
			if ($action eq "modif"){
				$prix/=$qte;
				$depart=&get("select ret_qte from retoursql where ret_code='$appro' and ret_cd_pr='$vdu_cd_pr'")+0;
				$qte=$depart-$qte;
				$ordre=&get("select ord_ordre from ordre where ord_cd_pr='$vdu_cd_pr'")+0;
				&save("insert IGNORE into retoursql value ('$appro','$ordre','$vdu_cd_pr','0','0','0','$qte','$prix','0')","aff");
			}
		}
		$total+=$prix;
		$total2+=$prix2;

        }
	print "detail vendusql:$total retoursql:$total2<br><hr>";

print "ecart entre oasix_caisse et vendusql<br>";

	$vente_pn =&get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro=$appro");
	$query="select sum(oac_esp),sum(oac_cb+oac_diners+oac_am),sum(oac_gratuite),sum(oac_voucher) from oasix_caisse where oac_appro='$appro' group by oac_appro";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($oac_esp,$oac_carte,$oac_gratuite,$oac_voucher)=$sth2->fetchrow_array;
	$oasix_caisse=$oac_esp+$oac_carte+$oac_gratuite+$oac_voucher;
	if ($oasix_caisse!=$vente_pn){
		print "$appro oasix_caisse:$oasix_caisse vendu_sql:$vente_pn<br>";
		$query="select vdu_tpe,sum(vdu_qte*vdu_prix) from vendusql where vdu_appro='$appro' group by vdu_tpe";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($tpe,$vente_pn)=$sth2->fetchrow_array){
			$oasix_caisse=&get("select sum(oac_esp+oac_cb+oac_diners+oac_am+oac_gratuite+oac_voucher) from oasix_caisse where oac_appro='$appro' and oac_num='$tpe'");
			print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tpe:$tpe oasix_caisse:$oasix_caisse vendu_sql:$vente_pn<br>";

		}			
	}
	print "<hr>";
	$total=$total2=0;

print "ecart entre oasix_caisse et oasix<br>";

	$query="select oac_appro,oa_serial,oac_num,oac_rot,oaa_date, oac_esp+oac_cb+oac_diners+oac_am+oac_gratuite+oac_voucher as montant from oasix_caisse,oasix_tpe,oasix_appro where oac_appro='$appro' and oac_num=oa_num and oaa_appro=oac_appro and oaa_serial=oa_serial";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($app,$serial,$num,$rot,$date,$montant) = $sth->fetchrow_array) {
		$rot="vente".$rot.".txt";
		push(@{$serial},$rot);
		$val=&get("select sum(oa_col2) from oasix where oa_type='c' and oa_serial='$serial' and oa_rotation='$rot' and oa_date_import='$date'")/100;
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$appro $rot $num $date $serial oasix:$montant oasix_appro:$val <br>";
		$total+=$montant;
		$total2+=$val;
	}
	print "oasix_caisse:$total oasix:$total2<br><hr>";
	$total=$total2=0;

print "ecart entre vendusql et oasix<br>";

	$query="select vdu_appro,oa_serial,vdu_cd_pr,vdu_qte,vdu_prix from vendusql,oasix_tpe where vdu_appro='$appro' and vdu_tpe=oa_num order by vdu_appro";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($app,$serial,$pr_cd_pr,$qte,$prix) = $sth->fetchrow_array) {
		$total+=$qte*$prix;
		$valeur=$qte*$prix;		
		$date=&get("select oaa_date from oasix_appro where oaa_appro='$appro' and oaa_serial='$serial'");
		if ($date eq "") {next;}
		$desi=&get("select oa_desi from oasix_prod where oa_cd_pr='$pr_cd_pr'");
		$val=0;		
		$valeur2=0;
		foreach $rot (@{$serial}) {
			if ($pr_cd_pr==1300){$desi="The nature";}
			if ($pr_cd_pr==1310){$desi="The noir";}

			# print "$serial $rot <br>";
			# $query="select oa_desi from oasix_prod where oa_cd_pr='$pr_cd_pr'";
			# $sth2 = $dbh->prepare($query);
			# $sth2->execute;
			$bug=0;
			# while (($desi) = $sth2->fetchrow_array) {
				$val+=&get("select count(*) from oasix where oa_type='p' and oa_serial='$serial' and oa_date_import='$date' and oa_col2='$desi' and oa_col3>=0 and oa_rotation='$rot'");
				$val-=&get("select count(*) from oasix where oa_type='p' and oa_serial='$serial' and oa_date_import='$date' and oa_col2='$desi' and oa_col3<0 and oa_rotation='$rot'");
				$valeur2+=&get("select sum(oa_col3) from oasix where oa_type='p' and oa_serial='$serial' and oa_date_import='$date' and oa_col2='$desi' and oa_rotation='$rot'")/100;
			# }		
		}
		if ($qte != $val) { print "qte $appro $date $serial $pr_cd_pr $desi oasix:$val vendusql:$qte <br>";}
		if ($valeur != $valeur2) { print "valeur $appro $date $serial $pr_cd_pr $desi oasix:$valeur2 vendusql:$valeur <br>";}
		$total2+=$valeur2;
	}
	print "vendusql:$total oasix:$total2 <br><hr>";

}

