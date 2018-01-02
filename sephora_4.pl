#!/usr/bin/perl
use HTML::Parser ();
use LWP::Simple;   
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI;
use Data::Dumper;
use Image::Grab;

$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
 
$query="select lien from sephora ";
$sth2=$dbh->prepare($query);
$sth2->execute();

while (($lien)=$sth2->fetchrow_array){
	my $content = get("http://www.sephora.fr$lien");
	my $parser = HTML::Parser->new();
	$debut=0;
	$parser->handler( text => \&text, "text" ); # Recuperer le texte brut
	$parser->handler( start => \&start, "tagname,attr" ); # balise ouvrante : appeler la routine start avec en parametre le tag et les attributs
	$parser->handler( end   => \&end,   "tagname" ); # balise fermante : appeler la routine end avec en parametre le tag
	$parser->unbroken_text( 1 );
	 
	$parser->parse($content);
	# $parser->parse($s); # parser le texte
	$parser->eof;
} 
 
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
			$ref=$args->{'data-sku-ref'};
			print $args->{'data-product-name'},"<br>";
			print $args->{'data-product-ref'},"<br>";
			$code=$args->{'data-product-ref'};
			$desi=$args->{'data-sku-name'};
			$desi=&trash($desi);
			print $desi,"<br>";
			print $args->{'data-popin-picture-url'},"<br>";
			$img=$args->{'data-popin-picture-url'};
			$pic = new Image::Grab;
			$pic->url("http://www.sephora.fr${img}");
			$pic->grab;
			$code_img=$code."_".$ref;
			open(IMAGE, ">/var/www/dfc.oasix/images_produits/$code_img.jpg") || die "image.jpg: $!";
			binmode IMAGE;  # for MSDOS derivations.
			print IMAGE $pic->image;
			close IMAGE;
			
			$query="insert ignore into sephora_ref (code,ref,desi) value ('$code','$ref',\"$desi\")";
			$sth=$dbh->prepare($query);
			$sth->execute();

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
		$query="update sephora_ref set prix='$text' where code='$code' and ref='$ref'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$aff=0;
	}
	if ($aff==3){
		print "$text<br>";
		$aff=0;
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
