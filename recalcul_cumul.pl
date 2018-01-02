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
	print "<body><center><h1>AJOUT D'UNE SEMAINE DE VENTE AU CUMUL</h1><br>";
	print "<br> une fois la semaine de vente importée selectionner un bateau et la même date pour effectuer le calcul du cumul<br>";
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
    	print "<br><input type=hidden name=action value=import><input type=submit value=recalcul></form></body>";
}
	
if ($action eq "import"){
	if ($mois<10){$mois='0'.$mois;}
	if ($jour<10){$jour='0'.$jour;}
	$date=$an.'-'.$mois.'-'.$jour;
	$query="select nav_cd_pr,nav_qte from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=2";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array){
		$query="update navire2 set nav_qte=nav_qte+$nav_qte where nav_nom='$navire' and nav_type=3 and nav_cd_pr='$nav_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		print "$query<br>";		
		
	}

}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}