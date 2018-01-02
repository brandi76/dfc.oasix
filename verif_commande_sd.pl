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
$cc="";
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
	$query="SELECT com_no,etat,blabla FROM $client.commande_info order by com_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com_no,$etat,$blabla)=$sth->fetchrow_array){
		$nb=0;
		$commande=&get("select count(*) from $client.commande where com2_no='$com_no'")+0;
		$commandearch=&get("select count(*) from $client.commandearch where com2_no='$com_no'","af")+0;
		if (($commande==0)&&($commandearch==0)&&($etat!=-1)){
			if ($pass==0){	$html.="<h3>$client</h3>";}
			$html.="Anomalie base de donnée:commande:$com_no etat:$etat absent de commande et commande_arch mais dans commande_info <br>";
			$pass=1;
		}
		elsif (($commande>0)&&($commandearch>0)){
			if ($pass==0){	$html.="<h3>$client</h3>";}
			$html.="Anomalie base de donnée:commande:$com_no etat:$etat à la fois dans commande et commande_arch<br>";
			$pass=1;
		}
		elsif (($commandearch>0)&&($etat<5)&&($etat!=-1)){
			if ($pass==0){	$html.="<h3>$client</h3>";}
			$html.= "Anomalie base de donnée:commande:$com_no etat:$etat  ";
			$bl=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no'");
			$entree=&get("select enh_no from $client.enthead where enh_document='$bl'");
			$html.= "no entree:$entree bl:<a href=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?onglet=1&sous_onglet=0&sous_sous_onglet=&action=voir&liv_id=$bl>$bl</a> commande non finalisée(etat) mais dans commande_arch";
			$html.= "<br>";
			$pass=1;
		}
		elsif (($commande>0)&&($etat==5)){
			if ($pass==0){	$html.="<h3>$client</h3>";}
			$html.= "Anomalie base de donnée:commande:$com_no etat:$etat  cette commande devrait être archivée<br>";
			$pass=1;
		}
	}
	$query="SELECT livh_id,livh_date,livh_facture from livraison_h where livh_base='$client' and livh_id>416 order by livh_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($liv_id,$livh_date,$livh_facture)=$sth->fetchrow_array){
		if ($liv_id==814){next;}
		$check=&get("select datediff('2016-07-25','$livh_date')");
		if ($check>0){next;}
		$commande=&get("select count(*) from $client.commande where com2_no_liv='$liv_id'")+0;
		$commandearch=&get("select count(*) from $client.commandearch where com2_no_liv='$liv_id'","af")+0;
		if (($commande==0)&&($commandearch==0)){
			if ($pass==0){	$html.="<h3>$client</h3>";}
			$html.="Anomalie base de donnée bl:<a href=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?onglet=1&sous_onglet=0&sous_sous_onglet=&action=voir&liv_id=$liv_id>$liv_id</a> $livh_date la commande n'est ni dans commande ni dans commande_arch <a href=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?onglet=1&sous_onglet=0&sous_sous_onglet=&action=sup&liv_id=$liv_id>sup</a><br>";
			$pass=1;
		}	
	}
	$query="select distinct(com2_no) from $client.commande where com2_no not in (select com_no from $client.commande_info)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no)=$sth->fetchrow_array){
		if ($pass==0){	$html.="<h3>$client</h3>";}
		$html.="Anomalie base de donnée commande:$com2_no introuvable dans commande_info alors qu'elle est dans commande<br>";
		$pass=1;
	}

}
=pod
$query="select livh_id,livh_four,datediff(curdate(),livh_date) from livraison_h where livh_base='corsica' and livh_id not in (select bl from facture_corse) order by livh_id";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_id,$livh_four,$age)=$sth->fetchrow_array){
	$local=&get("select fo2_identification from corsica.fournis where fo2_cd_fo='$livh_four'");
	if ($local){next;}
	$check=&get("select count(*) from corsica.enthead where enh_document='$livh_id'")+0;
	if (($check==0)&&($age>7)) {
		$html.="Corsica bl:$livh_id non entré <br>";
	}
	if ($check!=0) {
			$html.="Corsica bl:$livh_id non facturé (Dfc à Corsica) <br>";
	}
	$pass=1;
}	
=cut

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

