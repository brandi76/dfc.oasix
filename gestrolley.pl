#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "../oasix/simple.lib";

print $html->header;
require "./src/connect.src";
$lot=$html->param("lot");

print "<head>
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";


if ($lot eq ""){
	print "<form><input type=text name=lot><br><input type=submit></form>";
}
else
{
	$query="select lot_desi,lot_conteneur from lot where lot_nolot=$lot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($lot_desi,$lot_conteneur)=$sth->fetchrow_array;
	print "<h2>$lot $lot_desi $lot_conteneur</h2>";
	
	print "<table cellspacing=0 cellpadding=0>";
	$query="select tr_tiroir,tr_cd_pr,pr_desi,tr_qte/100 from trolley,produit where tr_code=$lot and tr_cd_pr=pr_cd_pr and tr_qte>0 order by tr_tiroir";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tr_tiroir,$tr_cd_pr,$pr_desi,$qte)=$sth->fetchrow_array){
		
		$ste+=0;
		if ($tr_tiroir!=$tiroir){&saut;}
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$qte</td></tr>" ;
		$total+=$qte;
	}
	if ($total!=0){
		print "<tr><th colspan=3>total:$total</th></tr>";
	}
	print "</table>";
}
sub saut{
	if ($total!=0){
		print "<tr><th colspan=2>Total</th><th>$total</th></tr>";
 		$total=0;
 		if ($tr_tiroir==6){
 			print "</table>";
 			print "<div id=saut>.</div>";
			print "<h2>$lot $lot_desi $lot_conteneur</h2>";

			print "<table cellspacing=0 cellpadding=0>";
			}

 	}

	print "<tr><th colspan=3>TIROIR No: $tr_tiroir</th></tr>";
	$tiroir=$tr_tiroir;
}
