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
$val2=$html->param("val2");
$valnew=$html->param("valnew");
$cle=$html->param("cle");
$cle2=$html->param("cle2");
$action=$html->param("action");

if ($fichier2 eq ""){$fichier2=$fichier;}
if ($action eq ""){
	print "Duplication d'un enregistrement <br><form>";
	print "fichier <input type=text name=fichier><br>";
	print "fichier cible (option) <input type=text name=fichier2><br>";
	print "<input type=hidden name=action value=file>";
	print "<input type=submit></form>";
}	
if ($action eq "file")
{	
	$query="show columns from $fichier";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@table)=$sth->fetchrow_array){
		print "$table[0]<br>";
	}
	print "<form>nom de la cle1<input type=text name=cle><br>";
	print "ancienne valeur <input type=text name=val><br>";
	print "nouvelle valeur <input type=text name=valnew><br>";
	print "nom de la cle2 (option) <input type=text name=cle2><br>";
	print "valeur <input type=text name=val2><br>";
	print "<input type=hidden name=fichier value=$fichier>";
	print "<input type=hidden name=fichier2 value=$fichier2>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit></form>";
}

if ($action eq "go")
{
	if ($cle2 eq ""){
		$query="select * from $fichier where $cle='$val'";
	}
	else 
	{
		$query="select * from $fichier where $cle='$val' and $cle2='$val2'";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@table)=$sth->fetchrow_array){
		$table[0]=$valnew;
		if ($fichier eq "comcli") {
			$table[5]=0;
			&save("update infococ2 set ic2_fact=0 where ic2_no=$table[0]","af");
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
