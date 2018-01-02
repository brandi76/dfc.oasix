#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "/var/www/cgi-bin/oasix/outils_perl2.lib";
require "/var/www/cgi-bin/dfc.oasix/src/connect.src";
$query="select * from survey where flag=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id)=$sth->fetchrow_array){
	if ($id==1){
		$check=&get("select count(*) from corsica.ticket_caisse where ticket_vendeuse='anita' and ticket_date>='2016-08-01'")+0;
		if ($check >0){
			system("/var/www/cgi-bin/dfc.oasix/send_bug.pl 'Anita en place' &");
			&save("update survey set flag=0 where id=1");
		}
	}
}	
