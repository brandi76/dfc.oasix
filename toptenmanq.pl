#!/usr/bin/perl
use CGI;
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
open(FILE,"/home/var/spool/uucppublic/toptenmanq.txt"); 
@produit_dat = <FILE>; 
close (FILE);
     
$code = $html->param("code");
&tete("TOP 20 DES MANQUANTS","/home/var/spool/uucppublic/toptenmanq.txt");
print "<center><br><br>";
@produit_dat=sort tri_num (@produit_dat);
print "<table border=1><tr><td>&nbsp;</td><td>&nbsp;</td><td><b>Qte client</td><td><b>stock restant</td><td><b>Valeur</td></tr>";
for ($i=$#produit_dat;$i>$#produit_dat-20;$i--)
{
	($ecart,$pr_cd_prod,$pr_desi,$client,$restant,$valeur)=split(/;/,$produit_dat[$i]);
	print "<tr><td>$pr_cd_prod</td><td>$pr_desi</td><td align=left>$client</td><td align=right>$restant</td><td align=right>";
	print &deci2($valeur);
	print "</td></tr>"
}
print "</table></body></html>";

# -E info produit manquant
