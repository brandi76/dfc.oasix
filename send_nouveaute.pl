#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
require "../oasix/outils_perl2.pl";
require("./src/connect.src");

$code=$ARGV[0];

$message="Bonjour,\n
le produit <a href=http://dfc.oasix.fr/cgi-bin/kit_dfc.pl?onglet=''&sous_onglet='0'&sous_sous_onglet=''&pr_cd_pr=$code&action=visu> \n
send_nouveaute.pl\n
";
$sujet="nouveau produit";
$mail="sylvainbrandicourt\@gmail.com";
&mail_joint_pdf("$message","$sujet","$mail");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];

MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
            From       => 'supply_dfc@dutyfreeconcept.com',
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
