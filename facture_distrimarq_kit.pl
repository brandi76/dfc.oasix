use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
use LWP::UserAgent;
@base_client=("camairco","togo","aircotedivoire","tacv");
$action=$html->param("action");
$facture=$html->param("facture");
$fichier=$html->param("fichier");
$date=$html->param("date");
$bl=$html->param("bl");
$firstdate=$html->param("firstdate");
$lastdate=$html->param("lastdate");
if (grep(/\//,$firstdate)) {
	($jj,$mm,$aa)=split(/\//,$firstdate);
	$firstdate=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$lastdate)) {
	($jj,$mm,$aa)=split(/\//,$lastdate);
	$lastdate=$aa."-".$mm."-".$jj;
}
$four="1260";
$date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
	
if ($action eq ""){
	print "<h3>Facture Pub Distrimarq Aerien</h3>";
	print "<form>";
	&form_hidden();
	print "<br> <br>Premiere date (incluse) <input id=\"datepicker\" type=text name=firstdate size=12>";
	print "<br> <br>Derniere date (incluse) <input id=\"datepicker2\" type=text name=lastdate size=12>";
	print "<input type=hidden name=action value=check>";
	print "<input type=submit>";
	print "</form>";
}	


if ($action eq "sendmail"){
	$mail=$html->param("mail");
	$mail=~s/@/\@/;
	$fichier1=$html->param("fichier1");
	$fichier2=$html->param("fichier2");
	$facture=$html->param("facture");
	system("/var/www/cgi-bin/dfc.oasix/sendpdf_pub2.pl $mail $fichier1 $fichier2 &");
	print "Mail envoyé<br>";
	$facture--;
	&save("update dfc.facture_pub set date_mail=curdate() where base='dfc' and mag='pub cosmetique $date_du_jour' and fournisseur='$four' and no_facture='$facture'");
	$facture++;
	&save("update dfc.facture_pub set date_mail=curdate() where base='dfc' and mag='pub cosmetique $date_du_jour' and fournisseur='$four' and no_facture='$facture'");
}

if ($action eq "check"){
	print "Du date:$firstdate au date:$lastdate<br>";
	print "<h2>Facture 1 Guerlain</h2>";
	foreach $client (@base_client){
		print "<h4>$client</h4>";
		$query="select pr_cd_pr,pr_desi,pr_prac from $client.produit,dfc.produit_desi where marque='GUERLAIN' and code=pr_cd_pr and pr_douane!='33030090' and pr_douane!='33030010'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "<table border=1 cellspacing=20>";
		while (($code,$pr_desi,$pr_prac)=$sth->fetchrow_array){
			$pr_prac/=100;
			$vendu=&get("select sum(ro_qte)/100 from $client.rotation,$client.vol where ro_cd_pr='$code' and ro_code=v_code and v_rot=1 and v_date_sql>='$firstdate' and v_date_sql<='$lastdate'","af")+0;
			if ($vendu==0){next;}
			$total=$pr_prac*$vendu;
			$total_gen+=$total;
			print "<td><td>$code</td><td>$pr_desi</td><td align=right>$pr_prac</td><td align=right>$vendu</td><td align=right>$total</td></tr>";
		}
		print "</table>";
		
	}
	print "Total:$total_gen €<br>";
	$cinq=int($total_gen*5)/100;
	print "5%:$cinq €<br><br>";

	$total_gen=0;	
	print "<h2>facture 2 Black_up</h2>";
	@base_client=("camairco","togo","aircotedivoire","tacv");
	foreach $client (@base_client){
		print "<h4>$client</h4>";
		$query="select pr_cd_pr,pr_desi,pr_prac from $client.produit,dfc.produit_desi where marque='BLACK UP' and code=pr_cd_pr and pr_douane!='33030090' and pr_douane!='33030010'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "<table border=1 cellpadding=10>";
		while (($code,$pr_desi,$pr_prac)=$sth->fetchrow_array){
			$pr_prac/=100;
			$vendu=&get("select sum(ro_qte)/100 from $client.rotation,$client.vol where ro_cd_pr='$code' and ro_code=v_code and v_rot=1 and v_date_sql>='$firstdate' and v_date_sql<='$lastdate'")+0;
			if ($vendu==0){next;}
			$total=$pr_prac*$vendu;
			$total_gen+=$total;
			print "<td><td>$code</td><td>$pr_desi</td><td align=right>$pr_prac</td><td align=right>$vendu</td><td align=right>$total</td></tr>";
		}
		print "</table>";
	}
	print "Total:$total_gen €<br>";
	$cinq=int($total_gen*5)/100;
	print "5%:$cinq €<br>";
	print "<form>";
	&form_hidden();
	print "<hr></hr><br>";
	print "Creer les factures<br>";
	print "<input type=hidden name=action value=facture>";
	print "<input type=hidden name=firstdate value='$firstdate'>";
	print "<input type=hidden name=lastdate value='$lastdate'>";
	print "<input type=submit>";
	print "</form>";
}


if ($action eq "facture"){ 
	$total=0;
	$total_gen=0;
	$index=0;
	$marque="Guerlain";
	$facture=&get("select max(no_facture) from dfc.facture_pub")+1;
	&save("insert ignore into facture_pub values ('dfc','pub cosmetique $date_du_jour','$four','$marque','$facture',curdate(),0,'','','','')");
 
	&facture_suite();
	foreach $client (@base_client){
		$tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
		$tete_text->translate( 20/mm, $ligne/mm );
		$tete_text->text("$client");
		$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
 		$ligne-=5;
		$query="select pr_cd_pr,pr_desi,pr_prac from $client.produit,dfc.produit_desi where marque='GUERLAIN' and code=pr_cd_pr and pr_douane!='33030090' and pr_douane!='33030010'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($code,$pr_desi,$pr_prac)=$sth->fetchrow_array){
			$pr_prac/=100;
			$vendu=&get("select sum(ro_qte)/100 from $client.rotation,$client.vol where ro_cd_pr='$code' and ro_code=v_code and v_rot=1 and v_date_sql>='$firstdate' and v_date_sql<='$lastdate'","af")+0;
			if ($vendu==0){next;}
			$nb++;
			$total=$pr_prac*$vendu;
			$total_gen+=$total;
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 8/pt );
 			$tete_text->translate( 20/mm, $ligne/mm );
			$tete_text->text("$pr_cd_pr $pr_desi");
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
 			$tete_text->translate( 140/mm, $ligne/mm );
			$tete_text->text("$vendu");
			$tete_text->translate( 150/mm, $ligne/mm );
			$tete_text->text("$pr_prac");
			$total=$pr_prac*$vendu;
			$tete_text->translate( 170/mm, $ligne/mm );
			$tete_text->text("$total Euros");
			$total_gen+=$total;
			$ligne-=5;
			if ($nb>21) {
				  $nb=0;
				  $tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
				  $tete_text->translate( 40/mm, $ligne/mm );
				  $tete_text->text("Suite .... ");
				  $index++;
				  &facture_suite();
			}
		}
	}
	&total();
	&save("update dfc.facture_pub set montant='$cinq' where base='dfc' and mag='pub cosmetique $date_du_jour' and fournisseur='$four' and marque like '$marque'","af");
	$pdf->save();
	$fichier1=$fichier;
	print "Guerlain <a href=http://dfc.oasix.fr/doc/$fichier><img src=/images/pdf.jpg height=30px /></a>";
	$total=0;
	$total_gen=0;
	$index=0;
	$marque="Blackup";
	$facture=&get("select max(no_facture) from dfc.facture_pub")+1;
	&save("insert ignore into facture_pub values ('dfc','pub cosmetique $date_du_jour','$four','$marque','$facture',curdate(),0,'','','','')");
	&facture_suite();
	foreach $client (@base_client){
		$tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
		$tete_text->translate( 20/mm, $ligne/mm );
		$tete_text->text("$client");
		$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
 		$ligne-=5;
		$query="select pr_cd_pr,pr_desi,pr_prac from $client.produit,dfc.produit_desi where marque='BLACK UP' and code=pr_cd_pr and pr_douane!='33030090' and pr_douane!='33030010'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($code,$pr_desi,$pr_prac)=$sth->fetchrow_array){
			$pr_prac/=100;
			$vendu=&get("select sum(ro_qte)/100 from $client.rotation,$client.vol where ro_cd_pr='$code' and ro_code=v_code and v_rot=1 and v_date_sql>='$firstdate' and v_date_sql<='$lastdate'","af")+0;
			if ($vendu==0){next;}
			$nb++;
			$total=$pr_prac*$vendu;
			$total_gen+=$total;
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 8/pt );
 			$tete_text->translate( 20/mm, $ligne/mm );
			$tete_text->text("$pr_cd_pr $pr_desi");
			$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
 			$tete_text->translate( 140/mm, $ligne/mm );
			$tete_text->text("$vendu");
			$tete_text->translate( 150/mm, $ligne/mm );
			$tete_text->text("$pr_prac");
			$total=$pr_prac*$vendu;
			$tete_text->translate( 170/mm, $ligne/mm );
			$tete_text->text("$total Euros");
			$total_gen+=$total;
			$ligne-=5;
			if ($nb>21) {
				  $nb=0;
				  $tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
				  $tete_text->translate( 40/mm, $ligne/mm );
				  $tete_text->text("Suite .... ");
				  $index++;
				  &facture_suite();
			}
		}
	}
	&total();
	&save("update dfc.facture_pub set montant='$cinq' where base='dfc' and mag='pub cosmetique $date_du_jour' and fournisseur='$four' and marque like '$marque'","af");
	$pdf->save();
	$fichier2=$fichier;
	print "Black_up <a href=http://dfc.oasix.fr/doc/$fichier><img src=/images/pdf.jpg height=30px /></a>";
	print "<form>";
	&form_hidden();
	print "Envoyer les factures à <input type=text name=mail value='$fo2_email' style=width:200px><br>";
	print "Copie à philippe.perraud5@orange.fr<br>";
	print "<input type=hidden name=action value=sendmail>";
	print "<input type=hidden name=fichier1 value=$fichier1>";
	print "<input type=hidden name=fichier2 value=$fichier2>";
	print "<input type=hidden name=facture value=$facture>";
	print "<input type=submit>";
	print "</form>";
}


sub total(){
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 100/mm, ($ligne-10)/mm );
  $tete_text->text("TOTAL :");
  $tete_text->translate( 148/mm, ($ligne-10)/mm );
  $tete_text->text("$total_gen");
  $tete_text->translate( 170/mm, ($ligne-10)/mm );
  $tete_text->text("Euros");
  $tete_text->translate( 100/mm, ($ligne-15)/mm );
  $tete_text->text("5%:");
  $cinq=int($total_gen*5)/100;
  $tete_text->translate( 148/mm, ($ligne-15)/mm );
  $tete_text->text($cinq);
  $tete_text->translate( 170/mm, ($ligne-15)/mm );
  $tete_text->text("Euros");
  &save("update dfc.facture_pub set montant='$total' where base='dfc' and mag='pub cosmetique $date_du_jour' and fournisseur='$four' and no_facture='$facture'","af");
  $total=0;
}

sub facture_suite{
	if ($index==0){
		$total=0;
		$fichier="${marque}_${facture}.pdf";
		&save("update dfc.facture_pub set pdf='$fichier' where base='dfc' and mag='pub cosmetique $date_du_jour' and fournisseur='$four' and no_facture='$facture'","af");
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
	$tete_text->text("FACTURE N° $facture");
	$ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("$tva");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Le:$date_du_jour");
	$ligne-=10;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Periode du $firstdate au $lastdate");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Marque $marque");
	$tete_text->fillcolor('navy');
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
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