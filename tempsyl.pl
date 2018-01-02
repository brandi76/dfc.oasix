#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>temp</title>";
require "./src/connect.src";
# $dbh2 = DBI->connect("DBI:mysql:host=192.168.1.87:database=FLYDEV;","root","",{'RaiseError' => 1});

$query="select pr_cd_pr,pr_desi,pr_codebarre from produit where (pr_type=1 or pr_type=5) and pr_cd_pr<10000000 and pr_sup=3";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_codebarre)=$sth->fetchrow_array)
	
{
  	$car=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'");
  	if ($car >0){next;}
  	$car=&get("select car_carton from carton where car_cd_pr='$pr_codebarre'")+0;
  	if ($car==0){next;}
  	
  	print "$pr_cd_pr $pr_desi $car";
   	&save ("update carton set car_carton=$car where car_cd_pr=$pr_cd_pr","aff");
  	print "<br>";
}
