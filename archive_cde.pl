#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";

$nocde=$html->param('nocde');
$client=$html->param('client');
if ($nocde eq ""){
	print "<form>";
	&form_hidden();
	print "cde <input name=nocde>";
	print "base <input name=client>";
	print "<input type=submit>";
	print "</form>";
}
else {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour,pr_prac/100,pr_prx_rev,com2_prac from $client.commande,$client.produit,$client.fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
	print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date,$pr_refour,$pr_prac,$remise,$com2_prac)=$sth->fetchrow_array){
		&save("delete from $client.commande where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr","aff");
		&save("replace into $client.commandearch values ('$com2_no','$com2_cd_fo','$com2_cd_pr','$com2_qte','$com2_prac','0','$com2_date','$delai','')","aff");
		&save("update $client.commande_info set etat=5 where com_no='$nocde'");
    }		
}	
;1 

