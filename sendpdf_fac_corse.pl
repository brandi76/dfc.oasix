#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
use Net::SMTP_auth;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");

$mail=$ARGV[0];
$fichier=$ARGV[1];
$fac_no=$ARGV[2];
$copie=$ARGV[3];

$message="Bonjour,\n
Ci joint la facture duty free concept no:$fac_no \n
Le service achat Duty Free Concept\n
";
$sujet="Facture Duty Free Concept no:$fac_no";

&mail_joint_pdf("$message","$sujet","$mail","$copie","$fichier","/var/www/dfca.oasix/doc");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
my ($cc)=$_[3];
my ($file)=$_[4];
my ($path)=$_[5];

my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', '6192_sb', 'passe123' );

# MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
            From       => 'supply_dfc@dutyfreeconcept.com',
            To         => "$to",
            Cc         => "$cc",
            Subject    => "$sujet",
            "X-Mailer" => 'moncourriel.pl v2.0',
            Type       => 'multipart/mixed'
            );
$mime->attach(
            Type       => 'TEXT',
            Encoding   => 'quoted-printable',
            Data       => $message
);
$mime->attr("content-type.charset" => "utf-8");

$mime->attach(
           Type       => 'application/pdf',
           Encoding   => 'base64',
           Path       => "$path/$file",
           Filename   => "$file"
);
$mime->send();
}
