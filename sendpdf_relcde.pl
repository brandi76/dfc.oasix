#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";

$mail=$ARGV[0];
$fichier=$ARGV[1];
$no_cde=$ARGV[2];
$base=$ARGV[3];
$copie=$ARGV[4];

$base_client=$base;
if ($base_client eq "dfca"){$base_client="corsica";}

$message="Bonjour,\n
la commande No $no_cde jointe n'a pas ete facturee\n
Merci de cliquer sur le lien ci dessous pour confirmer sa reception\n
Cette action est essentielle pour confirmer cette commande dans notre systeme, et eviter des relances recurrentes\n
http://dfc.oasix.fr/cgi-bin/confirmation_cde.pl?client=$base_client&com_no=$no_cde\n
(si un mot de passe vous est demandé cliquez sur annuler votre confirmation sera tout de même enregistrée.)\n
 cordialement Le service Achat Duty Free Concept\n
";
$sujet="Commande Duty Free Concept";

&mail_joint_pdf("$message","$sujet","$mail","$copie","$fichier","/var/www/$base.oasix/doc");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
my ($cc)=$_[3];
my ($file)=$_[4];
my ($path)=$_[5];

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

$mime->attach(
           Type       => 'application/pdf',
           Encoding   => 'base64',
           Path       => "$path/$file",
           Filename   => "$file"
);
$mime->send();
}
