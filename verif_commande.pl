#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use CGI;
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require "/var/www/cgi-bin/dfc.oasix/src/connect.src";
$html=new CGI;
print $html->header();
$sujet="Probleme sur les bons de livraisons";
$to="sylvainbrandicourt\@gmail";
#$cc="pp\@dutyfreeconcept.com,sylvainbrandicourt\@gmail.com,dg\@dutyfreeconcept.com";
my $html = <<"END_HTML";  
<span style=color:purple><strong>Anomalie sur les Bons de Livraison<br></strong></span>
END_HTML
$pass=0;
push(@bases_client,"corsica");
push(@bases_client,"cameshop");
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	$query="SELECT com_no,etat,blabla FROM $client.commande_info order by com_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com_no,$etat,$blabla)=$sth->fetchrow_array){
		$nb=0;
		$commande=&get("select count(*) from $client.commande where com2_no='$com_no'")+0;
		$commandearch=&get("select count(*) from $client.commandearch where com2_no='$com_no'","af")+0;
		if (($commande==0)&&($commandearch==0)&&($etat!=-1)){
			$html.="$client $com_no etat:$etat non trouve mais dans commande_info <br>";
			$pass=1;
		}
		elsif (($commande>0)&&($commandearch>0)){
			$html.= "$com_no $etat manquant";
			$liv=&get("select com2_no_liv from $client.commande where com2_no='$com_no'")+0;
			$liv_arch=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no'")+0;
			$html.= "no liv $liv no liv arch:$liv_arch<br>";
			$pass=1;
		}
		elsif (($commandearch>0)&&($etat<5)){
			$html.= "$com_no $etat pb etat ";
			$bl=&get("select com2_no_liv from $client.commandearch where com2_no='$com_no'");
			$entree=&get("select enh_no from $client.enthead where enh_document='$bl'");
			$html.= "no entree:$entree";
			$html.= "<br>";
			# &save("update $client.commande_info set etat=5 where com_no=$com_no","aff");
			$pass=1;
		}
		elsif (($commande>0)&&($etat==5)){
			$html.= "$com_no $etat pb etat<br>";
			$pass=1;
		}
	}
	$query="SELECT livh_id,livh_date,livh_facture from livraison_h where livh_base='$client' and livh_id>416 order by livh_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($liv_id,$livh_date,$livh_facture)=$sth->fetchrow_array){
		$check=&get("select datediff('2016-07-25','$livh_date')");
		if ($check>0){next;}
		$commande=&get("select count(*) from $client.commande where com2_no_liv='$liv_id'")+0;
		$commandearch=&get("select count(*) from $client.commandearch where com2_no_liv='$liv_id'","af")+0;
		if ($livh_facture eq ""){next;}
		if (($commande==0)&&($commandearch==0)){
			$html.="$client bl:$liv_id $livh_date commande inconnu <br>";
			$pass=1;
		}	
	}
	$query="select distinct(com2_no) from $client.commande where com2_no not in (select com_no from $client.commande_info)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no)=$sth->fetchrow_array){
		$html.="$client $com2_no introuvable dans commande_info<br>";
		$pass=1;
	}
	$query="select distinct com2_no,com2_cd_fo,com2_no_liv from $client.commande where com2_no_liv!=0 order by com2_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com_no_liv)=$sth->fetchrow_array){
		# if ($com2_no_liv <500){next;}
		$diff=&get("select datediff(curdate(),livh_date) from livraison_h where livh_id='$com_no_liv'"); 
		if ($diff<16){next;}
		$check=&get("select count(*) from livraison_x where livx_id='$com_no_liv'");
		if ($check>0){next;}
		$livh_user=&get("select livh_user from livraison_h where livh_id='$com_no_liv'"); 
		$livh_date=&get("select livh_date from livraison_h where livh_id='$com_no_liv'"); 
		$fo_add=&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo' ");
	    ($fo_nom)=split(/\*/,$fo_add);
		$html.="$client $com2_no bl:$com_no_liv $fo_nom cree par:$livh_user le $livh_date non rentre <br>";
		$pass=1;
	}
}
if ($pass){
	# $user="6192_infodfc";
	# $pass="5q6h5d";
	# my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
	# $smtp->auth( 'LOGIN', $user, $pass );
	# my $mime = MIME::Lite->new(
				# From       => 'info_dfc@dutyfreeconcept.com',
				# To         => "$to",
				# Cc         => "$cc",
				# Subject    => "$sujet",
				# "X-Mailer" => 'moncourriel.pl v2.0',
				# Type     => 'multipart/alternative',
	# );
	# my $att_html = MIME::Lite->new(  
	  # Type     => 'text',
	  # Data     => $html,  
	  # Encoding => 'quoted-printable', 
	# );  
	# $att_html->attr('content-type'   
	   # => 'text/html; charset=iso-8859-1');  
	# $mime->attach($att_html);  
	# $mime->send();
	print $html;
}

