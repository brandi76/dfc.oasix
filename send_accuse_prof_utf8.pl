#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
use utf8;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");

$mail=$ARGV[0];
$no=$ARGV[1];
$copie=$ARGV[2];


$message="Bonjour,\n
nous vous confirmons notre accord ééé pour la proforma. Le service achat de Duty Free Concept\n";
$sujet="Commande Duty Free Concept";

&mail_joint_pdf("$message","$sujet","$mail","$copie",);

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
my ($cc)=$_[3];

MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
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
$mime->send();
}
