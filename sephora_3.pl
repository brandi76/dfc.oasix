#!/usr/bin/perl
use HTML::Parser ();
use LWP::Simple;   
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI;
use Image::Grab;
use Data::Dumper;
# recuperation des liens vers la gamme de produit
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$genre="F";
for ($i=1;$i<6;$i++){
	print "<font color=red>sephora$i.html<br></font>";
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
		}

		if (($marque==1)&&($tag eq "a")){
			($marque,$null)=split(/;/,$args->{href});
			print $marque."<br>";
			$query="update sephora set lien=\"$marque\" where code='$code'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			$texte=1;
		}
		if (($libelle==1)&&($tag eq "a")){
			$texte=2;
		}		
		if (($visuel==1)&&($tag eq "img")){
			$img=$args->{'data-original'};
			($null,$null,$code)=split(/_/,$img);
			print "<b>$code</b><br>";
	
			print $args->{'data-original'}."<br>";
			$texte=1;
			$pic = new Image::Grab;
			$pic->url("http://www.sephora.fr${img}");
			$pic->grab;
			open(IMAGE, ">/var/www/dfc.oasix/images_produits/$code.jpg") || die "image.jpg: $!";
			binmode IMAGE;  # for MSDOS derivations.
			print IMAGE $pic->image;
			close IMAGE;
			$query="insert ignore into sephora (code,genre) value ('$code','$genre')";
			$sth=$dbh->prepare($query);
			$sth->execute();
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
		$text=~s/\"//g;
		$text=&trash($text);
		print "texte $texte:$text<br>";
		if ($texte==1){
			$query="update sephora set marque=\"$text\" where code='$code'";
			$sth=$dbh->prepare($query);
			$sth->execute();
		}
		if ($texte==2){
			$query="update sephora set libelle=\"$text\" where code='$code'";
			$sth=$dbh->prepare($query);
			$sth->execute();
		}
		if ($texte==3){
			$query="update sephora set concentration=\"$text\" where code='$code'";
			$sth=$dbh->prepare($query);
			$sth->execute();
		}

		$texte++;
	}	
}

sub trash{
  my $chaine=$_[0];
  my $chaine_clean="";
  my ($i)=0;
  for ($i=0;$i<length($chaine);$i++){
		$ok=1;
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==180)){
			$chaine_clean.="ô";
			$i++;
			$ok=0;
		}	
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==169)){
			$chaine_clean.="é";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==172)){
			$chaine_clean.="ì";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==136)){
			$chaine_clean.="È";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==160)){
			$chaine_clean.="à";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==174)){
			$chaine_clean.="î";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==168)){
			$chaine_clean.="è";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==175)){
			$chaine_clean.="ï";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==148)){
			$chaine_clean.="Ô";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==170)){
			$chaine_clean.="ê";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==137)){
			$chaine_clean.="É";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==226)&&(ord(substr($chaine,$i+1,1))==128)&&(ord(substr($chaine,$i+2,1))==153)){
			$chaine_clean.="'";
			$i++;
			$i++;
			$ok=0;
		}
	
		
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==176)){
			$chaine_clean.="°";
			$i++;
			$ok=0;
		}
		
		if ($ok) {
		# print ord(substr($chaine,$i,1)," ";
		$chaine_clean.=substr($chaine,$i,1);
		}
  }
  return($chaine_clean);
}
		_