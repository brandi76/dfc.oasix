#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require 'outils_perl.lib';
require 'manip_table.lib';

%pays_idx = &get_index_num("pays",0);
open(FILE2,"/home/var/spool/uucppublic/pays.txt");     
@pays_dat = <FILE2>;
close (FILE2);

$date = `/bin/date '+%d%m%y'`;   
chop($date);  
$user = &user(); 

print "<html><body>";
&tete("Relance interdite","/home/var/spool/uucppublic/archrelibs_li.txt",1); 

$action=$html->param("action");
$facture=$html->param("facture");
$client=$html->param("client");

if ($action eq ""){
	&choixfacture();
}
if ($action eq "motif"){
	&choixmotif();
}
if ($action eq "confirme"){
	&confirme();
	&choixmotif();

}

sub choixfacture {
	print "<center><br><br>";
	if ($erreur ==1){
		print "<font color=red>Facture $facture introuvable </font><br><br>";
		$erreur=0;
	}
	
	print"
	<form name=choix action=rel-interditibs.pl>No de facture :<input type=text size=8 name=facture><br><br>
	<input type=hidden name=action value=motif>
	<input type=hidden name=facture value=$facture>
	<input type=submit value=go></form>
	</body></html>";
}

sub choixmotif {
	($ec_cd_cl,$ec_no_fact,$ec_nom,$ec_dt,$ec_mont,$ec_reg,$ec_dt_reg,$ec_mont_dev,$ec_cd_dev) =&selecte("/home/var/spool/uucppublic/echeibs.txt",$facture,1);
	if ($ec_no_fact eq ""){
		$erreur=1;
		&choixfacture();
		exit;
		}	
	($cl_cd_cl,$cl_add,$cl_service,$cl_rue,$cl_ville)=&selecte("/home/var/spool/uucppublic/client2.txt",$ec_cd_cl,0); 

	print "<center><br><br><table border=1><tr><td><font color=red>$ec_cd_cl</font></td><td colspan=13><font color=black>Client:<font color=red>$cl_add</td></tr>";
        print "<tr bgcolor=#e8e8e8><td><font>facture</td><td align=middle><font >Nom</td><td><font >Date de facture</td><td><font >Montant </td><td><font >montant reglé </td><td><font >date du reglement</td><td><font >Montant en devise</td><td><font >reste </td><td><font >reste en devise</td></tr>\n";
	print "<tr bgcolor=$gris><td align=right><font size=2 color=$couleur>$ec_no_fact</a></td>";
	print "<td align=middle><font size=2 color=$couleur>$ec_nom</td><td align=right><font size=2 color=$couleur>";
	print &date($ec_dt);
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_mont);
	print " EU";
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_reg);
	$ec_reg+=0;
	print " EU";
	print "</td><td align=right><font size=2 color=$couleur>";
	print &date($ec_dt_reg);
	print "</td><td align=right><font size=2 color=$couleur>";
	print &separateur($ec_mont_dev);
	print " ";
	$dev=$ec_cd_dev;
	$ec_cd_dev=0+$ec_cd_dev;
		
	if ($pays_idx{$ec_cd_dev} ne ""){
		($nul,$nul,$nul,$nul,$nul,$nul,$dev)=split (/;/,@pays_dat[$pays_idx{$ec_cd_dev}]);
	}
	print "$dev</td>";
	$reste=$ec_mont-$ec_reg;
	print "<td align=right><font size=2 color=$couleur>";
	print  &separateur($reste);
	$reste+=0;
	print " EU";
	print "</td>"; 
	$reste_dev=0;
	if ($ec_mont!=0){$reste_dev=$reste*$ec_mont_dev/$ec_mont;}
	print "<td align=right><font size=2 color=$couleur>";
	print &separateur($reste_dev);
	print " $dev</td>"; 

	
	print "</tr></table><br><br>";
	%relancein_idx = &get_index_multiple("archrelibs_li",0);
	open(FILE2,"/home/var/spool/uucppublic/archrelibs_li.txt");     
	@relancein_dat = <FILE2>;
	close (FILE2);
	

	@liste=split(/;/,$relancein_idx{$ec_cd_cl});
	print "<table>";
	foreach (@liste) {
		(@ligne)=split(/;/,$relancein_dat[$_]);
		if ($ligne[1] eq $facture){
			print &ligne_tab("","le $ligne[2]","Blocage fait par $ligne[5]","Motif:<b>$ligne[4]</b>");
		}
	} 
	print "</table>";

	print "<br><br>";
	print "<form action=rel-interditibs.pl>";
	print "<input type=hidden name=facture value=$ec_no_fact>";
	print "<input type=hidden name=client value=$ec_cd_cl>";
	
	print "<input type=hidden name=action value=confirme>";
	print "<br><br>Commentaire<br><input type=text name=comment size=60><br>"; 
        print "<br><input type=submit value=valider></form>";
        
        print "</body></html>"; 

	
}

sub confirme {
	$ligne=$client.";".$facture.";".$date.";;".$html->param("comment").";".$user.";";
	&ajoute("/home/var/spool/uucppublic/archrelibs_li.txt",$ligne);     
	$ligne=$facture.";0;";
	&ajoute_n("/home/var/spool/uucppublic/relance.txt",$ligne,0);

}

# -E relance interdite ibs