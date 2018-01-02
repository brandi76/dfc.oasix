#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$perl="http://ibs.oasix.fr/cgi-bin/commande_client.pl";
$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$option=$html->param("option");
$mois=$html->param("mois");
$mois2=$html->param("mois2");
$retour=$html->param("retour");
$annee=$html->param("annee");
if ($annee==2007){$annee=70000;}
if ($annee==2006){$annee=60000;}
$debut=1000000 +$mois*100 + $annee;
$fin=1000100 +$mois2*100+ $annee;
if ($navire ne "tout"){$critere="ic2_com1=\"$navire\" ";}
else
{
# $critere="(ic2_com1 not like \"MEGA%\" and ic2_com1 not like \"EXPRE%\" and ic2_com1 not like \"SARDINIA%\" and ic2_com1 not like \"REGINA%\" and ic2_com1 not like \"SERENA%\" and ic2_com1 not like \"NOVA%\" and ic2_com1 not like \"MARI%\" and ic2_com1 not like \"VICTORIA%\")";}
$critere="ic2_com1=ic2_com1";
}
$critere2="coc_qte!=0";
if ($retour==2){
	$critere2="coc_qte>0";
}
if ($retour==3){
	$critere2="coc_qte<0";
}

$total=0;
require "./src/connect.src";


if ($action eq ""){
	print "<head><title>mouvement produit</title></head><body><center><h1>Historique navire<br><form>";
	print "<br> Choix d'un navire (corsica)</h1><br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
      	print "<option value=tout";
       	print ">Tout\n";
   	print "</select><br>\n";
    	print "<br>premier mois <select name=mois>\n";
       	print "<option value=1>janvier\n";
   	print "<option value=2>Fevrier\n";
       	print "<option value=3>Mars\n";
       	print "<option value=4>Avril\n";
       	print "<option value=5>Mai\n";
       	print "<option value=6>Juin\n";
       	print "<option value=7>Juillet\n";
       	print "<option value=8>Aout\n";
       	print "<option value=9>Septembre\n";
    	print "<option value=10>Octobre\n";
       	print "<option value=11>Novembre\n";
       	print "<option value=12>Decembre\n";
    	print "</select><br>\n";
    	print "<br>dernier mois <select name=mois2>\n";
       	print "<option value=1>janvier\n";
   	print "<option value=2>Fevrier\n";
       	print "<option value=3>Mars\n";
       	print "<option value=4>Avril\n";
       	print "<option value=5>Mai\n";
       	print "<option value=6>Juin\n";
       	print "<option value=7>Juillet\n";
       	print "<option value=8>Aout\n";
       	print "<option value=9>Septembre\n";
       	print "<option value=10>Octobre\n";
       	print "<option value=11>Novembre\n";
       	print "<option value=12>Decembre\n";
    	print "</select><br>\n";
 	print "<br>2006 <input type=radio name=annee value=2006>";
   	print "<br>2007 <input type=radio name=annee value=2007>";
    	print "<br><input type=hidden name=action value=visu>";
    	print "avec les retours <input type=radio name=retour value=1 checked><br>";
    	print "sans les retours <input type=radio name=retour value=2><br>";
    	print "que les retours <input type=radio name=retour value=3><br>";
    	print "<br><input type=submit value=voir></form></body>";
}
	

if ($action eq "visu"){
open (FILE,">mouvement-corsica.txt");
$query="select ic2_no,ic2_com1,ic2_com2,ic2_date,pr_cd_pr,pr_type,pr_desi,coc_qte/100,coc_casse/100 from infococ2,comcli,produit where ic2_cd_cl=500 and coc_in_pos=5 and coc_no=ic2_no and ic2_date>=$debut and ic2_date<$fin and coc_cd_pr=pr_cd_pr and $critere and $critere2 and pr_desi not like 'testeur%' order by ic2_com1,ic2_no"; 
print $query;
print "<table border=1 cellspacing=0 cellpadding=2><tr><th>No facture</th><th>Navire</th><th>commentaire</th><th>date</th><th>Code produit</th><th>neptune</th><th>type</th><th>designation</th><th>qte</th><th>prix achat</th><th>total achat</th></tr>";
$sth = $dbh->prepare("$query");
$sth->execute;
while (($ic2_no,$ic2_com1,$ic2_com2,$ic2_date,$pr_cd_pr,$pr_type,$pr_desi,$nav_qte,$pr_prac) = $sth->fetchrow_array) {
	$date=substr($ic2_date,5,2)."/".substr($ic2_date,3,2)."/".substr($ic2_date,1,2);	
	if (($ic2_no != $no)&&($total!=0)){
		# $total_gen+=$total;		
		# print "<tr><td colspan=11><b>Total</td><td><b>$total</b></tr></table><br><br>";
		# print "<table border=1 cellspacing=0 cellpadding=2><tr><th>No facture</th><th>Navire</th><th>commentaire</th><th>date</th><th>Code produit</th><th>neptune</th><th>type</th><th>designation</th><th>qte</th><th>prix achat</th><th>total achat</th></tr>";

		$total=0;
	}	
	$neptune=&get("select nep_cd_pr from neptune where nep_codebarre=$pr_cd_pr");
	$no=$ic2_no;
	$val=$pr_prac*$nav_qte;	
	if ($pr_prac==0){
		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query2);
		$sth3->execute();
		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}
		$val=$pr_prac*$nav_qte;	
		if ($pr_prac==0){
			$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$pr_cd_pr'")+0;
			$val=$pr_prac*$nav_qte;	
			if ($pr_prac==0){
				$pr_prac="---";$val=0;
			}
		}
	}
	$color="black";
	$color="white";
	if (($val>=0)&&($val<=5)){$color="red";}
	if (($val<-1500)||($val>1500)){$color="red";}
	
	print "<tr bgcolor=$color><td>$ic2_no</td><td><nobr>$ic2_com1</td><td>$ic2_com2</td><td>$date</td><td>$pr_cd_pr</td><td>$neptune</td><td>$pr_type</td><td><nobr><font size=-2>$pr_desi</td><td>$nav_qte</td><td>$pr_prac</td><td>$val</td></tr>";
	print FILE "$ic2_no;$ic2_com1;$ic2_com2;$date;$pr_cd_pr;$neptune;$pr_type;$pr_desi;$nav_qte;$pr_prac;$val;\n";
	$pr_sup=&get("select pr_sup from produit where pr_cd_pr='$pr_cd_pr'");
	$total+=$val;
	if ($pr_type==1 || $pr_type==5){
		if ($val>0) {
			$total_gen+=$val;
			if ($pr_sup!=5){$nbparf+=$nav_qte;}
		}
		else {
			$total_genn+=$val;
			if ($pr_sup!=5){$nbparfr+=$nav_qte;}
			}
		}
	else
	{
		if ($val>0) {$total_gena+=$val;}
		else {$total_genan+=$val;}		
	}

}


print "<tr><td colspan=11><b>Total</td><td><b>$total</b></tr></table><br><br>";
print "<table border=1 cellspacing=0 cellpadding=2><tr><th>No facture</th><th>Navire</th><th>commentaire</th><th>date</th><th>Code produit</th><th>neptune</th><th>designation</th><th>qte</th><th>prix de vente achat</th><th>prix achat</th><th>total achat</th></tr>";
$total=0;
print "</table>";
print "<table border=1 cellspacing=0>";
print "<tr><td>Livraison Parfums,cosmetique</td><td>$total_gen</td><td>$nbparf</td></tr>";
print "<tr><td>Retour Parfums,cosmetique</td><td>$total_genn</td><td>$nbparfr</td></tr>";
print "<tr><td>Livraison Autres</td><td>$total_gena</td></tr>";
print "<tr><td>Retour Autres</td><td>$total_genan</td></tr>";
print "</table>";
}
# -E edition des factures navires pour une periode (plagne)   09/06 actif
