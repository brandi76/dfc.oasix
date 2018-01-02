$base=$base_dbh;
if ($action eq "go"){
	$lta=$html->param("lta");
	$check=&get("select count(*) from dfc.livraison_h where livh_lta='$lta' and livh_base='$base'")+0;
	if ($check==0){$mess="Aucun numero de bl saisie ou numero invalide";}
	else {
		$rien=1;
		$query="select livh_id from livraison_h where livh_lta=''";
		$client=&get("select livh_base from livraison_h where livh_lta='$lta'");
		$fichier1=$html->param("fichier1");
		$fichier2=$html->param("fichier2");
		if ($fichier1 ne ""){
			$file="/var/www/$client.oasix/doc/lta_".$lta."_fact_fo.pdf";
			open(FILE,">$file");
			while (read($fichier1, $data, 2096)){
				print FILE $texte.$data;
			}
			close(FILE);
			print "$fichier1 enregistré<br>";
		}
		if ($fichier2 ne ""){
			$file="/var/www/$client.oasix/doc/lta_".$lta."_fact_tr.pdf";
			open(FILE,">$file");
			while (read($fichier2, $data, 2096)){
				print FILE $texte.$data;
			}
			close(FILE);
			print "$fichier2 enregistré<br>";
		 }
	 }
	  if ($mess ne ""){print "<mark> $mess </mark><br>";}
	  $action="";
}


if ($action eq ""){
	print "<form  method=POST enctype=multipart/form-data>";
	print "<br>Numero de BL <input type=text name=lta><br>";
	&form_hidden();
	print "<input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "Fichier factures fournisseurs <input type=file name=fichier1 accept=application/pdf maxlength=2097152><br>";
	print "Fichier facture transitaire <input type=file name=fichier2 accept=application/pdf maxlength=2097152><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit></form>";
  
}

;1