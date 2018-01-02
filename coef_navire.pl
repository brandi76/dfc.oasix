#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
$four=$html->param("four");
require "./src/connect.src";

print "<table border=1 cellspacing=0 cellpadding=0><tr><th>Navire</th>";
for ($i=1;$i<53;$i++){
print "<td><font size=-2>$i</td>";
}
print "</tr>";
$query="select se_navire from semaine2 group by se_navire order by se_navire";
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire)=$sth->fetchrow_array){
	print "<tr><td><b>$navire</td>";
	for ($i=1;$i<53;$i++){
		$coef=&get("select se_coef from semaine2 where se_navire='$navire' and se_no=$i","af")+0;
		$color="white";
		if ($coef==0){$color="#646464";}
		if ($i == &semaine()){$color=blue;}
		$coef=int($coef*10);
		$coef2=$coef/10;
		print "<td valign=bottom bgcolor=$color><font size=-3>$coef2</font><table cellspacing=0 cellpadding=0 width=100%><tr height=$coef bgcolor=red><td></td></tr></table></td>";
	}
	print "</tr>";
}
print "</table>";
