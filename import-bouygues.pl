#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$texte=$html->param('texte');

require "./src/connect.src";

if ($action eq ""){
	print "<body><center><h1>IMPORTATION MAIL NAVIRE</h1><br>";
	print "<br> selectionner un bateau une date (ou la dernière date pour une vente d'une semaine) puis faire un copier coller du mail<br><br>";
	print "<form method=post>";
	print "<br><h1> Choix d'un navire (corsica)<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
   	&select_date();
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";

    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form></body>";
}
	

if ($action eq "import"){
	if ($mois<10){$mois='0'.$mois;}
	if ($jour<10){$jour='0'.$jour;}
	$date=$an.'-'.$mois.'-'.$jour;
	print $date;
	(@tab)=split(/\n/,$texte);
	foreach (@tab){
		($neptune,$qte)=split(/;/,$_);
		print "$neptune:$qte<br>";
		$qte+=0;
		$query="select nep_codebarre from neptune where nep_cd_pr='$neptune'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($pr_cd_pr)=$sth->fetchrow_array;
		if (($pr_cd_pr eq "")||($pr_cd_pr==0)){next;}
		$query="replace into navire2 values ('$navire','$pr_cd_pr','$date','2','$qte')";
		print "$query<br>";		
		$sth=$dbh->prepare($query);
		$sth->execute();
	
	}

}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}