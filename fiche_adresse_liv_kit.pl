$fichier="adresse_liv";

print "<title>fiche_$fichier</title>";
print "<center><div class=titrefixe> Consultation du fichier $fichier <br></div>";
require("./src/connect.src");
$action=$html->param("action");
$adresse_id=$html->param("adresse_id");
$adresse_libelle=$html->param("adresse_libelle");
$adresse_adresse=$html->param("adresse_adresse");
$adresse_info=$html->param("adresse_info");

$pass=$html->param("pass");
if (($action eq "creation")&&($pass eq "true")){
	$query="insert into $fichier values ('','$adresse_libelle','$adresse_adresse','$adresse_info')";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="";
	$high=&get("SELECT LAST_INSERT_ID() FROM $fichier");
}
if (($action eq "modifier")&&($pass eq "true")){
	$query="update $fichier set adresse_libelle='$adresse_libelle',adresse_adresse='$adresse_adresse',adresse_info='$adresse_info' where adresse_id='$adresse_id'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="";
	$high=$adresse_id;
}
if ($action eq "sup"){
	$query="delete from $fichier where adresse_id='$adresse_id' limit 1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="";
	print "<font color=red> $fichier $adresse_id supprim&eacute;</font><br>";
}
if ((($action eq "creation")||($action eq "modifier"))&&($pass ne "true")){
	$adresse_libelle="";
	if ($action eq "modifier"){
		$query="select * from $fichier where adresse_id=$adresse_id";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($adresse_id,$adresse_libelle,$adresse_adresse,$adresse_info)=$sth->fetchrow_array;
	}
        print "<form>";
	require ("./src/form_hidden.src");
	print "<table>";
	$var1="Libelle";
	$var2="adresse_libelle";
	$var3=$adresse_libelle;
	print "<tr><td>$var1</td><td width=100%><textarea name=$var2 rows=5 style=width:500px>$var3</textarea></td></tr>";
	$var1="Adresse";
	$var2="adresse_adresse";
	$var3=$adresse_adresse;
	print "<tr><td>$var1</td><td><textarea name=$var2 cols=120 rows=5 style=width:500px>$var3</textarea></td></tr>";
	$var1="Info";
	$var2="adresse_info";
	$var3=$adresse_info;
	print "<tr><td>$var1</td><td><textarea name=$var2 cols=120 rows=5 style=width:500px>$var3</textarea></td></tr>";
	print "<tr><td colspan=2><input type=submit value=valider></td></tr>";
	print "</table>";
	print "<input type=hidden name=action value=$action>";
	print "<input type=hidden name=adresse_id value=$adresse_id>";
	print "<input type=hidden name=pass value=\"true\">";
	print "<br><br>";
}	

if ($action eq ""){
	print "<form>";
	$color="white";
	require ("./src/form_hidden.src");
	$onglet+=0;
	$sous_onglet+=0;
	$sous_sous_onglet+=0;

	print "<table border=1 cellspacing=0><tr><th>libelle</th><th colspan=2>Action</th></tr>";
	$query="select adresse_id,adresse_libelle,adresse_adresse,adresse_info from $fichier order by adresse_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($adresse_id,$adresse_libelle,$adresse_adresse,$adresse_info)=$sth->fetchrow_array){
# 		if ($adresse_id==$high){$color="yellow";}
		print "<tR bgcolor=$color><td>$adresse_libelle $adresse_adresse $adresse_info</td>";
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modifier&adresse_id=$adresse_id><img border=0 src=../../images/b_edit.png title='modifier'></a></td>";
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&adresse_id=$adresse_id><img border=0 src=../../images/b_drop.png title='Supprimer'></a></td>";
		if ($color eq "white"){$color="#efefef";}else{$color="white";}
	}	
	print "</table><br>";
	print "<input type=submit name=action value=creation>";
	print "</form></html>";
}		

;1
