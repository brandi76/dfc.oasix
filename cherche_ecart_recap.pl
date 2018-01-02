#!/usr/bin/perl

use CGI;
use DBI();
require "../oasix/outils_perl2.pl";


# compare le fichier brut oasix avec les valeurs qui apparaissent dans la recap
$html=new CGI;
print $html->header;
$appro=$html->param("appro");
require "../oasix/outils_perl2.pl";

require "./src/connect.src";

if ($appro eq ""){
print "<form> appro <input type=text name=appro><input type=submit></form>";
}
else
{

$query="select oac_num,oac_rot,oac_esp+oac_cb from oasix_caisse where oac_appro='$appro'";
print "ecart oasix et oasix_caisse<br>";

$sth = $dbh->prepare($query);
$sth->execute;
while (($num,$rot,$val) = $sth->fetchrow_array) {
	# oasix avec oasix caisse	
	$val2=&get("select sum(oa_col3)/100 from oasix,oasix_tpe,oasix_appro where oasix.oa_serial=oasix_tpe.oa_serial and oa_type='p' and oa_date_import=oaa_date and oa_rotation='vente$rot.txt' and oaa_appro=$appro and oa_num=$num and oaa_serial=oasix_tpe.oa_serial","af");
	if ($val!=$val2){	
		print "$num oasix_caisse:$val tpe:$val2<br>";
	}
	$totaltpe+=$val2;

	# retoursql avec oasix

	$query="select oa_col2,count(*) from oasix,oasix_tpe,oasix_appro where oasix.oa_serial=oasix_tpe.oa_serial and oa_type='p' and oa_col3>0 and oa_date_import=oaa_date and oa_rotation='vente$rot.txt' and oaa_appro=$appro and oa_num=$num and oaa_serial=oasix_tpe.oa_serial group by oa_col2";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (($desi,$qte) = $sth2->fetchrow_array){
		$tab{"$desi"}+=$qte;
	}
	$query="select oa_col2,count(*) from oasix,oasix_tpe,oasix_appro where oasix.oa_serial=oasix_tpe.oa_serial and oa_type='p' and oa_col3<0 and oa_date_import=oaa_date and oa_rotation='vente$rot.txt' and oaa_appro=$appro and oa_num=$num and oaa_serial=oasix_tpe.oa_serial group by oa_col2";
	# print "$query <br>";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (($desi,$qte) = $sth2->fetchrow_array){
		$tab{"$desi"}-=$qte;
		# print "****$desi $qte****<br>";
	}

}
$total=0;
print "**** Ecart retoursql oasix *****<br>";
$query="select ret_cd_pr,ret_qte-ret_retourpnc,ret_prix from retoursql where ret_code=$appro";
$sth2 = $dbh->prepare($query);
$sth2->execute;
while (($ret_cd_pr,$ret_qte,$ret_prix) = $sth2->fetchrow_array){
	$desi=&get("select oa_desi from oasix_prod where oa_cd_pr=$ret_cd_pr"); 
	if ($tab{"$desi"}!=$ret_qte) {
	 	print "$ret_cd_pr $desi $ret_prix retoursql:$ret_qte oasix:".$tab{"$desi"}." <br>";
	}
	$total+=$ret_qte*$ret_prix;
	$tab{"$desi"}=0;
}
print "**** Ecart oasix retoursql *****<br>";
foreach $cle (%tab) {
	if ($tab{$cle}!=0) {
	print "$cle $tab{$cle} <br>";
	}
}

print "<br>$total total tpe:$totaltpe";


}

