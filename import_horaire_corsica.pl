#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
$action=$html->param("action");
$texte=$html->param('texte');

require "./src/connect.src";
print $html->header;

print "<title>Importation horaire corsica</title>";
if ($action eq ""){
	print "<body><center><h1>IMPORTATION HORAIRE</h1><br>";
	print "format<pre>";
	print "copier coller à partir du fichier horaire.xls de paul
	Jour	Date	Code ligne	Ligne	Heure Départ	Heure Arr.	Code Navire	Navire	Etat	Motif	Motif de retard	H.Dep.Reel	H.Arr.dans Port Depart	Temps d'escale en h >=	Code Compagnie	Compagnie	Date Arr.	Marché	Couleur	Tarif	J/N	Mois	E/S	Port Dep.	Port Dest.
";
	print "</pre>";			

	print "<form method=post>";
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";
        print "<br><input type=reset>";
    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form><a href=#haut>haut</a></body>";
}
	

if ($action eq "import"){
$i=0;
# open(FILE,"HORAIRE_2009.csv");
# (@liste_dat)=<FILE>;
# close(FILE);

(@liste_dat)=split(/\n/,$texte);

	foreach (@liste_dat){
		print "*$_*<br>";
		chop($_);
		if (grep /Horaires/,$_){
			 chop($_);
			($null,$null,$null,$null,$null,$debut,$nul,$null,$fin,$null)=split(/ /,$_);
			while($fin=~s/ //){};
			while($debut=~s/ //){};
			($jj,$mois,$an)=split(/\//,$debut);
			$debut=$an."-".$mois."-".$jj;
			($jj,$mois,$an)=split(/\//,$fin);
			$an+=0;
			$fin=$an."-".$mois."-".$jj;
			&save("delete from horaire where nav_date>='$debut' and nav_date<='$fin'","aff");
			next;
		}			
		($jour,$date,$dest,$null,$hd,$ha,$navire,$null,$info)=split(/\t/,$_);
		($date)=split(/ /,$date);
		if ($info eq "Suspendu"){next;}
		($jj,$mois,$an)=split(/\//,$date);
		if ($an<200){$an+=2000;}
		$date=$an."-".$mois."-".$jj;
		if (($jour eq "") | ($jour eq "Jour")){next;}
		if ($navire==1){$navire="REGINA";}
		if ($navire==6){$navire="VERA";}
		if ($navire==9){$navire="MEGA 1";}
		if ($navire==12){$navire="MEGA 2";}
		if ($navire==8){$navire="VICTORIA";}
		if ($navire==14){$navire="MEGA 3";}
		if ($navire==15){$navire="MEGA 4";}
		if ($navire==16){$navire="MEGA 5";}
		if ($navire==17){$navire="SMERALDA";}
		if ($navire==11){$navire="SARDINIA EXPRESS";}
		if ($navire==4){$navire="MARINA";}
		if ($navire==2){$navire="SERENA II";}
		if ($navire==7){$navire="EXPRESS 3";}
		if ($navire==3){$navire="EXPRESS 2";}
		
		print "$jour,$date,$dest,$hd,$ha,$navire\n";
		# print "replace horaire values('$navire','$date','$jour','$dest','$hd','$ha')<br>";
	
		&save("replace horaire values('$navire','$date','$jour','$dest','$hd','$ha')","aff");
		$check=&get("select count(*) from horaire where nav_date='0000-00-00'")+0;
		if ($check >0){
			print "<font color=red>erreur importation";
			exit;
			}
	}
}

# -E importation des horaires navires de paul par fichier csv 06/09
