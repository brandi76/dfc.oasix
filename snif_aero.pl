#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
$texte=$html->param("texte");
@europe=("Allemagne", "Autriche", "Belgique", "Chypre", "Danemark", "Espagne", "Estonie","Finlande", "France", "Grece", "Hongrie", "Irlande", "Italie", "Lettonie", "Lituanie", "Luxembourg", "Malte", "Pays-Bas", "Pologne", "Portugal", "TchequeRepublique", "Grande-Bretagne", "Slovaquie", "Slovenie", "Suede","Suisse");

foreach (@europe){
	$query="select count(*) from aerodesi where aerd_desi='$_'"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array;
	# print "$_,$nb<br>";
}

while ($texte=~s/  / /){};
(@tab)=split(/ /,$texte);

foreach (@tab){
	$query="select aerd_trig,aerd_desi from aerodesi where aerd_trig='$_'"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	($trig,$desi)=$sth->fetchrow_array;
	$ok=1;
	foreach $pays (@europe){
		if ($desi eq $pays){$ok=0;}
		}
	if (($trig ne "")&&($ok==1)){
		$texte=~s/ $trig / <font color=red>$trig<\/font> /;
	}
	
}
# print $length($texte);
print "<br><br>";
print "<form method=post><pre>$texte</pre>";
print "<textarea name=texte>";
print "</textarea><input type=submit></form>";


