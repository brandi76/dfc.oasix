#!/usr/bin/perl
use CGI;

$html=new CGI;
print $html->header;
print "<head>
 <meta name=charset content= iso-8859-1>
</head>";
$login=$html->param("login");
$passe=$html->param("passe");
print "<center>Creation d'un compte <form>";
print "Nom <input type=text name=login><br>";
print "mot de passe <input type=text name=passe><br>";
print "<input type=submit>";
print "</form>";
if (($login  ne "")&&($passe ne "")){                
system("/usr/bin/htpasswd -b /var/www/.htpasswd_dfc $login $passe");
print "compte cree";
}
