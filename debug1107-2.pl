#!/usr/bin/perl

use CGI;
use DBI();
require "../oasix/outils_perl2.pl";


$html=new CGI;
print $html->header;
$appro=$html->param("appro");
require "./src/connect.src";

print "ecart entre vendusql et retoursql<br>";

print "<form>
<input type=text name=appro>
<input type=submit>
</form>";

if ($appro ne ""){
	$query="select vdu_cd_pr,sum(vdu_qte) from vendusql where vdu_appro='$appro' group by vdu_cd_pr";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($vdu_cd_pr,$qte) = $sth->fetchrow_array) {
		$check=0+&get("select ret_qte-ret_retourpnc from retoursql where ret_code='$appro' and ret_cd_pr=$vdu_cd_pr");
		if ($qte!=$check){
			$desi=&get("select pr_desi from produit where pr_cd_pr='$vdu_cd_pr'");
			print "$vdu_cd_pr $desi vdu_cd_pr:$qte retoursql:$check <br>";
			}
	}
	print "fin";
}

