#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require "/var/www/cgi-bin/dfc.oasix/src/connect.src";

$sujet="Probleme sur les bons de livraisons";
#$to="il\@dutyfreeconcept.com";
$cc="pp\@dutyfreeconcept.com,dg\@dutyfreeconcept.com,il\@dutyfreeconcept.com";
$to="sylvainbrandicourt\@gmail.com";
my $html = <<"END_HTML";  
<span style=color:purple><strong>Anomalie sur les Bons de Livraison<br></strong></span>
END_HTML
$pass=0;
$mail=0;
push(@bases_client,"corsica");
push(@bases_client,"cameshop");

foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	if ($pass==1){$mail=1;}
	$pass=0;
	$query="select distinct com2_no,com2_cd_fo,com2_no_liv from $client.commande where com2_no_liv!=0 order by com2_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com_no_liv)=$sth->fetchrow_array){
		$diff=&get("select datediff(curdate(),livh_date) from livraison_h where livh_id='$com_no_liv'"); 
		if ($diff<16){next;}
		($livx_date,$info)=&get("select livx_date,livx_blabla from livraison_x where livx_id='$com_no_liv'","af");
		if ($info ne ""){next;}
		($livh_date,$livh_facture,$livh_date_reglement)=&get("select livh_date,livh_facture,livh_date_reglement from livraison_h where livh_id='$com_no_liv'"); 
		$fo_add=&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo' ");
	    ($fo_nom)=split(/\*/,$fo_add);
		if ($pass==0){	$html.="<h3>$client</h3>";}
		$html.="Commande:$com2_no bl:$com_no_liv $fo_nom cree le $livh_date non saisie en stock <br>";
		if (length($livh_facture)>2){
			$html.="Facture no:$livh_facture";
			if ($livh_date_reglement ne "0000-00-00"){$html.=" Réglée le :$livh_date_reglement<br>";}else{$html.=" Non Réglée<br>";}
		}else{$html.=" Pas de  no de facture saisie<br>";}
		$html.="<a href=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?onglet=1&sous_onglet=0&sous_sous_onglet=1&action=visu&com_no=$com2_no&client=$client><button>Voir les infos de la commande</button></a>" ;
		
		$html.="<hr></hr>";
		$pass=1;
	}
}

if ($mail){
	$user="6192_infodfc";
	$pass="5q6h5d";
	my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
	$smtp->auth( 'LOGIN', $user, $pass );
	my $mime = MIME::Lite->new(
				From       => 'info_dfc@dutyfreeconcept.com',
				To         => "$to",
				Cc         => "$cc",
				Subject    => "$sujet",
				"X-Mailer" => 'moncourriel.pl v2.0',
				Type     => 'multipart/alternative',
	);
	my $att_html = MIME::Lite->new(  
	  Type     => 'text',
	  Data     => $html,  
	  Encoding => 'quoted-printable', 
	);  
	$att_html->attr('content-type'   
	   => 'text/html; charset=iso-8859-1');  
	$mime->attach($att_html);  
	$mime->send();
}

