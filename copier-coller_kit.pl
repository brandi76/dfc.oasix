$option=$html->param("option");
$param=$html->param("param");

if ($action eq ""){
		# print "<form method=post>";
		print "<form method=post>";
		&form_hidden();
		print "Date <input type=texte name=date id=datepicker><br>";
		print "<textarea class=\"form-control\" rows=\"5\" name=texte></textarea><br>";
		print "check <input type=checkbox name=option><br>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=cde_corsica>Cde corsica</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=cde_cameshop>Cde cameshop</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=code_ndp>Code Ndp</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=prix_dior>Prix Dior</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=inventaire_aci>Inventaire ACI</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=inventaire_cam>Inventaire cam</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=tmp_prod>Liste code (tmp_prod)</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=verif_prod_existe>verif prod existe</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=maj_ref_four>maj_ref_four</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=verif_cde_cam>verif_cde_cam</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=maj_famille_dfca>maj famille corsica</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=maj_fournisseur>maj fournisseur</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=cree_produit_desi>cree produit_desi</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=tenue>import tenue</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=tojson>To json</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=ecart>Ecart stock</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=double>Double fournisseur</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=excel>Conversion code excel</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=import_client_bp> importation client bp</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=import_four_bp> importation four bp</button>";
		print "<button type=\"submit\" class=\"btn btn-alerte\" name=action value=import_prod_bp> importation prod bp</button>";
		print "<br>Param <input type=texte name=param><br>";
		


print "</form>";

}
if ($action eq "import_prod_bp"){
        # $code=100590;
		# $code--;
		#1008	MAUBOUSSIN	3760048796309	24	LE SECRET D'ARIELLE EDP 50 ml	17.80 €	27.81 €
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
			# ($four,$marque,$refour,$pack,$desi,$prix,$null,$prac,$null)=split(/\t/,$ligne);
			# ($four,$marque,$refour,$barre,$pack,$desi,$prac,$prix)=split(/\t/,$ligne);
			 ($four,$marque,$refour,$pack,$desi,$prix,$null,$null,$prac)=split(/\t/,$ligne);
			if ($marque eq ""){next;}
			if ($desi eq ""){next;}
			$prac+=0;
			if ($prac==0){next;}
			($desi)=split(/\*/,$desi);
			 $code=&get("select max(pr_cd_pr) from dpaparis.produit");
			 if ($code eq ""){$code=100000;}else{$code++;}
			# $code++;
			$desi=$marque." ".$desi;
			print "$code $desi<br>";
			# $code=&get("select pr_cd_pr from dpaparis.produit where pr_refour=\"$refour\"","af");
			# print "$code $desi<br>";
			# &save("insert ignore into dpaparis.produit (pr_cd_pr,pr_desi,pr_marque,pr_refour,pr_four,pr_pack,pr_prac,pr_prix,pr_codebarre) values ($code,\"$desi\",\"$marque\",'$refour','$four','$pack','$prac','$prix','$barre')","aff");
			 &save("replace into dpaparis.produit (pr_cd_pr,pr_desi,pr_marque,pr_refour,pr_four,pr_pack,pr_prac,pr_prix,pr_codebarre) values ($code,\"$desi\",\"$marque\",'$refour','$four','$pack','$prac','$prix','$barre')","aff");
			
			# print "$PAYS,$SOCIETE,$ADRESSE,$MARCHE,$ACTIVITE,$NOMBRE $CONTACT,$FONCTION,$TEL,$EMAIL,$MARQUES<br><hr></hr>";
		}
}

if ($action eq "import_client_bp"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
			($PAYS,$SOCIETE,$ADRESSE,$MARCHE,$ACTIVITE,$NOMBRE,$CONTACT,$FONCTION,$TEL,$EMAIL,$MARQUES,$NOM)=split(/\t/,$ligne);
			if ($SOCIETE eq "SOCIETE"){next;}
			# ($mail)=split(/\//,$EMAIL);
			$mail=$EMAIL;
			$mail=~s/\//\;/;
			$mail=~s/\+/\;/;
			$mail=~s/ //g;
			$mail=~s/\#/\@/g;
			$code=&get("select max(code) from dpaparis.client");
			($a1,$a2,$a3)=split(/\;/,$NOM);
			if ($code eq ""){$code=1000;}else{$code++;}
			if ($SOCIETE eq ""){next;}
			&save("insert into dpaparis.client (code,organisme,email,pays,rue,code_postal,ville,contact) values ($code,\"$SOCIETE\",'$mail','$ADRESSE',\"$a1\",\"$a2\",\"$a3\",\"$CONTACT\")","aff");
			# print "$PAYS,$SOCIETE,$ADRESSE,$MARCHE,$ACTIVITE,$NOMBRE $CONTACT,$FONCTION,$TEL,$EMAIL,$MARQUES<br><hr></hr>";
		}
}
if ($action eq "import_four_bp"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
			($SOCIETE,$ADRESSE,$PAYS,$ACTIVITE,$MARQUES,$DISTRIBUTEUR_A,$DISTRIBUTEUR_M,$CONTACT,$FONCTION,$TEL,$TEL2,$EMAIL,$NOTES,$ENLEVEMENT)=split(/\t/,$ligne);
			if ($SOCIETE eq "SOCIETE"){next;}
			# ($mail)=split(/\//,$EMAIL);
			$mail=$EMAIL;
			$mail=~s/\//\;/;
			$mail=~s/\+/\;/;
			$mail=~s/ //g;
			$mail=~s/\#/\@/g;
			$code=&get("select max(code) from dpaparis.fournis");
			($a1,$a2,$a3)=split(/\;/,$NOM);
			$TEL=$TEL." ".$TEL2;
			if ($code eq ""){$code=1000;}else{$code++;}
			if ($SOCIETE eq ""){next;}
			&save("insert into dpaparis.fournis (code,organisme,email,pays,rue,code_postal,ville,contact,enlevement,tel) values ($code,\"$SOCIETE\",'$mail','$PAYS',\"$ADRESSE\",\"\",\"\",\"$CONTACT\",\"$ENLEVEMENT\",\"$TEL\")","aff");
			# print "$PAYS,$SOCIETE,$ADRESSE,$MARCHE,$ACTIVITE,$NOMBRE $CONTACT,$FONCTION,$TEL,$EMAIL,$MARQUES<br><hr></hr>";
		}
}

if ($action eq "excel"){
# attetion au plist avec : corrigé mais pas testé
		 print "<plaintext>";
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
		if (! grep (/split/,$ligne)){
		$ligne=~s/\<td\>/:/g;
		$ligne=~s/\<\/td\>/:/g;
		$ligne=~s/\<td align=right\>/:/g;
		$ligne=~s/\<th\>/:/g;
		$ligne=~s/\<\/th\>/:/g;
		$ligne=~s/\<th align=right\>/:/g;
		$ligne=~s/::/:/g;
		$ligne=~s/\<\/tr\>//g;
		$ligne=~s/\t/\|/g;
		
		if (grep /\<tr/,$ligne){
print <<EOF;
\$row++;
\$col=0;
EOF
		}	
		if (grep /:/,$ligne){
			(@tab)=split(/:/,$ligne);
			for ($i=1;$i<$#tab;$i++){
print <<EOF;
\$worksheet->write(\$row,\$col,"$tab[$i]");
\$col++;
EOF
			}
		}	
		else {
print <<EOF;
$ligne
EOF
}
		}
		else {
print <<EOF;
$ligne
EOF
		}
		}
		print "*** FIN *******";
}


if ($action eq "ecart"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$qte)=split(/\t/,$ligne);
				if (! grep /[0-9]/,$code){next;}
				&save("insert ignore into tacv.errdep value ('$code','2016-12-31','','$qte')","aff");
		}
}
if ($action eq "double"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$four)=split(/\t/,$ligne);
				$four=~s/[^0-9]//g;
				$four="F".$four;
				
				&save("delete from dutyfreeambassade.produit_four where ref_dfa='$code' and fournisseur='$four'","aff");
		}
}

if ($action eq "tenue"){
		@semaine=("Lundi","Mardi","Mercredi","Jeudi", "Vendredi", "Samedi","Dimanche");
		@age_tab=("","Enfant","Ado","Adulte");
		@niveau_tab=("","D&eacute;butant","Interm&eacute;diaire","Avanc&eacute;");
		$query="select id,libelle from tempsdanse2016.discipline";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($id2,$libelle)=$sth->fetchrow_array){
			$disci{$id2}=$libelle;
		}

		&save("truncate table tempsdanse2016.tenue_b");
		&save("truncate table tempsdanse2016.tenue_h");
		&save("truncate table tempsdanse2016.tenue_reglement");
		(@liste)=split(/\n/,$html->param("texte"));
		print "<table border=1>";
		foreach $ligne (@liste){
			($cours_,$nom,$prod,$taille,$prix,$reg,$nom_ch,$montant,$donne,$info)=split(/\t/,$ligne);
			(@tab)=split(/ /,$nom);
			$nom_eleve="";
			$prenom_eleve="";
			foreach (@tab){
					 if (! grep/[a-z]/,$_){
							 $nom_eleve.=" ".$_;
					 }
					 else {
							 $prenom_eleve.=" ".$_;
					 }
			 }
			 $nom_eleve=~s/^ //;
			 $prenom_eleve=~s/^ //;
			$eleve_id=&get("select id from tempsdanse2016.eleve where nom='$nom_eleve' and prenom='$prenom_eleve'","af");
			if ($eleve_id eq ""){
					$nom_eleve=~s/ /-/g;
					$eleve_id=&get("select id from tempsdanse2016.eleve where nom='$nom_eleve' and prenom='$prenom_eleve'");
			}
			if ($eleve_id eq ""){next;}
			print "<tr><td>";
			print "<a href=http://tempsdanse2016.oasix.fr/cgi-bin/kit.pl?onglet=0&sous_onglet=2&sous_sous_onglet=&eleve_id=$eleve_id&action=voir%2Fcreer>$eleve_id</a> ";
			print "<td>$nom_eleve</td><td>$prenom_eleve</td>";
			if ($taille eq ""){$taille="<span style=color:red>XXX</span>";}
			print "<td>$eleve_id</td><td>$prod</td><td>$taille</td><td align=right>";
			$pass=0;
			if ($prod eq "Collant"){$prod="Collants";}
			if (($prod eq "Tunique")&&($taille eq "4ans")){print "j4";$pro_id=1;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "6ans")){print "j6";$pro_id=1;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "8ans")){print "j8";$pro_id=1;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "10ans")){print "j10";$pro_id=1;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "12ans")){print "j12";$pro_id=1;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "14ans")){print "j14";$pro_id=2;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "S")){print "js";$pro_id=2;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "M")){print "jm";$pro_id=2;$pass=1;}
			if (($prod eq "Tunique")&&($taille eq "L")){print "jl";$pro_id=2;$pass=1;}
			if (($prod eq "Tunique")&&($pass==0)){print "tunique ***";}
			$pass=0;
			if (($prod eq "Collants")&&($taille eq "4/6ans")){print "c4";$pro_id=3;$pass=1;}
			if (($prod eq "Collants")&&($taille eq "8/10ans")){print "c8";$pro_id=3;$pass=1;}
			if (($prod eq "Collants")&&($taille eq "10/12ans")){print "c10";$pro_id=3;$pass=1;}
			if (($prod eq "Collants")&&($taille eq "S")){print "cs";$pro_id=4;$pass=1;}
			if (($prod eq "Collants")&&($taille eq "M")){print "cm";$pro_id=4;$pass=1;}
			if (($prod eq "Collants")&&($taille eq "L")){print "cl";$pro_id=4;$pass=1;}
			if (($prod eq "Collants")&&($taille eq "XL")){print "cxl";$pro_id=4;$pass=1;}
			if (($prod eq "Collants")&&($pass==0)){print "collant ***";}
			$pass=0;
			if (grep /poin/,$prod){print "pointe $taille";$pro_id=5;$pass=1;}
			if (($prod eq "cachecoeur")&&($taille<16)){print "cachecoeur $taille";$pro_id=6;$pass=1;}
			if (($prod eq "cachecoeur")&&($taille>+16)){print "cachecoeur $taille";$pro_id=7;$pass=1;}
			print "</td>";
			print "<td>";
			print $reg;
			print "</td>";
			print "<td>";
			print $nom_ch;
			print "</td>";
			$tenueh_id=&get("select tenueh_id from tempsdanse2016.tenue_h where eleve_id='$eleve_id'");
			@choix_cours=();
			if ($tenueh_id eq ""){
				(@cours)=&get("select cours1,cours2,cours3,cours4 from tempsdanse2016.choix where id='$eleve_id' and annee=2016");
				$nb_cours=0;
				@match=();
				foreach(@cours){
					if ($_ !=0){$nb_cours++;push(@choix_cours,$_);}
				}
				$match=$choix_cours[0];
				if ($nb_cours>1){
					$match=0;
					foreach $cours1 (@choix_cours){
						$query="select * from tempsdanse2016.cours where id=$cours1 ";
						$sth2=$dbh->prepare($query);
						$sth2->execute();
						($cours_id,$discipline,$jour,$heure,$prof,$age,$niveau,$duree)=$sth2->fetchrow_array;
						$jour=$semaine[$jour];
						$discipline=$disci{$discipline};
						$prof=$prof_tab{$prof};
						$age=$age_tab[$age];
						$niveau=$niveau_tab[$niveau];
						($quoi,$queljour,$quelheure)=split(/ /,$cours_);
						$queljour=ucfirst($queljour);
						$discipline=~s/ //g;
						$quoi=~s/ //g;
						$jour=~s/ //g;
						$queljour=~s/ //g;
						# print "$eleve_id *$discipline*$quoi*$jour*$queljour*$cours1*";
						if (($discipline eq $quoi)&&($jour eq $queljour)){$match=$cours1;}
						# print "$match <br>";
					}	
				}
				&save("insert into tempsdanse2016.tenue_h (eleve_id,cours) values ('$eleve_id','$match')");
				$tenueh_id=&get("SELECT LAST_INSERT_ID() FROM tempsdanse2016.tenue_h");
			}
			if ($reg ne ""){
				&save("insert into tempsdanse2016.tenue_reglement values ('$tenueh_id','$reg','$montant','$nom_ch')");
			}
			$prix=0;
			$livre=0;
			$prix=&get("select prix from tempsdanse2016.tenue_produit where pro_id='$pro_id'","af");
			if (grep /on/,$donne){$livre=1;}
			&save("insert ignore into tempsdanse2016.tenue_b values ('$tenueh_id','$pro_id','$taille','$livre','$prix')");
			if ($info ne ""){
				&save("update tempsdanse2016.tenue_h set info='$info' where tenueh_id='$tenueh_id'");
			}
			print "<td>$match</td></tr>";
		
			
		}
		print "</table>";
}
# $action="";
if ($action eq "cree_produit_desi"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code)=split(/\t/,$ligne);
				&save("insert ignore into corsica.produit_desi (code) value ('$code')","aff");
		}
}

if ($action eq "tmp_prod"){
		(@liste)=split(/\n/,$html->param("texte"));
		&save("TRUNCATE TABLE `tmp_prod`");
		foreach $ligne (@liste){
				($code)=split(/\t/,$ligne);
				if (! grep /[0-9]/,$code){next;}
				$code=~s/[^0-9]//g;
				# print "'$code'<br>";
				$inode=&get("select inode from produit_master where refour1='$code'");
				if ($inode eq ""){next;}
				$code=&get("select code from produit_inode where inode='$inode'");
				&save("insert ignore into dfc.tmp_prod value ('$code')","aff");
		}
}
if ($action eq "tojson"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				$ligne=~s/ //g;
				(@col)=split(/\t/,$ligne);
				print "{tri:\"$col[1]\",desi:\"$col[0]\"},";
		}
}

if ($action eq "cde_corsica"){
		# (@liste)=split(/\n/,$html->param("texte"));
		# foreach $ligne (@liste){
				# ($code,$desi,$qte)=split(/\t/,$ligne);
				# $prix=&get("select coc_puni from corsica.comcli where coc_no=6 and coc_cd_pr='$code'")+0;
				# &save("insert ignore into corsica.comcli value ('7','$code','$qte','$prix','0','0','$qte')","aff");
				# $qtecde=&get("select coc_qte from corsica.comcli where coc_no=6 and coc_cd_pr='$code'")+0;
				# if ($qte==$qtecde){
						# &save("delete from corsica.comcli where coc_no=6 and coc_cd_pr='$code'","aff");
				# }
				# else {
						# &save("update corsica.comcli set coc_qte=coc_qte-$qte where coc_no=6 and coc_cd_pr='$code'","aff");
				# }
		# }
}
if ($action eq "maj_fournisseur"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$pr_refour)=split(/\t/,$ligne);
				&save("update corsica.produit set pr_four=12910,pr_refour='$pr_refour' where pr_cd_pr='$code'","aff");
				# &save("update dfc.produit set pr_four=$pr_four where pr_cd_pr='$code'","aff");
		}
}


if ($action eq "maj_famille_dfca"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($famille,$code)=split(/\t/,$ligne);
				&save("insert ignore into corsica.produit_plus (pr_cd_pr,pr_famille) value ('$code','$famille')","aff");
				&save("update corsica.produit_plus set pr_famille=$famille where pr_cd_pr='$code'","aff");
		}
}

if ($action eq "cde_cameshop"){

		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$qte,$prix)=split(/\t/,$ligne);
				 #$code=&get("select pr_cd_pr from cameshop.produit where pr_refour='$code_four'");
				$pr_desi=&get("select pr_desi from cameshop.produit where pr_cd_pr='$code'");

				 print "$code $pr_desi<br>";
						# $nocde=&get("select dt_no from cameshop.atadsql where dt_cd_dt=205")+1;
						# &save("update cameshop.atadsql set dt_no=$nocde where dt_cd_dt=205");
						# &save("insert ignore into cameshop.commande_info (com_no,date,user,etat) values ('$nocde',curdate(),'$user','0')");
						# $prix=&get("select pr_prac from cameshop.produit where pr_cd_pr='$code'")+0;
						$qte*=100;
						&save("insert ignore into cameshop.commande value ('18888','10220','$code','$qte','$prix','0','2016-07-05','0',1,'')","aff");

		}
}
if ($action eq "verif_cde_cam"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$code_four,$prix,$qte)=split(/\t/,$ligne);
				$query="select com2_qte/100,com2_prac from cameshop.commande where com2_cd_pr=$code and com2_no=18900";
				$sth=$dbh->prepare($query);
				$sth->execute();
				($com2_qte,$com2_prac)=$sth->fetchrow_array;
				$qte*=100;
				# print "$code $prix $com2_prac $qte $com2_qte<br>"
						# $nocde=&get("select dt_no from cameshop.atadsql where dt_cd_dt=205")+1;
						# &save("update cameshop.atadsql set dt_no=$nocde where dt_cd_dt=205");
						# &save("insert ignore into cameshop.commande_info (com_no,date,user,etat) values ('$nocde',curdate(),'$user','0')");
						# $prix=&get("select pr_prac from cameshop.produit where pr_cd_pr='$code'")+0;
						 &save("insert ignore into cameshop.commande value ('18900','1260','$code','$qte','$prix','0','2016-07-23','828',1,'')","aff");
		}
}

if ($action eq "maj_ref_four"){
		(@liste)=split(/\n/,$html->param("texte"));
			
		foreach $ligne (@liste){
				chop($ligne);
		
				($code_four,$code)=split(/\t/,$ligne);
				# &save("update cameshop.produit set pr_refour='$code_four' where pr_cd_pr='$code'","aff");
				# &save("update corsica.produit set pr_refour='$code_four' where pr_cd_pr='$code'","aff");
				 &save("update dutyfreeambassade.produit_four set ref_four='$code_four' where ref_dfa='$code' and fournisseur='$param'","aff");
		}
}

if ($action eq "verif_prod_existe"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code)=split(/\t/,$ligne);
				$designation=&get("select pr_desi from cameshop.produit where pr_cd_pr='$code'");
				print "$code $designation<br>";
		}
}


if ($action eq "prix_dior"){
print "ici";
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($desi,$prix)=split(/\t/,$ligne);
				&save("update cameshop.produit set pr_prx_vte='$prix' where pr_desi=\"$desi\"","aff");
				# $sth=$dbh->prepare($query);
				# $sth->execute();
				# ($pr_desi,$pr_prac)=$sth->fetchrow_array;
				# $pr_prac/=100;
				# if ($pr_desi ne "") {
						# print "$code $pr_desi $pr_prac $prix<br>";
						# $prix*=100;
						# &save("update produit set pr_prac='$prix' where pr_cd_pr='$code'","aff");
				# }

		}
}

if ($action eq "code_ndp"){
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$ndp)=split(/\t/,$ligne,2);
				$ndp=~s/[^0-9]//g;
				if (length($ndp)>=9){$ndp=substr($ndp,0,8);}
				$pr_douane=&get("select pr_douane from dfc.produit where pr_cd_pr='$code'","aff");
				$color="";
				if ($pr_douane ne $ndp){
						$color="red";
						foreach $client (@bases_client) {
								&save("update $client.produit set pr_douane='$ndp' where pr_cd_pr='$code'","aff");
						}
				}
				&save("insert ignore into chapitre value ('$pr_douane','')");
				print "<span style=color:$color>*$code*$ndp*$pr_douane</span><br>";

		}
}

if ($action eq "inventaire_aci"){
		($date)=$html->param("date");
		if (grep(/\//,$date)) {
			($jj,$mm,$aa)=split(/\//,$date);
			$date=$aa."-".$mm."-".$jj;
		}
		$date2=$date;
		$date2=~s/-//g;
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$produit,$theorique,$physique,$casse,$ecart)=split(/\t/,$ligne);
				$check=&get("select count(*) from dfc.produit where pr_cd_pr='$code'")+0;
				if ($check==0){next;}
				if ($ecart==0){next;}
				&save("insert ignore into aircotedivoire.inventaire values ('$date','$code','$ecart',0)","aff");
				&save("replace into aircotedivoire.errdep values ('$code','$date2','','$ecart')","aff");
		}
}
if ($action eq "inventaire_cam"){
		($date)=$html->param("date");
		if (grep(/\//,$date)) {
			($jj,$mm,$aa)=split(/\//,$date);
			$date=$aa."-".$mm."-".$jj;
		}
		$date2=$date;
		$date2=~s/-//g;
		(@liste)=split(/\n/,$html->param("texte"));
		foreach $ligne (@liste){
				($code,$produit,$theorique,$physique,$casse,$ecart)=split(/\t/,$ligne);
				$check=&get("select count(*) from dfc.produit where pr_cd_pr='$code'")+0;
				if ($check==0){next;}
				if ($ecart==0){next;}
				&save("insert ignore into camairco.inventaire values ('$date','$code','$ecart',0)","aff");
				&save("replace into camairco.errdep values ('$code','$date2','','$ecart')","aff");
		}
}

;1

