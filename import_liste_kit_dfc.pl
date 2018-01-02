
require("./src/connect.src");


if ($action eq "upload"){
	&save("truncate table coefficient");
	$fic=$html->param("fichier1");
	print $fic;
 	while (read($fic, $data, 2096)){
 		$texte=$texte.$data;
 	}
	@lignes=split(/\n/,$texte);
	foreach (@lignes){
	  ($code,$coef)=split(/;/,$_);
	  $coef=~s/\,/\./;
	  &save("insert ignore into coefficient value ('$code','$coef')");
	}
	
	print "<table border=1 cellspacing=0 ><tr><th>Code</th><th>Désignation</th><th>Coef</th></tr>";
	$query="select code,pr_desi,coef from produit,coefficient where pr_cd_pr=code order by code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$pr_desi,$coef)=$sth->fetchrow_array){
	  print "<tr><td>$code</td><td>$pr_desi</td><td>$coef</td></tr>";
	  $nb++;
	}
	print "</table>";
	print "$nb produits importés";

}
else
{
print "Importation des produits pour coef de pick, fichier csv separateur point virgule<br>";
print "<form  method=POST enctype=multipart/form-data>";
&form_hidden();
  	print "<input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<input type=file name=fichier1 accept=\".csv\" maxlength=2097152><br>";
	print "<input type=hidden name=action value=upload>";
	print "<input type=submit></form>";}
;1

