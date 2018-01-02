#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$action=$html->param('action');
$src=$html->param('src');
$dest=$html->param('dest');
$message=$html->param('message');
$nb=$html->param('nb');
$index=$html->param('index');

print $html->header;
print "<html><head><title>messagerie</title><meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body>";
require "./src/connect.src";
if ($action eq "sup"){
	&save("delete from message where mes_index='$index'");
}

if ($action eq "creer"){
	&save("insert into message (mes_src,mes_dest,mes_fin,mes_message,mes_lu)value ('$src','$dest',DATE_ADD(now(),INTERVAL $nb DAY),'$message','0')");
}

print "<center><h1>Messagerie</h1>";
print "<table border=0 width=50%><tr><td><form>";
print "<select name=src><option value=null>De la part de</option>";
print "<option value=marie>marie</option>";
print "<option value=carole>carole</option>";
print "<option value=philippe>philippe</option>";
print "<option value=sylvain>sylvain</option>";
print "<option value=maxime>maxime</option>";
print "<option value=alain>alain</option>";
print "</select>";

print "</td><td><select name=dest>";
print "<option value=null>Pour</option>";
print "<option value=marie>marie</option>";
print "<option value=carole>carole</option>";
print "<option value=philippe>philippe</option>";
print "<option value=sylvain>sylvain</option>";
print "<option value=maxime>maxime</option>";
print "<option value=alain>alain</option>";
print "</select>";

print "</td><td>nb jour de validité <select name=nb>";
print "<option value=1>1</option>";
print "<option value=2>2</option>";
print "<option value=3 selected>3</option>";
print "<option value=4>4</option>";
print "<option value=5>5</option>";
print "<option value=5>6</option>";
print "<option value=5>7</option>";
print "<option value=5>14</option>";
print "<option value=5>21</option>";
print "</select>";
print "</tr></table><br>message sans accent,ponctuation (128 caracteres maxi) <bR>";
print "<textarea name=message cols=60 rows=4></textarea><br>";
print "<br><input type=submit value=envoyer><input type=hidden name=action value=creer></form>";


$query="select * from message where mes_fin>=now() order by mes_dest";
$sth=$dbh->prepare($query);
$sth->execute();
while (($index,$src,$dest,$date,$message,$lu)=$sth->fetchrow_array)
{
	$color="lightblue";
	if ($lu==1){$color="#efefef";}
	print "<table border=1 width=80% cellspacing=0><tr bgcolor=$color><td>de la part de $src pour <b>$dest</b> ";
	if ($lu==1){print " <font color=red>message lu";}
	print "</td><td>Date de validite:$date</td></tr>";
	print "<tr><td";
	print ">$message</td><td><a href=?action=sup&index=$index>sup</a></td></tr>";
	print "</table><br>";
}

