#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
$four=$html->param("four");
require "./src/connect.src";

$query="select oa_num,oa_serial from oasix_tpe order by oa_num";
$sth=$dbh->prepare($query);
$sth->execute();
@verif=(26,6,36,20,18,35,9,7,12,28,4,22,33,13,32,31,5,15,19,10,23,1);
print "<table border=1 cellspacing=0><tr><th>tpe</th>";
for ($i=1;$i<13;$i++){
	print "<th>";
	print &get("select monthname(\"2006-$i-01\")");
	print "</th>";
}
print "<th>check</th></tr>";
while (($num,$serie)=$sth->fetchrow_array){
	print "<tr><td><b>";
	print "$num $serie</td>";
	for ($i=1;$i<13;$i++){
		$qte=&get("select count(*) from oasix where oa_serial=$serie and oa_rotation='vente1.txt' and month(oa_date_import)=$i and oa_ind=1","af/")+0; 
	        
	        if ($qte>0) {print "<td align=center>$qte</td>";}
	        else {print "<td bgcolor=#646464>&nbsp;</td>";}
	}
	$check="";
	if (&get("select count(*) from oasix where oa_serial=$serie and oa_rotation='vente1.txt' and month(oa_date_import)=month(now()) and oa_ind=1","af/")+0==0){
		$check="<font color=blue>Warm</font>";
	}	
	if ($check eq "<font color=blue>Warm</font>"){
		if (&get("select count(*) from oasix where oa_serial=$serie and oa_rotation='vente1.txt' and month(oa_date_import)=month(now())-1 and oa_ind=1","af/")+0==0){
			$check="<font color=red>Alerte</font>";
		}
	}	

	foreach (@verif){
	if ($num==$_ ){$check="ok";}
	}
	
	print "<td>$check</td></tr>";
}
print "</table>";

# -E le 10/06 pour rechercher les tpe manquante