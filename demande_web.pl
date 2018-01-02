print "<title>Demande Web</title>";
require "./src/connect.src";
print "<center><div class=titrefixe> Demande de compte en attente<br></div>";
$action="";
if ($action eq ""){
	$query="select * from client_web  order by date"; 
	$sth=$dbh->prepare($query);
	$sth->execute;
	print "<table cellspacing=0 cellpadding=0 border=1><tr><th>Code client</th><th>Nom</th><th>Fonction</th><th>Email</th><th>Adresse</th><th>Organisme</th><th>Pays</th><th>Telephone</th><th>Date</th></tr>";	
	while (($client_id,$gender,$nom,$prenom,$email,$rue,$complement,$codepostal,$ville,$pays,$telephone,$password,$fonction,$organisme,$date)=$sth->fetchrow_array){
		print "<tr>";
		print "<td>$client_id</td>";
		print "<td>$nom $prenoml</td>";
		print "<td>$fonction</td>";
		print "<td>$email</td>";
		print "<td>$rue $complement $codepostal $ville</td>";
		print "<td>$organisme</td>";
		print "<td>$pays</td>";
		print "<td>$telephone</td>";
		print "<td>$date</td>";
		print "</tr>";
	}
	print "</table>";

}
;1
