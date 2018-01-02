#!/usr/bin/perl
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require "/var/www/cgi-bin/aircotedivoire.oasix/src/connect.src";
$cc="sylvainbrandicourt\@gmail.com";
# $cc="";
$to="pp\@dutyfreeconcept.com ";


$sujet="Anomalie preparation";
my $html ="<span style=color:purple><strong>Anomalie préparation<br></strong></span>";
$query="select ecartrol_arch.*,v_troltype from ecartrol_arch,vol where ecr_qte!=0 and ecr_stock>=12 and ecr_appro=v_code and datediff(curdate(),v_date_sql)<=7 order by ecr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
$pass=0;

while (($ecr_appro,$ecr_cd_pr,$ecr_qte,$ecr_stock,$v_troltype)=$sth->fetchrow_array){
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$ecr_cd_pr");
	if ($pr_desi ne $desi_run){
		$html.= "<h4>$ecr_cd_pr $pr_desi </h4>";
		$desi_run=$pr_desi;
	}	
	$prevu=&get("select tr_qte from trolley where tr_code=$v_troltype and tr_cd_pr=$ecr_cd_pr")+0;
	$prevu/=100;
	$ecr_qte/=100;
	$html.= "appro:$ecr_appro qte trolley standard:$prevu qte mise à bord:$ecr_qte qte en stock:$ecr_stock<br>";
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
