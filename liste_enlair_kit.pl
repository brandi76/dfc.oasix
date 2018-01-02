print "<title>bon en l'air </title></head>";


require "./src/connect.src";
print "Bon en l'air ou en attente de sortie douane (saiappauto)<br>";
$query="select distinct(so_appro),v_vol,v_date from sortie,vol where so_appro=v_code and v_rot=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($appro,$vol,$date)=$sth->fetchrow_array){
	print "appro:$appro vol:$vol $date<br>";
}

;1
