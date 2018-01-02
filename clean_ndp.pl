#!/usr/bin/perl
use CGI;
use DBI();
       
$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.lib";
$desi=$html->param('desi');
require "./src/connect.src";

print "<form> designation <input type=texte name=desi><input type=submit></form>";

print "<table border=1 cellspacing=0 cellpadding=1>";
if ($desi ne ''){
	$query="select pr_cd_pr,pr_desi,pr_douane,pr_deg,pr_pdn from produit where pr_desi like \"%$desi%\" order by pr_douane";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_douane,$pr_deg,$pr_pdn)=$sth->fetchrow_array)
	{
    		$nomenclature=substr($pr_douane,0,8);	
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$pr_douane</td><td>$pr_deg</td><td>$pr_pdn</td><td><font size=-2>";
		print &get("select chap_desi from chapitre where chap_douane='$nomenclature'","af");
		print "</td></tr>";
	}
}
print "</table>";
