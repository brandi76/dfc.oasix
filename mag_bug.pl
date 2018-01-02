#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
# require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;

$action=$html->param('action');

require "./src/connect.src";

use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
# use OpenOffice::OOCBuilder;
 use Spreadsheet::WriteExcel;

use File::Copy qw(copy);
# use Text::Levenshtein qw(distance);
use String::Similarity;
use LWP::UserAgent;
use PDF::Reuse;

$mag=$html->param("mag");	
$code=$html->param("code");	
$code_pub=$html->param("code_pub");	
$cases=$html->param("cases");	
$page=$html->param("page");
$info=$html->param("info");
$contact=$html->param("contact");
$prix=$html->param("prix");
$prix_xof=$html->param("prix_xof");
$desi=$html->param("desi");
$action_prev=$html->param("action_prev");	
$option=$html->param("option");	
$four=$html->param("four");
$focus=$html->param("focus");
$sous_tot=$html->param("sous_tot");
$sendpdf=$html->param("sendpdf");

# $mag_texte=$html->param("mag_texte");
 
#  print "<div style=background-color:pink> Developpement en cours ne pas utiliser</div>"; 
$desi=~s/'/ /g;
$info=~s/'/ /g;
$contact=~s/'/ /g;

$query="select cl_nom,cl_magazine from client where cl_cd_cl='$base_client_code'";
$sth=$dbh->prepare($query);
$sth->execute();
($cl_nom,$cl_magazine)=$sth->fetchrow_array;
	
$pub=$new;$texte=$visuel=0;
if ($html->param("pub") eq "on"){$pub=1;$pubcheck="checked";}
if ($html->param("new") eq "on"){$new=1;$newcheck="checked";}
if ($html->param("texte") eq "on"){$texte=1;$textecheck="checked";}
if ($html->param("visuel") eq "on"){$visuel=1;$visuelcheck="checked";}
if ($html->param("presentation") eq "on"){$visuel=-1;$presentationcheck="checked";}
$visuelprix=$html->param("visuelprix");
$pubprix=$html->param("pubprix");
$desi_pub=$html->param("desi_pub");
$desi_pub=~s/'/ /g;
$marque=$html->param("marque");
$marque=~s/'/ /g;
@liste_fragrance=("EDT","EDP","eau de cologne","parfum","eau fraiche","soie de parfum","eau tonique","coffret");
&cree_produit_tmp();
$query="select * from facture_pub where marque='VERSACE'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($base,$mag,$four,$marque,$facture_mag,$date_mag,$montant_mag)=$sth->fetchrow_array){
	$four=12630;
	&create_pdf();
}	

sub create_pdf{  
	$sous_total=0;
	$total=0;
	$en_cours=0;
	#   $fichier=&get("select fichier from dfc.facture_pub where base='$base' and mag='$mag' and fournisseur='$four' and marque like '$marque'");
	$date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
	$date_du_jour=$date_mag;
	$index=0;
	$query = "select code,pr_desi,visuel,pub,visuelprix,pubprix,marque,desi_pub from $base.mag,produit_tmp where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and pr_four='$four' and marque='VERSACE' order by pr_desi";
	$marqueindex=0;
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	$first=0;
	$marque_tamp="null";
	$ok=0;
	while (($code,$pr_desi,$visuel,$pub,$prix,$pubprix,$marque,$desi_pub)=$sth->fetchrow_array){
		$ok=1;
		if ($marque_tamp eq "null"){$marque_tamp=$marque;}
		if ($marque ne $marque_tamp){$marqueindex++;$marque_tamp=$marque;}
		$ref="afac_".$four."_".$marqueindex;
		if (($sous_tot==1)&&($html->param("$ref") ne "on")){next;}
		if ($prix!=0){
			$nb++;
			if ($first==0){
				$marque_facture=$marque;
				$index=0;
				&facture_suite();
			}	
			$first=1;
		#       print "*$marque*$marque_facture*$sous_tot*<br>"; 
		  
			if (($sous_tot==1)&&($marque ne $marque_facture)) {
				$nb=0;
				#print "la $marque_facture $marque-";
				&total();
				$index=0;
				$marque_facture=$marque;
				&facture_suite();
			}
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
		$prix=$pubprix;
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
	if ($ok){
		&total();
		$pdf->save();
		print "$base $mag $facture_mag $montant_mag*$total_bug<a href=http://dfc.oasix.fr/doc/fac2_${facture_mag}.pdf>file</a><br>";
	}
}

sub facture_suite{
  if (($index==0)&&($en_cours==0)){
    $debut=$facture;
  }  
  if (($index==0)&&($en_cours==1)){
    $pdf->save();
  }
  if ($index==0){
    $sous_total=0;
    $total=0;
    # $fichier=&get("select pdf from dfc.facture_pub where base='$base_dbh' and mag='$mag' and fournisseur='$four' and marque like '$marque'","af");
    $file="/var/www/dfc.oasix/doc/fac2_${facture_mag}.pdf";
      
   if ($fichier ne ""){
      # $file="/var/www/dfc.oasix/doc/".$fichier;
      # &save("update dfc.facture_pub set date=curdate() where base='$base_dbh' and mag='$mag' and fournisseur='$four' and marque like '$marque'","af");
      # if (-f $file){unlink ($file);}
    }
    else
    {
      # $fichier=&generate_random_string(8);
      # $fichier.=".pdf";
      # &save("replace into dfc.facture_pub values ('$base_dbh','$mag','$four','$marque','0',curdate(),'0','$fichier','','')","af");
      # $file="/var/www/dfc.oasix/doc/".$fichier;
    } 
    if ($controle eq "facture"){
      # $file="/var/www/dfc.oasix/doc/pub_".$facture.".pdf";
      # &save("replace into  dfc.facture_pub values ('$base_dbh','$mag','$four','$marque','$facture',curdate(),'0','pub_$facture.pdf','','')","af");
     }
    if (-f $file){unlink ($file);}
    $pdf = PDF::API2->new(-file => $file);
      # $page->cropbox  (7.5/mm, 7.5/mm, 97.5/mm, 140.5/mm);
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
  
  $query="select * from fournis where fo2_cd_fo=12630";
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  ($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
  ($nom,$rue,$ville)=split(/\*/,$fo2_add);
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
  $tete_text->text("FACTURE N° $facture_mag");
  $ligne-=5;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Le:$date_du_jour");
  $ligne-=10;
  $tete_text->translate( 20/mm, $ligne/mm );
  ($null,$mag_red)=split(/_/,$mag);
  $mag_red=$mag;
  $mag_red=~s/\D//g; #astuce regex nom numerique
  # $adresse=&get("select adresse from mag_info where mag='$mag'");
  # if ($adresse ne ""){
    # $tete_text->text("Magazine:$magazine N°:$mag_red Lien web: http://issuu.com/renaut/docs/$adresse");
  # }
  # else {
     $tete_text->text("Magazine:$mag");
  # }
  
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Compagnie $base");
  if ($sous_tot==1){
    $tete_text->translate( 100/mm, $ligne/mm );
    $tete_text->text("Marque $marque");
  }  
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
  $page= &get("select page from mag where mag='$mag' and cases='$cases' and code='$code'","af");
  $position= &get("select count(*) from mag where mag='$mag' and page='$page' and cases<='$cases'");
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
  $total_bug=$total;
  $total=0;
  $facture++;
}

sub cree_produit_tmp(){
 if ($pass_cree_produit_tmp != 1){
  &save("create temporary table produit_tmp (pr_cd_pr int(12),pr_desi varchar(40),pr_four int(10), primary key (pr_cd_pr))"); 
  &save("insert into produit_tmp select pr_cd_pr,pr_desi,pr_four from produit");
  &save("update produit_tmp,produit_plus set pr_four=pr_four_pub where produit_tmp.pr_cd_pr=produit_plus.pr_cd_pr and pr_four_pub!=0");
 }
 $pass_cree_produit_tmp=1;
}
;1 

