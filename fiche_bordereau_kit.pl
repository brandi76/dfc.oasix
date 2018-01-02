$fichier="bordereau";

print "<title>fiche_$fichier</title>";
print "<center><div class=titrefixe> Consultation du fichier $fichier <br></div>";
require("./src/connect.src");
$action=$html->param("action");
$no=$html->param("no");
$devise=$html->param("devise");
$montant=$html->param("montant");
$montantdev=$html->param("montantdev");
$pass=$html->param("pass");

if (($action eq "modifier")&&($pass eq "true")){
	$query="update $fichier set montant='$montant',montantdev='$montantdev' where no='$no' and devise='$devise'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="";
	$high=$no;
	print "Modification effectuée<br />";
}
if ($action eq "sup"){
	$query="delete from $fichier where no='$no' and devise='$devise' limit 1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="";
	print "<font color=red> $fichier $no supprim&eacute;</font><br>";
}
if ((($action eq "creation")||($action eq "modifier"))&&($pass ne "true")){
	if ($action eq "modifier"){
		$query="select montant,montantdev from $fichier where no=$no and devise='$devise'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($montant,$montantdev)=$sth->fetchrow_array;
	}
	print "<span class=titre>Bordereau:$no Devise:$devise<br /></span>";
        print "<form>";
	require ("./src/form_hidden.src");
	print "<table>";
	$var1="Montant";
	$var2="montant";
	$var3=$montant;
	print "<tr><td>$var1</td><td><input type=text name=$var2 value=\"$var3\" ></td></tr>";
	$var1="Contre valeur";
	$var2="montantdev";
	$var3=$montantdev;
	print "<tr><td>$var1</td><td><input type=text name=$var2 value=\"$var3\" ></td></tr>";
	print "<tr><td colspan=2><input type=submit value=valider></td></tr>";
	print "</table>";
	print "<input type=hidden name=action value=$action>";
	print "<input type=hidden name=no value=$no>";
	print "<input type=hidden name=devise value=$devise>";
	print "<input type=hidden name=pass value=\"true\">";
	print "<br><br>";
	print "</form>";
}	

if ($action eq ""){
	print "<form>";
	$color="white";
	require ("./src/form_hidden.src");
	$onglet+=0;
	$sous_onglet+=0;
	$sous_sous_onglet+=0;

	print "<table border=1 cellspacing=0><tr><th>No</th><th>Devise</th><th>Date</th><th>Montant</th><th colspan=2>Action</th></tr>";
	$query="select no,devise,date_creation,montant from $fichier where montant!=0 order by no desc limit 100";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no,$devise,$date_creation,$montant)=$sth->fetchrow_array){
# 		if ($no==$high){$color="yellow";}
		print "<tR bgcolor=$color><td>$no</td><td>$devise</td><td>$date_creation</td><td align=right>$montant</td>";
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modifier&no=$no&devise=$devise><img border=0 src=../../images/b_edit.png title='modifier'></a></td>";
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&no=$no&devise=$devise><img border=0 src=../../images/b_drop.png title='Supprimer'></a></td>";
		if ($color eq "white"){$color="#efefef";}else{$color="white";}
	}	
	print "</table><br>";
	print "</form></html>";
}		

;1
