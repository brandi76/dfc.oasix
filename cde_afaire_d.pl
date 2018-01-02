#!/usr/bin/perl
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Net::SMTP_auth;
use Encode qw(encode);
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
require "/var/www/cgi-bin/dfc.oasix/src/connect.src";

$vendredi_reference="2017-11-03";
$base="aircotedivoire";
$nb_sem=&get("select datediff(curdate(),'$vendredi_reference')")/7;
if (&Odd(int($nb_sem))){
	$nb_sem=int($nb_sem)+1;
}
else{
	$nb_sem=int($nb_sem)+2;
}
$prochain_depart=&get("select adddate('$vendredi_reference',interval $nb_sem WEEK)");
$sujet="Commande a passer ACI";
$cc="dg\@dutyfreeconcept.com,il\@dutyfreeconcept.com";
# $cc="";
$to="sylvainbrandicourt\@gmail.com";
$html ="<span style=color:purple><strong>Prochain depart le $prochain_depart<br></strong></span>";

$nb_jour=&get("select datediff('$prochain_depart',curdate())");
# $nb_jour=&get("select datediff('$prochain_depart','$curdate()')");

# print " dans $nb_jour jours";
$pass=0;
$query="select distinct pr_four from $base.mag,$base.produit,$base.mag_run where mag=mag_actif and code=pr_cd_pr";
my ($sth)=$dbh->prepare($query);
$sth->execute();
while (($pr_four)=$sth->fetchrow_array){
	($fo2_add,$fo_minicde,$fo2_delai,$fo2_identification)=&get("select fo2_add,fo_minicde,fo2_delai,fo2_identification from $base.fournis where fo2_cd_fo='$pr_four'");
	if ($fo2_identification==1){next;}
	($fo_nom)=split(/\*/,$fo2_add);
	if ($fo2_delai==21){$fo2_delai=10;}
	if ($fo2_delai==$nb_jour){
		$html.="$pr_four $fo_nom<br>";
		$pass=1;
	}	
}	
#print $pass;
if ($pass){&send_mail();}

$vendredi_reference="2017-10-27";
$base="togo";
$nb_sem=&get("select datediff(curdate(),'$vendredi_reference')")/7;
if (&Odd(int($nb_sem))){
	$nb_sem=int($nb_sem)+1;
}
else{
	$nb_sem=int($nb_sem)+2;
}
$prochain_depart=&get("select adddate('$vendredi_reference',interval $nb_sem WEEK)");
$sujet="Commande a passer TOGO";
$cc="dg\@dutyfreeconcept.com,il\@dutyfreeconcept.com";
# $cc="";
$to="sylvainbrandicourt\@gmail.com";
$html ="<span style=color:purple><strong>Prochain depart le $prochain_depart<br></strong></span>";

$nb_jour=&get("select datediff('$prochain_depart',curdate())");
# $nb_jour=&get("select datediff('$prochain_depart','$curdate()')");

# print " dans $nb_jour jours";
$pass=0;
$query="select distinct pr_four from $base.mag,$base.produit,$base.mag_run where mag=mag_actif and code=pr_cd_pr";
my ($sth)=$dbh->prepare($query);
$sth->execute();
while (($pr_four)=$sth->fetchrow_array){
	($fo2_add,$fo_minicde,$fo2_delai,$fo2_identification)=&get("select fo2_add,fo_minicde,fo2_delai,fo2_identification from $base.fournis where fo2_cd_fo='$pr_four'");
	if ($fo2_identification==1){next;}
	($fo_nom)=split(/\*/,$fo2_add);
	if ($fo2_delai==21){$fo2_delai=10;}
	if ($fo2_delai==$nb_jour){
		$html.="$pr_four $fo_nom<br>";
		$pass=1;
	}	
}	
#print $pass;
if ($pass){&send_mail();}


sub send_mail{
	$user="6192_infodfc";
	$pass="5q6h5d";
	my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
	$smtp->auth( 'LOGIN', $user, $pass );
	my $mime = MIME::Lite->new(
				From       => 'info_dfc@dutyfreeconcept.com',
				To         => "$to",
				Cc         => "$cc",
				Subject    => "$sujet",
				"X-Mailer" => 'moncourriel.pl v2.0',
				Type     => 'multipart/alternative',
	);
	my $att_html = MIME::Lite->new(  
	  Type     => 'text',
	  Data     => $html,  
	  Encoding => 'quoted-printable', 
	);  
	$att_html->attr('content-type'   
	   => 'text/html; charset=iso-8859-1');  
	$mime->attach($att_html);  
	$mime->send();
}






sub Odd() {
 my($value) = @_;
 return ($value & 1) == 1;
} 