print "creation d'un acces pnc au site";
require "./src/connect.src";

$login = $html->param('login');
if ($login ne ""){
	$pwd = $html->param('pwd');
	$client = $html->param('client');
	$tri = $html->param('tri');
		
	&save("replace into accespnc values ('$login','$pwd','$tri','$client')","aff");
}

print "<form>";
require ("form_hidden.src");
print "Login <input type=text name=login size=30><br>";
print "Mot de passe <input type=text name=pwd size=30><br>";
print "Trigramme <input type=text name=tri size=30><br>";
print "Client <input type=text name=client size=30><br>";
print "<input type=submit value=creer></form>";
;1

