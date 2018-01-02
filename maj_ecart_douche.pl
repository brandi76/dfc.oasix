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
$date=$html->param('date');
$prodet=$html->param('produit');
if ($prodet ne "") {$option="debug";}

print "<head><title>maj ecart</title></head>";
if ($action eq ""){
	print "<body><center><h1>MAJ Ecart navire<br><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
       	$date=&get("select max(nav_date) from navire2 where nav_type=3");
       	print "<br>date <input type=text name=date value='$date'>";
    	print "</select><br>\n";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=voir></form></body>";
}
else
{
&save("delete from navire2 where nav_nom='$navire' and nav_type=3 and nav_date='$date'","aff");

if ($option ne "debug"){
	$query="select nav_cd_pr,pr_desi,pr_prac/100,pr_sup,nav_pos from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and pr_sup!=5 and pr_sup!=4 and pr_sup!=2 and (pr_type=1 or pr_type=5) group by nav_cd_pr order by nav_cd_pr";
}
else
{ 
	$query="select nav_cd_pr,pr_desi,pr_prac/100,pr_sup,nav_pos from navire2,produit where nav_nom='$navire' and nav_cd_pr=pr_cd_pr and nav_type=0 and pr_sup!=5 and pr_sup!=4 and pr_sup!=2 and (pr_type=1 or pr_type=5) and pr_cd_pr=$prodet";
}
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_sup,$nav_pos)=$sth->fetchrow_array){
	%calcul=&table_navire($navire,$pr_cd_pr,$option);
	$inv=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=10 and nav_cd_pr='$pr_cd_pr' and nav_date='$date'","aff")+0;
	 # $inv+=&get("select floor(sum(coc_qte/100)) from infococ2,comcli where ic2_cd_cl=500 and ic2_com1='$navire' and coc_in_pos=5 and coc_qte>0 and coc_no=ic2_no and coc_cd_pr=$pr_cd_pr and ic2_no='8745'  ")+0; 
	 # $inv-=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_date='2006-07-30'","aff")+0;

 	$ecart=$inv-$calcul{'stock_navire'};
 	print "$calcul{'stock_navire'} $inv $ecart";
 	&save("replace into navire2 values ('$navire','$pr_cd_pr','$date',3,'$ecart',0)","aff");
}
}