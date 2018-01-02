#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";

$html=new CGI;
print $html->header;
$action=$html->param("action");
$appro=$html->param("appro");
$esp1=$html->param("esp1")+0;
$cb1=$html->param("cb1")+0;
$am1=$html->param("am1")+0;
$diners1=$html->param("diners1")+0;
$voucher1=$html->param("voucher1")+0;
$master1=$html->param("master1")+0;
$esp2=$html->param("esp2")+0;
$cb2=$html->param("cb2")+0;
$am2=$html->param("am2")+0;
$diners2=$html->param("diners2")+0;
$voucher2=$html->param("voucher2")+0;
$master2=$html->param("master2")+0;
$tpe=$html->param("tpe");

require "./src/connect.src";

$vol=&get("select v_vol from vol where v_code='$appro' and v_rot=1");
$date=&get("select v_date from vol where v_code='$appro' and v_rot=1");

if ($action eq "sup" ) {
	&save("delete from vendusql where vdu_appro='$appro' and vdu_tpe='$tpe'","aff");
	&save("delete from oasix_caisse where oac_appro='$appro' and oac_num='$tpe'","aff");
}

if ($action eq "modif" ) {
	&save("update caisse set ca_esp='$esp1',ca_cb='$cb1',ca_diners='$diners1',ca_am='$am1',ca_voucher='$voucher1',ca_master='$master1' where ca_code='$appro' and ca_rot=1","af");
	&save("update caisse set ca_esp='$esp2',ca_cb='$cb2',ca_diners='$diners2',ca_am='$am2',ca_voucher='$voucher2',ca_master='$master2' where ca_code='$appro' and ca_rot=2");
}

print "<center><h3>$vol $date Noref:$appro</h3><br>";
print "<table border=1><caption>Déchargement bancaire</caption><tr><th>Type</th><th>Tpe</th><th>No remise</th><th>Montant</th></tr>";
$query="select tb_no,tb_noremise,tb_montant from tpebqsql where tb_code='$appro'";
$sth = $dbh->prepare($query);
$sth->execute;
while (($tb_no,$tb_noremise,$tb_montant) = $sth->fetchrow_array) {
     	print "<tr><td>Visa</td><td>$tb_no</td><td>$tb_noremise</td><td>$tb_montant</td></tr>";
	$total+=$tb_montant;
}
# $query="select tb_no,tb_noremise,tb_montant from tpedinsql where tb_code='$appro'";
# $sth = $dbh->prepare($query);
# $sth->execute;
# while (($tb_no,$tb_noremise,$tb_montant) = $sth->fetchrow_array) {
#      	print "<tr><td>Diners</td><td>$tb_no</td><td>$tb_noremise</td><td>$tb_montant</td></tr>";
# 	$total+=$tb_montant;
# }
# $query="select tb_no,tb_noremise,tb_montant from tpeamsql where tb_code='$appro'";
# $sth = $dbh->prepare($query);
# $sth->execute;
# while (($tb_no,$tb_noremise,$tb_montant) = $sth->fetchrow_array) {
#      	print "<tr><td>American express</td><td>$tb_no</td><td>$tb_noremise</td><td>$tb_montant</td></tr>";
# 	$total+=$tb_montant;
# }

print "<tr><th colspan=3>Total</th><th>$total</th></tr>";
print "</table>";     
$total=0;
$query="select oac_num,oac_rot,oac_esp,oac_cb,oac_diners,oac_am,oac_gratuite,oac_voucher,oac_master from oasix_caisse where oac_appro='$appro' order by oac_num,oac_rot";
$sth = $dbh->prepare($query);
$sth->execute;
print "<table border=1><caption>Caisse tpe</caption><th>Tpe</th><th>Rotation</th><th>Espece</th><th>cb</th><th>Diners</th><th>American express</th><th>master card</th><th>gratuite</th><th>voucher</th><th>Total</th></tr>";
while (($oac_num,$oac_rot,$oac_esp,$oac_cb,$oac_diners,$oac_am,$oac_gratuite,$oac_voucher,$oac_master) = $sth->fetchrow_array) {
	$totali=$oac_esp+$oac_cb+$oac_diners+$oac_am+$oac_master+$oac_gratuite+$oac_voucher;
	print "<tr><td>$oac_num</td><td>$oac_rot</td><td>$oac_esp</td><td>$oac_cb</td><td>$oac_diners</td><td>$oac_am</td><td>$oac_master</td><td>$oac_gratuite</td><td>$oac_voucher</td><td>$totali</td><td><a href=?appro=$appro&tpe=$oac_num&action=sup>sup</a></td></tr>";	
	$tesp+=$oac_esp;
	$tcb+=$oac_cb;
	$tdiners+=$oac_diners;
	$tam+=$oac_am;
	$tvoucher+=$oac_voucher;
	$tmaster+=$oac_master;
	$tgratuite+=$oac_gratuite;

	}

print "<tr><th colspan=2>Total</th><th>$tesp</th><th>$tcb</th><th>$tdiners</th><th>$tam</th><th>$tmaster</th><th>$tgratuite</th><th>$tvoucher</th>";
$totalf=$tesp+$tcb+$tdiners+$tam+$tmaster+$tgratuite+$tvoucher;
print "<th>$totalf</th></tr>";
print "</table>";     

$modif=&get("select sum(ca_modif) from caisse where ca_code='$appro'")+0;
if ($modif==0){
		# pas de saisie pre_enregistrement avec les données tpe
	for ($rot=1;$rot<3;$rot++)	
	{	
		$query="select sum(oac_cb),sum(oac_diners),sum(oac_am) from oasix_caisse where oac_appro='$appro' and oac_rot='$rot' group by oac_appro";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($oac_cb,$oac_diners,$oac_am)=$sth2->fetchrow_array;
		$oac_cb+=0;
		$oac_diners+=0;
		$oac_am+=0;
		&save("update caisse set ca_cb=$oac_cb,ca_am=$oac_am,ca_diners=$oac_diners,ca_modif=1 where ca_code='$appro' and ca_rot='$rot'","af");
	}
}	
$query="select ca_rot,ca_esp,ca_cb,ca_diners,ca_am,ca_voucher,ca_master from caisse where ca_code='$appro' and ca_rot=1";
$sth = $dbh->prepare($query);
$sth->execute;

print "<form><table border=1><caption>Caisse brink's</caption><th>Tronçon</th><th>Espece</th><th>cb</th><th>Diners</th><th>American express</th><th>Master card</td><th>Voucher</th></tr>";
($ca_rot,$ca_esp,$ca_cb,$ca_diners,$ca_am,$ca_voucher,$ca_master) = $sth->fetchrow_array;
print "<tr><td>$ca_rot</td><td><input type=text name=esp1 value=$ca_esp></td><td><input type=text name=cb1 value=$ca_cb></td><td><input type=text name=diners1 value=$ca_diners></td><td><input type=text name=am1 value=$ca_am></td><td><input type=text name=master1 value=$ca_master></td><td><input type=text name=voucher1 value=$ca_voucher></td></tr>";	

$query="select ca_rot,ca_esp,ca_cb,ca_diners,ca_am,ca_voucher,ca_master from caisse where ca_code='$appro' and ca_rot=2";
$sth = $dbh->prepare($query);
$sth->execute;
($ca_rot,$ca_esp,$ca_cb,$ca_diners,$ca_am,$ca_voucher,$ca_master) = $sth->fetchrow_array;
# print "$query *** $ca_diners ***";
print "<tr><td>$ca_rot</td><td><input type=text name=esp2 value=$ca_esp></td><td><input type=text name=cb2 value=$ca_cb></td><td><input type=text name=diners2 value=$ca_diners></td><td><input type=text name=am2 value=$ca_am></td><td><input type=text name=master2 value=$ca_master></td><td><input type=text name=voucher2 value=$ca_voucher></td></tr>";	
print "</table><br><input type=hidden name=appro value='$appro'><input type=hidden name=action value=modif><input type=submit value=modif></form>";     
