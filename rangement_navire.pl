#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");

require "./src/connect.src";

if ($action eq ""){
	print "<body><center><h1>Rangement navire<br><form>";
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

	
if ($action eq "modif"){
	$query="select nav_cd_pr,nav_pos from navire2,produit where nav_nom='$navire' and  nav_cd_pr=pr_cd_pr and nav_type=0 and (pr_type=5 or pr_type=1) and (pr_sup=0 or pr_sup=3)";
	print $query;
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($nav_cd_pr,$nav_pos) = $sth->fetchrow_array) {
		$newpos=$html->param($nav_cd_pr);
    		if ($newpos!=$nav_pos){
    			&save("update navire2 set nav_pos=$newpos where nav_nom='$navire' and nav_type=0 and nav_cd_pr='$nav_cd_pr'","aff");
		}
	}
	$action="visu";
}
if ($action eq "visu"){
	print "<html><body><center><h2>$navire</h2><form method=POST><table border=1 cellspacing=0>";
	$sth = $dbh->prepare("select nav_cd_pr,pr_desi,pr_four,fo2_add,nav_pos from navire2,produit,fournis where nav_nom='$navire' and nav_type=0 and nav_cd_pr=pr_cd_pr and pr_four=fo2_cd_fo and (pr_type=5 or pr_type=1) and (pr_sup=0 or pr_sup=3) order by nav_pos,pr_desi");
	$sth->execute;
	while (($nav_cd_pr,$pr_desi,$pr_four,$fo2_add,$nav_pos) = $sth->fetchrow_array) {
    	($fo2_add)=split(/\*/,$fo2_add);
    	print "<tr>";
    	print "<td>$nav_cd_pr</td><td>$pr_desi</td><td><input type=text name=$nav_cd_pr size=3 value=$nav_pos></td><td>$pr_four</td><td>$fo2_add</td>\n";
    	print "</tr>";
   	}
print "</table><input type=submit value=valider><input type=hidden name=action value=modif><input type=hidden name=navire value='$navire'></form></body></html>";
}
    
