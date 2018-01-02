#!/usr/bin/perl
use CGI::Session;
use CGI;

# Ricuperation parametre action
$query = new CGI;

if ($query->param('logout')) {
  # Utilisateur voulant fermer sa session manuellement
  # Ricupiration de la session
  $cookie = $query->cookie(-name => "session");
  if ($cookie) {
    CGI::Session->name($cookie);
  }
  # Expiration de la session serveur
  $session = new CGI::Session("driver:File",$cookie,{'Directory'=>"/tmp/apache"}) or die "$!";
  $session->clear();
  $session->expire('+2h');
  # Destruction du cookie de session
  print "Set-Cookie: session=$id; domain=.$host; path=/; expires=Sat, 8-Oct-2001 01:01:01 GMT\n";
  # Retour automatique ` la page d'identification
  print "Location: ".$ENV{'HTTP_REFERER'}."\n\n";
  exit(0);
}

# Initiation de la session
$session = new CGI::Session("driver:File",undef,{'Directory'=>"/tmp/apache"});

# Ricupiration de l'identifiant et du mot de passe
$login = $query->param('login');
$login =~ s/(?:\012\015|\012|\015)//g;
$pwd = $query->param('pwd');
$pwd =~ s/(?:\012\015|\012|\015)//g;

# Test de validiti de la paire et assignation d'une variable de status.
if (($login eq 'Admin') and ($pwd eq 'Password')) {
  $zstatus = 'administrator';
} elsif (($login eq 'Private') and ($pwd eq 'Soldier')) {
  $zstatus = 'private';
} else {
  print "Content-type: text/plain\n\nNope !";
  exit(0);
}

# Inscription de la variable dans la session sur le serveur
$session->param('status',$zstatus);
$session->expire('+2h');

# Envoi du cookie reliant l'utilisateur ` sa session serveur
$id = $session->id();
$host = $ENV{'HTTP_HOST'};
print "Set-Cookie: session=$id; domain=.$host; path=/\n";

# Retour ` la page d'accueil
print "Location: ".$ENV{'HTTP_REFERER'}."\n\n";

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

exit(0);
