#!/usr/bin/perl
use CGI;
use DBI();
use LWP;
$html=new CGI;
print $html->header;
require "./src/connect.src";
$chap=$html->param("chap");
if ($chap eq ""){$chap=34;}
my $ua  = LWP::UserAgent->new();
my $req = HTTP::Request->new( GET => "http://www.cbsa-asfc.gc.ca/trade-commerce/tariff-tarif/2015/html/00/ch${chap}-fra.html" );
my $res=$ua->request($req);
if (! $res->is_success){print " <span style=background-color:red;color:white>Lien invalide !</span>";}
else {$Resultat = $res->content;}
while ($Resultat=~s/\<\/tr\>/\n/g){};
while ($Resultat=~s/\<tr\>/\n/g){};
	
(@tab)=split(/\n/,$Resultat);
foreach (@tab){
	if (grep /tbody/,$_){$debut=1;}
	if (grep /\/tbody/,$_){$debut=0;}
	if ($debut){
		while ($_=~s/;/ /g){};
		while ($_=~s/\&nbsp;/ /g){};
	 	while ($_=~s/\<\/td\>\<td\>/\;/g){};
		while ($_=~s/\<td\>//g){};
		(@tab2)=split(/\;/,$_);
		while($tab2[0]=~s/\.//g){};
		$texte_trad=ascii2($tab2[2]);
		if (($tab2[2] ne "")&&(! grep /[a-z]/,$tab2[0])){print "$tab2[0];$texte_trad<br>";$nb++;}
	}
    # if ($nb>20){exit;}	
}

sub ascii2()
{
	my($texte)=$_[0];
	my ($texte_trad)='';
    for ($i=0;$i<length($texte);$i++){
		if ( (ord(substr($texte,$i,1))<32) || (ord(substr($texte,$i,1))>125) ) {$texte_trad.='e';}else{$texte_trad.=substr($texte,$i,1);}
	}
	while ($texte_trad=~s/ee/e/g){};
	return($texte_trad);
}

sub ascii()
{
	my($texte)=$_[0];
	my ($texte_trad)='';
    for ($i=0;$i<length($texte);$i++){
		if ((ord(substr($texte,$i,1))==191)&&($trouve)){$confirme=1;}
		if (ord(substr($texte,$i,1))==239){$trouve=1;}else{$trouve=0;}
		
		if ((! $confirme)&& (ord(substr($texte,$i,1))!=239)&& (ord(substr($texte,$i,1))!=195)&& (ord(substr($texte,$i,1))!=169)&& (ord(substr($texte,$i,1))!=170)){
			  $color="";
			  if (ord(substr($texte,$i,1))>122){$color="red";}
			  # print "<span style=color:$color>",substr($texte,$i,1),":",ord(substr($texte,$i,1))," conf:$confirme trouv:$trouve:</span><br>";
			 # print substr($texte,$i,1);
			$texte_trad.=substr($texte,$i,1);
		}
		if ((ord(substr($texte,$i,1))==189)&&($confirme)){$trouve=0;$confirme=0;$texte_trad.='e';}
		if (ord(substr($texte,$i,1))==195){$texte_trad.='e';}

	}
	return($texte_trad);
}