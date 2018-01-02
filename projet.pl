#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$action=$html->param("action");
$titres=$html->param("titres");
$titre=$html->param("titre");
$date=$html->param("date");
$texte=$html->param("texte");
# astuce
$texte=$dbh->quote($texte);
print "<title> suivi de projet</title>";
if ($date eq ""){$date=&get("select now()");}


if (($action eq "supprimer")&&($titre eq "")){
 	&save("delete from projet where pro_titre='$titre'","aff");
 	$action="";
}	


if ($titre eq ""){$titre=$titres;}

if ($action eq "sup"){
	&save("delete from projet where pro_titre='$titre' and pro_date='$date'");
	$action="";
}	


if ($action eq "ajout"){
	&save("replace into projet value ('$titre','$date',$texte)","af");
	$action="voir";
}	
if ($action eq ""){
	print "<script>
	function verif(message){
	        document.forms[0][1].value=\"supprimer\";
		if (confirm(message)){document.forms[0].submit();}
	}
	</script>";

	print "<center><br><br><h3>Suivi de projet version1.0</h3><br>";
	$query="select distinct pro_titre from projet order by pro_titre";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form>";
	print "<select name=titres>";
	while (($titre)=$sth->fetchrow_array)
	{
			print "<option value=\"$titre\">$titre";
	}
	print "</select><br><br>";
	print "<input type=hidden name=action value=voir>";
	print "<input type=submit value=voir>";
        # suppression avec confirmation astuce
	print "<br><br>";
	print "<input type=button value=supprimer onclick=verif(\"confirmez_vous_la_suppression\")>";
	print "<br><br><form>nouveau projet <input type=texte name=titre size=25><br></form>";
}


if ($action eq "voir"){
	$textarea=&get("select pro_texte from projet where pro_titre='$titre' and pro_date='$date'");
	print "<center><h3>$titre</h3><br><a href=?>retour</a><br>";
	print "<form method=POST><textarea name=texte cols=80 rows=10>$textarea</textarea>";
	print "<input type=hidden name=titre value='$titre'>";
	print "<input type=hidden name=date value='$date'>";
	print "<input type=hidden name=action value=ajout><br><input type=submit></form>";
	$query="select pro_titre,pro_date,pro_texte from projet where pro_titre='$titre' order by pro_date desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pro_titre,$pro_date,$pro_texte)=$sth->fetchrow_array)
	{
		$diff=&get("select datediff(now(),'$pro_date')");
		print "<table border=1 cellspacing=0 width=80%><tr><td bgcolor=lightyellow><b>$pro_date il y a $diff jours</b></td></tr>";
		print "<tr><td>$pro_texte<br><br>";
		print "<form><input type=hidden name=titre value='$titre'>";
		print "<input type=hidden name=date value='$pro_date'>";
		print "<input type=submit name=action value=select> ";
		print "<input type=submit name=action value=sup></form></td></tr></table><br> ";
	}

}	

