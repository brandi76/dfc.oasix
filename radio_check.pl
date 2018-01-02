#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
$action=$html->param('action');
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$today=&nb_jour($jour,$mois,$an);
if ($action eq ""){
	print "<center><h1>check</h1>";
	print "<form><br><br> Date des retours<br><form>";
	&select_date();
	print "<input type=submit name=action value=go></form>";
}
else 
{
	$query = "select rj_appro from retjour,vol where rj_date>='$today' and rj_appro=v_code and v_rot=1 and v_cd_cl=345";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ($rj_appro= $sth->fetchrow_array) {
		$query="select ret_cd_pr,ret_qte,ret_retour from retoursql,appro where ret_code=$rj_appro and ap_ordre >=180 and ap_ordre <1000 and ap_cd_pr=ret_cd_pr and ap_code=$rj_appro";
		# print "$query<bR>";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ret_cd_pr,$ret_qte,$ret_retour)= $sth2->fetchrow_array) {
			# print "$ret_cd_pr $ret_retour $ret_qte<br>";
			$qte=&get("select count(*) from radio_appro,radio_tiroir,radio_produit where raa_code='$rj_appro' and raa_no=rat_no and rat_date=now() and rap_no=rat_no and rap_cd_pr='$ret_cd_pr'","af"); 			
			# $qte+=&get("select count(*) from radio_tiroir,radio_produit where rat_tiroir='retour' and rat_date=now() and rap_no=rat_no and rap_cd_pr='$ret_cd_pr'","af"); 			

			if ($qte!=$ret_retour){
				$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$ret_cd_pr'");
				print "appro:$rj_appro $pr_cd_pr $pr_desi qte retour:$ret_retour trouvé:$qte<br>";
			}
		}
	}
print "check terminé";
}
	
# -E controle du depart