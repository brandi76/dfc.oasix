#!/usr/bin/perl
use CGI;
use DBI();
#  use CGI::Carp qw(fatalsToBrowser); 
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$texte=$html->param('texte');
$save=$html->param('save');
$type=$html->param('type');
$produit=$html->param('produit');

require "./src/connect.src";
                
print "<title>Consultation fichier neptune</title>";

if ($action eq ""){
	print "<body><center><h1>Consulttaion du fichier neptune</h1><br>";
	print "<form  method=POST enctype=multipart/form-data>";
	print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<input type=file name=fichier accept=text/* maxlength=2097152><br>";
       	print "Produit <input type=text name=produit><br>";
       	print " <input type=hidden name=action value=upload>";
	print " <input type=submit></form>";
}

if ($action eq "upload"){
	$fic=$html->param("fichier");
 	# print $fic;
 	while (read($fic, $data, 2096)){
 		$texte=$texte.$data;
 	}
	$action="import";
}


if ($action eq "import"){
	(@tab)=split(/\n/,$texte);
	$ok=0;
	print "<table border=1 cellspacing=0 cellpadding=0>";
	foreach $ligne (@tab){
		if ((grep /^Famille/,$ligne)||(grep /^s\/Famille/,$ligne)||(grep /^s\/s\/Famille/,$ligne)){
			next;
		}
		if (grep /^ibs/,$ligne){
			next;
		}
# 		if (grep /^Numero/,$ligne){
# 			next;
# 		}
		if (grep /^;;/,$ligne){
			next;
		}

		if ($ligne eq ""){
			next;
		}
		(@tab2)=split(/\t/,$ligne);
# 		($neptune,$codebarre,$desi,$null,$null)=split(/\t/,$ligne);
# 		$verif=&get("select count(*) from neptune where nep_cd_pr='$neptune'");
# 		if ($verif >0){next;}
# 		while ($desi=~s/'/ /){};
#  		&save("insert into neptune values ('$neptune','$codebarre','$desi','0','0')","aff");
#   		print "$neptune;$codebarre;$desi<br>";
		if (($tab2[0] eq "Numero")||($tab2[1]==$produit)){
			print "<tr>";
			foreach (@tab2) {
				print "<td>$_</td>";
	
			}
		print "</tr>";
		}
		
	}
	print "</table>";
}
