#!/usr/bin/perl
use HTML::Parser ();
use LWP::Simple;   
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI;
use Image::Grab;
use Data::Dumper;
$html=new CGI;
print $html->header();
require "../oasix/outils_perl2.pl";
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$parser = HTML::Parser->new();
# a partir d'une page enregistré maquillage , choix de marque, creation du code produit dans le fichier sephora
$debut=0;
$parser->handler( text => \&text, "text" ); # Recuperer le texte brut
$parser->handler( start => \&start, "tagname,attr" ); # balise ouvrante : appeler la routine start avec en parametre le tag et les attributs
$parser->handler( end   => \&end,   "tagname" ); # balise fermante : appeler la routine end avec en parametre le tag
$parser->unbroken_text( 1 );
$parser->parse_file("sephora_maquillage.html");
$parser->eof;
print "total:$nb<br>";
 
sub start {
	my ( $tag, $args ) = @_;
	if ($args->{class} eq "produit"){
		$trouve=1;
	}	
	if ($trouve){
		if ($args->{class} eq "visuelProduit"){
			$visuel=1;
			$marque=0;
			$libelle=0;
		}
		if ($args->{class} eq "marque"){
			$visuel=0;
			$marque=1;
			$libelle=0;
		}
		if ($args->{class} eq "libelle"){
			$visuel=0;
			$marque=0;
			$libelle=1;
		}
		if ($args->{class} eq "prix"){
			$visuel=0;
			$marque=0;
			$libelle=0;
			$trouve=0;
			# exit;
		}

		if (($marque==1)&&($tag eq "a")){
			($marque,$null)=split(/;/,$args->{href});
			print "lien:$marque"."<br>";
			&save("update sephora set lien='$marque' where code='$code'","af");
			
			$texte=1;
		}
		if (($libelle==1)&&($tag eq "a")){
			$texte=2;
		}		
		if (($visuel==1)&&($tag eq "img")){
			$img=$args->{'data-original'};
			($null,$null,$code)=split(/_/,$img);
			print "<b>$code</b><br>";
			&save("replace into sephora (code,genre) values ('$code','M')","af");
			print $args->{'data-original'}."<br>";
			$texte=1;
			# $pic = new Image::Grab;
			# $pic->url("http://www.sephora.fr${img}");
			# $pic->grab;
			# open(IMAGE, ">/var/www/dfc.oasix/images_produits/$code.jpg") || die "image.jpg: $!";
			# binmode IMAGE;  # for MSDOS derivations.
			# print IMAGE $pic->image;
			# close IMAGE;
		}		
	}	
} 
sub end {
  my $tag = shift;
  if ($tag eq "a"){$texte=0;}
} 
sub text {
	$text = shift;
	if (($texte>0)&&(grep /[a-zA-Z]/,$text)){
	    $text=&trash($text);
		print "texte $texte:$text<br>";
		if ($texte==1){
			&save("update sephora set marque=\"$text\" where code='$code'","af");
		}
		if ($texte==2){
			&save("update sephora set libelle=\"$text\" where code='$code'","aff");
		}
		
		$texte++;
	}	
	# if ($aff==2){
		# $text =~ y/\012\015//d;
		# $text=~s/^\s+(.*)\s+\n*$/$1/;
		# $text=~s/,/\./g;
		# $text=~s/[^\x20-\x7A]//g;
		# print "$text\n\n";
		# $aff=0;
	# }
}
_