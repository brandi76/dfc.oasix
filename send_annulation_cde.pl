#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";

$mail=$ARGV[0];
$com_no=$ARGV[2];
$client=$ARGV[3];
$copie=$ARGV[4];

$date=&get("select date from $client.commande_info where com_no='$com_no'");
$message="Bonjour,\n
Notre commande no:$com_no est annulée car elle n'a pas fait l'objet d'un accusé de réception de votre part depuis le $date
, nous vous remercions de bien vouloir l'annuler dans votre système\n
Cordialement\n
Le service achat Duty Free Concept\n
";
$sujet="Annulation de Commande Duty Free Concept";

&mail_joint_pdf("$message","$sujet","$mail","$copie");

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
$mime->attr("content-type.charset" => "utf-8");
$mime->send();
}
