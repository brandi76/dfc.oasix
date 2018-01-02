#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
$tiroir=$html->param("tiroir");
$action=$html->param("action");

if ($action eq "") {
	print "<form>";
	print "Tiroir (xxx_x):<input type=text name=tiroir>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit value=go>";
	print "</form>";
}
else
{
 &save("delete from radio_tiroir where rat_tiroir='$tiroir'");

 print "<h2>Lecture en cours<br>";
 `/home/intranet/cgi-bin/radio_1.2.pl`;
$query="select * from radio order by rad_no";
$sth=$dbh->prepare($query);
$sth->execute;
while ($rad_no= $sth->fetchrow_array) {
	# print "$rad_no<br>";
 	&save("replace into radio_tiroir values('$tiroir','$rad_no',now())","af");
	$i++;
}
print $i;
print "</h2>";
if ($tiroir ne "retour"){
	$type=substr($tiroir,0,3);
	$query="(select tr_cd_pr,tr_qte/100 from trolley where tr_code=$type and tr_ordre >180 and tr_ordre<1000 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)) union (select ecr_cd_pr,ecr_qte/100 from ecartrol where ecr_cdtrol=$type)";
	# print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while (($tr_cd_pr,$tr_qte)=$sth->fetchrow_array) {
		$ordre=&get("select tr_ordre from trolley where tr_code=$type and tr_cd_pr='$tr_cd_pr'");
		if (($ordre <=180)||($ordre>=1000)){next;}
		$qte_radio=&get("select count(*) from radio_tiroir,radio_produit where rat_tiroir='$tiroir' and rat_no=rap_no and rap_cd_pr='$tr_cd_pr'","af");
		if ($qte_radio!=$tr_qte){
			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$tr_cd_pr'");
			print "$tr_cd_pr $pr_desi qte appro:$tr_qte qte radio:$qte_radio<br>";
		}
	}
	$query="select rat_cd_pr from radio_tiroir,radio_produit where rat_tiroir=$tiroir and rat_no=rap_no and rap_cd_pr not in (select tr_cd_pr,tr_qte from trolley where tr_code=$type and tr_ordre >180 and tr_ordre<1000)";
	# print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute;
	while ($tr_cd_pr=$sth->fetchrow_array) {
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$tr_cd_pr");
		print "$tr_cd_pr $pr_desi trouvé dans le tiroir mais pas sur le bon appro<br>";
		}
	}
}


# -E affectation d un tiroir avec appro
