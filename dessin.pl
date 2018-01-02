#!/usr/bin/perl
use CGI;

$html=new CGI;
print $html->header;
$reponse=$html->param("reponse");
$index=$html->param("index");

print "<table border=1 cellspacing=0>";
for ($j=1;$j<30;$j++){
print "<tr>";
for ($i=1;$i<30;$i++)
{
print "<td width=20><a href=?i=$i&j=$j>&nbsp;</a></td>";
}
print "</tr>";
}
print "</table>";
