#!/usr/bin/perl
use CGI; 
$html=new CGI;
print $html->header; # impression des parametres obligatoires


$fich_catal = "cata20.csv";	# fichier catalogue


$code = uc($html->param('code_rech'));
$designation = uc($html->param('design_rech'));
$page = uc($html->param('page_rech'));
$chapitre = uc($html->param('chap_rech'));
$default = "INDIFFERENT";

print "<html>\n";
print "<TITLE>Listing de produits en stock.</TITLE>\n";


print "<body>\n";
	print "<table border=0>\n";
	print "<tr><td><img src=http://intranet.dom/images/ibs_france.jpg height=120></td>\n";
	print "<td width=300><font color=\"#101646\">Boite postale n°143 &nbsp &nbsp &nbsp 76204 DIEPPE CEDEX</font></td><td width=300>\n";
	print "<br><br><br><table><tr><td align=right><font color=\"#101646\">Tél : </td><td><font color=\"#4A516B\">33 (0) 232 140 280</td></tr>\n";
	print "<tr><td align=right><font color=\"#101646\">Téléfax :</td><td><font color=\"#4A516B\">33 (0) 232 140 299</td></tr>\n";
	print "<tr><td align=right><font color=\"#101646\">Internet : </td><td><font color=\"#4A516B\">www.ibsfr.com</td></tr>\n";
	print "</table>\n";
	print "</tr></table>\n";
	
	open(CATALOGUE,"< $fich_catal");
	@FICHIER = <CATALOGUE>;
# print $code,"*",$designation,"*",$page,"*",$chapitre,"*<br>";
	$trouver = 0;
        if ($code eq $designation and $page eq $chapitre and $chapitre eq $default){}else{
	foreach(@FICHIER){
		($code_test,$design_test,$nul_test,$page_test,$chap_test,$soustitre_test,$design2_test)=split(/;/,$_);
		
		################################################
		# elimination des criteres indifferents
		################################################
		if($code eq $default){			
			$code_test = $code;
		}
		if($designation eq $default){
			$design_test = $designation;
			$design2_test = $designation;
		
		}
		if($page eq $default){
			$page_test = $page;
			$lapage=$page_test;
		}
		else{
			$lapage = uc("Page $page");
		}
		
#		if($chapitre eq $default){
#			$chap_test = $chap_test;
#		}
				
		##################################################
		# recherche de chaqu'un des criteres dans la ligne courante du fichier catalogue
		#if ((grep /$code/,$code_test) and ((grep /$designation/,uc($design_test)) or (grep /$designation/,uc($design2_test))) and ($lapage eq uc($page_test)) and (grep /$chapitre/,uc($chap_test)) ){
		if ((grep /$designation/,uc($design_test)) or (grep /$designation/,uc($chap_test))  or (grep /$designation/,uc($soustitre_test)) or (grep /$designation/,uc($design2_test)) ){
			# les criteres sont dans la lignes alors on garde celui-ci dans un tableau
#                        print "--",$lapage,"*",uc($page_test),"<br>";
#                        print "--",$designation,"*",uc($design_test),"<br>";
			push (@liste,$_);
			$trouver=$trouver+1;	# il y a au moins 1 element
		}
	}
        }
	##################################
	# Affichage du resultat de la recherche
        print "<p>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp<font color=\"#101646\">Dieppe, le \n";
	print "<script>\n";
	print "<!-- Affichage de la date du jour -->\n";
	print "today = new Date\n";
	print "document.write(today.getDate() + \"/\" + today.getMonth() + \"/\" + today.getYear())</script>\n";
	print "<br><br><br><br>\n";
	if($trouver gt 0){ &Affichage_Resultat();}
        else
        {&Affichage_Rien();}	
	##################################
	close(CATALOGUE);

#}
print "</body></html>\n";



#################################################
# Affichage du resultat de la recherche
sub Affichage_Resultat(){

	print "<table border=\"0\" width=\"100%\" cellspacing=\"8\" cellpadding=\"0\">\n";
	foreach(@liste){
		($lecode,$ladesignation,$lenul,$lapage,$letitre,$lesoustitre,$ladesi2)=split(/;/,$_);

		# ----------------------- rsh pour recuperer le stock ------------------------
		open (workfile ," rsh -l sylvain unisys ./linux-sco PRODUIT-H *$lecode |");
		@fic=<workfile>;
		foreach (@fic){
			($date,$heure,$code,$designation,$prix_rev,$prix_unitaire,$stock,$tarif_a,$tarif_b,$tarif_c,$tarif_d,$diff_stock)=split (/;/,$_);
		}
		close(workfile);
		# ----------------------------------------------------------------------------
	
	
	   	$ladesignation=substr($ladesignation,0,40);
	   	$ladesi2=substr($ladesi2,0,40);
	   	$letitre=substr($letitre,0,40);
	   	$lesoustitre=substr($lesoustitre,0,40);
		if($stock != 0){
	   		print "<tr><td><font color=blue><b><i>$lecode</i></b></font></td><td>$ladesi2</td><td><b><i>Stock :</b></i> $stock</td>\n";
	   		print "<td>$lapage</td></tr>";
  		}
	}
}



sub Affichage_Rien(){
	print "Aucun produit trouvé veuillez reformuler votre demande";
}
