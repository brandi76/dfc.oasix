$copie1=$html->param("copie1");
$copie2=$html->param("copie2");
$copie3=$html->param("copie3");


if ($action eq ""){
	print "Mailing Fournisseur<br>";
	print "<form  method=POST>";
 	&form_hidden();
	$query="select distinct fo2_cd_fo,fo2_add from fournis where fo2_delai>0 and fo2_email!='' order by fo2_add";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array){
		($fo_desi)=split(/\*/,$fo2_add);
		print "<input type=checkbox name=$fo2_cd_fo> $fo2_cd_fo $fo_desi<br>";
	}
	print "Cc <input type=text name=copie1 size=50><br>";	
	print "Cc <input type=text name=copie2  size=50><br>";	
	print "Cc <input type=text name=copie3 size=50><br>";	
	print "Sujet (les accents ne sont pas autoris&eacute;s): <input type=text name=sujet><br>";
	print "<textarea name=texte style=width:100%;height:200px>";
	print "texte d'accompagnement ";
	print "</textarea><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit value='Envoyer le mailing'>";
	print "</form>";
}

if ($action eq "go"){
	$ok=1;
	$sujet=$html->param("sujet");
	print "<p><strong>$sujet</strong></p>";
	$texte=$html->param("texte");
	print "<pre>$texte</pre>";
	$texte=~s/\"//g;
	&save("insert into mailing_four (texte) values (\"$texte\")");
	$texte_id=&get("select LAST_INSERT_ID() from mailing_four");
	# $texte_id=13;
	# $texte=&get("select texte from mailing_four where texte_id=13");
	
	if (length($texte)<25){
			print "<p style=background:pink>Le texte d'accompagnement est trop court, l'envoi ne sera pas fait</p>";
			$ok=0;
	}
	if ($sujet eq ""){
			print "<p style=background:pink>Pas de sujet, l'envoi ne sera pas fait</p>";
			$ok=0;
	}
	if ($sujet=~m/[^a-zA-Z 0-9-_]/){
			print "<p style=background:pink>Caractere non autoris&eacute; dans le sujet, l'envoi ne sera pas fait</p>";
			$ok=0;
	}
	$rien=1;
	if ($ok){
		$query="select distinct fo2_cd_fo,fo2_email from fournis where fo2_delai>0 and fo2_email!='' order by fo2_add";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($fo2_cd_fo,$fo2_email)=$sth->fetchrow_array){
			($mail)=split(/\;/,$fo2_email);
			if ($html->param("$fo2_cd_fo") eq "on"){
				print "Envoi $mail<br>";
				system("/var/www/cgi-bin/dfc.oasix/send_mailing_four.pl '$mail' '$sujet' '$texte_id' &");
				$rien=0;
			}	
			$rien=0;
		}
		if ($copie1 ne ""){
				print "Envoi $copie1<br>";
				system("/var/www/cgi-bin/dfc.oasix/send_mailing_four.pl '$copie1' '$sujet' '$texte_id' &");
		}
		if ($copie2 ne ""){
				print "Envoi $copie2<br>";
				system("/var/www/cgi-bin/dfc.oasix/send_mailing_four.pl '$copie2' '$sujet' '$texte_id' &");
		}
		if ($copie3 ne ""){
				print "Envoi $copie3<br>";
				system("/var/www/cgi-bin/dfc.oasix/send_mailing_four.pl '$copie3' '$sujet' '$texte_id' &");
		}
	
		$mail="supply_dfc\@dutyfreeconcept.com";
		print "Envoi $mail<br>";
		system("/var/www/cgi-bin/dfc.oasix/send_mailing_four.pl '$mail' '$sujet' '$texte_id' &");
	}
	if ($rien){print "<p style=background:pink>Aucun fournisseur n'a &eacute;t&eacute; selectionn&eacute;</p>";}
}
;1
