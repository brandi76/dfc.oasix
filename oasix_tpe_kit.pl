require "./src/connect.src";
$serial=$html->param("serial");
if ($serial ne "") {
  $nb=0;
  $fin=substr($serial,length($serial)-3,3)+1000;
  $debut=substr($serial,0,4);
  while ($debut >10){
    $nb=0;
    for ($i=length($debut);$i>0;$i--){
	$nb+=substr($serial,$i,1);
    }
    $debut=$nb;
  }
  $nb=$debut*100+$fin;
  if ($nb>1000){
    $nb=substr($nb,1,3);
  }
  print "<h3>$serial-> $nb</h3><br>";
 &save("replace into oasix_tpe values ('$nb','$serial')");
}
print "<table border=1><tr><th>Numero</th><th>No de serie</th></tr>";
$query="select oa_num,oa_serial from oasix_tpe order by oa_num";
# print $query;
$sth=$dbh->prepare($query);
$sth->execute();
while (($oa_num,$oa_serial)=$sth->fetchrow_array)
{
	print "<tr><td>$oa_num</td><td>$oa_serial</td></tr>";
}
print "</table>";
print "<form>";
require ("form_hidden.src");
print "Numero de serie:<input type=text name=serial size=20><br>";
print "<input type=submit></form>";
;1