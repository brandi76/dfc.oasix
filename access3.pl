#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;


open(HTML,"< /home/intranet/public_html/commande.html");
@htm = <HTML>;
close(HTML);

foreach $ligne (@htm){
	if(! grep /<!--pass incorect-->/,$ligne){
		print "$ligne";
	}
	else{
		print "<font color=red><b><i>Code personnel ou mot de passe invalide !</b></i></font>";
	}
}

# -E Error de mot de passe ou code agent pour OCDE