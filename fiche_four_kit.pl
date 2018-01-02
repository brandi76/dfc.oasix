require "./src/connect.src";
@base_client=("camairco","togo","aircotedivoire","dfc","tacv");
print "<center><div class=titrefixe> Consultation du fichier fournisseur <br></div>";
$action=$html->param("action");
$fo2_cd_fo=$html->param("fo2_cd_fo");
$recherche=$html->param("recherche");
if (($fo2_cd_fo!='')&&($action ne "modif")){
	$query="select * from fournis where fo2_cd_fo='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email,$fo_delai_pai,$fo_mode_pai,$fo_iban,$fo_bic,$fo_minicde)=$sth->fetchrow_array;
}
$creation=$html->param("creation");

$ref_fournis=$html->param("ref_fournis");
$fo2_add=$html->param("fo2_add");
$fo2_telph=$html->param("fo2_telph");
$fo2_fax=$html->param("fo2_fax");
$fo2_contact=$html->param("fo2_contact");
$fo2_email=$html->param("fo2_email");
$fo2_delai=$html->param("fo2_delai");
$fo_delai_pai=$html->param("fo_delai_pai");
$fo_mode_pai=$html->param("fo_mode_pai");
$fo_iban=$html->param("fo_iban");
$fo_bic=$html->param("fo_bic");
$fo_minicde=$html->param("fo_minicde");


$nom=$html->param("nom");
$rue=$html->param("rue");
$ville=$html->param("ville");
if (($nom ne '')||($rue ne '')||($ville ne '')){
	$fo2_add=$nom.'*'.$rue.'*'.$ville.'*';
}

if ((($action eq "modif")||($action eq "sup"))&&($base_dbh ne "corsica")){
    print "<div style=\"border:1px solid black;text-align:justify;background-color:yellowgreen;padding:15px;border-radius:20px;margin:10px\">Les modifications/creations des fournisseurs sont désormais centralisées en france, merci de transmettre les modifications à faire à info\@dutyfreeconcept.com</div>"; 
   $action="";
}   
if ($action eq "sup"){
	$nb=0;
	foreach $client (@bases_client){
		$nb+=&get("select count(*) from $client.produit where pr_four=$ref_fournis")+0;
	}
	if ($nb >0){
		print "<p style=font-color:red>Impossible un ou plussieurs produits a cette reference comme  fournisseur</p>";
	}
	else {
		foreach $client (@bases_client){
			&save("delete from $client.fournis where fo2_cd_fo='$ref_fournis'");
		}
		print "<p>Fournisseur:$ref_fournis supprimé</p>";
	}
	$action="";
}

if ($action eq "liste"){
        @liste=("actif","supprimé","delisté","new","déstockage","suivi par paul","délisté par paul","délisté par le fournisseur");
	$query="select pr_cd_pr,pr_desi,pr_refour,pr_sup,pr_prac/100,pr_stre/100 from produit where pr_four=$fo2_cd_fo order by pr_desi";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<h3>$fo2_cd_fo $fo2_add</h3><br>";
	print "<table border=1 cellpadding=0 cellspacing=0><tr><th>Code produit</th><th>Designation</th><th>Ref fournisseur</th><th>Code suppression</th><th>Prix achat</th><th>Stock</th><th>Packing</th><th>Trolley actif</tr>";
	while (($pr_cd_pr,$pr_desi,$pr_refour,$pr_sup,$pr_prac,$pr_stre)=$sth->fetchrow_array)
	{
		$pr_prac=int($pr_prac*100)/100;
		$pr_stre=int($pr_stre*100)/100;
		print "<tr><td><a href=?onglet=''0''&sous_onglet='0'&sous_sous_onglet='0'&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td><td>$pr_refour</td>";
		if (($pr_sup !=0)&&($pr_sup!=3)){print "<td bgcolor=pink>";}else{print "<td>";}
		print "$pr_sup $liste[$pr_sup]</td><td align=right>$pr_prac</td><td align=right>$pr_stre</td>";
		$packing=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'")+0; 
		print "<td>$packing</td>";
		$liste="";
		$query="select tr_code from trolley,lot where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($tr_code)=$sth2->fetchrow_array){
		  $liste.="$tr_code<bR>";
		}
		if ($liste eq ""){print "<td bgcolor=pink>&nbsp;";}else{print "<td>";}
		print "$liste</td>";
		print "</tr>";
	}
	print "</table>";
}

if (($action eq "") && ($recherche eq "") && ($fo2_cd_fo eq "")){
    $recherche="*";
    }

if (($action eq "")||(($action eq "visu") && ($recherche ne ""))){
	print "</div><form>";
	require ("form_hidden.src");
	print "Code fournisseur <input type=text name=fo2_cd_fo size=16><br>";
	print "<br>recherche <input type=text name=recherche size=16><br>";
	print "<input type=hidden name=action value=visu><br>";
	print "Creation d'un nouveau fournisseur <input type=checkbox name=creation><br><br>";
	print "<input type=submit class=bouton value=envoie> <br>";
	print "<br><table border=1 cellspacing=0><tr><th>Code fournis</th><th>Désignation</th></tr>";
	$query="select fo2_cd_fo from fournis limit 0";
	if ($recherche ne ""){
		$query="select fo2_cd_fo,fo2_add from fournis where fo2_add like \"%$recherche%\" order by fo2_cd_fo";
		$action="";
	}
	
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array){
	    $check=&get("select count(*) from dfc.livraison_h where livh_base='$base_dbh' and livh_four=$fo2_cd_fo","af")+0;
		$gras="";
		if ($check>0){$gras="style=font-weight:bold";}
		print "<tR $gras><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=visu>$fo2_cd_fo</a></td><td><font color=$color>$fo2_add</td></tR>"
	}
	print "</table><br>";
# 	print "<input type=hidden name=onglet value=$onglet>";
#         print "<input type=hidden name=sous_onglet value=$sous_onglet>";
#         print "<input type=hidden name=sous_sous_onglet value=$sous_sous_onglet>";
	print "</form></html>";
}		
$query="select count(*) from fournis where fo2_cd_fo='$fo2_cd_fo'";
$sth=$dbh->prepare($query);
$sth->execute();
($nb)=$sth->fetchrow_array;

# if (($action eq "modif")&&($nb>0)&&($fo2_cd_fo!=$ref_fournis)){$action="visu";}

if (($action eq "visu")&&($creation eq "on")){
	$fo2_cd_fo=&get("select max(fo2_cd_fo) from fournis");
	$fo2_cd_fo+=10;
	$fo2_add="Nouveau fournisseur";
	foreach $client (@bases_client){
		&save("replace into $client.fournis value ('$fo2_cd_fo','$fo2_add','','','','','15','','','','','15','','','','','','')","");
	}

}


if ($action eq "modif"){
	foreach $client (@bases_client){
		&save("replace into $client.fournis value ('$ref_fournis','$fo2_add','$fo2_telph','$fo2_fax','$fo2_contact','$fo2_identification','$fo2_delai','$fo2_transp','$fo2_livraison','$fo2_transport','$fo2_deb','$fo2_freq','$fo2_email','$fo_delai_pai','$fo_mode_pai','$fo_iban','$fo_bic','$fo_minicde')","");
	}
	$fo2_cd_fo=$ref_fournis;	
	print "<br><Font color=red>fournisseur modifié</font><br>";
	$action="visu";
}

if ($action eq "visu"){
	$query="select * from fournis where fo2_cd_fo='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email,$fo_delai_pai,$fo_mode_pai,$fo_iban,$fo_bic,$fo_minicde)=$sth->fetchrow_array;
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	print "<div class=titre>$fo2_cd_fo</div>";
	print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
 	require ("form_hidden2.src");
	print "<div style=float:left;width:150px;>Nom</div> <input type=text  name=nom value=\"$nom\" size=30><br />";
	print "<div style=float:left;width:150px;>Rue</div> <input type=text  name=rue value=\"$rue\" size=30><br />";
	print "<div style=float:left;width:150px;>Ville</div> <input type=text  name=ville value=\"$ville\" size=30><br />";
	print "<div style=float:left;width:150px;>Telephone</div> <input type=text  name=fo2_telph value='$fo2_telph' size=30><br />";
	print "<div style=float:left;width:150px;>Fax</div><input type=text  name=fo2_fax value='$fo2_fax' size=30><br />";
	print "<div style=float:left;width:150px;>Contact</div> <input type=text  name=fo2_contact value='$fo2_contact' size=30><br />";
	print "<div style=float:left;width:150px;>Email</div> <input type=text  name=fo2_email value='$fo2_email' size=30><br />";
	print "<div style=float:left;width:150px;>Mini cde</div> <input type=text  name=fo_minicde value='$fo_minicde' size=30><br />";
	print "<div style=float:left;width:150px;>Delai de paiement</div> <input type=text  name=fo_delai_pai value='$fo_delai_pai' size=30><br />";
	print "<div style=float:left;width:150px;>Mode de paiement</div> <input type=text  name=fo_mode_pai value='$fo_mode_pai' size=30><br />";
	print "<div style=float:left;width:150px;>Iban</div> <input type=text  name=fo_iban value='$fo_iban' size=30><br />";
	print "<div style=float:left;width:150px;>Bic</div> <input type=text  name=fo_bic value='$fo_bic' size=30><br />";
	print "<div style=float:left;width:150px;";
	if ($fo2_delai+0==0){print "background-color:pink;"}
	print ">Delai de livraison</div> <input type=text  name=fo2_delai value=\"$fo2_delai\" size=30><br />";
	print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=liste&fo2_add=$fo2_add>liste des produits</a>";
	print "<br><input type=hidden name=ref_fournis value=$fo2_cd_fo>";
	print "<br><input type=hidden name=action value=modif><input type=submit value=modif class=bouton>";
	print "</form>";
	print "<br /><form >";
 	&form_hidden();
	print "<input type=hidden name=ref_fournis value=$fo2_cd_fo>";
	print "<input type=hidden name=action value=sup><input type=submit value=supprimer style=background-color:pink;></form>";
}		
	
;1