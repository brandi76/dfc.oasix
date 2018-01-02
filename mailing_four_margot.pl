#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
@base=("corsica","dfc","cameshop");

$query="select * from fournis_parf";
$sth2=$dbh->prepare($query);
$sth2->execute();
while (($fo_cd_fo)=$sth2->fetchrow_array){
	print "<table border=1>";
	print "<tr><th>Base</th><th>fo2_cd_fo</th><th>fo2_add</th><th>fo2_telph</th><th>fo2_fax</th><th>fo2_contact</th><th>fo2_email</th><th>fo_delai_pai</th><th>fo_mode_pai</th></tr>";
	foreach (@base){
		$query="select $_.fournis.* from $_.fournis where fo2_cd_fo=$fo_cd_fo";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email,$fo_delai_pai,$fo_mode_pai,$fo_iban,$fo_bic,$fo_minicde)=$sth->fetchrow_array;
		print "<tr><td>$_</td><td>$fo2_cd_fo</td><td>$fo2_add</td><td>$fo2_telph</td><td>$fo2_fax</td><td>$fo2_contact</td><td>$fo2_email</td><td>$fo_delai_pai</td><td>$fo_mode_pai</td></tr>";
	}
	print "</table><br>";
}