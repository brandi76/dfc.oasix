#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;

$action=$html->param("action");
$produit=$html->param("produit");
$option=$html->param("option");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>Livraison a venir</title></head>";
print "<body link=black>";


require "./src/connect.src";
print "<center><h1>Livraison a venir (4 semaines) <br><br>";
print "<form>";
print "<br>Code produit<br><input type=text name=produit><bR>";
print "<br><input type=hidden name=action value=go><input type=submit value='envoie'></form><br>"; 

if ($action eq "go"){
	$semaine=&semaine("")+1;
	$query="select nav_nom from navire,semaine2 where nav_nom=se_navire and se_no>=$semaine and se_no<=$semaine+4 and se_coef!=0 group by nav_nom order by nav_nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nom)=$sth->fetchrow_array){
		push (@navire,"$nom");
	}
	print "<form><table border=1 cellspacing=0 width=100%><tr><td colspan=2>&nbsp;</td>";
	foreach $nom (@navire) {
		print "<th";
		print "><font size=-1>";
		for ($i=0;$i<length($nom);$i++){
			$digit=substr($nom,$i,1);
	 		print "$digit<br>";
		}
	}
	print "</font></th>";
	print "</tr>";
	$nbnavire=$#navire+1;
	$query="select pr_cd_pr,pr_desi from produit where pr_cd_pr='$produit'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
		foreach $nom (@navire) {
			print "<td align=right>";
			%calcul=&table_navire("$nom",$pr_cd_pr,"$option");
			print $calcul{"alivrer"};
			$total+=$calcul{"alivrer"};
			print "</td>";
		}
		print "<td align=right><b>$total</td>";
		print "</tr>";
	}
	print "</table>";
}	


# -E Livraison a venir detail