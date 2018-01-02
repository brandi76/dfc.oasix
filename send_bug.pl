#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";

$message=$ARGV[0];
$sujet="Alerte serveur";
$mail="sylvainbrandicourt\@gmail.com";
# $mail="sb\@dutyfreeconcept.com";
&mail_joint_pdf("$message","$sujet","$mail");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
$user="6192_infodfc";
$pass="5q6h5d";
my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', $user, $pass );

#MIME::Lite->send('smtp','smtp.dutyfreeconcept.com',Debug=>1);
my $mime = MIME::Lite->new(
            From       => 'info_dfc@dutyfreeconcept.com',
            To         => "$to",
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

$mime->send();
}
