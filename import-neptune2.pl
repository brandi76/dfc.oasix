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

require "./src/connect.src";
                
print "<title>Importation code neptune</title>";

if ($action eq ""){
	print "<body><center><h1>IMPORTATION du fichier neptune</h1><br>";
	print "<form  method=POST enctype=multipart/form-data>";
	print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
	print "<input type=file name=fichier accept=text/* maxlength=2097152>";
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
	&save("delete from neptune");
	(@tab)=split(/\n/,$texte);
	$ok=0;
# 	print "<table>";
	foreach $ligne (@tab){
		if ((grep /^Famille/,$ligne)||(grep /^s\/Famille/,$ligne)||(grep /^s\/s\/Famille/,$ligne)){
			next;
		}
		if (grep /^ibs/,$ligne){
			next;
		}
 		if (grep /^Numero/,$ligne){
 			next;
 		}
 		if (grep /^giuli/,$ligne){
 			next;
 		}

		if (grep /^;;/,$ligne){
			next;
		}

		if ($ligne eq ""){
			next;
		}
 		while ($ligne=~s/'/ /){};
		(@tab2)=split(/\t/,$ligne);
		
# 		($neptune,$codebarre,$desi,$null,$null)=split(/\t/,$ligne);
# 		$verif=&get("select count(*) from neptune where nep_cd_pr='$neptune'");
# 		if ($verif >0){next;}
		$tab2[11]*=100;
		$tab2[20]*=100;
  		&save("insert into neptune values ('$tab2[0]','$tab2[1]','$tab2[2]','$tab2[20]','$tab2[11]')","aff");
#   		print "$neptune;$codebarre;$desi<br>";
# 		print "<tr>";
# 		print "$tab2[1] ;$tab2[11];$tab2[20]<br>";
# 		print "</tr>";
		
	}
# 	print "</table>";
print "fin";
}
