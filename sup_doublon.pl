#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
$action=$html->param('action');

print "<head><title>suppression des doublons</title></head>";
print "supprime les doublons sur le type 0 pour tous les navires";

if ($action ne ""){
	$query="select nav_nom,nav_cd_pr,count(*) as qte from navire2 where nav_type=0  group by nav_nom,nav_cd_pr order by qte desc";
        $sth = $dbh->prepare($query);
    	$sth->execute;
    	while (($navire,$pr_cd_pr,$qte) = $sth->fetchrow_array) {
		if ($qte>1){ 
			&save("delete from navire2 where nav_nom='$navire' and nav_type=0 and nav_cd_pr='$pr_cd_pr' limit 1","aff"); 	
		}
	}
}
print "<form>";    	
print "<br><input type=hidden name=action value=visu><input type=submit value=sup></form></body>";


# -E suppression des doublons dans le fichier navire2
