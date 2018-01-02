#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
use Spreadsheet::WriteExcel;
use JSON;
use Switch;
use PDF::API2;
use PDF::Reuse;

use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
use File::Copy;

$html=new CGI;
print $html->header();
$action=$html->param("action");
$mag=$html->param("mag");
$four=$html->param("four");
$base=$html->param("base");
$pdf=$html->param("pdf");
$new_facture=$html->param("new_facture");
$new_pdf=$html->param("new_pdf");
$montant=$html->param("montant");
$new_bis=$html->param("new_bis");


if ($action eq "valide"){
	$bon_pdf="pub_".$new_facture.$new_bis.".pdf";
	# print "/var/www/dfc.oasix/doc/$new_pdf /var/www/dfc.oasix/doc/$bon_pdf";
	move("/var/www/dfc.oasix/doc/$new_pdf","/var/www/dfc.oasix/doc/$bon_pdf") or die "move failed: $!";
	&save("update facture_pub set no_facture='$new_facture',pdf='$bon_pdf',montant='$montant',bis='$new_bis' where mag like '$mag' and base like '$base' and fournisseur='$four' and pdf='$pdf'","");
	$action="modif";
	$message="Mise à jour effectuée, vous pouvez fermer cette page et faire un rafraichissement de le page facture pub, pour voir les changements";
	$pdf=$bon_pdf;
	$groupement=&get("select groupement from dfc.facture_pub where no_facture='$new_facture' and pdf='$bon_pdf' and mag like '$mag' and base like '$base' and fournisseur='$four'");
	if ($groupement ne ""){
			prFile("../../dfc.oasix/doc/$groupement");
			$query="select pdf from dfc.facture_pub where groupement like '$groupement' and pdf!=''";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($pdf_sql)=$sth->fetchrow_array){
				prDoc("../../dfc.oasix/doc/$pdf_sql");
			}
			prEnd();
	}
}

if ($action eq "modifier"){
	$query="select * from dfc.facture_pub where no_facture='$new_facture'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($doublon_base,$doublon_mag,$doublon_fournisseur,$doublon_marque,$doublon_no_facture,$doublon_date,$doublon_montant,$doublon_pdf,$doublon_date_mail,$doublon_groupement,$doublon_bis)=$sth->fetchrow_array){
		if (($doublon_base ne $base)||($doublon_mag!=$mag)||($doublon_fournisseur!=$fournisseur)||($doublon_marque!=$marque)){
			$message="No facture $new_facture <b>$doublon_bis</b> déja existant pour $doublon_base $doublon_mag $doublon_fournisseur $doublon_marque";
			# $action="modif";
		}
	}
}

print <<EOF;
<html>
  <head>
    <link href="/css/bootstrap.min.css" rel="stylesheet" >
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
  </head>
  <body>
	<h4 class="alert alert-info">$message</h4>
    <div class="container">
		<div class="row">
			<div class="col-lg-12">
EOF
if (($action eq "modif")||($action eq "modifier")){
	$query="select cl_nom,cl_magazine from $base.client,$base.vol where cl_cd_cl=v_cd_cl limit 1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cl_nom,$cl_magazine)=$sth->fetchrow_array;

	$query="select * from dfc.facture_pub where mag like '$mag' and base like '$base' and fournisseur='$four' and pdf='$pdf'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$null,$null,$marque,$no_facture,$date,$montant,$null,$date_mail,$groupement,$bis)=$sth->fetchrow_array;
	# print "marque $marque<br>Facture $no_facture<br>Date $date<br>Montant $montant<br>Mail $date_mail<br>Groupement $groupement<br>";
	# print "<br>";
	if ($action eq "modifier"){
		$no_facture=$new_facture;
	}
	$query="select * from dfc.fournis where fo2_cd_fo='$four'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville,$pays,$tva)=split(/\*/,$fo2_add);
	print "<div style=margin-left:50%>";
	print "<h4>$nom</h4><h4>$rue</h4><h4>$ville</h4><h4>$pays</h4>";
	print "</div>";
	print "<h5>Le $date</h5>";
	if ($no_facture <100){$class="alert alert-danger";}
	print "<h4 class='$class'>Facture no:$no_facture${bis}</h4>";
	($null,$mag_red)=split(/_/,$mag);
	$mag_red=$mag;
	$mag_red=~s/\D//g; #astuce regex nom numerique
	$query="select * from $base.mag_info where mag='$mag'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$adresse,$debut,$fin,$null)=$sth->fetchrow_array;
	if (($debut ne '0000-00-00')&&($fin ne '0000-00-00')){$mag_red=$mag_red.=" $debut $fin";}
	print "<h5>Magazine:$cl_magazine N°:$mag_red Marque:$marque</h5>";
	if ($adresse ne ""){
		print "Lien web: <a href=http://issuu.com/renaut/docs/$adresse>http://issuu.com/renaut/docs/$adresse</a><br>";
	}
	######## MASTER ###########
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	# print "<tr class=\"success\"><th>Date Importation</th><th>Date Validitée</th><th>Nom</th><th>Fournisseur</th><th>Libelle</th><th>Action</th><th>Base</th></tr>";
	print "</thead>";
	
	$query = "select code,pr_desi,pr_four,visuel,pub,visuelprix,pubprix,desi_pub,cases,page from $base.mag,produit where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and marque='$marque' order by pr_four,marque,pr_desi";
	$sth=$dbh->prepare($query);
    $sth->execute();
	while (($code,$pr_desi,$pr_four,$visuel,$pub,$prix,$pubprix,$desi_pub,$cases,$page)=$sth->fetchrow_array){
		if ($prix <0){
				$prix=$prix*-1;
				$pr_desi="$pr_desi $prix Euros";
				$prix="Offert";
		}
		print "<tr><td>PACKSHOT $pr_desi</td><td>$prix</td></tr>";
		if ($prix ne "Offert"){	
			$total+=$prix;
		}
	}	
	print "</table>";
	print "<div style=margin-left:50%>";
	print "<table>";
	print "<tr><td>TOTAL HT:</td><td>$total Euros</td></tr>";
	print "<tr><td>TOTAL TVA:</td><td>0</td></tr>";
	$class="";
	if ($total==0){$class="alert alert-danger";}
	print "<tr ><td><span class='$class'> TOTAL TTC:</span></td><td >$total Euros</td></tr>";
	print "</table>";
	print "</div>";
	print "<form>";
	print "<input type=hidden name=mag value='$mag'>";
	print "<input type=hidden name=four value='$four'>";
	print "<input type=hidden name=base value='$base'>";
	print "<input type=hidden name=pdf value='$pdf'>";
	print "<input type=hidden name=action value=modifier>";
	print "Nouveau numero de facture <input type=text name=new_facture size=8 value='$no_facture'> Extension <input type=text name=new_bis size=1 value='$bis'> (mettre le même numero de facture pour avoir une version sous format excel)<br>";
	print "<button type=submit class=\"btn btn-info\">Modifier</button>"; 
	print "</form>";
	print "<br>Version actuelle <a href=http://dfc.oasix.fr/doc/$pdf><img src=/images/pdf.jpg /></a><br>";
	
	if ($action eq "modifier"){
		&create_excel();
		&create_pdf();
		print "<form>";
		print "<input type=hidden name=mag value='$mag'>";
		print "<input type=hidden name=four value='$four'>";
		print "<input type=hidden name=base value='$base'>";
		print "<input type=hidden name=pdf value='$pdf'>";
		print "<input type=hidden name=montant value='$montant'>";
		print "<input type=hidden name=new_facture value='$new_facture'>";
		print "<input type=hidden name=new_bis value='$new_bis'>";
		print "<input type=hidden name=new_pdf value='$fichier'>";
		print "<br>Version modifiée total:$montant (pour controle) <a href=http://dfc.oasix.fr/doc/$fichier><img src=/images/pdf.jpg /></a>";
		print "<input type=hidden name=action value=valide>";
		print "<button type=submit class=\"btn btn-danger\">Valider cette version</button>"; 
		print "<br>Version excel <a href=http://dfc.oasix.fr/doc/$fichier_excel><img src=/images/excel.gif /></a>";
		print "</form>";
	}

}

print "</div></div></div>";
print <<EOF;
<script type="text/javascript">
   \$('.form_date').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 2,
		minView: 2,
		forceParse: 0
    });
	\$('.form_time').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 1,
		minView: 0,
		maxView: 1,
		forceParse: 0
    });
</script>
</body>
EOF
print "</body>";

sub create_excel{
	$sous_total=0;
	$total=0;
	$en_cours=0;
	$date_du_jour=$date;
	$index=0;
	$query = "select code,pr_desi,pr_four,visuel,pub,visuelprix,pubprix,desi_pub,cases,page from $base.mag,produit where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and marque='$marque' order by pr_desi";
	$marqueindex=0;
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$first=0;
	$marque_tamp="null";
	$index=0;
	&facture_suite_excel();
	$ligne=11;
	while (($code,$pr_desi,$pr_four,$visuel,$pub,$prix,$pubprix,$null,$desi_pub)=$sth->fetchrow_array){
		if ($prix!=0){
			$nb++;
			$first=1;
			if ($prix <0){
				$prix=$prix*-1;
				$pr_desi="$pr_desi $prix Euros";
				$prix="Offert";
			}
			$sheet->write($ligne,1,"PACKSHOT $pr_desi");
			$sheet->write($ligne,4,"$prix");

			if ($prix ne "Offert"){
				$total+=$prix;
				$sous_total+=$prix;
			}
			$ligne++;
		}
		$prix=$html->param("pub$code");
		if ($prix!=0){
			if ($first==0){
				$marque_facture=$marque;
				$index=0;
				&facture_suite_excel();
			}
			$first=1;
			$nb++;
			if ($desi_pub eq ""){
				$desi_pub="PLEINE PAGE ".substr($pr_desi,0,25);
			}
			else {$desi_pub=$desi_pub." ".substr($pr_desi,0,25);}

			if ($prix <0){
				$prix=$prix*-1;
				$sheet->write($ligne,1,"$desi_pub $prix Euros");
				$prix="Offert";
			}
			else{
				$sheet->write($ligne,1,"$desi_pub");
			}
		}
		$sheet->write($ligne,4,"$prix");
		if ($prix ne "Offert"){
			$total+=$prix;
			$sous_total+=$prix;
		}
	}	
	&total_excel();
	$workbook->close();
}


sub facture_suite_excel{
	$sous_total=0;
	$total=0;
	$fichier_excel=&generate_random_string(8);
	$fichier_excel.=".xls";
	$file="/var/www/dfc.oasix/doc/".$fichier_excel;
	if (-f $file){unlink ($file);}
	$workbook = Spreadsheet::WriteExcel->new("../../dfc.oasix/doc/$fichier_excel");
	$sheet = $workbook->add_worksheet();
	$ligne=1;
	$col=1;
	$en_cours=1;
	$nb=0;
	$query="select * from dfc.fournis where fo2_cd_fo='$four'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville,$pays,$tva)=split(/\*/,$fo2_add);
	$col=3;
	$sheet->write($ligne,$col, "$nom");
	$ligne++;
	$sheet->write($ligne,$col, "$rue");
	$ligne++;
	$sheet->write($ligne,$col, "$ville");
	$ligne++;
	$sheet->write($ligne,$col, "$pays");
	$ligne++;
	$col=1;
	$sheet->write($ligne,$col, "FACTURE N° $no_facture $new_bis");
	$ligne++;
	$sheet->write($ligne,$col, "$tva");
	$ligne++;
	$sheet->write($ligne,$col, "Le:$date_du_jour");
	$ligne++;
	
	($null,$mag_red)=split(/_/,$mag);
	$mag_red=$mag;
	$mag_red=~s/\D//g; #astuce regex nom numerique
	$query="select * from $base.mag_info where mag='$mag'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$adresse,$debut,$fin,$null)=$sth->fetchrow_array;
	if (($debut ne '0000-00-00')&&($fin ne '0000-00-00')){$mag_red=$mag_red.=" $debut $fin";}
	if ($adresse ne ""){
		$sheet->write($ligne,$col,"Magazine:$cl_magazine N°:$mag_red Lien web: http://issuu.com/renaut/docs/$adresse");
	}
	else {
		$sheet->write($ligne,$col,"Magazine:$cl_magazine N°:$mag_red");
	}
	$ligne++;
	$sheet->write($ligne,$col,"Compagnie $cl_nom Marque $marque");
	$ligne=30;
	$sheet->write($ligne,$col, "Coordonnées bancaires");
	$ligne++;
	$sheet->write($ligne,$col, "Domiciliation:Bred Paris Opera Bic:BREDFRPPXXX Iban:FR76 1010 7001 7500 2150 4596 342");
	$ligne++;
	$sheet->write($ligne,$col,"Paiement à réception de facture");
	$ligne++;
	$sheet->write($ligne,$col, "TVA payée sur les encaissements");
	$ligne++;
	$sheet->write($ligne,$col,"Tout litige ou contestation sont exclusivement du ressort du tribunal de commerce du siège de l'entreprise.");
	$ligne++;
	$sheet->write($ligne,$col,"Aucun mode de règlement ou mode de livraison ne peuvent modifier cette clause.");
	$ligne++;
	$sheet->write($ligne,$col, "2 - Conformément à la loi du 12 mai 1980, nos produits restent notre propriété jusqu'à complet règlement.");
	$ligne++;
	$sheet->write($ligne,$col, "3 - Le non-retour de ccette facture dans un délai de huit jours implique acceptation de cette facturation. Toute somme");
	$ligne++;
	$sheet->write($ligne,$col, "non réglée à la date d'échéance donnera lieu à la perception d'une indemnité de retard au taux minimum de 1,3%.");
	$ligne++;
	$sheet->write($ligne,$col, "DUTY FREE CONCEPT 1 passage du Grand Cerf 75002 PARIS");
	$ligne++;
	$sheet->write($ligne,$col, "TVA intracommunautaire FR09 524 057 049 - RCS PARIS 524 057 049 00016");
}



sub create_pdf{  
  $sous_total=0;
  $total=0;
  $en_cours=0;
  $date_du_jour=$date;
  $index=0;
  $query = "select code,pr_desi,pr_four,visuel,pub,visuelprix,pubprix,desi_pub,cases,page from $base.mag,produit where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and marque='$marque' order by pr_desi";
  $marqueindex=0;
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  $first=0;
  $marque_tamp="null";
  while (($code,$pr_desi,$pr_four,$visuel,$pub,$prix,$pubprix,$marque_sql,$desi_pub)=$sth->fetchrow_array){
  	if ($prix!=0){
		$nb++;
		if ($first==0){
			$marque_facture=$marque;
			$index=0;
			&facture_suite();
		}
		$first=1;
		if ($prix <0){
			$prix=$prix*-1;
			$pr_desi="$pr_desi $prix Euros";
			$prix="Offert";
		}
		$tete_text->translate( 20/mm, $ligne/mm );
		$tete_text->text("PACKSHOT $pr_desi");
		$tete_text->translate( 150/mm, $ligne/mm );
		$tete_text->text("$prix");

		if ($prix ne "Offert"){
			$total+=$prix;
			$sous_total+=$prix;
			$tete_text->translate( 170/mm, $ligne/mm );
			$tete_text->text("Euros");
		}
		$ligne-=5;
    }
    $prix=$html->param("pub$code");
    if ($prix!=0){
		if ($first==0){
		$marque_facture=$marque;
		$index=0;
		&facture_suite();
	}
      $first=1;
      $nb++;
      if ($nb>21) {
	      $nb=0;
	      $tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
	      $tete_text->translate( 40/mm, $ligne/mm );
	      $tete_text->text("Suite .... ");
	      $index++;
	      &facture_suite();
      }
      $tete_text->translate( 20/mm, $ligne/mm );
      if ($desi_pub eq ""){
	  $desi_pub="PLEINE PAGE ".substr($pr_desi,0,25);
	}
      else {$desi_pub=$desi_pub." ".substr($pr_desi,0,25);}

      if ($prix <0){
	$prix=$prix*-1;
	$tete_text->text("$desi_pub $prix Euros");
	$prix="Offert";
      }
      else{
      	$tete_text->text("$desi_pub");
      }
      if ($prix >999){
      	$tete_text->translate( 146/mm, $ligne/mm );
      }
      else {
	if ($prix >100){
	  $tete_text->translate( 148/mm, $ligne/mm );
	}
	else {
	  $tete_text->translate( 150/mm, $ligne/mm );
	}
      }
      $tete_text->text("$prix");
      if ($prix ne "Offert"){
	$total+=$prix;
	$sous_total+=$prix;
	$tete_text->translate( 170/mm, $ligne/mm );
	$tete_text->text("Euros");
      }
      $ligne-=5;
    }
  }
  $marque=$marque_facture;
  &total();
  $pdf_file->save();

}


sub facture_suite{
	if ($index==0){
		$sous_total=0;
		$total=0;
		$fichier=&generate_random_string(8);
		$fichier.=".pdf";
		$file="/var/www/dfc.oasix/doc/".$fichier;
		if (-f $file){unlink ($file);}
		$pdf_file = PDF::API2->new(-file => $file);
		%font = (
		Helvetica => {
		Bold   => $pdf_file->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
		Roman  => $pdf_file->corefont( 'Helvetica',         -encoding => 'latin1' ),
		Italic => $pdf_file->corefont( 'Helvetica-Oblique', -encoding => 'latin1' ),
		},
		Times => {
		Bold   => $pdf_file->corefont( 'Times-Bold',   -encoding => 'latin1' ),
		Roman  => $pdf_file->corefont( 'Times',        -encoding => 'latin1' ),
		Italic => $pdf_file->corefont( 'Times-Italic', -encoding => 'latin1' ),
		},
		);
		$en_cours=1;
	}  
	$nb=0;
	$page[$index] = $pdf_file->page();
	$page[$index]->mediabox('A4');
	$tete_text = $page[$index]->text;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$tete_text->fillcolor('navy');

	my $logo1 = $page[$index]->gfx;
	my $logo1_file = $pdf_file->image_png('./logoDFC.png');
	$logo1->image( $logo1_file, 20/mm, 260/mm, 113, 88 );

	$query="select * from dfc.fournis where fo2_cd_fo='$four'";
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
	# $ligne-=5;
	# $tete_text->translate( 110/mm, $ligne/mm );
	# $tete_text->text("$tva");
	$ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Bold'}, 14/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("FACTURE N° $no_facture${new_bis}");
	$ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("$tva");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Le:$date_du_jour");
	$ligne-=10;
	$tete_text->translate( 20/mm, $ligne/mm );
	($null,$mag_red)=split(/_/,$mag);
	$mag_red=$mag;
	$mag_red=~s/\D//g; #astuce regex nom numerique

	$query="select * from $base.mag_info where mag='$mag'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$adresse,$debut,$fin,$null)=$sth->fetchrow_array;
	if (($debut ne '0000-00-00')&&($fin ne '0000-00-00')){$mag_red=$mag_red.=" $debut $fin";}
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	if ($adresse ne ""){
		$tete_text->text("Magazine:$cl_magazine N°:$mag_red Lien web: http://issuu.com/renaut/docs/$adresse");
	}
	else {
		$tete_text->text("Magazine:$cl_magazine N°:$mag_red");
	}
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Compagnie $cl_nom");
	$tete_text->translate( 100/mm, $ligne/mm );
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
 

sub place{
  $page= &get("select page from $base.mag where mag='$mag' and cases='$cases' and code='$code'","af");
  $position= &get("select count(*) from $base.mag where mag='$mag' and page='$page' and cases<='$cases'");
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
sub total(){
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$tete_text->translate( 100/mm, ($ligne-10)/mm );
	$tete_text->text("TOTAL HT:");
	$tete_text->translate( 148/mm, ($ligne-10)/mm );
	$tete_text->text("$total");
	$tete_text->translate( 170/mm, ($ligne-10)/mm );
	$tete_text->text("Euros");

	$tete_text->translate( 100/mm, ($ligne-15)/mm );
	$tete_text->text("TVA:");
	$tete_text->translate( 155/mm, ($ligne-15)/mm );
	$tete_text->text("0");
	$tete_text->translate( 170/mm, ($ligne-15)/mm );
	$tete_text->text("Euros");

	$tete_text->translate( 100/mm, ($ligne-20)/mm );
	$tete_text->text("TOTAL TTC:");
	$tete_text->translate( 148/mm, ($ligne-20)/mm );
	$tete_text->text("$total");
	$tete_text->translate( 170/mm, ($ligne-20)/mm );
	$tete_text->text("Euros");
	# &save("update dfc.facture_pub set montant='$total' where base='$base_dbh' and mag='$mag' and fournisseur='$four' and marque like '$marque_facture'","af");
	$total=0;
	$facture++;
}
sub total_excel(){
	$sheet->write($ligne,2,"TOTAL HT:");
	$sheet->write($ligne,3,"$total");
	$ligne++;
	$sheet->write($ligne,2,"TVA:");
	$sheet->write($ligne,3,"0");
	$ligne++;
	$sheet->write($ligne,2,"TOTAL TTC:");
	$sheet->write($ligne,3,"$total");
	$total=0;
	$facture++;
}

