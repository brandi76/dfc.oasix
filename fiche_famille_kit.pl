$fichier="famille";

print "<title>fiche_$fichier</title>";
print "<center><div class=titrefixe> Consultation du fichier $fichier <br></div>";
require("./src/connect.src");
$action=$html->param("action");
$fa_id=$html->param("fa_id");
$fa_desi=$html->param("fa_desi");


$pass=$html->param("pass");

if (($action eq "creation")&&($pass eq "true")){
	$query="insert ignore into $fichier values ('$fa_id','$fa_desi')";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="";

}
if (($action eq "modifier")&&($pass eq "true")){
	$query="replace into $fichier values ('$fa_id','$fa_desi') ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$action="";
	$high=$fa_id;
}
if ($action eq "sup"){
	$control=&get("select count(*) from produit_plus where pr_famille='$fa_id'")+0;
	if ($control>0){
		print "<font color=red> Impossible la famille apparait dans $control produit(s)</font><br>";
	}
	else 
	{
		$query="delete from $fichier where fa_id='$fa_id' limit 1";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$action="";
		print "<font color=red> $fichier $fa_id supprim&eacute;</font><br>";
	}
}
if ((($action eq "creation")||($action eq "modifier"))&&($pass ne "true")){

	$fa_desi="";
	if ($action eq "modifier"){
		$query="select * from $fichier where fa_id=$fa_id";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($fa_id,$fa_desi)=$sth->fetchrow_array;
	}
        print "<form>";
	require ("./src/form_hidden.src");
	print "<table>";
	$var1="Libelle";
	$var2="fa_desi";
	$var3=$fa_desi;
	print "<tr><td>$var1</td><td><input type=text name=$var2 value=\"$var3\" size=50></td></tr>";
	print "<tr><td colspan=2><input type=submit value=valider></td></tr>";
	print "</table>";
	print "Id <input type=text name=fa_id value=$fa_id>";
	print "<input type=hidden name=action value=$action>";
	print "<input type=hidden name=pass value=\"true\">";
	print "<br><br>";
}	

if ($action eq "visu"){
	$libelle=&get("select fa_desi from $fichier where fa_id='$fa_id'");
        print "<form>";
	require ("./src/form_hidden.src");
	print "Famille $libelle<br><br>";
	print "<table border=1>";
	print "<tr><th>Code</th><th>Designation</th></tr>";
	$query="select produit.pr_cd_pr,pr_desi from produit,produit_plus  where produit_plus.pr_famille='$fa_id' and produit_plus.pr_cd_pr=produit.pr_cd_pr order by produit.pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>";
		print "<a href=?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a>";
		print "</td><td>$pr_desi</td>";
		print "</tr>";	
	}
	print "</table><br><br>";
	print "<input type=submit value=\"retour\">";
	print "<input type=hidden name=id value=$id>";
	print "</form>";
}	



if ($action eq ""){
	print "<form>";
	$color="white";
	require ("./src/form_hidden.src");
	$onglet+=0;
	$sous_onglet+=0;
	$sous_sous_onglet+=0;

	print "<table border=1 cellspacing=0><tr><th>libelle</th><th colspan=2>Action</th></tr>";
	$query="select fa_id,fa_desi from $fichier order by fa_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fa_id,$fa_desi)=$sth->fetchrow_array){
# 		if ($fa_id==$high){$color="yellow";}
		print "<tR bgcolor=$color><td>$fa_id</td><td>$fa_desi</td>";
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modifier&fa_id=$fa_id><img border=0 src=../../images/b_edit.png title='modifier'></a></td>";
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&fa_id=$fa_id><img border=0 src=../../images/b_drop.png title='Supprimer'></a></td>";
		print "<td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&fa_id=$fa_id><img border=0 src=../../images/b_list.png title='visualisation'></a></td>";
		if ($color eq "white"){$color="#efefef";}else{$color="white";}
	}	
	print "</table><br>";
	print "<input type=submit name=action value=creation>";
	print "</form></html>";
}		

;1
