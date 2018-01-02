#!/usr/bin/perl
use CGI;
$html = new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

$fichier = "/home/var/spool/uucppublic/red-ale.txt";

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
print "<font color='#CCCCCC'>Listing Crée par <I>RED-ALERTE.pl</I> au partir du fichier <I>RED-ALERTE.txt</I> crée par <A>RED-ALERTEAL.z</A> (MAJ:</FONT>";&datemod($fichier);print "<BR>";

print "<TABLE BORDER=0>\n";

open(FILE,"< $fichier");
@listing = <FILE>;

$COLOR='#EEEEEE';
$LineProd = 0;
$temp_title = "";
foreach $tmp_line (@listing){
# Parcourir les lignes du fichier .....
	@temp = split(/;/,$tmp_line);
	print "<TR>\n";
	if($temp[0] eq "PROD"){ $LineProd = 1; }else{ $LineProd=0; }
	if($LineProd==1 || $temp_title eq "PROD"){
		if($COLOR eq '#EEEEEE'){ $COLOR='#FFFFFF'; }else{ $COLOR='#EEEEEE';}
	}

	if($temp[0] eq "FOURN"){
		print "<TD><FONT CLASS='FOURN'>$temp[1]</TD>\n";
		print "<TD><FONT CLASS='FOURN'>$temp[2]</TD>\n";
		print "<TD COLSPAN='2'><FONT CLASS='FOURN'>$temp[3]</TD>\n";
		print "<TD COLSPAN='2'><FONT CLASS='FOURN1'>$temp[4]</TD>\n";
		print "<TD><FONT CLASS='FOURN1'>$temp[5]</TD>\n";
	$temp_title = "FOURN";
	$COLOR='#FFFFFF';
	}


	if($temp[0] eq "TITLECOL"){
		print "<TD><FONT CLASS='TITLECOL'>$temp[1]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[2]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[3]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[4]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[5]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[6]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[7]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[8]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[9]</TD>\n";
		print "<TD><FONT CLASS='TITLECOL'>$temp[10]</TD>\n";
	$temp_title="TITLECOL";
	}

	
	if($temp[0] eq "PROD"){
		@prod = split(/;/,$produit_dat[$produit_idx{$temp[1]}]);
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[1]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[2]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[3]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[4]</TD>\n";
		$temp[6] =~ s/[-+]{1,}/RUPTURE/g;
		$temp[6] =~ s/[*]{1,}//g;
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[5]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[6]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[7]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[8]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>",date(daten($temp[9])),"</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[10]</TD>\n";
		print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$prod[2]</TD>\n";
	$temp_title = "PROD";
	}
	
	if($temp[0] ne "FOURN" && $temp[0] ne "PROD" && $temp[0] ne "TITLECOL"){
		if($temp_title eq "PROD"){
				$temp[0] =~ s/[*]{1,}//g;
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>&nbsp;</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>&nbsp;</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>&nbsp;</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>&nbsp;</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>&nbsp;</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[0]</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[1]</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[2]</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[3]</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[4]</TD>\n";
				print "<TD BGCOLOR='$COLOR'><FONT CLASS='PROD'>$temp[5]</TD>\n";
				$LineProd=1;
					$temp_title = "PROD";
			}else{
		print "<TD COLSPAN='5'><FONT CLASS='PROD'>$temp[0]</TD>\n";
		}

	}	
	print "</TR>\n";
	#print "<TR>\n";

	$i=0;
	$SUP=6;
#	foreach $tmp_champ (@temp){
	#parcourir les colonne du fichier
#		if($tmp_champ ne "FOURN" && $tmp_champ ne "PROD" && $tmp_champ ne "TITLECOL"){
#		if($i!=6 && $i!=7 && $i!=8 && $i!=9){
#			print "<TD";
#			if($LineProd==1){
#				print " BGCOLOR='$COLOR'";
#			}
#			if($temp[0] ne "FOURN" && $temp[0] ne "PROD" && $temp[0] ne "TITLECOL"){
#				print " colspan=5";
#			}
#			print "><FONT CLASS='$temp[0]' FACE='Verdana' SIZE='1'>$tmp_champ</FONT></TD>\n";
#		}
#		}
#		$i++;
#	}
#	print "</TR>\n\n";
	

	
}
close(FILE);

print "</TABLE>\n";

# -E Listing 3 Commande du Matin