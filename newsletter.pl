#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "./src/connect.src";

print "<center>";
print "
<body text=white bgcolor=black>	

<h3>newsletter</h3>
	<br>    ";
$query="select * from contact";
$sth=$dbh->prepare($query);
$sth->execute();
while (($mail)=$sth->fetchrow_array){
$liste.="$mail;";
}
chop($liste);
print "<font size=-3>";
print $liste;
print "</font>";
print "<br>";
print "<br>";
print "<br>";

print "<a href=mailto:".$liste."?Subject=newsletter_du_trois_pieces>envoyer</a>";
