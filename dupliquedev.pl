#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

print $html->header;
require "./src/connect.src";
$fichier=$html->param("fichier");
$val=$html->param("val");
$valnew=$html->param("valnew");
$cle=$html->param("cle");

if ($fichier eq ""){
	print "Duplication d'un enregistrement <br><form>fichier <input type=text name=fichier> nom de la cle <input type=text name=cle> ancienne valeur <input type=text name=val> nouvelle valeur <input type=text name=valnew><br>";
	print "<input type=submit></form>";
}
else {
	$query="select * from $fichier where $cle=$val";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@table)=$sth->fetchrow_array){
		$table[0]=$valnew;
		  $query="replace into $fichier values(";
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
