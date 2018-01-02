# $dbh = DBI->connect("DBI:mysql:host=192.168.1.87:database=FLY;","root","",{'RaiseError' => 1});

$action=$html->param("action");

print "*";
if ($action eq "login"){
	# Initiation de la session
	$session = new CGI::Session("driver:File",undef,{'Directory'=>"/tmp/apache"});
	
	$login = $html->param('login');
	$login =~ s/(?:\012\015|\012|\015)//g;
	$pwd = $html->param('pwd');
	$pwd =~ s/(?:\012\015|\012|\015)//g;
	
	if (&get("select ac_pwd from accespnc where ac_login='$login'") ne $pwd){
		print "<font color=red>Mot de passe ou login invalide</font>";
		$action="";
                }
       else {
		# Inscription de la variable dans la session sur le serveur
		$session->param('status',$login);
		$session->expire('+2h');
		# Envoi du cookie reliant l'utilisateur ` sa session serveur
		$id = $session->id();
		$host = $ENV{'HTTP_HOST'};
		# Petit nettoyage du dossier des sessions
		if (int(rand(10)) == 1) {
			# expire old sessions
			$filez = "/tmp/apache/*";
			while ($file = glob($filez)) {
					@stat=stat $file; 
				$days = (time()-$stat[9]) / (60*60*24);
				unlink $file if ($days > 3);
			}
		}
		print "***";
		exit;
		print "<script>document.location.href=\"set_session_cookie.pl?id=$id&host=$host\"</script>";
	}
}

if ($action eq ""){
	print "<form method=get>";
	require ("form_hidden.src");
	print "<fieldset id=\"identification\">";
	print "<legend>Identification</legend>
	<dl>
	<dt><label for=login>Login</label></dt>
	<dd><input type=text name=login id=login size=10 /></dd>
	<dt><label for=pwd>Mot de passe</label></dt>
	<dd><input type=password name=pwd id=pwd size=10 /></dd>
	</dl>
	<p><input type=submit value=\"Ouvrir une session en mode sécurisé\">
	</fieldset>
	<input type=hidden name=action value=login>	
	</form>";
}
if ($action eq "logout"){
	# Utilisateur voulant fermer sa session manuellement
	$cookie = $query->cookie(-name => "session");
	if ($cookie) {
	CGI::Session->name($cookie);
	}
	# Expiration de la session serveur
	$session = new CGI::Session("driver:File",$cookie,{'Directory'=>"/tmp/apache"}) or die "$!";
	$session->clear();
	$session->expire('+2h');
	print "<script>document.location.href=\"sup_session_cookie.pl?id=$id&host=$host\"</script>";
}
;1

