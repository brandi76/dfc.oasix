print "<div class=titre>Importation des ventes du tpe</div><br>";

require("./src/connect.src");

# $texte=$html->param("texte");
$rot=$html->param("rot");

if ($action eq "upload"){
	$fic=$html->param("fichier");
	print $fic;
 	while (read($fic, $data, 4192)){
 		$texte=$texte.$data;
 	}

	while ($texte=~s/'//){};
	print "<center>";

	if (($texte ne "") && ($rot >0))
	{
		(@ligne)=split(/\n/,$texte);
		$nom="vente".$rot.".txt";
		foreach $ligne (@ligne){
			chop($ligne);
			($type,$col1,$col2,$col3,$col4)=split(/;/,$ligne);
			while($type=~s/ //){};		
			if ($type eq "e"){
					$serial=$col1;
					$date=$col2;
					$query="delete from oasix where oa_serial='$serial' and oa_date_import=now() and oa_rotation='$nom'";
					# print "$query<br>";
					my ($sth)=$dbh->prepare($query);
					$sth->execute() or die (print $query);
			}	
			else
			{
					$query="insert into oasix (oa_serial,oa_date,oa_type,oa_col1,oa_col2,oa_col3,oa_col4,oa_date_import,oa_rotation) values ('$serial','$date','$type','$col1','$col2','$col3','$col4',now(),'$nom')";
					# print "$query<br>";
					my ($sth)=$dbh->prepare($query);
					$sth->execute() or die (print $query);
			}
		}
		print "<br>importation $nom effectuée<br>";
	}
	else
	{
		print "merci de metre un fichier et une rotation";
	}
}
else
{
	print "<form method=post>";
	print "<form  method=POST enctype=multipart/form-data>";
	require ("form_hidden.src");
	print "numero de rotation : <input type=text name=rot size=3><br><br>Fichier<br>";
	print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<input type=file name=fichier accept=text/* maxlength=2097152>";
       	print " <input type=hidden name=action value=upload>";
	print " <input type=submit></form>";
}
;1
