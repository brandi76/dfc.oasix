#!/usr/bin/perl
use HTML::Parser ();
use LWP::Simple;   
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI;
use Data::Dumper;
use Image::Grab;
# recuperation description et image hd
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
 
$query="select lien from sephora where lien like '%P79105'";
# $query="select lien from sephora";
$sth2=$dbh->prepare($query);
$sth2->execute();

while (($lien)=$sth2->fetchrow_array){
	$code="";
	$description="";
	$note="";
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
	 if (($aff==1)&&($tag eq "br")) {$description.="<br>";}
	if (($aff==3)&&($tag eq "br")) {$note.="<br>";}
 
 
	if ($args->{'data-zoom-image'}ne""){
		$image_hd=$args->{'data-zoom-image'};
	}
	# if ($args->{class} eq "contenu"){
			# $aff=1;
	# }			
	if (($args->{class} eq "sku-thumb")&&($args->{'data-sku-ref'}ne"")&&($code eq"")){
			$code=$args->{'data-product-ref'};
			print "<b>$code</b><br>";
			print "$image_hd<br>";
			
			# $pic = new Image::Grab;
			# $pic->url("http://www.sephora.fr${image_hd}");
			# $pic->grab;
			# $code_img=$code."_hd";
			# open(IMAGE, ">/var/www/dfc.oasix/images_produits/$code_img.jpg") || die "image.jpg: $!";
			# binmode IMAGE;  # for MSDOS derivations.
			# print IMAGE $pic->image;
			# close IMAGE;
	}		
	
	if ($args->{class} eq "descProduct tab-content"){$aff=1;}
	if (($args->{class} eq "contenu")&&($aff==2)){$aff=3;}
	
} 
sub end {
  my $tag = shift;
  if (($tag eq "div")&&($aff==1)){
		$aff=2;
		$description=~s/\"//g;
		$description=&trash($description);
		$query="update sephora set description=\"$description\" where code='$code'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		print "desc:",$description,"<br>";
		print "<table>";
		for ($j=0;$j<length($description);$j++){
			print "<tr><td>".substr($description,$j,1)."</td></tr>";
			print "<tr><td>".ord(substr($description,$j,1))."</td></tr>";
		}
		print "</table>";
	}
	if (($tag eq "div")&&($aff==3)){
		$aff=0;
		$note=~s/\"//g;
		$note=&trash($note);
		 $query="update sephora set note=\"$note\" where code='$code'";
		 $sth=$dbh->prepare($query);
		 $sth->execute();
		 print "note",$note;
	}
}  
sub text {
	$text = shift;
	if (($aff==1)&&($text ne "")){
		# $text =~ y/\012\015//d;
		#$text=~s/^\s+(.*)\s+<br>*$/$1/;
		#$text=~s/,/\./g;
		# $text=~s/[^\x20-\x7A]//g;
		$description.=$text;
		# print "$text";
	}
	if (($aff==3)&&($text ne "")){
		# $text =~ y/\012\015//d;
		#$text=~s/^\s+(.*)\s+<br>*$/$1/;
		#$text=~s/,/\./g;
		#$text=~s/[^\x20-\x7A]//g;
		$note.=$text;
		# print "$text";
	}
}
 
sub trash{
  my $chaine=$_[0];
  my $chaine_clean="";
  my ($i)=0;
  for ($i=0;$i<length($chaine);$i++){
		$ok=1;
		if (ord(substr($chaine,$i,1))<32){
			$ok=0;
		}	
		# if (ord(substr($chaine,$i,1))>=224){
			# $chaine_clean.="é";
			# $ok=0;
		# }	
		
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
