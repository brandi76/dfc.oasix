#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

print $html->header;

$action=$html->param('action');
require "./src/connect.src";

$base="aircotedivoire";
$query="select * from $base.errdep where erdep_depart>1000 and erdep_depart<9999";
$sth=$dbh->prepare($query);
$sth->execute();
while (($erdep_cd_pr,$erdep_depart,$erdep_code,$erdep_qte)=$sth->fetchrow_array){
	$date=&get("select liv_date from $base.listevol where liv_dep='$erdep_depart'");
	print "$date ";
	print &julian($date,"yyyymmdd");
	print "$erdep_code<br>";
	$newdate=&julian($date,"yyyymmdd");
	$check=&get("select count(*) from $base.errdep where erdep_depart='$newdate' and erdep_cd_pr='$erdep_cd_pr' and erdep_code='$erdep_code'","aff")+0;
	print "*$check*";
	if ($check==0){
	  &save("update  $base.errdep set erdep_depart='$newdate' where erdep_cd_pr='$erdep_cd_pr' and erdep_code='$erdep_code'","aff");
	}
}