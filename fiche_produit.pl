#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
print "<title>fiche produit</title>"; 
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$action=$html->param("action");
$pr_cd_pr=$html->param("pr_cd_pr");
if (($pr_cd_pr!='')&&($action ne "modif")){
	$query="select * from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$pr_desi,$pr_casse,$pr_prx_rev,$pr_stre,$pr_douane,$pr_ventil,$pr_stanc,$pr_type,$pr_prx_vte,$pr_stvol,$pr_sup,$pr_emb,$pr_prac,$pr_deg,$pr_pdn,$pr_diff,$pr_acquit,$pr_orig,$pr_pdb,$pr_qte_comp,$pr_cond,$pr_devac,$pr_four,$pr_refour,$pr_codebarre)=$sth->fetchrow_array;
	$pr_casse/=100;
	$pr_prx_rev/=100;
	$pr_stre/=100;
	$pr_stanc/=100;
	$pr_prx_vte/=100;
	$pr_stvol/=100;
	$pr_prac/=100;
	$pr_deg/=100;
	$pr_diff/=100;
}

$ref_produit=$html->param("ref_produit");
$pr_desi=$html->param("pr_desi");
$pr_casse=$html->param("pr_casse");
$pr_prx_rev=$html->param("pr_prx_rev");
$pr_prx_vte=$html->param("pr_prx_vte");
$pr_stre=$html->param("pr_stre");
$pr_douane=$html->param("pr_douane");
$pr_ventil=$html->param("pr_ventil");
$pr_stanc=$html->param("pr_stanc");
$pr_type=$html->param("pr_type");
# $pr_prx_vte=$html->param("pr_prx_vte");
$pr_stvol=$html->param("pr_stvol");
$pr_sup=$html->param("pr_sup");
# $pr_emb=$html->param("pr_emb");
$pr_prac=$html->param("pr_prac");
$pr_deg=$html->param("pr_deg");
$pr_pdn=$html->param("pr_pdn");
$pr_diff=$html->param("pr_diff");
# $pr_acquit=$html->param("pr_acquit");
# $pr_orig=$html->param("pr_orig");
$pr_pdb=$html->param("pr_pdb");
$pr_qte_comp=$html->param("pr_qte_comp");
# $pr_cond=$html->param("pr_cond");
# $pr_devac=$html->param("pr_devac");
$pr_four=$html->param("pr_four");
$pr_refour=$html->param("pr_refour");
$recherche=$html->param("recherche");

$pr_codebarre=$html->param("pr_codebarre");
$car_carton=$html->param("car_carton");
$car_pal=$html->param("car_pal");

&tetehtml();

if (($action eq "")||(($action eq "visu") && ($recherche ne ""))){
	print "</div><form name=prod>";
	print "Code produit <input type=text name=pr_cd_pr size=16><br>";
	print "<br>recherche <input type=text name=recherche size=16><br>";
	print "<input type=hidden name=action value=visu><br>";
	print "<br><input type=submit class=bouton value=envoie><br>";
	print "<br><table border=1 cellspacing=0><tr><th>Code produit</th><th>Désignation</th></tr>";
	$query="";
	if ($recherche ne ""){
		$query="select pr_cd_pr,pr_desi from produit where pr_desi like \"%$recherche%\" order by pr_cd_pr";
		$action="";
	}
	
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$query="select count(*) from ordre,produit where ord_cd_pr='$pr_cd_pr' and pr_cd_pr=ord_cd_pr and pr_sup=0 limit 1";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($res)=$sth3->fetchrow_array;
	
		if ($res==0){$color="green";}else{$color="white";}
		print "<tR><td><a href=?pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a></td><td><font color=$color>$pr_desi</td></tR>"
	}
	print "</table><br></form></html>";
}		
$query="select count(*) from produit where pr_cd_pr='$pr_cd_pr'";
$sth=$dbh->prepare($query);
$sth->execute();
($nb)=$sth->fetchrow_array;

if (($action eq "modif")&&($nb>0)&&($pr_cd_pr!=$ref_produit)){$action="visu";}

if ($action eq "modif"){
	$pr_casse*=100;
	$pr_prx_rev*=100;
	$pr_prx_vte*=100;
	$pr_stre*=100;
	$pr_stanc*=100;
	$pr_stvol*=100;
	$pr_prac*=100;
	$pr_deg*=100;
	$pr_diff*=100;
	# print "$pr_cd_pr";
	if (! &checkbarre($pr_cd_pr)){print "<br><font color=red size=+3>Code barre erroné</font>"; exit;}
	if (! &checkbarre($pr_codebarre)){print "<br><font color=red size=+3>Code barre erroné</font>"; exit;}
	if ($nb!=1){
		# creation d'un nouveau produit
		$pr_stanc=$pr_stre=$pr_diff=$pr_stvol=$pr_casse=0;
		$pr_refour="";
		$pr_prac=0;
		$pr_prx_rev=0;
		$pr_prx_vte=0;
		$pr_desi="Nouveau produit";
		$pr_sup=3;
		# mise a jour des stock mini bateau
		$query="select nav_nom,nav_date,nav_qte,nav_pos from navire2 where nav_cd_pr=$pr_codebarre and nav_type=0";
		# $sth=$dbh->prepare($query);
		# $sth->execute();
		# while (($nav_nom,$nav_date,$nav_qte,$nav_pos)=$sth->fetchrow_array){
			# &save("replace into navire2 value ('$nav_nom','$pr_cd_pr','$nav_date',0,'$nav_qte','$nav_pos')");
		# }
		$pr_codebarre=$pr_cd_pr;
	}
	$dbh->do("replace into carton value ('$pr_cd_pr','$car_carton','$car_pal')");
	# print "replace into produit value ('$pr_cd_pr','$pr_desi','$pr_casse','$pr_prx_rev','$pr_stre','$pr_douane','$pr_ventil','$pr_stanc','$pr_type','$pr_prx_vte','$pr_stvol','$pr_sup','$pr_emb','$pr_prac','$pr_deg','$pr_pdn','$pr_diff','$pr_acquit','$pr_orig','$pr_pdb','$pr_qte_comp','$pr_cond','$pr_devac','$pr_four','$pr_refour','$pr_codebarre')";
	&save("replace into produit value ('$pr_cd_pr','$pr_desi','$pr_casse','$pr_prx_rev','$pr_stre','$pr_douane','$pr_ventil','$pr_stanc','$pr_type','$pr_prx_vte','$pr_stvol','$pr_sup','$pr_emb','$pr_prac','$pr_deg','$pr_pdn','$pr_diff','$pr_acquit','$pr_orig','$pr_pdb','$pr_qte_comp','$pr_cond','$pr_devac','$pr_four','$pr_refour','$pr_codebarre')","af");
	# print "replace into produit value ('$pr_cd_pr','$pr_desi','$pr_casse','$pr_prx_rev','$pr_stre','$pr_douane','$pr_ventil','$pr_stanc','$pr_type','$pr_prx_vte','$pr_stvol','$pr_sup','$pr_emb','$pr_prac','$pr_deg','$pr_pdn','$pr_diff','$pr_acquit','$pr_orig','$pr_pdb','$pr_qte_comp','$pr_cond','$pr_devac','$pr_four','$pr_refour','$pr_codebarre')";
	
	if ($nb!=1){
		$dbh->do("replace into produit2 value ('$pr_cd_pr','$pr_douane',0,0)");
		print "<br><Font color=red>Produit crée</font><br>";
	}
	else { print "<br><Font color=red>Produit modifié</font><br>";}
	$action="visu";
}

if ($action eq "visu"){
	print "<a href=?>Debut</a><br>";
	if (! &checkbarre($pr_cd_pr)){print "<br><font color=red size=+3>Code barre erroné</font>"; exit;}
	print "<form name=prod>";
	$query="select * from produit where pr_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$pr_desi,$pr_casse,$pr_prx_rev,$pr_stre,$pr_douane,$pr_ventil,$pr_stanc,$pr_type,$pr_prx_vte,$pr_stvol,$pr_sup,$pr_emb,$pr_prac,$pr_deg,$pr_pdn,$pr_diff,$pr_acquit,$pr_orig,$pr_pdb,$pr_qte_comp,$pr_cond,$pr_devac,$pr_four,$pr_refour,$pr_codebarre)=$sth->fetchrow_array;
	$pr_casse/=100;
	$pr_prx_rev/=100;
	$pr_stre/=100;
	$pr_stanc/=100;
	$pr_prx_vte/=100;
	$pr_stvol/=100;
	$pr_prac/=100;
	$pr_deg/=100;
	$pr_diff/=100;
	$query="select fo2_add from fournis where fo2_cd_fo='$pr_four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo_add)=$sth->fetchrow_array;
	($fo_add)=split(/\*/,$fo_add);
	&tablep();
	print "<br><input type=hidden name=ref_produit value=$pr_cd_pr>";
	print "<br><input type=hidden name=action value=modif><input type=submit value=modif class=bouton></form>";

}		
	
sub tetehtml()
{
	print "<html><head><style type=\"text/css\">
	body {color=white;}
	td {font-weight:bold;text-align:center;font-size:larger;}
	th {font-weight:bold;background-color:yellow;text-align:center;color=black;}
	
	.gauche {
		td {font-weight:bold;text-align:left;}
	}
	
	<!--
	.ombre {
	filter:shadow(color=black, direction=120 , strength=2);
	width:800px;}
	.ombre2 {
	filter:shadow(color=white, direction=120 , strength=3);
	width:800px;}
		
	.bouton {border-width=3pt;color:black;background-color:white;font-weight:bold;}
	-->
	</style></head>";

	print "<body background=../fond2.jpg link=white alink=white vlink=white><div class=ombre><center><font size=+5>Gestion des produits</font>";
}

sub tablep {
print "<center><table border=1 cellspacing=20>
<tr><td colspan=4 class=gauche>Code <input type=text name=pr_cd_pr value='$pr_cd_pr' size=16><a href=http://ibs.oasix.fr/inv.php?prod=$pr_cd_pr> Inventaire </a> Désignation <input type=text name=pr_desi value='$pr_desi' size=80>";
# lien sur les clones
	$query="select pr_cd_pr from produit where pr_codebarre='$pr_cd_pr' and pr_cd_pr!='$pr_cd_pr'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	while (($clone)=$sth->fetchrow_array){
		print "<a href=fiche_produit.pl?pr_cd_pr=$clone&action=visu>$clone </a>";
	}
	$query="select pr_cd_pr from produit where pr_cd_pr='$pr_codebarre' and pr_cd_pr!='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($clone)=$sth->fetchrow_array){
		print "<a href=fiche_produit.pl?pr_cd_pr=$clone&action=visu>$clone </a>";
	}

print "</td></tr>

<tr bgcolor=yellow><th>Douane</th><th>Inventaire</th><th>Logistique</th><th>Fournisseur</th></tr>

<tr>
<td>Code ndp :<br><input type=text name=pr_douane value='$pr_douane' size=14></td>
<td>Stock douane :<br><input type=text name=pr_stre value='$pr_stre' size=8 onChange=\"document.prod.pr_stanc.value=document.prod.pr_stre.value-($pr_stre-($pr_stanc))\"></td>
<td>Code ventilation :<br><input type=text name=pr_type value='$pr_type' size=2>";
if ($pr_type==1){print "<br>Parfum";}
if ($pr_type==2){print "<br>Alcool";}
if ($pr_type==3){print "<br>Cigarette";}
if ($pr_type==4){print "<br>Boutique";}
if ($pr_type==5){print "<br>Cosmetique";}
print "
</td>
<td>Code fournisseur :<br><input type=text name=pr_four value='$pr_four' size=6><br><a href=fiche_fournisseur.pl?action=visu&fo2_cd_fo=$pr_four>$fo_add</a></td>
</tr> 

<tr>
<td>Code ventilation :<br><input type=text name=pr_ventil value='$pr_ventil' size=8>";
my($query)="select type_desi from typedesi where type_code='$pr_ventil'";
my($sth)=$dbh->prepare($query);
$sth->execute();
(my($type_desi))=$sth->fetchrow_array;
print "<br>$type_desi
</td>
<td>Stock ancien :<br><input type=text name=pr_stanc value='$pr_stanc' size=8></td>
<td>Index suppression :<br>
<select name=pr_sup>";
@option=("actif","supprimé","delisté","new","déstockage","suivi par paul","délisté par paul","délisté par le fournisseur");
for ($i=0;$i<=$#option;$i++){
	print "<option value=$i";
	if ($pr_sup==$i){print " selected";}
	print ">$option[$i] $i</option><br>";
}
print "</select>
</td>
<td>Référence fournisseur :<br><input type=text name=pr_refour value='$pr_refour' size=8></td>
</tr>

<tr>
<td>Degrée :<br><input type=text name=pr_deg value='$pr_deg' size=8></td>
<td>Stock casse :<br><input type=text name=pr_casse value='$pr_casse' size=8></td>
<td>Code barre :<br><input type=text name=pr_codebarre value='$pr_codebarre' size=14></td>
<td>Prix d'achat :<br><input type=text name=pr_prac value='$pr_prac' size=8></td>
</tr>
<tr>
<td>Poids net :<br><input type=text name=pr_pdn value='$pr_pdn' size=8></td>
<td>Difference de Stock :<br><input type=text name=pr_diff value='$pr_diff' size=8></td></td>
<td>Code neptune ";
$query="select nep_cd_pr from neptune where nep_codebarre='$pr_cd_pr'";
my($sth2)=$dbh->prepare($query);
$sth2->execute();
while (($neptune)=$sth2->fetchrow_array){print "$neptune ";}

print "&nbsp;</td><td>Remise<br><input type=text name=pr_prx_rev value='$pr_prx_rev' size=8></td>
</tr>
<tr>
<td>Poids brut :<br><input type=text name=pr_pdb value='$pr_pdb' size=8></td>
<td>Stock vol :<br><input type=text name=pr_stvol value='$pr_stvol' size=8></td>
<td>&nbsp;</td><td>Prix de vente<br><input type=text name=pr_prx_vte value='$pr_prx_vte' size=8></td>
</tr>
<tr>
<td>Qte complementaire :<br><input type=text name=pr_qte_comp value='$pr_qte_comp' size=8></td>
<td>&nbsp;</td>
<td>&nbsp;</td>";
my($query)="select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'";
my($sth)=$dbh->prepare($query);
$sth->execute();
(my($car_carton),my($car_pal))=$sth->fetchrow_array;
print "<td>packing carton :<br><input type=text name=car_carton value='$car_carton' size=8><br>
packing palette :<br><input type=text name=car_pal value='$car_pal' size=8><br>
</td>
</tr>
</table>";
}
