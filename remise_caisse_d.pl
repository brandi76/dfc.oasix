#!/usr/bin/perl
# use LWP::Simple;   
# use CGI::Carp qw(fatalsToBrowser);
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$message="";
$query="select distinct(no) from aircotedivoire.bordereau where datediff(curdate(),date_creation)<100";
$sth=$dbh->prepare($query);
$sth->execute();
while (($no)=$sth->fetchrow_array){
		# print "$no\n";
		
		# $date_remise=&get("select max(date_remise) from aircotedivoire.bordereau where no='$no'");
		$query="select max(date_remise) from aircotedivoire.bordereau where no='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$date_remise=$sth2->fetchrow_array;
		# print "$date_remise\n";
		if ($date_remise eq "0000-00-00"){
			$message.="$no\n";
		}
}
if ($message ne ""){
	$message="Les bordereaux ci dessous n'ont pas été remis en banque, merci de procéder d urgence aux remises ou nous informer des raisons entrainant l absence de remise en banque \n".$message;
	&message_send();
}


sub message_send {
$sujet="Alerte bordeau non remis";
$mail="yomiedwigeorsy\@yahoo.fr";
$cc="pp\@dutyfreeconcept.com,dg\@dutyfreeconcept.com";
#$mail="sylvainbrandicourt\@gmail.com,sb\@dutyfreeconcept.com";
# $cc="sylvainbrandicourt\@gmail.com";
$user="6192_infodfc";
$pass="5q6h5d";
my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', $user, $pass );

#MIME::Lite->send('smtp','smtp.dutyfreeconcept.com',Debug=>1);
my $mime = MIME::Lite->new(
            From       => 'info_dfc@dutyfreeconcept.com',
            To         => "$mail",
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
