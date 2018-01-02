#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

print $html->header;

$action=$html->param("action");
$produit=$html->param("produit");

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>Livraison a venir</title></head>";
print "<body link=black>";


require "./src/connect.src";
print "<center><h1>stock mini dieppe<br><br>";
print "<form>";
print "<br>Code produit<br><input type=text name=produit><bR>";
print "<br><input type=hidden name=action value=go><input type=submit value='envoie'></form><br>"; 



if ($action eq "go"){
	$query="select nav_nom,nav_nationalite from navire order by nav_boutique,nav_nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nom,$flag)=$sth->fetchrow_array){
		push (@navire,"$nom".";"."$flag");
	}
	print "<form><table border=1 cellspacing=0 width=100%><tr><td colspan=2>&nbsp;</td>";
	foreach $ele (@navire) {
		($nom,$flag)=split(/;/,$ele);
		print "<th";
		if ($flag==0){ print " bgcolor=pink ";}
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
		foreach $ele (@navire) {
			($nom,$flag)=split(/;/,$ele);
			
			print "<td align=right>";
			%calcul=&table_navire("$nom",$pr_cd_pr);
			if ($flag!=0){ 
				print $calcul{"stockmini_suiv"};
				$total+=$calcul{"stockmini_suiv"};
			}				
			print "</td>";
			
		}
		print "<td align=right><b>$total</td>";
		print "</tr>";
	}
	print "</table>";
}	


# -E Livraison a venir detail