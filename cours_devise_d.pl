#!/usr/bin/perl
use HTML::Parser ();
use LWP::Simple;   
use CGI::Carp qw(fatalsToBrowser);
# use CGI;
# use Data::Dumper;
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
# $html=new CGI;
# print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
my $content = get("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml");
$parser = HTML::Parser->new();
$parser->handler( text => \&text, "text" ); # Recuperer le texte brut
$parser->handler( start => \&start, "tagname,attr" ); # balise ouvrante : appeler la routine start avec en parametre le tag et les attributs
$parser->handler( end   => \&end,   "tagname" ); # balise fermante : appeler la routine end avec en parametre le tag
$parser->unbroken_text( 1 );
$parser->parse($content);
$parser->eof;
if ($message ne ""){&message_send();}
sub start {
	 my ( $tag, $args ) = @_;
	 if (($tag eq "cube")&& ($args->{currency} eq "USD")){
		$cours_new=$args->{rate};
		$query="select cours  from togo.devise where id=840";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($cours_ancien)=$sth->fetchrow_array;
		$ecart=abs(100*($cours_ancien-$cours_new)/$cours_new);
		if ($ecart >=3){$message.="Togo cours:$cours_ancien Cours du jour:$cours_new \n";}

		$query="select cours  from cameshop.devise where id=840";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($cours_ancien)=$sth->fetchrow_array;
		$ecart=abs(100*($cours_ancien-$cours_new)/$cours_new);
		if ($ecart >=3){$message.="cameshop cours:$cours_ancien Cours du jour:$cours_new \n";}

		$query="select cours  from aircotedivoire.devise where id=840";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($cours_ancien)=$sth->fetchrow_array;
		$ecart=abs(100*($cours_ancien-$cours_new)/$cours_new);
		if ($ecart >=3){$message.="aircotedivoire cours:$cours_ancien Cours du jour:$cours_new \n";}
	}
} 
sub end {
  my $tag = shift;
} 
sub text {
	$text = shift;
}


sub message_send {
$sujet="Alerte devise";
$mail="pp\@dutyfreeconcept.com";
# $cc="sylvainbrandicourt\@gmail.com";
$user="6192_infodfc";
$pass="5q6h5d";
my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', $user, $pass );

#MIME::Lite->send('smtp','smtp.dutyfreeconcept.com',Debug=>1);
my $mime = MIME::Lite->new(
            From       => 'info_dfc@dutyfreeconcept.com',
            To         => "$mail",
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
