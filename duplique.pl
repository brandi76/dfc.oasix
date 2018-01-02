#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

print $html->header;
print "<title>duplique</title>";
require "./src/connect.src";
$fichier=$html->param("fichier");
$fichier2=$html->param("fichier2");
$val=$html->param("val");
$valnew=$html->param("valnew");
$cle=$html->param("cle");
if ($fichier2 eq ""){$fichier2=$fichier;}
if ($fichier eq ""){
	print "Duplication d'un enregistrement <br><form>";
	print "fichier <input type=text name=fichier><br>";
	print "fichier cible (option) <input type=text name=fichier2><br>";
	print "nom de la cle <input type=text name=cle><br>";
	print "ancienne valeur <input type=text name=val><br>";
	print "nouvelle valeur <input type=text name=valnew><br>";
	print "<input type=submit></form>";
}
else {
	$query="select * from $fichier where $cle='$val'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@table)=$sth->fetchrow_array){
		$table[0]=$valnew;
		if ($fichier eq "comcli") {
			$table[5]=0;
			&save("update infococ2 set ic2_fact=0 where ic2_no=$table[0]");
		}
		if ($fichier2 eq "produit") {
			$table[4]=$table[7]=$table[10]=$table[16]=0;
		}
		$query="replace into $fichier2 values(";
		for ($i=0;$i<=$#table;$i++)
		{
		 	$query.="'$table[$i]',";
		}
		chop($query);
		$query.=")";
		print "$query<br>";;
		$sth2=$dbh->prepare($query);
		$sth2->execute();
	 }
}
