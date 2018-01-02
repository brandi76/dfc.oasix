# Utilisateur voulant fermer sa session manuellement
$cookie = $html->cookie(-name => "session");
if ($cookie) {
CGI::Session->name($cookie);
}
# Expiration de la session serveur
$session = new CGI::Session("driver:File",$cookie,{'Directory'=>"/tmp/apache"}) or die "$!";
$session->clear();
$session->expire('+2h');
print "<script>document.location.href=\"sup_session_cookie.pl?id=$id&host=$host\"</script>";
;1

