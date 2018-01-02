#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";


$action=$html->param("action");
$solution=$html->param("solution");
$probleme=$html->param("probleme");
$id=$html->param("id");
while ($solution=~s/\'/ /){};
while ($probleme=~s/\'/ /){};

if ($action eq "sauv" and $solution ne "" and $probleme ne ""){
	
	$query="insert into rex (rex_probleme,rex_solution) values ('$probleme','$solution')";
	$sth=$dbh->prepare($query);
	$sth->execute();
}	
if ($action eq "modif"){
	
	$query="replace into rex values ('$id','$probleme','$solution')";
	$sth=$dbh->prepare($query);
	$sth->execute();
}	

if ($action eq "sup"){
	
	$query="delete from rex where rex_index='$id'";
	$sth=$dbh->prepare($query);
	$sth->execute();
}	

if ($action eq "voir"){
	print "<html><body>";
		
	$query="select * from rex where rex_index='$id'";
	$sth=$dbh->prepare($query);
	$sth->execute();
        if (($rex_id,$rex_probleme,$rex_solution)=$sth->fetchrow_array){
        	print "<b>$rex_probleme</b><br>";
		print "<form><textarea cols=80 rows=20 name=solution >$rex_solution</textarea></br><input type=submit value=modif>";
		print "<input type=hidden name=action value=modif>";
		print "<input type=hidden name=id value=$id>";
		print "<input type=hidden name=probleme value='$rex_probleme'>";
		print "<br><br><input type=button value=retour name=retour onclick=javascript:history.back()>";
		print "</form></body></html>";
	}
        print "</body></html>";
	
}	
else
{
print "<html><body><h1>REX</h1><br>";
$query="select * from rex order by rex_index";
$sth=$dbh->prepare($query);
$sth->execute();
while (($rex_id,$rex_probleme,$rex_solution)=$sth->fetchrow_array){
	print "<a href=rex.pl?action=voir&id=$rex_id>$rex_id $rex_probleme</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href=rex.pl?action=sup&id=$rex_id><font size=-2>sup</font></a><br>";
}
print "<form><br>Problème <input type=texte name=probleme size=80><br><textarea cols=80 rows=20 name=solution></textarea></br><input type=submit value=envoie>";
print "<input type=hidden name=action value=sauv>";
print "</form></body></html>";
}

