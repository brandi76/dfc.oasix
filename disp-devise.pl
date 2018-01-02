#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require 'outils_perl.lib';
print "<html>\n";
print "<title>DISP-DEVISE &copy;</title>";
print "<LINK rel=\"stylesheet\" href=\"/intranet.css\" type=\"text/css\">\n";	
&body();

&tete("DIS-DEVISE","/home/var/spool/uucppublic/pays.txt","");
print "<br><center><table border=0>\n" ;
print "<tr bgcolor=#E8E8E8><td><center><a><font color=red><b><i>Code Pays</b></i></font></a></center></td><td><center><a><font color=green><b><i>Désignation</i></b></font></a></center></td><td><center><a><b>cour Douane</b></a></center></td><td><center><a>cour Facture</a></center></td><td><center><a><b>cour Achat</b></a></center></td><td><center><a>cour Compta</a></center></td>";
# print "<td><center><a><b>cour Catalogue</b></a></center></td>";
print "</tr>\n" ;

open (PAYS,"/home/var/spool/uucppublic/pays.txt");
while ( <PAYS> )
{
($pa_cd_pa,$pa_desi,$pa_desi_do,$pa_cour_do,$pa_cour_fa,$pa_desi_dev,$pa_cd_dev,$pa_cour_prev,$pa_cour_ach,$pa_cour_compta,$pa_er)  = split(/;/,$_);
	$gras="";
	print "<tr";
	if ($pa_cd_pa !=1 && $pa_cd_pa !=6 && $pa_cd_pa !=400 && $pa_cd_pa !=17 && $pa_cd-_pa != 39){
		print " bgcolor=#E8E8E8";
	}
	else{
	$gras = "<b>";
        }
	print ">";
	$pa_cour_do/=1000000;
	$pa_cour_fa/=1000;
	$pa_cour_compta/=1000;
	print "<td><font color=red>$gras$pa_cd_pa</font></td><td><font color=green>$gras$pa_desi</font></td>";
	print "<td align=right>$gras";
	printf ("%.6f",$pa_cour_do); 
	print "</td>";	
	print "<td align=right>$gras";
	printf ("%.6f",$pa_cour_fa);
	print "</td>";     
	print "<td align=right>$gras";
	printf ("%0.6f",$pa_cour_ach);
	print "</td>";     
        print "<td align=right>$gras";
        printf ("%0.6f",$pa_cour_compta);
        print "</td>"; 
	print "</tr>";
}
print "</table></center><p>";
print "</body></html>\n";
# -E  Affichage des devises des diff. pays
