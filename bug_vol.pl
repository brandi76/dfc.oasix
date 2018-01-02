#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$client="aircotedivoire";
 $query="select v_code,v_rot,v_date_sql from $client.vol where v_rot=1 "; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_rot,$date)=$sth->fetchrow_array){
	# $date=&get("select v_date_sql from $client.vol where v_code='$v_code' and v_rot=1");
	&save("update $client.vol set v_date_sql='$date' where v_rot=2 and v_code='$v_code'","aff");
	
}

