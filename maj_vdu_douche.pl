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

print "<head><title>maj vendu</title></head>";
if ($action eq ""){
	print "<body><center><h1>MAJ vendu navire<br><form>";
	print "<br> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
       	print "</select><br>\n";
       	$date=&get("select max(nav_date) from navire2 where nav_type=10");
       	print "<br>date <input type=text name=date value='$date'>";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=voir></form></body>";
}
else
{
$query="select nav_cd_pr,sum(nav_qte) as qte from navire2,produit where nav_cd_pr=pr_cd_pr and nav_type=2 and (pr_type=1 or pr_type=5) and nav_date >DATE_SUB(curdate(),INTERVAL 3 MONTH) group by nav_cd_pr order by qte desc limit 120";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
	push (@top120,$pr_cd_pr);
}

 &save("delete from navire2 where nav_nom='$navire' and nav_type=3 and nav_date='$date'","aff");
 &save("delete from navire2 where nav_nom='$navire' and nav_type=2 and nav_date='$date'","aff");

$date_1=&get("select distinct nav_date from navire2 where nav_nom='$navire' and nav_type=10 and nav_date<=now() order by nav_date desc limit 1,1","af");
$date_mini=&datesimple($date_1);	

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
	$inv_1=0+&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_cd_pr='$pr_cd_pr' and nav_date='$date_1'","af");
	$inv=0+&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=1 and nav_cd_pr='$pr_cd_pr' and nav_date='$date'","af");
 	$liv=0+&get("select sum(coc_qte)/100 from comcli,infococ2 where coc_cd_pr=$pr_cd_pr and coc_no=ic2_no and ic2_com1='$navire' and coc_in_pos=5 and ic2_date>=$date_mini","af");
 	# $vente=0+&get("select nav_qte from navire2 where nav_nom='$navire' and nav_type=2 and nav_cd_pr='$pr_cd_pr' and nav_date>='$date_1'","af");
 	$vendu=$inv_1+$liv-$inv;
 	print "$pr_cd_pr $pr_desi $inv_1 $liv $inv $vendu <br>";
 	if ($vendu > 12){
 		$vendu=12;
		print "vendu modifié $vendu<br>";
 	}
	if (($vendu > 6)&&(! grep /$pr_cd_pr/,@top120)){
		$vendu=4;
		print "vendu modifié $vendu<br>";
 	}
 	if ($vendu>=0){
 		 &save("replace into navire2 values ('$navire','$pr_cd_pr','$date',2,'$vendu',0)","af");
 	}
 	else
 	{
 		 &save("replace into navire2 values ('$navire','$pr_cd_pr','$date',3,'$vendu',0)","af");
 	}
}
}