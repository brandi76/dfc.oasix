print "<title>bon en attente de document douane</title></head>";


require "./src/connect.src";
print "Bon en attente de sortie douane (saiappauto)<br>";
$query="select ns_code,v_vol,v_date from non_sai,vol where ns_code=v_code and v_rot=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($appro,$vol,$date)=$sth->fetchrow_array){
	print "appro:$appro vol:$vol $date<br>";
}

;1
