#!/usr/bin/perl
use HTML::Parser ();
use LWP::Simple;   
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI;
use Data::Dumper;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
 $genre="F";
# my $content = get("http://www.sephora.fr/Parfum/Parfum-Femme/C309");
for ($i=1;$i<6;$i++){
if ($i >3){$genre="H";}
$parser = HTML::Parser->new();
$debut=0;
$parser->handler( text => \&text, "text" ); # Recuperer le texte brut
$parser->handler( start => \&start, "tagname,attr" ); # balise ouvrante : appeler la routine start avec en parametre le tag et les attributs
$parser->handler( end   => \&end,   "tagname" ); # balise fermante : appeler la routine end avec en parametre le tag
$parser->unbroken_text( 1 );
$parser->parse_file("sephora$i.html");
$parser->eof;
}


print "total:$nb<br>";
 
sub start {
	my ( $tag, $args ) = @_;
	if ($args->{class} eq "marque"){
		$aff=1;	
	}	
	if (($aff==1)&&($tag eq "a")){
		($marque,$null)=split(/;/,$args->{href});
		print $marque."<br>";
		$query="insert ignore into sephora value (\"$marque\",'$genre')";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$nb++;
		$aff=0;
	}	
} 
sub end {
  my $tag = shift;
} 
sub text {
	$text = shift;
	# if ($aff==2){
		# $text =~ y/\012\015//d;
		# $text=~s/^\s+(.*)\s+\n*$/$1/;
		# $text=~s/,/\./g;
		# $text=~s/[^\x20-\x7A]//g;
		# print "$text\n\n";
		# $aff=0;
	# }
	# if ($aff==3){
		# print "$text\n";
		# $aff=0;
	# }	
}
_