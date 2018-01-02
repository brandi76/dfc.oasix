#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
require "./src/connect.src";
print $html->header;
$navire=$html->param('navire');
$action=$html->param('action');
print "<head><style>TD{text-align:right;}.gauche{text-align:left;} </style><title>ecart</title></head>";
if ($action eq ""){
	print "<body><center><h1>Ecart navire<br><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=voir></form></body>";
}
else
{
$query="select nav_date from navire2 where nav_nom='$navire' and nav_type=3 group by nav_date order by nav_date";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nav_date)=$sth->fetchrow_array){
	push (@date,$nav_date);
}

print "<table border=1 cellspacing=0><tr><th>Produit</th>";
foreach (@date)
{
print "<th>$_</th>";
}
print "<th>Total</th></tr>";

$query="select nav_cd_pr,pr_desi from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=3 and pr_sup!=5 and (pr_type=1 or pr_type=5) group by nav_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
        $total=0;
        print "<tr><td class=gauche>$pr_cd_pr $pr_desi</td>";
 	foreach (@date)
	{
		$qte=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=3 and nav_cd_pr='$pr_cd_pr' and nav_date='$_'","af")+0;
		print "<td>$qte</td>";
		$total+=$qte;
	}
	print "<td>$total</td></tr>";

}
print "</table>";
}