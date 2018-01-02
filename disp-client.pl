#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header; # impression des parametres obligatoires

print "<html>\n";


$code = uc($html->param('code'));  
$type = uc($html->param('type'));  
$pays = uc($html->param('pays'));  
$nom = uc($html->param('nom'));  
$adresse = uc($html->param('adresse'));  
$bp = uc($html->param('bp'));   
$fichier="client.csv";
$default = "INDIFFERENT"; 
 print "<script language=javascript>\n";
 print "function client(code,nom,type,pays,adresse,bp){\n";
 print "this.nom = nom;\n";
 print "this.type = type;\n";
 print "this.pays = pays;\n";
 print "this.code = code;\n";
 print "this.adresse = adresse;\n";
  print "this.bp = bp;\n";
 print "}\n";

print "function afficher(){\n";
print "document.chercher.elements[\"nom_aff\"].value = table_client[document.chercher.elements[0].value].nom;\n";
print "document.chercher.elements[\"type_aff\"].value = table_client[document.chercher.elements[0].value].type;\n";
print "document.chercher.elements[\"pays_aff\"].value = table_client[document.chercher.elements[0].value].pays;\n";	
print "document.chercher.elements[\"code_aff\"].value = table_client[document.chercher.elements[0].value].code;\n";		
print "document.chercher.elements[\"adresse_aff\"].value = table_client[document.chercher.elements[0].value].adresse;\n";	
print "document.chercher.elements[\"bp_aff\"].value = table_client[document.chercher.elements[0].value].bp;\n";		
	
print "}\n";

print "function Effacer(){\n";
print "document.chercher.elements[\"nom\"].value = \"INDIFFERENT\";\n";
print "document.chercher.elements[\"type\"].value = \"INDIFFERENT\";\n";
print "document.chercher.elements[\"pays\"].value = \"INDIFFERENT\";\n";
print "document.chercher.elements[\"code\"].value = \"INDIFFERENT\";\n";
print "document.chercher.elements[\"adresse\"].value = \"INDIFFERENT\";\n";
print "document.chercher.elements[\"bp\"].value = \"INDIFFERENT\";\n";
print "}\n";
 
 print "table_client = new Array();\n";

 
 open(F1,"<$fichier");
 @FIC=<F1>;
 
$trouver = 0;
$temp = "";
	
foreach(@FIC){
 ($code_client,$type_client,$pays_client,$nom_client,$adresse_client,$bp_client) = split(/;/,$_);
		$temp = $code_client;
		$code_tmp = $code_client;
		$type_tmp = $type_client;
		$pays_tmp = $pays_client;
		$nom_tmp = $nom_client;
		$adresse_tmp = $adresse_client;
		$bp_tmp = $bp_client;
		################################################
		# elimination des criteres indifferents
		################################################
		if($code eq $default){			
			$code_client = $code;
		}
		if($type eq $default){
			$type_client = $type;
		
		}
		if($pays eq $default){
			$pays_client = $pays;
		}
		
		if($nom eq $default){
			$nom_client = $nom;
		}
		if($adresse eq $default){
			$adresse_client = $adresse;
		}
		if($bp eq $default){
			$bp_client = $bp;
		}
				
		##################################################
		# recherche de chaqu'un des criteres dans la ligne courante du fichier catalogue
		if((grep /$code/,$code_client) and ($type eq $type_client) and (grep /$pays/,$pays_client) and (grep /$nom/,$nom_client) and (grep /$adresse/,$adresse_client) and (grep /$bp/,$bp_client)){
			# les criteres sont dans la lignes alors on garde celui-ci dans un tableau
			push (@liste,$_);
			print "table_client[$temp] = new client(\"$code_tmp\",\"$nom_tmp\",\"$type_tmp\",\"$pays_tmp\",\"$adresse_tmp\",\"$bp_tmp\");\n";
			$trouver=1;	# il y a au moins 1 element
		}
 }
if($trouver eq 0){
	print "table_client[\"$code\"] = new client(\"INDIFFERENT\",\"INDIFFERENT\",\"INDIFFERENT\",\"INDIFFERENT\",\"INDIFFERENT\",\"INDIFFERENT\");\n";
}

print "</script>\n";
print "<TITLE>Rechercher un Client.</TITLE>\n";
print "<body><center><form name=chercher action=../cgi-bin/disp-client.pl>\n";
print "<h3>QUIDCL2.</h3>\n";

	
print "<select option size=10>\n";
if($trouver eq 1){
foreach(@liste){
	($code_client,$type_client,$pays_client,$nom_client,$adresse_client,$bp_client) = split(/;/,$_);
	print "<option value=$code_client>$code_client, $pays_client, $nom_client, $adresse_client, $bp_client</option>\n";
}
}else{
	print "<option value=$code>====== PAS DE RESULTAT ======</option>\n";
}
print "</select>\n<p>\n";




 
 
 
&rechercher();
 


print "</form>\n";


print "</body></html>\n";
exit;



sub rechercher(){

	
	print "<h3>Rechercher un client.</h3>\n";
	
	print "<table border=0 cellspacing=0>\n";
	print "<tr bgcolor=black>\n<td align=center><font color=white><b><i>Code Client</td>\n";
	print "<td align=center><font color=white><b><i>Type</td>\n";
	print "<td align=center><font color=white><b><i>Pays</td>\n";
print "<td align=center><font color=white><b><i>Nom</td>\n";
	print "<td align=center><font color=white><b><i>Adresse</td>\n";
	print "<td align=center><font color=white><b><i>Boite Postale</td>\n</tr>\n";
	
	print "<tr>\n<td><input name=code type=text value=$code size=12 maxlength=7></td>\n";
	print "<td>";
	
	
	
#	print "<input name=type type=text value=$type></td>\n";
print "<select name=type option>\n";
print "<option ";
if($type eq "INDIFFERENT"){
	print "selected ";	
}
print "value=INDIFFERENT>INDIFFERENT</option>\n";
print "<option ";
if($type eq "AMBASSADE"){
	print "selected ";	
}
print "value=AMBASSADE>AMBASSADE</option>\n";
print "<option ";
if($type eq "CONSULAT"){
	print "selected ";	
}
print "value=CONSULAT>CONSULAT</option>\n";
print "<option ";
if($type eq "MISSION"){
	print "selected ";	
}
print "value=MISSION>MISSION</option>\n";
print "<option ";
if($type eq "DELEGATION"){
	print "selected ";	
}
print "value=DELEGATION>DELEGATION</option>\n";
print "<option ";
if($type eq "REPRESENTATION"){
	print "selected ";	
}
print "value=REPRESENTATION>REPRESENTATION</option>\n";

print "<option ";
if($type eq ""){
	print "selected ";	
}
print "value=\"\">AUTRE</option<\n";
print "</select>\n</td>\n";



	print "<td><input name=pays type=text value=$pays></td>\n\n";
	
	

	print "<td><input name=nom type=text value=$nom></td>\n";
	print "<td><input name=adresse type=text value=$adresse></td>\n";
	print "<td><input name=bp type=text value=$bp></td>\n</tr>\n";
	print "</table>\n";
	print "<input type=button value=\"== R.A.Z ==\" onClick=Effacer()> <input type=submit value=Rechercher>\n";
	
	
	
	


}
