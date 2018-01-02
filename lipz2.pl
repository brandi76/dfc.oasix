#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

#Fichier provenant de l'aryx
$fichier = "/home/var/spool/uucppublic/lipz2.txt";

%produit_idx = &get_index_multiple("produit",1);
open(FILE2,"/home/var/spool/uucppublic/produit.txt");     
@produit_dat = <FILE2>;
close (FILE2);


print "<HTML>\n";
print "<HEAD>\n";
print "<STYLE TYPE='text/css'>
font.FOURN { color: red; font-family:\"Vedana\"; font-size:12Px; font-weight:bold;} 
font.FOURN1 { color: red; font-family:\"Vedana\"; font-size:9Px; font-weight:bold;} 
font.PROD { color: black; font-family:\"Vedana\"; font-size:10Px; font-style: italic;}
font.TITLECOL { color: black; font-family:\"Vedana\"; font-size:10Px; font-weight:bold;} 
</STYLE></head>";
print "</HEAD>\n";

print "<BODY>\n";
print "<FONT FACE='Verdana' SIZE='1'>\n";
print "<font color='#CCCCCC'>Listing Crée par <I>LIPZ2.pl</I> au partir du fichier <I>LIPZ2.txt</I> crée par <A>LIPZ2ALE.z</A> (MAJ : ";&datemod($fichier,0);print ")</FONT><BR>";

print "<TABLE BORDER=0>\n";

open(FILE,"< $fichier");
@listing = <FILE>;

$COLOR='#EEEEEE';
$LineProd = 0;
foreach $tmp_line (@listing){
# Parcourir les lignes du fichier .....
	@temp = split(/;/,$tmp_line);
	print "<TR>\n";
	if($temp[0] eq "PROD"){ $LineProd = 1; }else{ $COLOR='GREEN';$LineProd=0; }
	# Change de couleur 1 ligne sur 2 pour les ligne produit
	if($LineProd==1){
		if($COLOR eq '#EEEEEE'){ $COLOR='#FFFFFF'; }else{ $COLOR='#EEEEEE';}
	}

	# Si la ligne est une ligne fournisseur
	if($temp[0] eq "FOURN"){
		print "<TD><FONT CLASS='FOURN'>$temp[1]</TD>\n";
		print "<TD><FONT CLASS='FOURN'>$temp[2]</TD>\n";
		print "<TD COLSPAN='2'><FONT CLASS='FOURN'>$temp[3]</TD>\n";
		print "<TD COLSPAN='2'><FONT CLASS='FOURN1'>$temp[4] :</TD>\n";
		print "<TD><FONT CLASS='FOURN1'>$temp[5]</TD>\n";
	}

	# Si ligne de titre de colonnes
	if($temp[0] eq "TITLECOL"){
		print "<TD COLSPAN='2'><FONT CLASS='TITLECOL'>&nbsp;</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[3]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[4]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[10]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[11]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>BIS</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[13]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[14]</TD>\n";
	}

	# Si ligne de produit
	if($temp[0] eq "PROD"){
		$temp[1] += 0;
		@prod = split(/;/,$produit_dat[$produit_idx{$temp[1]}]);
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[1]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[2]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[3]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[4] $temp[5]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[10]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[11]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[12]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[13]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[14]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$prod[2]</TD>\n";
	}
	
	# Si ligne de nature indéfinie
	if($temp[0] ne "FOURN" && $temp[0] ne "PROD" && $temp[0] ne "TITLECOL"){
		print "<TD COLSPAN='8'><FONT CLASS='PROD'>$temp[0]</TD>\n";

	}	
	print "</TR>\n";
	$i=0;
	$SUP=6;
}
close(FILE);

print "</TABLE>\n";

# -E Listing 1 (Parfum) Commande du Matin