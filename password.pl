#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;


$action=$html->param('action');
$mail = $html->param('mail');

$code = $html->param('code');
$old_pass = $html->param('old_pass');
$new_pass = $html->param('new_pass');
$new1_pass = $html->param('new1_pass');

$mailprog = '/usr/sbin/sendmail'; 

####################################
if($action eq "oublie"){
	&oublier_mot_de_passe;
}
if($action eq "change"){
	&changer_mot_de_passe;
}


####################################

if($action eq "send_pass"){
	&envoyer_mot_de_passe;
}

if($action eq "change_pass"){
	&enregistrer_mot_de_passe;
}

####################################
sub oublier_mot_de_passe {
	print "<HTML>\n";
	print "<TITLE>Commande OCDE : Password : Forgotten&nbsp;&nbsp;&nbsp;-&nbsp;IBS France&copy;&nbsp;</TITLE>\n";
	print "<BODY BGCOLOR=white text=darkgoldenrod>\n";
	print "<center><h2>Envoie du mot de passe par Mail</h2>\n<br><br><br><p>";
	print "<form method=post action=/cgi-bin/password.pl>";
	print "Vous ne vous souvenez plus de votre mot de passe ?\n<br>";
	print "Il vous suffit de nous envoyer votre adresse electronique et votre mot de passe vous sera automatiquement envoyer dans les 10min.\n";
	print "<p>\n";
	print "<i>Votre code client personnel : </i>\n<input type=text name=code size=20><p>\n";
	print "<i>E-Mail : </i><input type=text size=30 name=mail>\n";
	print "<input type=hidden name=action value=send_pass>\n";
	print "<p>&nbsp;</p><input type=submit value=\"Recevoir le mot de passe !\">\n";
	print "<input type=button onclick='javascript:history.back()' value=\"Annuler\">\n";
	print "</form></BODY></HTML>\n";
		
}
sub changer_mot_de_passe {
	print "<HTML>\n";
	print "<TITLE>Commande OCDE : Password : Change&nbsp;&nbsp;&nbsp;-&nbsp;IBS France&copy;&nbsp;</TITLE>\n";
	print "<BODY BGCOLOR=white text=darkgoldenrod>\n";
	print "<center><h2>Changement de mot de passe.</h2>\n<br><br><br><p>\n";
	print "<form method=post action=/cgi-bin/password.pl>\n<table>\n";
	print "<tr>\n<td><i>Votre code personnel : </i></td>\n<td><input type=text name=code size=20></td>\n</tr>\n";
	print "<tr>\n<td><i>Votre ancien mot de passe : </i></td><td><input type=password name=old_pass size=20></td></tr>\n";
	print "<tr><td><i>Votre nouveau mot de passe : </i></td><td><input type=password name=new_pass size=20></td></tr>\n";
	print "<tr><td><i>Confirmer le nouveau mot de passe : </i></td><td><input type=password name=new1_pass size=20></td></tr>\n";
	print "</table><input type=hidden name=action value=change_pass>\n";
	print "&nbsp;<p><input type=submit value=\"Effectuer le changement\">\n";
	print "<input type=button onclick='javascript:history.back()' value=\"Annuler\">\n";
	print "</form></BODY></HTML>\n";
	
}


###################################
sub envoyer_mot_de_passe {
	$recipient = "ibsfrance\@wanadoo.fr";
	open(FILE,"< passwd.txt");
	@ligne = <FILE>;
	close(FILE);
	$bool=0;

	foreach $tmp (@ligne){
		($code_ocde,$password_ocde) = split (/;/,$tmp);
		if($code_ocde eq $code ){
			$bool=1;
			last;
		}	
		
	}
	
	if($bool eq 1){
		open (MAIL, "|$mailprog -t") || die "Can't open $mailprog!\n"; 
		print MAIL "To: ",$html->param('mail'),"\n"; 
		print MAIL "From: $recipient\n"; 
		print MAIL "Subject: Mot de passe IBS France.\n\n"; 
		print MAIL "Vous aviez oublier votre mot de passe,\n"; 
		print MAIL "alors voici les parametres qui vous permette d'acceder a votre commande.\n\n";
		print MAIL "Code client personnel : $code_ocde\n";
		print MAIL "Mot de passe : $password_ocde\n\n\n";
		print MAIL "La consultation de votre commande est disponible sur : http://intranet.com/commande.htm\n\n";
		print MAIL "Nous vous rapelons qu'il est possible de modifier votre mot de passe a tout moment à cette adresse meme.\n\n";
		print MAIL "Nos remerciement pour l'utilisation de nos services\n";
		print MAIL "           I.B.S.  FRANCE\n";
		close (MAIL); 
		
		print "<HTML>\n";
		print "<TITLE>Commande OCDE : Password : Send&nbsp;&nbsp;&nbsp;-&nbsp;IBS France&copy;&nbsp;</TITLE>\n";
		print "<BODY text=darkgoldenrod>\n";
		print "<center><h2>Mot de passe envoyer</h2>\n<br><br><br><p>";
		print "Vous recevrez votre mot de passe d'ici 10min à l'adresse suivant :.\n";
		print "<br><br><font color=red><i>$mail</i></font><br>\n";
		print "<p>\n";
		print "<a href=/commande.html>Retour page d'acceuil</a>\n";
		print "</BODY></HTML>\n";
	}else{
		print "<HTML>\n";
		print "<TITLE>Commande OCDE : Password : Forgotten&nbsp;&nbsp;&nbsp;-&nbsp;IBS France&copy;&nbsp;</TITLE>\n";
		print "<BODY text=darkgoldenrod>\n";
		print "<center><h2>Envoie du mot de passe par Mail</h2>\n<br><br><br><p>";
		print "<form method=post action=/cgi-bin/password.pl>Vous ne vous souvenez plus de votre mot de passe ?\n<br>";
		print "Il vous suffit de nous envoyer votre adresse electronique et votre mot de passe vous sera automatiquement envoyer dans les 10min.\n";
		print "<p>\n";
		print "<i>Votre code client personnel : </i><input type=text name=code size=20><p>";
		print "<i>E-Mail : </i><input type=text size=30 name=mail>";
		print "<input type=hidden name=action value=send_pass>\n";
		print "<p><font color=red><i><b>Erreur dans votre code personnel !</b></i></font><p><input type=submit value=\"Recevoir le mot de passe !\"></form></BODY></HTML>\n";

	}
	
}

sub enregistrer_mot_de_passe {
	$find = 0;
	open(PASSFILE,"< passwd.txt");
	@file = <PASSFILE>;
	close(PASSFILE);	
	if($new_pass ne $new1_pass){
		print "<HTML>\n";
		print "<TITLE>Commande OCDE : Password : Change : Error&nbsp;&nbsp;&nbsp;-&nbsp;IBS France&copy;&nbsp;</TITLE>\n";
		print "<BODY text=darkgoldenrod>\n";
		print "<center><h2>Changement de mot de passe.</h2>\n";
		print "<br><br><br><p><form method=post action=/cgi-bin/password.pl>\n";
		print "<table><tr><td><i>Votre code personnel : </i></td><td><input type=text name=code size=20 value=$code></td></tr>\n";
		print "<tr><td><i>Votre ancien mot de passe : </i></td><td><input type=password name=old_pass size=20 value=$old_pass></td></tr>\n";
		print "<tr><td><i><font color=black><b>Votre nouveau mot de passe : </b></font></i></td><td><input type=password name=new_pass size=20></td></tr>\n";
		print "<tr><td><i><font color=black><b>Confirmer le nouveau mot de passe : </b></font></i></td><td><input type=password name=new1_pass size=20></td></tr>\n";
		print "</table><input type=hidden name=action value=change_pass>\n";
		print "<font color=red><i><b>Erreur dans la confirmation du nouveau mot de passe.</i></b></font>\n";
		print "<p><input type=submit value=\"Effectuer le changement\"></form></BODY></HTML>\n";
	
	}
	else{
			foreach $ligne (@file){
				($code_file,$password_file) = split(/;/,$ligne);
				if($code_file eq $code && $password_file eq $old_pass){
					#print "$code:$new_pass:\n";
					push(@newfile,"$code;$new_pass;");
					$find = 1;
				}
				else{
					push(@newfile,"$ligne");
					#print "$ligne";
				}
			}

		if($find eq 0){
			print "<HTML>\n";
			print "<TITLE>Commande OCDE : Password : Change : Error&nbsp;&nbsp;&nbsp;-&nbsp;IBS France&copy;&nbsp;</TITLE>\n";			
			print "<BODY text=darkgoldenrod>\n";
			print "<center><h2>Changement de mot de passe.</h2>\n";
			print "<br><br><br><p><form method=post action=/cgi-bin/password.pl>\n";
			print "<table><tr><td><font color=black><b><i>Votre code personnel : </b></font></i></td><td><input type=text name=code size=20></td></tr>\n";
			print "<tr><td><font color=black><b><i>Votre ancien mot de passe : </b></font></i></td><td><input type=password name=old_pass size=20></td></tr>\n";
			print "<tr><td><i>Votre nouveau mot de passe : </i></td><td><input type=password name=new_pass size=20></td></tr>\n";
			print "<tr><td><i>Confirmer le nouveau mot de passe : </i></td><td><input type=password name=new1_pass size=20></td></tr>\n";
			print "</table><input type=hidden name=action value=change_pass>\n";
			print "<font color=red><i><b>Code personnel ou ancien mot de passe eroné.</i></b></font>\n";
			print "<p><input type=submit value=\"Effectuer le changement\"></form></BODY></HTML>\n";
		}
		else{
			open(PASSFILE,"< /home/intranet/cgi-bin/passwd.txt");
			@file = <PASSFILE>;
			
	
			print "<HTML>\n";
			print "<TITLE>Commande OCDE : Password : Change : Ok&nbsp;&nbsp;&nbsp;-&nbsp;IBS France&copy;&nbsp;</TITLE>\n";
			print "<BODY text=darkgoldenrod>\n";
			print "<center><h2>Changement effectué</h2>\n<br><br><br><p>";
			print ".\n";
			print "<br><br><font color=red><i>**$mail**</i></font></br>\n";
			print "<p>\n";
			print @newfile,"\n";
			print "</BODY></HTML>\n";
		}
	}
}

# -E gestion des mot de pass pour OCDE