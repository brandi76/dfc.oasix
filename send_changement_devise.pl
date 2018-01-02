#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require "/var/www/cgi-bin/dfc.oasix/src/connect.src";

$base=$ARGV[0];
$sujet="Changement de cours de devise";
if ($base eq "aircotedivoire"){
	$to="yomiedwigeorsy\@yahoo.fr";
	$cc="jeanpaulyao1\@gmail.com";
}
if ($base eq "cameshop"){
	$to="rn\@dutyfreeconcept.com";
	$cc="gibsint\@gmail.com";
}
if ($base eq "cameshop"){
	$to="vn\@dutyfreeconcept.com";
	$cc="xn\@dutyfreeconcept.com";
}
if ($base eq "test"){
	$to="sylvainbrandicourt\@gmail.com";
	$cc="";
}

if ($to eq ""){exit;}

my $html = <<"END_HTML";  
<span style=color:purple><strong>Un changement a été fait dans les devises merci de faire la mise à jour de l'outils caisse<br></strong></span>
END_HTML



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

