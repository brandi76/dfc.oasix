#!/usr/bin/perl 
use DBI();
use CGI::Carp qw(fatalsToBrowser);
use CGI;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$html=new CGI;
print $html->header();


	$query="select fo2_cd_fo,fo2_add,fo2_email from fournis order by fo2_cd_fo";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fo2_cd_fo,$fo2_add,$fo2_email)=$sth->fetchrow_array){
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	if (! &validemail($fo2_email)){
	  if ($fo2_email eq ""){$fo2_email="Pas de mail";}
	  print "$fo2_cd_fo $nom <span style=color:red>$fo2_email</span><br>";
	}
	}
