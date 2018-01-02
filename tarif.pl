#!/usr/bin/perl
use CGI; 
$html=new CGI;
require 'manip_table.lib';
print $html->header; # impression des parametres obligatoires


$fich_catal = "/home/var/spool/uucppublic/catalogue2007.csv";	# fichier catalogue


$tarif = $html->param('tarif');
$cour = $html->param('cour');
$cour2 = $html->param('cour2');
$page_premiere = $html->param('page_premiere');
$page_derniere = $html->param('page_derniere');

print "<html>\n";
print "<HEAD>\n";
print "<STYLE TYPE='text/css'>
BR.BREAK{ page-break-after: right; }
span.police { font-family:\"Vedana\"}
span.taille1 {font-size:40px; font-weigth:20;}
span.taille2 {font-size:18px}
span.taille3 {font-size:14px}
span.taille4 {font-size:12px}
 </STYLE></head>";
 
print "<TITLE>T A R I F S&nbsp;&nbsp;&nbsp;S P E C I A U X&nbsp;&nbsp;\"$tarif\"</TITLE>\n";

print "<body bgcolor=white>\n";
print "<FONT FACE='Verdana'>\n";
&papier_entete();
#print "<img src=http://intranet.dom/images/bis_france.jpg>\n";
print "<P>&nbsp;</P><P>&nbsp;</P><P>&nbsp;</P><P>&nbsp;</P>";
print "<p>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp<font color=\"#101646\">Dieppe, le \n";
print "<script>\n";
print "<!-- Affichage de la date du jour -->\n";
print "today = new Date\n";
print "jour = today.getDate();\n";
print "mois = today.getMonth();\n";
print "mois++;\n";
print "annee = today.getYear();\n";
print "document.write(jour+\"/\"+mois+\"/\"+annee)</script>\n";
print "<br>\n";


$init=1;
print "<table border=\"0\" width=\"670\" cellspacing=\"0\" cellpadding=\"0\">\n";
%produit_idx = &get_index("produit",1);
%stre_idx = &get_index_num("stre",0);
open(FILE1,"/home/var/spool/uucppublic/produit.txt");
@produit_dat = <FILE1>;
open(FILE2,"/home/var/spool/uucppublic/stre.txt");
@stre_dat = <FILE2>;
%pays_idx = &get_index_num("pays",0);
open(FILE3,"/home/var/spool/uucppublic/pays.txt");
@pays_dat = <FILE3>;
@pays_item=("","","","",1000);
open(DOWN,"> /home/intranet/public_html/resulttarif.csv");

if ($cour eq "POUNDS"){@pays_item=split (/;/,@pays_dat[$pays_idx{6}]);$cour='Livre (£)';};
if ($cour eq "EURO"){@pays_item=split (/;/,@pays_dat[$pays_idx{12}]);$cour = "Euro (€)";}; 
if ($cour eq "FRANC BELGE"){@pays_item=split (/;/,@pays_dat[$pays_idx{2}]);$cour='Franc (BEF)';}; 
if ($cour eq "FRANC SUISSE"){@pays_item=split (/;/,@pays_dat[$pays_idx{39}]);$cour='Franc (CHF)';}; 
if ($cour eq "FF"){@pays_item=split (/;/,@pays_dat[$pays_idx{1}]);$cour='Franc (FRF)';}; 
$devise=$pays_item[4];
if ($cour2 eq "POUNDS"){@pays_item=split (/;/,@pays_dat[$pays_idx{6}]);$cour2='Livre (£)';};
if ($cour2 eq "EURO"){@pays_item=split (/;/,@pays_dat[$pays_idx{12}]);$cour2 = "Euro (€)";}; 
if ($cour2 eq "FRANC BELGE"){@pays_item=split (/;/,@pays_dat[$pays_idx{2}]);$cour2='Franc (BEF)';}; 
if ($cour2 eq "FRANC SUISSE"){@pays_item=split (/;/,@pays_dat[$pays_idx{39}]);$cour2='Franc (CHF)';}; 
if ($cour2 eq "FF"){@pays_item=split (/;/,@pays_dat[$pays_idx{1}]);$cour2='Franc (FRF)';}; 
$devise2=$pays_item[4];
$NBLIGNE = 1;
open(CATALOGUE,"< $fich_catal");
@FICHIER = <CATALOGUE>;
        foreach(@FICHIER){
	($code,$desi_cata,$contents,$page,$titre,$soustitre,$sous_sous_titre,$notes,$TA,$TB,$TC,$TD)=split(/;/,$_); 
	
	($nul,$page2)=split(/ /,$page);
	$soustitre=~s/\"\"/&#147/g;
	$soustitre=~s/\"//g;
	$desi_cata=~s/\"\"/&#147/g;
	$desi_cata=~s/\"//g;
	$sous_sous_titre=~s/\"\"/&#147/g;
	$sous_sous_titre=~s/\"//g;
	# print "$page*$page2*$page_premiere $page_derniere<br>";

	if (($page2 >= $page_premiere) && ($page2 <= $page_derniere))
	{
	
	# Affichage a chaque changement de Chapitre
	if($page_ref ne $page){
	print "<tr>\n";
		print "    <td colspan=5>";	print "<BR";
		if($init != 1){
			print " CLASS='BREAK'";
		}
			$page_ref=$page;
		print "></td></tr>\n";
		$sautpage = 1;
		
	}else{
		$sautpage=0;
	}
	if ($titre ne $titre_ref || $sautpage==1){
		print "<tr>\n";
		print "    <td colspan=5>";
		print "<BR";
		#if($init != 1){
#			print " CLASS='BREAK'";
#		}
		print "><P>&nbsp;</P><P>&nbsp;</P><P>&nbsp;</P>\n";
		print "<FONT SIZE='4px'><B><U>$titre</U></b></FONT></td>\n</tr>";
		#print "<TR>\n";
		#print "    <TD>&nbsp;</TD>\n<TD>&nbsp;</TD>\n";
		#print "    <td align='right' width='90'><font size='2'>Contents</font></td>\n";
		#print "    <td align='right' width='75'><font size='2'>$cour&nbsp;</font></td>\n";
		print DOWN "$titre;\n";
		#Si selection d'une deuxième devise.
		#if($cour2 ne ""){
			#print "    <td align='right' width='75'><font size='2'>$cour2&nbsp;</font></td>\n";
			#print DOWN "$cour2;";
		#}
		#print "    <td align=center width='35'><font size='2'>Page</font></td>\n</tr>\n\n";
		#print DOWN "Page;\n";
		$titre_ref=$titre;
		$NBLIGNE+=1;
		$init=0;
	}
	#Affichage du Sous_Titre avec décalage
	if ($soustitre ne $soustitre_ref || $sautpage==1){
		if ($soustitre ne 0){print "<tr>\n    <td colspan=2>";
		print "<BR>";
		print "<FONT SIZE='2px'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>$soustitre</b></FONT></td>\n\n\n";
		print "    <td align='right' width='90'><BR><font size='1'><i>Contents</i></font></td>\n";
		print "    <td align='right' width='75'><BR><font size='1'><i>$cour&nbsp;</i></font></td>\n";
		#print DOWN "$titre;;Contents;$cour;";
		#Si selection d'une deuxième devise.
		if($cour2 ne ""){
			print "    <td align='right' width='75'><BR><font size='1'><i>$cour2&nbsp;</i></font></td>\n";
			#print DOWN "$cour2;";
		}
		print "    <td align=center width='35'><BR><font size='1'><i>Page</i></font></td>\n</tr>\n\n";
		print DOWN "$soustitre;\n";}
		$soustitre_ref=$soustitre;
		$NBLIGNE+=2;
	}
	if (($sous_sous_titre ne $sous_sous_titre_ref && $sous_sous_titre ne "") || $sautpage==1){
		if ($sous_sous_titre ne 0){
		print "<tr>\n    <td colspan=3><FONT SIZE='1px'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b><i>$sous_sous_titre</i></b></FONT></td>\n</tr>\n\n";
		print DOWN "$sous_sous_titre;\n";
		$NBLIGNE+=1;
		}
		$sous_sous_titre_ref=$sous_sous_titre;
	}

	print "<tr>\n    <td width='90' align='right'><font size='1px'>&nbsp;$code&nbsp;</font></td>\n";
	$NBLIGNE+=1;
	print DOWN "$code;";

	$longueur = length($desi_cata);
	
	if( $longueur > 50){
		$desi_cata=substr($desi_cata,0,47);
		$desi_cata.="...";
	}
	print "    <td><font size='1px'>$desi_cata";
	if($notes ne ""){
		print "<BR><I><font color=gray>$notes</font></I>";
	}
	print "</font></td>\n";
	print "    <td align='right'><font size='1px'><I>$contents</I></font></td>\n";
	print DOWN "$desi_cata;$contents;";
	@produit_item=();
	if($produit_idx{$code} ne ""){
        @produit_item=split (/;/,@produit_dat[$produit_idx{$code}]);
        $index=@produit_item[0]*1000000+@produit_item[1];
        }     
        @stre_item=();
	if($stre_idx{$index} ne ""){
	        	@stre_item=split(/;/,@stre_dat[$stre_idx{$index}]);
	}        
        #print "<td><font size=2 color=gray>@produit_item[9]</font></td>";

        if ($tarif eq "A") {$index=21};
        if ($tarif eq "B") {$index=22};
        if ($tarif eq "C") {$index=23};
        if ($tarif eq "D") {$index=24};
        if ($tarif eq "CATAL") {
        		$tarif_special= @produit_item[15]*1000/$devise;
        }
        else{
        	$tarif_special= @stre_item[2]*@produit_item[$index]/$devise;
        }
        $color="black";
	# Afficher le prix en rouge si pas de prix ! ! ! 
        if($tarif_special <= 0){
        		$color="RED";
        }
        printf ("    <td align=right><font size='1px' color='$color'><b> %10.2f </b>&nbsp;</font></td>\n",$tarif_special);
        printf DOWN ("%10.2f;",$tarif_special);
        if($cour2 ne ""){
        	if ($tarif eq "CATAL") {
        		$tarif_special2= @produit_item[15]*1000/$devise2;
        	}else{
        		$tarif_special2= @stre_item[2]*@produit_item[$index]/$devise2;
        	}
        	# Afficher le prix en rouge si pas de prix ! ! ! 
        	if($tarif_special2 <= 0){
        		$color="RED";
        	}
        	printf ("    <td align=right><font size='1px' color='$color'><b>%10.2f </b>&nbsp;</font></td>\n",$tarif_special2);
       	        printf DOWN ("%10.2f;",$tarif_special2);
        }
        $page =~ s/Page //g;
        print "    <td align=right><font size='1px' color=gray><B>$page</B>&nbsp;</font></td>\n";
        print DOWN "$page;\n";
        print "</tr>\n\n";
	#$NBLIGNE++;
	}
	       }      
	
close(CATALOGUE);
print "</table></body></html>\n";
print "<P>&nbsp;</P><P>&nbsp;</P><P>&nbsp;</P>\n";
print "<a href=\"http://ibs.oasix.fr/resulttarif.csv\">Fichier</A>\n";


sub papier_entete{
print "<span class=police>
	<span class=taille1>
		<SPAN style=\"position: absolute; top: ",$page*27.7,"cm; left: 0cm;\">B.I.S. France</SPAN>
	</span>
	<span class=taille2>
		<SPAN style=\"position: absolute; top: ",$page*27.7+1.2,"cm; left: 0cm;\"><b>Diplomatic Corps Supplier</b></SPAN>
	</span>
	<span class=taille3>
		<SPAN style=\"position: absolute; top: ",$page*27.7+2,"cm; left: 0cm;\">B.P. 106 -76203 DIEPPE Cedex</SPAN>
		<SPAN style=\"position: absolute; top: ",$page*27.7+2.5,"cm; left: 0cm;\">Tél. 33 (0) 232 140 280 - Téléfax : 33 (0) 232 140 299</SPAN>
	</span>
</span>
";
}
# -E edition des tarif speciaux

# -B 31/10/2000 sylvain tous les prix etaient idendiques ,passage en get_index_num sur stre.idx attention les get invalides ne sont pas gerés
