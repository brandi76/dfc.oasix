#!/usr/bin/perl
use CGI;
#use integer;
$html = new CGI;
print $html->header;
require 'manip_table.lib';
require 'outils_perl.lib';


open(FILE,'/home/var/spool/uucppublic/echeanc.txt');
@lignefac = <FILE>;
close(FILE);

%pays_idx = &get_index_num("pays",0); 
open(FILE2,"/home/var/spool/uucppublic/pays.txt");      
@pays_dat = <FILE2>; 
close (FILE2); 

%client_idx = &get_index_num("client2",0); 
open(FILE2,"/home/var/spool/uucppublic/client2.txt");      
@client_dat = <FILE2>; 
close (FILE2); 


$nb_facture = 0;
print "<HTML>\n";
print "<HEAD>\n";
print "<style>
   body { font-family: Verdana, sans-serif; font-size: 10pt; color: #000000;}
   table.Contour { font-size: 10pt; color: #000000; border-style: solid; border-color: black; border-width: 1px; }
   TD.negatif { font-size: 10pt; color: green; font-weigth: bold; }
   TD.devisediff { font-size: 10pt; color: blue; font-weigth: bold; }
   TD.warn { font-size: 8pt; color: red; font-weigth: bold; }
   TD.Titre { font-size: 8pt; color: black; font-style: bold; }
</style>";


print "</HEAD>\n";
print "<BODY LEFTMARGIN='0'>\n";

&tete('Purge Fact','/home/var/spool/uucppublic/echeanc.txt','');

print "<P><CENTER><TABLE BORDER='1' CELLSPACING='0' CELLPADDING='3' RULES='ROWS'>";
$COLOR='#EEEEEE';	
	print "<TR><TD>Listing facture dont montant restant du est -1.5>x<1.5 ou -0.5%>x<0.5</TD></TR>";
foreach $une_ligne (@lignefac){
	($ec_cd_cl, $ec_no_fact, $ec_nom, $ec_dt, $ec_mont, $ec_reg, $ec_dt_reg, $ec_mont_dev, $ec_cd_dev ) = split(/;/,$une_ligne);
	$class='normal';
	$ec_mont+=0;
	$ec_reg+=0;
	$restedu = $ec_mont - $ec_reg;
	if($ec_mont<=0){
		$class='negatif';
	}
	if($ec_mont!=$ec_mont_dev){
		$class='devisediff';
	}
	if($restedu != 0){
		if($ec_mont!=0){
			$poucent = 100 - ($ec_reg*100)/$ec_mont;
		}
		#print "$poucent<BR>";
		if( ($restedu>=-1.5 && $restedu<=1.5) || ($poucent>=-0.5 && $poucent<=0.5 && $poucent!=0)){
			$class='warn';
		}else{next;}
	}else{next;}

	@tab_cli = split(/;/,$client_dat[$client_idx{$ec_cd_cl}]);
	$tab_cli[0] += 0;
	$ec_cd_cl += 0;
if($temp_cli ne $tab_cli[1] || $tab_cli[0] ne $temp_cd_cli){
	$temp_cli = $tab_cli[1];
	$temp_cd_cli = $tab_cli[0];
	print "</TABLE><BR>\n\n";
	print "<TABLE BORDER='0' CELLSPACING='0' CELLPADDING='3' WIDTH='720' CLASS='Contour'>\n";
	
	print "<TR>\n";
	print "<TD WIDTH='60'>$tab_cli[0]</TD>\n";
	print "<TD COLSPAN='2' WIDTH='250'>";
	print "<B>$tab_cli[1]*</B>";
	print "</TD>\n";
	print "<TD COLSPAN='5' WIDTH='330'>";
	print "<B>$tab_cli[2]</B>";
	print "</TD>\n";
	print "<TD WIDTH='75'>";
	print "<B>$tab_cli[7]</B>";
	print "</TD>\n";
	print "</TR>\n\n";
	#print "<TD CLASS='Titre' WIDTH='70'><I>Code Client</TD>";
	print "<TR>\n";
	print "<TD CLASS='Titre'><I>N° Fact.</TD>\n";
	print "<TD CLASS='Titre' WIDTH='200'><I>Nom</I></FONT></TD>\n";
	print "<TD ALIGN='CENTER' CLASS='Titre' WIDTH='50'><I>Date</TD>\n";
	print "<TD ALIGN='CENTER' CLASS='Titre' WIDTH='78'><I>Montant</TD>\n";
	print "<TD ALIGN='CENTER' CLASS='Titre' WIDTH='78'><I>Reglé</TD>\n";
	print "<TD ALIGN='CENTER' CLASS='Titre' WIDTH='50'><I>Date Reglé</TD>\n";
	print "<TD ALIGN='CENTER' CLASS='Titre' WIDTH='78'><I>Montant Devise</TD>\n";
	print "<TD ALIGN='CENTER' CLASS='Titre' WIDTH='45'><I>Code Devise</TD>\n";
	print "<TD ALIGN='CENTER' CLASS='Titre'><I>Diff. Constatée</TD>\n";
	print "</TR>\n\n";
}
	if($COLOR ne '#EEEEEE'){$COLOR='#EEEEEE';}else{$COLOR='WHITE';}
	print "<TR>\n";
	#print "<TD CLASS='$class'>$ec_cd_cl</TD>";
	print "<TD BGCOLOR='$COLOR' CLASS='$class'>$ec_no_fact</TD>\n";
	print "<TD BGCOLOR='$COLOR' CLASS='$class'>$ec_nom</TD>";
	print "<TD BGCOLOR='$COLOR' CLASS='$class'>".&date($ec_dt)."</TD>\n";
	print "<TD BGCOLOR='$COLOR' CLASS='$class' ALIGN='RIGHT'>$ec_mont</TD>\n";
	print "<TD BGCOLOR='$COLOR' CLASS='$class' ALIGN='RIGHT'>$ec_reg</TD>\n";
	print "<TD BGCOLOR='$COLOR' CLASS='$class' ALIGN='RIGHT'>".&date($ec_dt_reg)."</TD>\n";
	print "<TD BGCOLOR='$COLOR' CLASS='$class' ALIGN='RIGHT'>$ec_mont_dev</TD>\n";
	print "<TD BGCOLOR='$COLOR' CLASS='$class' ALIGN='RIGHT'>$ec_cd_dev</TD>\n";
#	$ec_cd_dev +=0;
#	@tab = split(/;/,$pays_dat[$pays_idx{$ec_cd_dev}]);
#	print "<TD>$tab[1]<br>$restedu €<br>$poucent %</TD>\n";
	
	printf "<TD ALIGN='RIGHT' BGCOLOR='$COLOR' CLASS='$class'>%.2f</TD>\n",$restedu;
	print "</TR>\n\n";	
	$nb_facture++;
}
print "</TABLE>";
print "<P>&nbsp;</P>\n";
print "<FONT COLOR='red'>Nb ligne trait‚e : <B>$nb_facture</B></font>";