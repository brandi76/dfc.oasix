#!/usr/bin/perl 
use DBI();
use MIME::Lite;
# use utf8; 
use HTML::Entities;
require "../oasix/outils_perl2.pl";
$mail=$ARGV[0];
$mail=~s/@/\@/;
$sujet=$ARGV[1];
$texte_id=$ARGV[2];
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$message=&get("select texte from mailing_four where texte_id='$texte_id'") ;
$message=encode_entities($message);
$message=~s/\./\.\<br\>/g;
MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
			From       => 'supply_dfc@dutyfreeconcept.com',
			To         => "$mail",
			Subject    => "$sujet",
			"X-Mailer" => 'moncourriel.pl v2.0',
			Type       => 'multipart/mixed'
			);
$mime->attach(
			Type       => 'text/html',
			Encoding   => 'quoted-printable',
			Data       => $message
);
	
$mime->send();
