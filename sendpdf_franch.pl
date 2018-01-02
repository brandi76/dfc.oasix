#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
require "../oasix/outils_perl2.pl";

$mail=$ARGV[0];
# $mail="sylvainbrandicourt\@gmail.com";
# $mail=~s/@/\@/;
$client_id=$ARGV[1];
$fichier1=$ARGV[2];
$fichier2=$ARGV[3];
$contact=$ARGV[4];
$copie=$ARGV[5];

# $fichier_pdf="lettre_dutyfreeambassade.pdf";
$message="A l'attention de $contact\n
Cher Cliente, cher client,
Nous vous prions de bien vouloir trouver ci joint vos demandes de franchises.
L'ensemble des demandes est à adresser au Ministere des Affaires Etrangeres en trois exemplaires.
Veuillez joindre une enveloppe timbree par formulaire de franchise pour le retour des documents 
(une enveloppe timbree  pour le F1 et une autre pour le F4).
Nous attirons votre attention sur le fait que le formulaire 1 doit etre imprime recto verso.

A la demande de la Direction Generale des Douanes, nous vous prions d'indiquer :
- Nom, prenom, numero de carte diplomatique, date de prise de fonction du titre spécial de la personne qui signe la franchise N°4.

Si vous souhaitez recevoir les franchises par courrier, merci de nous en faire part.

Meilleures salutations
Le Service Commercial


Dear customer,

We hereby send you your demands of franchises.
We kindly request you to send the demands to the Ministry of Foreign Affairs in three copies.
Please do not forget to join two envelopes with a stamp (one for the F1 and another for the F4)
so that the documents can be sent back to you.
We draw your attention to the fact that the form 1 should be copied on both sides of the page.

Would you please note the name, surname, diplomatic card number, and date of the card of the person who signs the franchise N°4.

Finally, if you wish to receive the initial forms by post, please let us know.
We thank you for your cooperation.

Sincerely yours,

Sales Department

";
$sujet="Franchise Duty Free Ambassade";
# $message = encode_qp(encode("UTF-8", "$message"));

&mail_joint_pdf("$message","Franchise Dutyfreeambassade","$mail","$copie","$fichier1","$fichier2","/var/www/dutyfree/doc/$client_id");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
my ($cc)=$_[3];
my ($file1)=$_[4];
my ($file2)=$_[5];
my ($path)=$_[6];

MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
            From       => 'info@dutyfreeambassade.com',
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
           Path       => "$path/$file1",
           Filename   => "$file1"
);
$mime->attach(
           Type       => 'application/pdf',
           Encoding   => 'base64',
           Path       => "$path/$file2",
           Filename   => "$file2"
);
$mime->send();
}
