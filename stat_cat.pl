#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;

require "./src/connect.src";
$query="select at_code from vol,etatap,inforetsql where at_etat>=3 and at_code=v_code and v_rot=1 and v_troltype=105 and infr_code=at_code and infr_caisseth>0 and at_code>21000 order by at_code";
$sth=$dbh->prepare($query);
$sth->execute();
while (($at_code)=$sth->fetchrow_array)
{	
push (@tab,$at_code);
}
print "<table border=1 cellspacing=0><tr><th>&nbsp;</th>";
foreach (@tab) {
	$ca=&get("select infr_caisseth from inforetsql where infr_code=$_")+0;
	$date=&get("select v_date from vol where v_code='$_' and v_rot=1");
	$dest=&get("select v_dest from vol where v_code='$_' and v_rot=1");

	print "<th>$_<br>ca:$ca<br>date:$date<br>$dest</th>";
	
}
print "</tr>";
$query="select pr_cd_pr,pr_desi,tr_qte/100 from produit,trolley where tr_code=105  and tr_cd_pr=pr_cd_pr and pr_type=0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$tr_qte)=$sth->fetchrow_array)
{	
	print "<tr><th>$pr_cd_pr $pr_desi $tr_qte</th>";
	foreach $ap (@tab) {
		$qte=&get("select ret_qte-ret_retour from retoursql where ret_code='$ap' and ret_cd_pr='$pr_cd_pr'")+0;
		print "<td>$qte</td>";
	}
	print "</tR>";
}
	print "</table>";


