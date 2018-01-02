#!/usr/bin/perl
use DBI();
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$mag=$ARGV[0];
$base_dbh="aircotedivoire";
$query = "select fournisseur,pdf from dfc.facture_pub  where base='$base_dbh' and mag='$mag' and groupement=''";
$sth=$dbh->prepare($query);
$sth->execute();
while (($four,$pdf)=$sth->fetchrow_array){
		$fo2_email=&get("select fo2_email from fournis where fo2_cd_fo='$four'");
		if (&validemail($fo2_email)){
				$fo2_email=~s/@/\@/;
				system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $fo2_email $pdf $mag &");
				print "$fo2_email $pdf $mag\n";
		  }
}		  
$query = "select distinct fournisseur,groupement from dfc.facture_pub  where base='$base_dbh' and mag='$mag' and groupement!='' ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($four,$pdf)=$sth->fetchrow_array){
		$fo2_email=&get("select fo2_email from fournis where fo2_cd_fo='$four'");
		if (&validemail($fo2_email)){
				$fo2_email=~s/@/\@/;
				system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $fo2_email $pdf $mag &");
				print "$fo2_email $pdf $mag\n";
		  }
}		  
								
  