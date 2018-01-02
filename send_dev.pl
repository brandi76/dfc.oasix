#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use CGI;
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
$html=new CGI;
print $html->header;
$sujet="Bug afrique";
$mail="sylvainbrandicourt\@gmail.com";
&mail_joint_pdf("$message","$sujet","$mail");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];

MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
            From       => 'info_dfc@dutyfreeambassade.com',
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
