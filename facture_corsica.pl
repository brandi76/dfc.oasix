#!/usr/bin/perl
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
use DBI();
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
use CGI;
$html=new CGI;
use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
use File::Copy qw(copy);
use String::Similarity;
use LWP::UserAgent;
use PDF::Reuse;

print $html->header();
$action=$html->param("action");
$facture=$html->param("facture");
$date=$html->param("date");
$bl=$html->param("bl");

if ($action eq ""){
print "<form>";
print "Numero de facture <input name=facture><br>";
print "Numero de bl <input name=bl><br>";
print "Date <input name=date><br>";
print "<input type=submit name=action value=go></form>";
}

if ($action eq "go") {
	$check =&get("select livb_code,pr_desi,livb_qte_liv,livb_prix from livraison_b,corsica.produit where livb_id='$bl' and livb_code=pr_cd_pr")+0;
	if ($check==0){print "Ancun produit pour votr demande";}
	else {&create_pdf();}
}	

sub create_pdf{  
	$sous_total=0;
	$total=0;
	$en_cours=0;
	# $date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
	$date_du_jour=$date;
	$index=0;
	$four=&get("select livh_four from livraison_h where livh_id='$bl'");
	$query = "select livb_code,pr_desi,livb_qte_liv,livb_prix from livraison_b,corsica.produit where livb_id='$bl' and livb_code=pr_cd_pr";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$first=0;
	$marque_tamp="null";
	while (($code,$pr_desi,$qte,$prix)=$sth->fetchrow_array){
		$prix+=$prix*3/100;
		$prix=int($prix*100)/100;
		if ($first==0){
			$index=0;
		
			&facture_suite();
		}
		$first=1;
		$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
		$tete_text->translate( 20/mm, $ligne/mm );
		$tete_text->text("$pr_desi");
		$tete_text->translate( 140/mm, $ligne/mm );
		$tete_text->text("$qte");
		$tete_text->translate( 155/mm, $ligne/mm );
		$tete_text->text("$prix");
		$montant=$prix*$qte;
		$tete_text->translate( 170/mm, $ligne/mm );
		$tete_text->text("$montant");
		$tete_text->translate( 185/mm, $ligne/mm );
		$tete_text->text("Euros");
		$total+=$montant;
	   $ligne-=5;
		$nb++;
		if ($nb>21) {
		  $nb=0;
		  $tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
		  $tete_text->translate( 40/mm, $ligne/mm );
		  $tete_text->text("Suite .... ");
		  $index++;
		  &facture_suite();
		}
	}
	$tete_text->translate( 20/mm, $ligne/mm );
	&total();
	$pdf->save();
	print "<a href=http://dfc.oasix.fr/doc/$fichier><img src=/images/pdf.jpg /></a>";
}

sub facture_suite{
  if ($index==0){
    $sous_total=0;
    $total=0;
    $fichier="corsica_${facture}";
    $fichier.=".pdf";
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
    $en_cours=1;
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
  ($nom,$rue,$ville)=split(/\*/,$fo2_add);
  $nom="Corsica Duty Free";
  $rue="";
  $ville=" BIGUGLIA";
  $ligne=245;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$nom");
  $ligne-=5;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$rue");
  $ligne-=5;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$ville");
  $ligne-=10;
  $tete_text->font( $font{'Helvetica'}{'Bold'}, 14/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("FACTURE N° $facture");
  $ligne-=5;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Le:$date_du_jour");
  $ligne-=10;
  $tete_text->translate( 20/mm, $ligne/mm );
  ($null,$mag_red)=split(/_/,$mag);
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
sub total(){
 $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 100/mm, ($ligne-10)/mm );
  $tete_text->text("TOTAL HT:");
  $tete_text->translate( 148/mm, ($ligne-10)/mm );
  $tete_text->text("$total");
  $tete_text->translate( 170/mm, ($ligne-10)/mm );
  $tete_text->text("Euros");
  $tva=int($total*20)/100;
  $tete_text->translate( 100/mm, ($ligne-15)/mm );
  $tete_text->text("TVA 20%:");
  $tete_text->translate( 148/mm, ($ligne-15)/mm );
  $tete_text->text("$tva");
  $tete_text->translate( 170/mm, ($ligne-15)/mm );
  $tete_text->text("Euros");
  $total_tva=$total+$tva;
  $tete_text->translate( 100/mm, ($ligne-20)/mm );
  $tete_text->text("TOTAL TTC:");
  $tete_text->translate( 148/mm, ($ligne-20)/mm );
  $tete_text->text("$total_tva");
  $tete_text->translate( 170/mm, ($ligne-20)/mm );
  $tete_text->text("Euros");
#   $total_fo+=$total;
#   if ($sous_tot==1){$tot{"$marque_facture"}=$total;
#   }
  $total=0;
  $facture++;

}
