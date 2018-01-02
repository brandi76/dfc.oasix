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
	$query="select * from $client.commandearch where com2_no=$nocde";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com2_cd_pr,$com2_qte,$com2_prac,$com2_type,$com2_date,$com2_delai,$com2_no_liv)=$sth->fetchrow_array){
	   $com2_qte*=100;
		&save("delete from $client.commandearch where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr","aff");
		&save("replace into $client.commande values ('$com2_no','$com2_cd_fo','$com2_cd_pr','$com2_qte','$com2_prac','0','$com2_date','$com2_no_liv','1','')","aff");
		&save("update $client.commande_info set etat=3 where com_no='$nocde'");
    }		
}	
;1 

