print "<title>Readtpe</title>";

require("./src/connect.src");

$query="select distinct oa_serial,oa_date_import from oasix order by oa_date_import desc limit 100 ";
$sth=$dbh->prepare($query);
$sth->execute();

print " <div class=titre>100 dernieres tpes déchargées</div><br>";
while (($oa_serial,$oa_date_import)=$sth->fetchrow_array)
{
	$num=&get("select oa_num from oasix_tpe where oa_serial=$oa_serial");
	if ($num eq "") {$num=$oa_serial;}
	print " tpe:$num $oa_date_import <br>";	
}

;1
