use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
use LWP::UserAgent;
$action=$html->param("action");
$facture=$html->param("facture");
$fichier=$html->param("fichier");
$date=$html->param("date");
$firstdate=$html->param("firstdate");
$lastdate=$html->param("lastdate");
$base=$html->param("base");
$option=$html->param("option");


$four=1260;
if (grep(/\//,$firstdate)) {
	($jj,$mm,$aa)=split(/\//,$firstdate);
	$firstdate=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$lastdate)) {
	($jj,$mm,$aa)=split(/\//,$lastdate);
	$lastdate=$aa."-".$mm."-".$jj;
}
($mois,$an_ref)=&get("select month(curdate()),year(curdate())");
if ($mois<4){$an_ref=$an_ref-1;}
# if ($base eq "cameshop"){$firstdate="$an_ref-04-15";}else{$firstdate="$an_ref-01-01";
$trimestre=-1;
($null,$mois_ref,$jour_ref)=split(/-/,$lastdate);
if ($mois_ref==6){$trimestre=0;}
if ($mois_ref==9){$trimestre=1;}
if ($mois_ref==12){$trimestre=2;}
if ($mois_ref==4){$trimestre=3;}
if (($action ne "")&&($trimestre==-1)&&($action ne "sendmail")){
	print " Erreur La date de fin doit être soit le dernier jour d'un trimestre soit le 14 avril";
	$action="";
}
# A VERIFIER 1 TRIMESTRE 2018
 
$four="1260";
$date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
@trimestre_tab=("15 Avril-Juin","Juillet-Septembre","Octobre-Decembre","Janvier-14 Avril");
if ($base eq "corsica"){
	@trimestre_tab=("Janvier-Juin","Juillet-Septembre","Octobre-Decembre","Janvier-Mars");
}
if ($an_ref>2017){
	@trimestre_tab=("Janvier-Mars","Avril-Juin","Juillet-Septembre","Octobre-Decembre","Janvier-Mars");
}


if ($action eq ""){
   print "<h3>Facture Backwall Distrimarq </h3>";
	$query="select distinct base,facture,trimestre from backwall where annee=$an_ref order by trimestre";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($base,$facture,$trimestre)=$sth->fetchrow_array){
		print "$base @trimestre_tab[$trimestre] $an_ref No de facture:$facture<br>";
	}
	print "<form>";
	&form_hidden();
	print "Doula <input type=radio name=base value=\"cameshop\" checked> Corse <input type=radio name=base value=\"corsica\" ><br>";
	print "<br> <br>Premiere date (incluse) <input id=\"datepicker\" type=text name=firstdate size=12 value='15/04/$an_ref'";
	print "<br> <br>Derniere date (incluse) <input id=\"datepicker2\" type=text name=lastdate size=12>";
	print "<input type=hidden name=action value=check>";
	
	print "<br><input type=submit>";
	print "</form>";
}	


if ($action eq "sendmail"){
	$mail=$html->param("mail");
	$mail=~s/@/\@/;
	$fichier=$html->param("fichier1");
	$facture=$html->param("facture");
	system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub3.pl $mail $fichier &");
	print "Mail envoyé<br>";
	&save("update dfc.facture_pub set date_mail=curdate()  where base='dfc' and mag='backwall $base' and fournisseur='$four' and no_facture='$facture'","af");
}

if ($action eq "check"){
	&save("create temporary table back_tmp (marque varchar(30),qte int(8),montant decimal(8,2), primary key (marque))"); 
	print uc($base);
	print " Du $firstdate au $lastdate  <br>";
	$query="select distinct enh_document from $base.enso,$base.enthead,$base.produit  where  es_dt>='$firstdate' and es_dt<='$lastdate' and es_type=10 and es_cd_pr=produit.pr_cd_pr  and pr_four=1260 and es_no_do=enh_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($enh_document)=$sth->fetchrow_array){
			$query="select marque,sum(livb_qte_fac),sum(livb_qte_fac*livb_prix) from dfc.livraison_b,$base.produit_desi where livb_id='$enh_document' and livb_code=code group by marque";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($marque,$qte,$montant)=$sth2->fetchrow_array){
				&save("insert ignore into back_tmp values ('$marque',0,0)");
				&save("update back_tmp set qte=qte+$qte,montant=montant+$montant where marque='$marque'");
			}
	}
    $query="select * from back_tmp";
	print "<table cellspacing=10 cellpadding=10 border=1><tr><th>Marque</th><th>Achat</th><th>8% sell-in</th>";
	if ($trimestre==3){print "<th>Mini</th>";}
	print "<th>Maxi</th><th>Facturé</th><th>A Facturer</th></tr>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($marque,$qte,$montant)=$sth->fetchrow_array){
		if ($qte==0){next;}
		$deja_sell=&get("select sum(montant) from backwall where base='$base' and annee='$an_ref' and marque='$marque'")+0;
		$mini=0;
		$maxi=0;
		$sell=round(8*$montant/100);
		$sell_reste=$sell-$deja_sell;
		if ($trimestre==3){
			$sell_run=$deja_sell+$sell_reste;
			if ($marque eq "CARON"){
				if ($sell_run<150){$sell_reste=150-$deja_sell;}
				$mini=150;
			}
			if ($marque eq "ESCADA"){
				if ($sell_run<120){$sell_reste=120-$deja_sell;}
				$mini=120;
			}
		}
		if ($marque eq "GUERLAIN"){
			if (($sell>3000)&&($deja_sell==3000)){$sell_reste=0;}
			if (($sell>3000)&&($deja_sell<3000)){$sell_reste=3000-$deja_sell;}
			$maxi=3000;
		}
		if ($marque eq "HERMES"){
			if (($sell>2500)&&($deja_sell==2500)){$sell_reste=0;}
			if (($sell>2500)&&($deja_sell<2500)){$sell_reste=2500-$deja_sell;}
			$maxi=2500;
		}
		print "<tr><td>$marque</td><td align=right>$montant</td><td td align=right>$sell</td>";
		if ($trimestre==3){print "<td>$mini</td>";}
		print "<td  align=right>$maxi</td><td  align=right>$deja_sell</td><td  align=right>$sell_reste</td>";
		print "</tr>";
		$total_montant+=$montant;
		$total_sell+=$sell_reste;
	}	
	print "<tr><td><strong>Total</td><td align=right>$total_montant</td><td colspan=3>&nbsp;</td><td align=right>$total_sell</td></tr>";
	print "</table>";
	$query="select facture,sum(montant) from backwall where base='$base' and annee='$an_ref' group by facture order by facture";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($facture,$montant)=$sth2->fetchrow_array){
		print "Déjà facturé :No $facture $montant €<br>";
	}	
	print "<form>";
	&form_hidden();
	print "<hr></hr><br>";
	print "Creer la facture<br>";
	print "<input type=hidden name=action value=facture>";
	print "<input type=hidden name=firstdate value='$firstdate'>";
	print "<input type=hidden name=lastdate value='$lastdate'>";
	print "<input type=hidden name=base value='$base'>";
	print "<input type=submit>";
	print "<br><br><input name=option>";
	print "</form>";
}


if ($action eq "facture"){ 
	$total=0;
	$total_gen=0;
	$index=0;
	$facture=&get("select max(no_facture) from dfc.facture_pub")+1;
	if ($option eq "re"){$facture=&get("select max(no_facture) from dfc.facture_pub");}
	&save("insert ignore into facture_pub values ('dfc','backwall $base','$four','@trimestre_tab[$trimestre]','$facture',curdate(),0,'','','','')");
 	&facture_suite();
	$tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("$client");
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$ligne-=5;

	&save("create temporary table back_tmp (marque varchar(30),qte int(8),montant decimal(8,2), primary key (marque))"); 
	$query="select distinct enh_document from $base.enso,$base.enthead,$base.produit  where  es_dt>='$firstdate' and es_dt<='$lastdate' and es_type=10 and es_cd_pr=produit.pr_cd_pr  and pr_four=1260 and es_no_do=enh_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($enh_document)=$sth->fetchrow_array){
			$query="select marque,sum(livb_qte_fac),sum(livb_qte_fac*livb_prix) from dfc.livraison_b,$base.produit_desi where livb_id='$enh_document' and livb_code=code group by marque";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($marque,$qte,$montant)=$sth2->fetchrow_array){
				&save("insert ignore into back_tmp values ('$marque',0,0)");
				&save("update back_tmp set qte=qte+$qte,montant=montant+$montant where marque='$marque'");
			}
	}
    $query="select * from back_tmp";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($marque,$qte,$montant)=$sth->fetchrow_array){
	  if ($qte==0){next;}
	  	$deja_sell=&get("select sum(montant) from backwall where base='$base' and annee='$an_ref' and marque='$marque'")+0;
		$mini=0;
		$maxi=0;
		$sell=round(8*$montant/100);
		$sell_reste=$sell-$deja_sell;
		if ($trimestre==3){
			$sell_run=$deja_sell+$sell_reste;
			if ($marque eq "CARON"){
				if ($sell_run<150){$sell_reste=150-$deja_sell;}
				$mini=150;
			}
			if ($marque eq "ESCADA"){
				if ($sell_run<120){$sell_reste=120-$deja_sell;}
				$mini=120;
			}
		}
		if ($marque eq "GUERLAIN"){
			if (($sell>3000)&&($deja_sell==3000)){$sell_reste=0;}
			if (($sell>3000)&&($deja_sell<3000)){$sell_reste=3000-$deja_sell;}
			$maxi=3000;
		}
		if ($marque eq "HERMES"){
			if (($sell>2500)&&($deja_sell==2500)){$sell_reste=0;}
			if (($sell>2500)&&($deja_sell<2500)){$sell_reste=2500-$deja_sell;}
			$maxi=2500;
		}
		$tete_text->font( $font{'Helvetica'}{'Roman'}, 8/pt );
		$tete_text->translate( 20/mm, $ligne/mm );
		$tete_text->text("$marque");
		$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
		$tete_text->translate( 90/mm, $ligne/mm );
		$tete_text->text("$montant");
		$tete_text->translate( 110/mm, $ligne/mm );
		$tete_text->text("$sell");
		if ($trimestre==3){
			$tete_text->translate( 130/mm, $ligne/mm );
			$tete_text->text("$mini");
		}
		$tete_text->translate( 150/mm, $ligne/mm );
		$tete_text->text("$maxi");
		$tete_text->translate( 170/mm, $ligne/mm );
		$tete_text->text("$deja_sell");
		$tete_text->translate( 190/mm, $ligne/mm );
		$tete_text->text("$sell_reste");
		$total_gen+=$total;
		$ligne-=5;
		$total_montant+=$montant;
		$total_sell+=$sell_reste;
		&save("replace into backwall values ('$base','$an_ref','$trimestre','$marque','$sell_reste','$facture')");
	
	}	
	&total();
	&save("update dfc.facture_pub set montant='$total_sell' where base='dfc' and mag='backwall $base' and fournisseur='$four' and no_facture='$facture'","af");
	$pdf->save();
	$fichier1=$fichier;
	print "Facture  <a href=http://dfc.oasix.fr/doc/$fichier><img src=/images/pdf.jpg height=30px /></a>";
	print "<form>";
	&form_hidden();
	print "Envoyer la facture à <input type=text name=mail value='$fo2_email' style=width:300px><br>";
	print "Copie à philippe.perraud5\@orange.fr et lamullecompta\@yahoo.fr<br>";
	print "<input type=hidden name=action value=sendmail>";
	print "<input type=hidden name=fichier1 value=$fichier>";
	print "<input type=hidden name=facture value=$facture>";
	print "<input type=hidden name=base value='$base'>";
	print "<input type=submit>";
	print "</form>";
}


sub total(){
	$ligne-=10;
	$query="select facture,sum(montant) from backwall where base='$base' and annee='$an_ref' group by facture order by facture";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($facture,$montant)=$sth2->fetchrow_array){
		$tete_text->translate( 80/mm, ($ligne)/mm );
		$tete_text->text("Déjà facturé:No ");
		$tete_text->translate( 140/mm, ($ligne)/mm );
		$tete_text->text("$facture $montant");
		$tete_text->text(" Eu");
		$ligne-=5;
	}	
	$tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
	$tete_text->translate( 100/mm, ($ligne-10)/mm );
	$tete_text->text("TOTAL :");
	$tete_text->translate( 180/mm, ($ligne-10)/mm );
	$tete_text->text("$total_sell");
	$tete_text->text(" Eu");
	$total=0;
}

sub facture_suite{
	$four=1260;
	if ($index==0){
		$total=0;
		$fichier="distrimarq_${facture}.pdf";
		&save("update dfc.facture_pub set pdf='$fichier' where base='dfc' and mag='backwall $base' and fournisseur='$four' and no_facture='$facture'","af");
  		$file="/var/www/dfc.oasix/doc/".$fichier;
		if (-f $file){unlink ($file);}
		$pdf = PDF::API2->new(-file => $file);
		%font = (
		Helvetica => {
		Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
		Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'latin1' ),
		Italic => $pdf->corefont( 'Helvetica-Oblique', -encoding => 'latin1' ),
		},
		Times => {
			Bold   => $pdf->corefont( 'Times-Bold',   -encoding => 'latin1' ),
			Roman  => $pdf->corefont( 'Times',        -encoding => 'latin1' ),
			Italic => $pdf->corefont( 'Times-Italic', -encoding => 'latin1' ),
		},
		);
	}	
	$nb=0;
	$page[$index] = $pdf->page();
	$page[$index]->mediabox('A4');
	$tete_text = $page[$index]->text;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$tete_text->fillcolor('navy');
	my $logo1 = $page[$index]->gfx;
	my $logo1_file = $pdf->image_png('./logoDFC.png');
	$logo1->image( $logo1_file, 20/mm, 260/mm, 113, 88 );
	$query="select * from fournis where fo2_cd_fo='$four'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville,$pays,$tva)=split(/\*/,$fo2_add);
	$ligne=250;
	$tete_text->translate( 110/mm, $ligne/mm );
	$tete_text->text("$nom");
	$ligne-=5;
	$tete_text->translate( 110/mm, $ligne/mm );
	$tete_text->text("$rue");
	$ligne-=5;
	$tete_text->translate( 110/mm, $ligne/mm );
	$tete_text->text("$ville");
	$ligne-=5;
	$tete_text->translate( 110/mm, $ligne/mm );
	$tete_text->text("$pays");
	$ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Bold'}, 14/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("FACTURE N° $facture ");
	$ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	if ($base eq "corsica"){
		$tete_text->text("Sellin Corse");
	}
	else {
		$tete_text->text("Sellin Douala");
	}
	# $tete_text->text("$tva");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Le:$date_du_jour");
	$ligne-=10;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Periode du $firstdate au $lastdate");
	$tete_text->fillcolor('navy');
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	
		$ligne=198;
		$tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
		$tete_text->translate( 20/mm, $ligne/mm );
		$tete_text->text("Marque");
		$tete_text->translate( 90/mm, $ligne/mm );
		$tete_text->text("Sell-in");
		$tete_text->translate( 110/mm, $ligne/mm );
		$tete_text->text("8% Sell-in");
		if ($trimestre==3){
			$tete_text->translate( 130/mm, $ligne/mm );
			$tete_text->text("Mini");
		}
		$tete_text->translate( 150/mm, $ligne/mm );
		$tete_text->text("Maxi");
		$tete_text->translate( 160/mm, $ligne/mm );
		$tete_text->text("Déjà Facturé");
		$tete_text->translate( 185/mm, $ligne/mm );
		$tete_text->text("Montant");
		
	
	$ligne=60;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Coordonnées bancaires");
	$ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Domiciliation:Bred Paris Opera Bic:BREDFRPPXXX Iban:FR76 1010 7001 7500 2150 4596 342");
	$ligne-=9;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Paiement à réception de facture");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("TVA payée sur les encaissements");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Tout litige ou contestation sont exclusivement du ressort du tribunal de commerce du siège de l'entreprise.");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Aucun mode de règlement ou mode de livraison ne peuvent modifier cette clause.");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("2 - Conformément à la loi du 12 mai 1980, nos produits restent notre propriété jusqu'à complet règlement.");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("3 - Le non-retour de ccette facture dans un délai de huit jours implique acceptation de cette facturation. Toute somme");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("non réglée à la date d'échéance donnera lieu à la perception d'une indemnité de retard au taux minimum de 1,3%.");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("DUTY FREE CONCEPT 1 passage du Grand Cerf 75002 PARIS");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("TVA intracommunautaire FR09 524 057 049 - RCS PARIS 524 057 049 00016");
	$tete_text->fillcolor('black');
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$ligne=195;
	&boite(15,203,200,65);
}
 


sub boite() {
	$a=$_[0];
	# x gauche
	$b=$_[1];
	# y haut
	$c=$_[2];
	# x droit
	$d=$_[3];
	# y bas
	# y bas
	my $line = $page[$index]->gfx;
	$line->strokecolor('black');

	# horizontale 
	$line->move( $a/mm, $b/mm );
	$line->line( $c/mm, $b/mm );
	$line->stroke;
	$line->move( $a/mm, $d/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;

	# verticale 	
	$line->move( $a/mm, $b/mm );
	$line->line( $a/mm, $d/mm );
	$line->stroke;
	$line->move( $c/mm, $b/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;
}

;1