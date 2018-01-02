#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();

$html=new CGI;
print $html->header();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";


$query="select code,libelle from sephora";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$chaine)=$sth->fetchrow_array){
	$ko=0;
	for ($i=0;$i<length($chaine);$i++){
		if ((ord(substr($chaine,$i,1))>=193)&&(ord(substr($chaine,$i,1))<=197)){
			$ko=1;
		}
	}
	if ($ko){
		$chaine=&trash($chaine);
		print $chaine;
		&save("update sephora set libelle=\"$chaine\" where code='$code'","aff");
	}
	if (2==3){	
		for ($i=0;$i<length($chaine);$i++){
			if ((ord(substr($chaine,$i,1))>=193)&&(ord(substr($chaine,$i,1))<=197)){
					print "$chaine<br><span style=color:blue>";
					print substr($chaine,$i,length($chaine)-$i);
					# print substr($chaine,277,length($chaine)-$i);
					# $i=277;
					print "</span><br>";
					print ord(substr($chaine,$i,1));
					print " ";
					print ord(substr($chaine,$i+1,1));
					print " ";
					print ord(substr($chaine,$i+2,1));
					print "<br>";
					print "<a href=http://www.sephora.fr$lien>Lien Sephora</a><br>";

					exit;
				}
		}
	}
}


sub trash{
 # codage ansi
  my $chaine=$_[0];
  $chaine =~ s/^\s+//; 
  $chaine =~ s/\s+$//; 
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
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==128)){
			$chaine_clean.="À";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==174)){
			$chaine_clean.="î";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==142)){
			$chaine_clean.="Î";
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
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==178)){
			$chaine_clean.="ò";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==188)){
			$chaine_clean.="ü";
			$i++;
			$ok=0;
		}
		
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==167)){
			$chaine_clean.="ç";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==162)){
			$chaine_clean.="â";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==187)){
				$chaine_clean.="û";
				$i++;
				$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==185)){
			$chaine_clean.="ù";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==171)){
			$chaine_clean.="«";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==174)){
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==187)){
			$chaine_clean.="»";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==160)){
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==170)){
			$chaine_clean.="ê";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==138)){
			$chaine_clean.="Ê";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==195)&&(ord(substr($chaine,$i+1,1))==137)){
			$chaine_clean.="É";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==197)&&(ord(substr($chaine,$i+1,1))==147)){
			$chaine_clean.="œ";
			$i++;
			$ok=0;
		}
		if ((ord(substr($chaine,$i,1))==197)&&(ord(substr($chaine,$i+1,1))==146)){
			$chaine_clean.="Œ";
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
		if ((ord(substr($chaine,$i,1))==194)&&(ord(substr($chaine,$i+1,1))==169)){
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
