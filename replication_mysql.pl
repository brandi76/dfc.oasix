#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
require "./src/connect.src";

$html=new CGI;
print $html->header;
$requete=$html->param("requete");
if ($requete ne ""){
	foreach $client (@bases_client){
			if ($client eq "dfc"){next;}
			
			$requete_new=$requete;
			$requete_new=~s/TABLE /TABLE $client\./;
			while($requete_new=~s/client\./$client\./){};
			$requete_new=~s/ALTER/ALTER IGNORE/;
			$requete_new=~s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/;
			if (! grep /ignore/,$requete_new){$requete_new=~s/insert/insert ignore/;}
		
		# print "$requete_new<br>";
			&save("$requete_new","aff");
	}
	
# ALTER TABLE `commande` ADD `com2_liv` INT NOT NULL 
}
print "
mettre client a la place de la base
<form>
requete 
<textarea name=requete>
</textarea>
<input type=submit>
</form>";


