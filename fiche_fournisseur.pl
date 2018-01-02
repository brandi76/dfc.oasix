#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$action=$html->param("action");
$fo2_cd_fo=$html->param("fo2_cd_fo");
$recherche=$html->param("recherche");
if (($fo2_cd_fo!='')&&($action ne "modif")){
	$query="select * from fournis where fo2_cd_fo='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
}

$ref_fournis=$html->param("ref_fournis");
$fo2_add=$html->param("fo2_add");
$fo2_telph=$html->param("fo2_telph");
$fo2_fax=$html->param("fo2_fax");
$fo2_contact=$html->param("fo2_contact");
$fo2_email=$html->param("fo2_email");
$fo2_delai=$html->param("fo2_delai");

$nom=$html->param("nom");
$rue=$html->param("rue");
$ville=$html->param("ville");
if (($nom ne '')||($rue ne '')||($ville ne '')){
	$fo2_add=$nom.'*'.$rue.'*'.$ville.'*';
}

&tetehtml();

if ($action eq "liste"){
        @liste=("actif","supprimé","delisté","new","déstockage","suivi par paul","délisté par paul","délisté par le fournisseur");
	$query="select pr_cd_pr,pr_desi,pr_refour,pr_sup,pr_prac/100 from produit where pr_four=$fo2_cd_fo order by pr_desi";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<h3>$fo2_cd_fo $fo2_add</h3><br>";
	print "<table border=1><tr bgcolor=yellow><th>Code produit</th><th>designation</th><th>ref fournisseur</th><th>code suppression</th><th>prix achat</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_refour,$pr_sup,$pr_prac)=$sth->fetchrow_array)
	{
		print "<tr><td><a href=http://ibs.oasix.fr/cgi-bin/fiche_produit.pl?pr_cd_pr=$pr_cd_pr&recherche=&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td><td>$pr_refour</td><td>$pr_sup $liste[$pr_sup]</td><td>$pr_prac</td><td></tr>";
	}
	print "</table>";
}

if (($action eq "")||(($action eq "visu") && ($recherche ne ""))){
	print "</div><form name=prod>";
	print "Code fournisseur <input type=text name=fo2_cd_fo size=16><br>";
	print "<br>recherche <input type=text name=recherche size=16><br>";
	print "<input type=hidden name=action value=visu><br>";
	print "<br><input type=submit class=bouton value=envoie><br>";
	print "<br><table border=1 cellspacing=0><tr><th>Code fournis</th><th>Désignation</th></tr>";
	$query="";
	if ($recherche ne ""){
		$query="select fo2_cd_fo,fo2_add from fournis where fo2_add like \"%$recherche%\" order by fo2_cd_fo";
		$action="";
	}
	
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array){
		print "<tR><td><a href=?fo2_cd_fo=$fo2_cd_fo&action=visu>$fo2_cd_fo</a></td><td><font color=$color>$fo2_add</td></tR>"
	}
	print "</table><br></form></html>";
}		
$query="select count(*) from fournis where fo2_cd_fo='$fo2_cd_fo'";
$sth=$dbh->prepare($query);
$sth->execute();
($nb)=$sth->fetchrow_array;

# if (($action eq "modif")&&($nb>0)&&($fo2_cd_fo!=$ref_fournis)){$action="visu";}

if ($action eq "modif"){
	if ($nb!=1){
	$fo2_delai=15,
	$fo2_freq=15;
	}
	print "*";
	&save("replace into fournis value ('$fo2_cd_fo','$fo2_add','$fo2_telph','$fo2_fax','$fo2_contact','$fo2_identification','$fo2_delai','$fo2_transp','$fo2_livraison','$fo2_transport','$fo2_deb','$fo2_freq','$fo2_email')","");
	if ($nb!=1){ print "<br><Font color=red>fournisseur cree</font><br>";}
	else {print "<br><Font color=red>fournisseur modifié</font><br>";}
	$action="visu";
}

if ($action eq "visu"){
	print "<a href=?>Debut</a><br>";
	print "<form name=prod>";
	$query="select * from fournis where fo2_cd_fo='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	&tablep();
	print "<br><input type=hidden name=ref_fournis value=$fo2_cd_fo>";
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

	print "<body background=../fond2.jpg link=white alink=white vlink=white><div class=ombre><center><font size=+5>Gestion des fournisseurs</font>";
}

sub tablep {
print "<center><table border=1 cellspacing=20>
<tr><td colspan=4 class=gauche>Code <input type=text name=fo2_cd_fo value='$fo2_cd_fo' size=8></td></tr>";
($nom,$rue,$ville)=split(/\*/,$fo2_add);
print "<tr><td>Nom <input type=text name=nom value='$nom' size=30><br>Rue <input type=text name=rue value='$rue' size=30><br>Ville <input type=text name=ville value='$ville' size=30></td></tr>";

print "
<tr><td>Telephone :<br><input type=text name=fo2_telph value='$fo2_telph' size=12></td></tr>
<tr><td>Fax<br><input type=text name=fo2_fax value='$fo2_fax' size=12 </td></tr>
<tr><td>Contac<br><input type=text name=fo2_contact value='$fo2_contact' size=30 </td></tr>
<tr><td>Email<br><input type=text name=fo2_email value='$fo2_email' size=30 </td></tr>
<tr><td>Delai de livraison<br><input type=text name=fo2_delai value='$fo2_delai' size=5 </td></tr>
</table>";
print "<a href=?fo2_cd_fo='$fo2_cd_fo'&action=liste&fo2_add=$fo2_add>liste des produits</a>";
}
