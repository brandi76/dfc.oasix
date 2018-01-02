#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser); 
$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>temp</title>";
require "./src/connect.src";
# $dbh2 = DBI->connect("DBI:mysql:host=192.168.1.87:database=FLYDEV;","root","",{'RaiseError' => 1});


$query="select coc_no,ic2_date,coc_cd_pr,coc_qte/100,coc_puni/100,ic2_com1 from comcli,infococ2 where coc_no>=12044 and coc_no<=12073 and coc_no=ic2_no and ic2_cd_cl=500 and coc_in_pos=5 order by ic2_com1,ic2_no";
$sth=$dbh->prepare($query);
$sth->execute();
while (($coc_no,$date,$coc_cd_pr,$qte,$coc_puni,$navire)=$sth->fetchrow_array){
	$desi=&get("select pr_desi from produit where pr_cd_pr=$coc_cd_pr");
	$val=$coc_puni*$qte;
	print "$coc_no;$navire;$coc_no;$date;$coc_cd_pr;$desi;$qte;$coc_puni;$val<br>";
}

