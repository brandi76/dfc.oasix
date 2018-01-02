#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print $html->header;
$action=$html->param('action');

print "<head><title>suppression des doublons</title></head>";
print "supprime les doublons sur contact 3pieces";

if ($action ne ""){
	$query="select email,count(*) from contact group by email";
        $sth = $dbh->prepare($query);
    	$sth->execute;
    	while (($email,$qte) = $sth->fetchrow_array) {
		if ($qte>1){ 
			&save("delete from contact where email='$email' limit 1","aff"); 	
		}
	}
}
print "<form>";    	
print "<br><input type=hidden name=action value=visu><input type=submit value=sup></form></body>";


# -E suppression des doublons dans contact