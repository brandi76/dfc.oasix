#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$date="2009-12-31";
$query="select infr_code,v_date,infr_date from inforetsql,vol where infr_date>'$date' and infr_code=v_code and v_rot=1 and  FROM_UNIXTIME(v_date_jl*24*60*60,'%Y-%m-%d')<='$date'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_date,$infr_date)=$sth->fetchrow_array){
	$val=&get("select sum(ro_qte*pr_prac)/10000 from rotation,produit where ro_code=$v_code and ro_cd_pr=pr_cd_pr");
  	print "$v_code date de vol:$v_date,date de saisie:$infr_date $val<br>";
  	$total+=$val;
}
print "$total";