#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

# $perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
require "./src/connect.src";

$query="select nav_nom from navire";
$sth=$dbh->prepare($query);
$sth->execute();

while (($navire)=$sth->fetchrow_array){

$date1="2008-05-05";
for ($x=0;$x<10;$x=$x+1){
	$date2=&get("select date_add('$date1',interval 6 day)","af");
# print "$date1 $date2 <br>";
	
	$nb=&get("select count(*) from corsica_tva where tva_date>'$date1' and tva_date < '$date2' and tva_famille='PARFUMS' and tva_nom='$navire'")+0;
	if ($nb==0){next;}
	$nb2=&get("select count(*) from corsica_tva where tva_date>'$date1' and tva_date < '$date2' and tva_famille='PARFUMS' and tva_type like 'Bon%' and tva_nom='$navire'");
	
	$pour=int($nb2*100/$nb);
	print "$navire semaine:", &semaine($date1)," $pour%<br>";
	$date1=&get("select date_add('$date1',interval 7 day)","af");
}
}