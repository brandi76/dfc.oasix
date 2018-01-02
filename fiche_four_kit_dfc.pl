require "./src/connect.src";
@bases_client=("camairco","togo","aircotedivoire","dfc","tacv","cameshop","corsica");
print "<center><div class=titrefixe> Consultation du fichier fournisseur <br></div>";
$action=$html->param("action");
$fo2_cd_fo=$html->param("fo2_cd_fo");
$recherche=$html->param("recherche");
if (($fo2_cd_fo!='')&&($action ne "modif")){
	$query="select * from fournis where fo2_cd_fo='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo_local,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email,$fo_delai_pai,$fo_mode_pai,$fo_iban,$fo_bic,$fo_minicde)=$sth->fetchrow_array;
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
$fo_local=$html->param("fo_local");
if ($fo_local eq "on"){$fo_local=1;}
$fo_minicde=$html->param("fo_minicde");


$nom=$html->param("nom");
$rue=$html->param("rue");
$ville=$html->param("ville");
$pays=$html->param("pays");
$tva=$html->param("tva");

if (($nom ne '')||($rue ne '')||($ville ne '')||($pays ne '')||($tva ne '')){
	$fo2_add=$nom.'*'.$rue.'*'.$ville.'*'.$pays.'*'.$tva.'*';
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
	$query="select code,designation1,refour1,poids_net from produit_master,produit_inode where produit_inode.inode=produit_master.inode and code_fournisseur1=$fo2_cd_fo order by designation1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<h3>$fo2_cd_fo $fo2_add</h3><br>";
	print "<table border=1 cellpadding=0 cellspacing=0><tr><th>Code produit</th><th>designation</th><th>ref fournisseur</th><th>litrage</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_refour,$poids_net)=$sth->fetchrow_array)
	{
		# $pr_prac=int($pr_prac*100)/100;
		print "<tr><td><a href=?onglet=''0''&sous_onglet='0'&sous_sous_onglet='0'&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td><td>$pr_refour</td><td>$poids_net</td>";
		# if (($pr_sup !=0)&&($pr_sup!=3)){print "<td bgcolor=pink>";}else{print "<td>";}
		# print "$pr_sup $liste[$pr_sup]</td><td>$pr_prac</td>";
		# $ord_ordre=&get("select ord_ordre from ordre where ord_cd_pr='$pr_cd_pr'"); 
		# if ($ord_ordre eq ""){print "<td bgcolor=pink>&nbsp;</td>";}else{print "<td>$ord_ordre</td>";}
		# $liste="";
		# $query="select tr_code from trolley,lot where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr='$pr_cd_pr'";
		# $sth2=$dbh->prepare($query);
		# $sth2->execute();
		# while (($tr_code)=$sth2->fetchrow_array){
		  # $liste.="$tr_code<bR>";
		# }
		# if ($liste eq ""){print "<td bgcolor=pink>&nbsp;";}else{print "<td>";}
		# print "$liste</td>";
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
	
		print "<tR><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=visu>$fo2_cd_fo</a></td><td><font color=$color>$fo2_add</td></tR>"
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
		&save("replace into $client.fournis value ('$fo2_cd_fo','$fo2_add','','','','','15','','','','','15','','','','','','')","af");
	}

}


if ($action eq "modif"){
	foreach $client (@bases_client){
		&save("replace into $client.fournis value ('$ref_fournis','$fo2_add','$fo2_telph','$fo2_fax','$fo2_contact','$fo_local','$fo2_delai','$fo2_transp','$fo2_livraison','$fo2_transport','$fo2_deb','$fo2_freq','$fo2_email','$fo_delai_pai','$fo_mode_pai','$fo_iban','$fo_bic','$fo_minicde')","af");
	}
	$fo2_cd_fo=$ref_fournis;	
	print "<br><Font color=red>fournisseur modifié</font><br>";
	$action="visu";
}

if ($action eq "modif_contact"){
	$fo2_cd_fo=$ref_fournis;
	$query="select id from contact where fo_id='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($id)=$sth->fetchrow_array){
		$nom=$html->param("${id}_nom");
		$fonction=$html->param("${id}_fonction");
		$email=$html->param("${id}_email");
		$telephone=$html->param("${id}_telephone");
		$pub=$html->param("${id}_pub");
		&save("replace into contact values ('$fo2_cd_fo','$id','$nom','$fonction','$email','$telephone','$pub')","af");
		if ($nom eq ""){&save("delete from contact where fo_id='$fo2_cd_fo' and id='$id'","af");}
	}	
	print "<br><Font color=red>fournisseur modifié</font><br>";
	$action="visu";
}

if ($action eq "ajout_contact_v"){
	$nom=$html->param("nom");
	$fonction=$html->param("fonction");
	$telephone=$html->param("telephone");
	$email=$html->param("email");
	$pub=$html->param("pub");
	$id=&get("select max(id) from contact where fo_id='$fo2_cd_fo'")+1;
	&save("insert ignore into contact values ('$fo2_cd_fo','$id','$nom','$fonction','$email','$telephone','$pub')","af");
	$action="visu";
}	

if ($action eq "ajout_contact"){
	print "<div class=titre>Contact supplémentaire</div>";
	print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
	&form_hidden();
	print "<div style=float:left;width:150px;>Nom</div> <input type=text  name=nom value=\"$nom\" size=30><br />";
	print "<div style=float:left;width:150px;>Fonction</div> <input type=text  name=fonction value=\"$fonction\" size=30><br />";
	print "<div style=float:left;width:150px;>Telephone</div> <input type=text  name=telephone value='$telephone' size=30><br />";
	print "<div style=float:left;width:150px;>Email</div> <input type=text  name=email value='$email' size=30><br />";
	print "<div style=float:left;width:150px;>Contact Publicitaire</div> <input type=checkbox  name=pub" ;
	print "<br><input type=hidden name=fo2_cd_fo value=$fo2_cd_fo>";
	print "<br><input type=hidden name=action value=ajout_contact_v><input type=submit value=Ajout class=bouton>";
	print "</form>";
}

if ($action eq "visu"){
	$query="select * from fournis where fo2_cd_fo='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo_local,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email,$fo_delai_pai,$fo_mode_pai,$fo_iban,$fo_bic,$fo_minicde)=$sth->fetchrow_array;
	($nom,$rue,$ville,$pays,$tva)=split(/\*/,$fo2_add);
	print "<div class=titre>$fo2_cd_fo</div>";
	print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
 	require ("form_hidden2.src");
	print "<div style=float:left;width:150px;>Nom</div> <input type=text  name=nom value=\"$nom\" size=30><br />";
	print "<div style=float:left;width:150px;>Rue</div> <input type=text  name=rue value=\"$rue\" size=30><br />";
	print "<div style=float:left;width:150px;>Ville</div> <input type=text  name=ville value=\"$ville\" size=30><br />";
	print "<div style=float:left;width:150px;>Pays</div> <input type=text  name=pays value=\"$pays\" size=30><br />";
	print "<div style=float:left;width:150px;>Tva</div> <input type=text  name=tva value=\"$tva\" size=30><br />";
	print "<div style=float:left;width:150px;>Telephone</div> <input type=text  name=fo2_telph value='$fo2_telph' size=30><br />";
	print "<div style=float:left;width:150px;>Portable</div><input type=text  name=fo2_fax value='$fo2_fax' size=30><br />";
	print "<div style=float:left;width:150px;>Contact</div> <input type=text  name=fo2_contact value='$fo2_contact' size=30><br />";
	print "<div style=float:left;width:150px;>Email</div> <input type=text  name=fo2_email value='$fo2_email' size=30";
	($mail1,$mail2)=split(/,/,$fo2_email);
	if ($mail2 eq ""){$mail2=$mail1;}
	if ((&validemail($mail1))&&(&validemail($mail2))){
	  print ">";
	}
	else {
	  print " style=background-color:pink> mail invalide";
	}
	print "<br />";
	print "<div style=float:left;width:150px;>Mini cde</div> <input type=text  name=fo_minicde value='$fo_minicde' size=30><br />";
	print "<div style=float:left;width:150px;>Delai de paiement (jours)</div> <input type=text  name=fo_delai_pai value='$fo_delai_pai' size=30><br />";
	print "<div style=float:left;width:150px;>Mode de paiement</div> <input type=text  name=fo_mode_pai value='$fo_mode_pai' size=30><br />";
	print "<div style=float:left;width:150px;>Iban</div> <input type=text  name=fo_iban value='$fo_iban' size=30><br />";
	print "<div style=float:left;width:150px;>Bic</div> <input type=text  name=fo_bic value='$fo_bic' size=30><br />";
	print "<div style=float:left;width:150px;";
	if ($fo2_delai+0==0){print "background-color:pink;"}
	print ">Delai de livraison</div> <input type=text  name=fo2_delai value=\"$fo2_delai\" size=30><br />";
	if ($fo_local==1){$fo_local_check="checked";}
	print "<div style=float:left;width:150px;>Fournisseur Local</div> <input type=checkbox name=fo_local $fo_local_check><br />";
	print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=liste&fo2_add=$fo2_add>liste des produits</a>";
	print "<br><input type=hidden name=ref_fournis value=$fo2_cd_fo>";
	print "<br><input type=hidden name=action value=modif><input type=submit value=modif class=bouton>";
	print "</form>";
	print "<div class=titre>Contacts supplémentaires</div> (laisser vide le nom pour supprimer un contact)";
	print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
	&form_hidden();
	$query="select * from contact where fo_id='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($null,$id,$nom,$fonction,$email,$telephone,$pub)=$sth->fetchrow_array){
		$pubcheck="";
		$pubcheck="checked" if ($pub eq "on");
		print "<div style=float:left;width:150px;>Nom</div> <input type=text  name=${id}_nom value=\"$nom\" size=30><br />";
		print "<div style=float:left;width:150px;>Fonction</div> <input type=text  name=${id}_fonction value=\"$fonction\" size=30><br />";
		print "<div style=float:left;width:150px;>Telephone</div> <input type=text  name=${id}_telephone value='$telephone' size=30><br />";
		print "<div style=float:left;width:150px;>Email</div> <input type=text  name=${id}_email value='$email' size=30";
		($mail1,$mail2)=split(/,/,$email);
		if ($mail2 eq ""){$mail2=$mail1;}
		if ((&validemail($mail1))&&(&validemail($mail2))){
		  print ">";
		}
		else {
		  print " style=background-color:pink> mail invalide";
		}
		print "<br><div style=float:left;width:150px;>Contact Publicitaire</div> <input type=checkbox  name=${id}_pub $pubcheck>";
		print "<hr></hr>";
	}		
	print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=ajout_contact&fo2_cd_fo=$fo2_cd_fo>Ajouter un contact</a>";
	print "<br><input type=hidden name=ref_fournis value=$fo2_cd_fo>";
	print "<br><input type=hidden name=action value=modif_contact><input type=submit value=modif class=bouton>";
	print "</form>";
	print "<br /><form >";
 	&form_hidden();
	print "<input type=hidden name=ref_fournis value=$fo2_cd_fo>";
	print "<input type=hidden name=action value=sup><input type=submit value='supprimer le fournisseur' style=background-color:pink;></form>";
	
}		
	
;1