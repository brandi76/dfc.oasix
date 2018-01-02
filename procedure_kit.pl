if ($action eq "go"){
	$fichier1=$html->param("fichier1");
	if ($fichier1 ne ""){
		$file="/var/www/procedures/$fichier1";
		open(FILE,">$file");
		while (read($fichier1, $data, 2096)){
			print FILE $texte.$data;
		}
		close(FILE);
		print "$fichier1 enregistré<br>";
	}
	else { print "Fichier vide<br>";}
	$action="";
}
if ($action eq ""){
	print "<form  method=POST enctype=multipart/form-data>";
  	print "<div class=titre>Enregistrement des procedures</div><br>";
	&form_hidden();
	print "<h2>Nom de fichier sans accents sans espaces</h2>";
	print "<input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "Fichier pdf <input type=file name=fichier1 accept=application/pdf maxlength=2097152><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit></form>";
	open(FICHIER,"ls /var/www/dfc.oasix/doc/procedures/*|");
	@ls=<FICHIER>;
	foreach (@ls){
		($null,$null,$null,$null,$null,$null,$fich)=split(/\//,$_);
		print "<a href=http://dfc.oasix.fr/doc/procedures/$fich>";
		print "$fich</a><br>";
	}	
}

;1