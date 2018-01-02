#!/usr/bin/perl
use HTML::Parser ();
use LWP::Simple;   
use CGI::Carp qw(fatalsToBrowser);
use CGI;
 use Data::Dumper;
$html=new CGI;
print $html->header();
 
my $content = get("http://www.sephora.fr/Parfum/Parfum-Femme/Illicit-Eau-de-Parfum/P2417014");
 
my $parser = HTML::Parser->new();
$debut=0;
$parser->handler( text => \&text, "text" ); # Recuperer le texte brut
$parser->handler( start => \&start, "tagname,attr" ); # balise ouvrante : appeler la routine start avec en parametre le tag et les attributs
$parser->handler( end   => \&end,   "tagname" ); # balise fermante : appeler la routine end avec en parametre le tag
$parser->unbroken_text( 1 );
 
$parser->parse($content);
# $parser->parse($s); # parser le texte
$parser->eof;
 
 
sub start {
  my ( $tag, $args ) = @_;
  # if ($args->{id} eq "filAriane"){$debut=1;}
  # if ($debut){
	# print "start:$tag $args->{id} <br>";
  # }
  if ($args->{id} eq "descProduct tab-content"){$aff=3;}
  #if ($args->{data-product-ref} ne ""){
	# if ($args->{class} eq "sku-thumb"){
		# print Dumper($args);
	# }
	# print $args->{class};
	if (($args->{class} eq "sku-thumb")&&($args->{'data-sku-ref'}ne"")){
			# print Dumper($args),"<br>";
			print $args->{'data-sku-ref'},"<br>";
			print $args->{'data-product-name'},"<br>";
			print $args->{'data-product-ref'},"<br>";
			print $args->{'data-sku-name'},"<br>";
			print $args->{'data-popin-picture-url'},"<br>";
	}
	if ($aff==1){$aff=2;}
	if ($args->{class} eq "price"){
			$aff=1;	
			 # print Dumper($args),"<br>";
	}
	# print $args->{data-sku-ref};
	
	# print "<br>";
#	}		
  
  
} 
sub end {
  my $tag = shift;
  # $aff=0;
  # print "end:$tag<br>";
} 
sub text {
	$text = shift;
	if ($aff==2){
		$text =~ y/\012\015//d;
		$text=~s/^\s+(.*)\s+<br>*$/$1/;
		$text=~s/,/\./g;
		$text=~s/[^\x20-\x7A]//g;
		print "$text<br><br>";
		$aff=0;
	}
	if ($aff==3){
		print "$text<br>";
		$aff=0;
	}	
 }
_