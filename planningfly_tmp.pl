#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
foreach $client (@bases_client){
if ($client eq "dfc"){next;}
if ($client eq "formation"){next;}

	$query="select fl_date,fl_vol from $client.flyhead order by fl_date";  
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while(($fl_date,$fl_vol)=$sth3->fetchrow_array){
		$date_sql=&julian($fl_date,"yyyy-mm-dd");
		&save("update $client.flyhead set fl_date_sql='$date_sql' where fl_date='$fl_date' and fl_vol='$fl_vol'","aff");
		}
}
