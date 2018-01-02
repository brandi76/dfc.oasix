#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require "/var/www/cgi-bin/dfc.oasix/src/connect.src";

$code=$ARGV[0];
$prix_avant=$ARGV[1];
$prix_apres=$ARGV[2];
$base=$ARGV[3];
$prix_apres+=0;
if ($prix_apres==0){$prix_apres=0.1;}
$sujet="Changement de prix suite livraison";
$to="il\@dutyfreeconcept.com";
$cc="pp\@dutyfreeconcept.com,sylvainbrandicourt\@gmail.com";
# $to="sylvainbrandicourt\@gmail.com";
# $cc="sb\@dutyfreeconcept.com";

$desi=&get("select designation1 from produit_master,produit_inode where produit_master.inode=produit_inode.inode and code='$code'");


my $html = <<"END_HTML";  
<span style=color:purple><strong>$code $desi ancien prix d'achat:$prix_avant<br></strong></span>
END_HTML
if ($base eq "aerien"){
	$html.="<table><tr><th>Base</th><th>Nouveau prix achat</th><th>Prix de vente</th><th>Coef</th></tr>";
	$query="select base_lib from base where base_type='aerien'";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
    while (($client)=$sth->fetchrow_array){
		$prix_vente=&get("select ap_prix/100 from $client.appro where ap_cd_pr='$code' order by ap_code desc limit 1")+0;
		$coef=int($prix_vente*100/$prix_apres)/100;
		$html.="<tr><td>$client</td><td align=right>$prix_apres</td><td align=right>$prix_vente</td><td align=right>$coef</td></tr>";
    }
	$html.="</table>";
}
if ($base ne "aerien"){
	$html.="<table><tr><th>Base</th><th>Nouveau prix achat</th><th>Prix de vente</th><th>Coef</th></tr>";
	$prix_vente=&get("select pr_prx_vte from $base.produit where pr_cd_pr=$code")+0;
	$coef=int($prix_vente*100/$prix_apres)/100;
	$html.="<tr><td>$base</td><td align=right>$prix_apres</td><td align=right>$prix_vente</td><td align=right>$coef</td></tr>";
	$html.="</table>";
}
	
	

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

