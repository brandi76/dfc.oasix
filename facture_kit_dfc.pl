$mail=$html->param("mail"); 
$mag=$html->param("mag"); 
$pdf=$html->param("pdf"); 
$base=$html->param("base"); 
$four=$html->param("four");

if ($action eq "sendpdf"){ 
	$cp1=$html->param("cp1"); 
	$cp2=$html->param("cp2"); 
	$cp3=$html->param("cp3"); 
	$cp4=$html->param("cp4"); 
	$copie="";
	if (&validemail($cp1)&&($cp1 ne "")){$copie="$cp1,";}
	if (&validemail($cp2)&&($cp2 ne "")){$copie.="$cp2,";}
	if (&validemail($cp3)&&($cp3 ne "")){$copie.="$cp3,";}
	if (&validemail($cp4)&&($cp4 ne "")){$copie.="$cp4,";}
	chop($copie);
	if (&validemail($mail)){
		$mail=~s/@/\@/;
		# print "/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $pdf $mag $copie &";
		system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $pdf $mag $copie &");
		if ($base ne "dfc"){
		print "Mail envoyé<br>
		<i>Bonjour,<br>
		Nous vous prions de bien vouloir trouvez ci-joint notre facture<br>
		relative à la participation publicitaire du magazine No:$mag<br>
		Cordialement<br>
		Le service facturation Duty Free Concept<br></i>
		";
		&save("update dfc.facture_pub set date_mail=curdate() where base='$base' and mag='$mag' and fournisseur='$four' and pdf='$pdf'","af");
		}
		else{
		print "Mail envoyé<br>
		<i>Bonjour,<br>
		Nous vous prions de bien vouloir trouvez ci-joint notre facture<br>
		relative à la participation publicitaire<br>
		Cordialement<br>
		Le service facturation Duty Free Concept<br></i>
		";
		&save("update dfc.facture_pub set date_mail=curdate() where base='$base' and fournisseur='$four' and pdf='$pdf'","af");
		}
		print "<form>";
		&form_hidden();
		print "<input type=submit value=retour></form>";
	}
	else
	{
		print "mail invalide";
	}
} 


if ($action eq "mail_mag"){
	#$mailsyl="sylvainbrandicourt\@gmail.com";
	$mag_sql=$mag;
	$base_sql=$base;
	$four_sql=$four;
	if ($four eq "tous"){$four_sql="fournisseur";}
	$query="select * from facture_pub where mag like '$mag_sql' and base like '$base_sql' and fournisseur=$four_sql order by no_facture desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($base,$mag,$fournisseur,$marque,$no_facture,$date,$montant,$pdf,$date_mail,$groupement,$bis)=$sth->fetchrow_array){
		if (($groupement ne "")&&($groupement ne $groupement_tamp )){
			print "$mag $fournisseur base=$base pdf=$groupement ";
			$mail=&get("select fo2_email from fournis where fo2_cd_fo='$fournisseur'");
			if (&validemail($mail)){
				$mail=~s/@/\@/;
				system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $groupement $mag &");
				print " Mail envoyé<br>";
				&save("update dfc.facture_pub set date_mail=curdate() where base='$base' and mag='$mag' and fournisseur='$fournisseur' and groupement='$groupement'","");
			}
			else
			{
				print "mail invalide<br>";
			}  
			$groupement_tamp=$groupement;
		}
		else {
		    if ($groupement eq ""){
				print "$mag $fournisseur base=$base pdf=$pdf<br>";
				$mail=&get("select fo2_email from fournis where fo2_cd_fo='$fournisseur'");
				if (&validemail($mail)){
					$mail=~s/@/\@/;
					system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub.pl $mail $pdf $mag &");
					print " Mail envoyé<br>";
					&save("update dfc.facture_pub set date_mail=curdate() where base='$base' and mag='$mag' and fournisseur='$fournisseur' and pdf='$pdf'","");
				}
				else
				{
					print "mail invalide<br>";
				}  
			}		
		}	
	}
} 

if ($action eq "mail"){ 
  $mail=&get("select fo2_email from fournis where fo2_cd_fo='$four'");
  print "<form>";
  &form_hidden();
  print "email:<input type=text name=mail value='$mail' size=50";
  if (! &validemail($mail)){print " style=background:pink";}
  print "> <br />";
  print "copie <input type=texte name=cp1 value='philippe.perraud5\@orange.fr' size=50><br />";
  print "copie <input type=texte name=cp2 value='il\@dutyfreeconcept.com' size=50><br />";
  print "copie <input type=texte name=cp3 value='lamullecompta\@yahoo.fr' size=50><br />";
  print "copie <input type=texte name=cp4 value='dg\@dutyfreeconcept.com' size=50><br />";
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=hidden name=four value=$four>";
  print "<input type=hidden name=pdf value=$pdf>";
  print "<input type=hidden name=base value=$base>";
  print "<input type=hidden name=action value=sendpdf>";
  print "<a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a>";
  print "<br><input type=submit value=envoyer>";
  print "</form><br>	";
  print "<form>";
  &form_hidden();
  print "<input type=submit value=retour></form>";
}  


if ($action eq ""){
	$mag_sel=$html->param("mag_sel"); 
	($mag,$base)=split(/,/,$mag_sel);
	print "Les cases avec une bordure correspondent à des regroupements de facture<br>";
	if ($mag eq "") {print "ci dessous Les 100 dernieres factures ";}
	print "<br><form>";
	&form_hidden();
	print "Mag<br><select name=mag_sel>";
	print "<option value=tous>Factures Non Mag</option>";
	$query="select distinct mag,base from facture_pub order by date desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($mag_sel,$base_sel)=$sth->fetchrow_array){
		$option="$mag_sel,$base_sel";
		print "<option value=$option>$base_sel $mag_sel</option>";
	}  
	print "</select>";
	
	print "<br>Fournisseur<br><select name=four>";
	print "<option value=tous>Tous</option>";
	$query="select distinct fournisseur,fo2_add from facture_pub,fournis where fournisseur=fo2_cd_fo";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array){
		$option="$mag_sel,$base_sel";
		($fo_nom)=split(/\*/,$fo2_add);
		print "<option value=$fo2_cd_fo>$fo_nom</option>";
	}  
	print "</select>";
	print " <input type=submit>";
	print "</form>";
	# print "*$mag*$mag_sel*";
	if ($mag eq "pub"){$query="select * from facture_pub where mag like 'pub%'  order by no_facture desc limit 100 ";}
	else {
		if ($mag eq ""){$query="select * from facture_pub order by no_facture desc limit 100 ";}
		else {
			# if ($mag eq "tous"){ $query="select * from facture_pub order by mag,no_facture desc";}
			# else{
				$mag_sql=$mag;
				$base_sql=$base;
				$four_sql=$four;
				if ($mag eq "tous"){$mag_sql="%";$base_sql="dfc";}
				if ($four eq "tous"){$four_sql="fournisseur";}
				$query="select * from facture_pub where mag like '$mag_sql' and base like '$base_sql' and fournisseur=$four_sql order by no_facture desc";
				# print $query;
				if ($mag ne "tous"){
					print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=mail_mag&mag=$mag&base=$base&four=$four>Renvoyez toutes les factures de la selection</a>";
				}
			# }
		}
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($base,$mag,$fournisseur,$marque,$no_facture,$date,$montant,$pdf,$date_mail,$groupement,$bis)=$sth->fetchrow_array){
		if ($mag ne $mag_tamp){
			$total_mag=&get("select sum(montant) from facture_pub where mag='$mag' and base='$base'")+0;
			print "<div style=clear:both;text-align:center;font-weight:medium;width:100%;font-size:1.2em>$mag $base total:$total_mag Euros</div>";
			$total_gen+=$total_mag;
			$mag_tamp=$mag;
		}
		($nom)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$fournisseur'"));
		if ($groupement ne $groupement_tamp ){$engroup=0;}
		if (($groupement ne "")&&($groupement ne $groupement_tamp )){
			
			$montant_group=&get("select sum(montant) from facture_pub where groupement='$groupement'");
			$engroup=1;
			&changecolor();
			print "<div style=\"float:left;width:160px;height:250px;padding:10px;margin:10px;font-size:0.8em;background:$color;border:1px solid black;overflow:hidden\"><span style=color:#FF8000;font-size:1.2em;font-weight:bold>";
			print "$mag $base</span><br>";
			print "<a href=http://dfc.oasix.fr/doc/$groupement><img src=/images/pdf.jpg /></a><br>";
			print "<strong>Fact_no:$groupement</strong><br>$fournisseur $nom<br><span style=color:#FF8000;>Groupement</span><br>$montant_group Euros<br>Date facture:$date<br>";
			if (($date_mail ne "0000-00-00")&&($date_mail ne "")){
				print "Date mail:$date_mail";
			}
			else {
				print "<span style=color:red>mail non envoyé</span>";
			}
			print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=mail&mag=$mag&four=$fournisseur&base=$base&pdf=$groupement><img border=0 src=http://image.oasix.fr/email.png></a>";
			print "</div>";
			$groupement_tamp=$groupement;
		}  
		if ($engroup !=1) {&changecolor();}
		print "<div style=float:left;width:160px;height:250px;padding:10px;margin:10px;font-size:0.8em;background:$color;overflow:hidden><span style=color:#FF8000;font-size:1.2em;font-weight:bold>";
		print "$mag $base</span><br><a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a><br>";
		print "Fact_no:$no_facture<b>${bis}</b><br>$fournisseur $nom<br><span style=color:#FF8000;>$marque</span><br>$montant Euros<br>Date facture:$date<br>";
		if (($date_mail ne "0000-00-00")&&($date_mail ne "")){
			print "Date mail:$date_mail";
		}
		else {
			print "<span style=color:red>mail non envoyé</span>";
		} 
		if ($base ne "dfc"){
			print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=mail&mag=$mag&four=$fournisseur&base=$base&pdf=$pdf><img border=0 src=http://image.oasix.fr/email.png></a>";
			print "   <a href=modif_facture_pub.pl?action=modif&mag=$mag&four=$fournisseur&mag=$mag&base=$base&pdf=$pdf target=_blank><img border=0 src=http://image.oasix.fr/b_edit.png></a>";
		}
		else{
			print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=mail&mag=backwall&base=$base&four=$fournisseur&pdf=$pdf><img border=0 src=http://image.oasix.fr/email.png></a>";
		}
		print "</div>";
	}
	
	# print "<h3>Total:$total_gen</h3>";
}

sub changecolor(){
 if ($color eq "#F2F2F2"){$color="#CEF6CE";}else{$color="#F2F2F2";}
}
;1