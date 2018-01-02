# use Net::SMTP;

$action=$html->param("action");


if ($action eq ""){
	print "<table cellspacing=20><tr><td><div class=titre>S'inscrire : saisir vos informations</div><br>Pour des raisons de confidentialité l'inscription est obligatoire<br>";
	print "Suite à votre demande nous allons verifier que vous faites bien partie du personnel de nos clients<br>";
	print "Nous nous engageons à ouvrir votre compte dans la journée, vous serez averti par un email<br>";
        print "Tous les champs sont obligatoire<br><form>";
       	require ("form_hidden.src");
        print "Nom<br><input type=text name=nom size=25><br>Compagnie aérienne<br><input type=text name=client>";
        print "<br>Adresse email<br><input type=text name=email size=30><br>Trigramme compagnie<br><input type=text name=tri size=3>";
        print "<br>Choisir un pseudo (par defaut se sera l'adresse email) <input type=text name=pseudo><br>";
        print "Mot de passe <input type=password name=pwd><br>";
        print "<input type=hidden name=action value=go>";
        print "<br><input type=submit value=\"s'inscrire\"></form></td></tr></table>";
}        	
if ($action eq "go"){
	$nom=$html->param("nom");
	$client=$html->param("client");
	$email=$html->param("email");
	$tri=$html->param("tri");
	$pseudo=$html->param("pseudo");
	$pwd=$html->param("pwd");
        $texte="nom:$nom\nclient:$client\nemail:$email\ntri:$tri\npseudo:$pseudo\npwd:$pwd\n";
	$email=~s/@/\@/;
=pod
	$smtp = Net::SMTP->new('smtp.altitudetelecom.fr',
			Debug => 0,
			Timeout => 30);
	$smtp->mail('ibsfrance@wanadoo.fr');
	$smtp->to('ibsfrance@wanadoo.fr');
	$smtp->data();
	$smtp->datasend("From: Ibs France <ibsfrance\@wanadoo.fr>\n");
	$smtp->datasend("To: ibsfrance \n");
	$smtp->datasend("Subject: inscription\n");}
	$smtp->datasend("$texte\n");
	$smtp->datasend("\n\n");
	$smtp->dataend();
	$smtp->quit();
=cut
	print " Votre demande à bien été prise en compte , elle sera éffective d'ici quelques heures";
}


;1


