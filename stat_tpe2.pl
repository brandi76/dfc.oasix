#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
$mois=$html->param("mois");
require "./src/connect.src";
print "<table border=1><tr><th>appro</th><th>client</th><th>date</th><th>tpe</th><th>reel</th></tr>";

$query="select v_code,v_cd_cl,v_date from vol where from_unixtime(v_date_jl*24*60*60,'%m')=$mois and from_unixtime(v_date_jl*24*60*60,'%Y')=2007 and v_rot=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($i,$v_cd_cl,$v_date)=$sth->fetchrow_array){
	$reel=&get("select sum((ret_qte-ret_retour)*ret_prix) from retoursql where ret_code=$i")+0;
	if ($reel==0){next;}                                                                           
	$tpe=&get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro=$i")+0;
	print "<tr><td>$i</td><td>$v_cd_cl</td><td>$v_date</td><td>$tpe</td><td>$reel</td></tr>";
	$nb++;
	if ($tpe==0){$null++;}
	if ($tpe==$reel){$ok++;}
	if ($tpe>$reel){$sup++;}
	if ($tpe<$reel){$moins++;}
}

print "</table>";
print "nombre de vol:$nb<br>";
print "nombre de vol sans utilisation de la tpe :$null<br>";
print "nombre de vol ou la tpe correspond au reel:$ok<br>";
print "nombre de vol ou la tpe est superieur au reel :$sup<br>";
print "nombre de vol ou la tpe est inferieur au reel :$moins<br>";
