#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
$produit=$html->param("produit");
$action=$html->param("action");

if ($action eq "") {
	print "<form>Code Produit:";
	$query="select distinct pr_cd_pr,pr_desi from trolley,produit,lot  where pr_cd_pr=tr_cd_pr and tr_code=lot_nolot and lot_flag=1 and (pr_type=1 or pr_type=5) order by tr_ordre";
	$sth2=$dbh->prepare($query);
	$sth2->execute;
	print "<select name=produit>\n";
	while (my @tables = $sth2->fetchrow_array) {
		print "<option value=\"$tables[0]\">$tables[0] $tables[1]\n";
	}
        print "</select>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit value=go></form>";
}
else
{
$desi=&get("select pr_desi from produit where pr_cd_pr='$produit'","ff");
 print "<h2>$desi<br>";
 `/home/intranet/cgi-bin/radio_1.2.pl`;
$query="select * from radio order by rad_no";
$sth=$dbh->prepare($query);
$sth->execute;
while ($rad_no= $sth->fetchrow_array) {
 	print "$rad_no<br>";
 	$bug=&get("select pr_desi from produit,radio_produit where rap_no='$rad_no' and rap_cd_pr=pr_cd_pr","af");
	if (($bug ne "") and ($bug ne $desi)){
		print "<font color=red>attention etiquette qui etait affectée a $bug</font></br>";
	}
	&save("replace into radio_produit values('$rad_no','$produit')");
	$i++;
}
print $i;
print "<br><a href=radio_produit.pl>retour</a><br>";
}



# -E enregistrement des produits
