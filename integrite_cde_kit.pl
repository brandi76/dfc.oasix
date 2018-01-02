$com_no=$html->param("cde");
print "<form>";
&form_hidden();
print "No de cde <input name=com_no><br>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";
$com_no=$html->param("com_no");
@etat_desi=("0 état de base","1 proforma verifiée","2 commande expédiée par le fournisseur","3 commande chez transitaire","4 commande expédiée sur base","5 entrée faite");

if ($action eq "go"){
	foreach $client (@bases_client){
		if ($client eq "dfc"){next;}
		$commande=&get("select count(*) from $client.commande where com2_no='$com_no'")+0;
		$commandearch=&get("select count(*) from $client.commandearch where com2_no='$com_no'","af")+0;
		if (($commande!=0)||($commandearch!=0)){
			print "<strong>$no_cde $client</strong><br>";
			print "Nb de ligne dans commande :$commande<br>";
			print "Nb de ligne dans commandearch :$commandearch<br>";
			if ($commande){
				($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis,$client.commande where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'","af"));
				print "$fo_nom<br>";
				$query="select com2_cd_pr,pr_desi,com2_qte from $client.commande,produit where com2_no='$com_no' and com2_cd_pr=pr_cd_pr";
				$sth=$dbh->prepare($query);
				$sth->execute();
				while (($com2_cd_pr,$pr_desi,$com2_qte)=$sth->fetchrow_array){
					print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&client=$client&com_no=$com_no&pr_cd_pr=$com2_cd_pr&action=enso>$com2_cd_pr</a> $pr_desi $com2_qte<br>";
				}	
				 
			}
			if ($commandearch){
				($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis,$client.commandearch where fo2_cd_fo=com2_cd_fo and com2_no='$com_no'","af"));
				print "$fo_nom<br>";
				
			}
			$liv=&get("select com2_no_liv from $client.commande where com2_no='$com_no'")+0;
			$liv_arch=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no'")+0;
			print "no liv $liv no liv arch:$liv_arch<br>";
			$etat=&get("SELECT etat FROM $client.commande_info where com_no='$com_no'");
			print "etat: $etat_desi[$etat]";
		}
		$query="select com2_no from $client.commande where com2_no not (select com_no from commandearch)";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($com2_no)=$sth->fetchrow_array){
			print "Commande $cleint $com_no introuvable dans commande_info<br>";
		}
				
	}
}

if ($action eq "enso"){
	$pr_cd_pr=$html->param("pr_cd_pr");
	$client=$html->param("client");
	$query="select * from $client.enso where es_cd_pr='$pr_cd_pr' and es_qte_en!=0 order by es_dt desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array){
		print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&client=$client&es_no_do=$es_no_do&action=enso_detail>no entree:$es_no_do</a> $es_dt $es_qte_en <a href=http://$client.oasix.fr/doc/ent_$es_no_do.pdf><img src=../../images/pdf.jpg></a><br>";
	}
	
}	

if ($action eq "enso_detail"){
	$client=$html->param("client");
	$es_no_do=$html->param("es_no_do");
	$query="select * from $client.enthead where enh_no='$es_no_do'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($enh_no,$enh_date,$enh_scelle,$enh_provenance,$enh_document,$enh_lieu)=$sth->fetchrow_array;
	print "date $enh_date Bl:$enh_document<br>";
	$query="select es_cd_pr,pr_desi,es_qte_en from $client.enso,produit where es_no_do=$es_no_do and es_cd_pr=pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_cd_pr,$pr_desi,$es_qte_en)=$sth->fetchrow_array){
		print "$es_cd_pr $pr_desi $es_qte_en <br>";
	}
}	
	

     
	
;1