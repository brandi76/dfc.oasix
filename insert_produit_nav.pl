#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
$navire=$html->param('navire');
$action=$html->param('action');
$date=$html->param('date');
$produit=$html->param('produit');

print "<head><title>insert produit</title></head>";
$sth = $dbh->prepare("select nav_nom from navire");
$sth->execute;
while ($nom = $sth->fetchrow_array) {
	push (@liste,$nom);
}
if ($action ne ""){
  #     	foreach $navire (@liste){
       		$date=&get("select max(nav_date) from navire2 where nav_type=1 and nav_nom='$navire'");
		#$nb=&get("select count(*) from navire2 where nav_type=0 and nav_cd_pr='$produit' and nav_nom='$navire'","af");
		#if ($nb==0){
			&save("insert into navire2 values ('$navire','$produit','$date','0','6','')","aff");
			&save("insert into navire2 values ('$navire','$produit','$date','1','0','')","aff");
		#}
#	}
}
	print "<body><center><h1>insertion produit<br><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
      		print "</select><br>\n";
      	print "<br>produit <input type=text name=produit value='$produit'>";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=insertion></form></body>";
