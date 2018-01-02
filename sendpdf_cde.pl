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
$com_no=$ARGV[2];
$copie=$ARGV[3];

$message="Bonjour,\n
Nous vous prions de bien vouloir traiter la commande no:$com_no ci jointe\n
Merci de cliquer sur le lien ci dessous pour confirmer sa reception\n
Cette action est essentielle pour confirmer cette commande dans notre systeme, et eviter des relances recurrentes\n
http://dfc.oasix.fr/cgi-bin/confirmation_cde.pl?client=$base_dbh&com_no=$com_no\n
(si un mot de passe vous est demandé cliquez sur annuler votre confirmation sera tout de même enregistrée.)\n
Avec nos remerciements\n
Cordialement\n
Le service achat Duty Free Concept\n
";
$sujet="Commande Duty Free Concept";
# $message = encode_qp(encode("UTF-8", "$message"));

# `echo "$message","$sujet","$mail","$copie","$fichier","/var/www/$base_rep/doc/$fichier" >/tmp/log`;

&mail_joint_pdf("$message","$sujet","$mail","$copie","$fichier","/var/www/$base_rep/doc");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
my ($cc)=$_[3];
my ($file)=$_[4];
my ($path)=$_[5];
$type="pdf";
if (grep /xls$/,$fichier){$type="vnd.ms-excel";}

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
           Type       => "application/$type",
           Encoding   => 'base64',
           Path       => "$path/$file",
           Filename   => "$file"
);
$mime->send();
}
