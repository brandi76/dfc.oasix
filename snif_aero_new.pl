#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$texte=$html->param("texte");
@europe=("Allemagne", "Autriche", "Belgique", "Chypre", "Danemark", "Espagne", "Estonie","Finlande", "France", "Grece", "Hongrie", "Irlande", "Italie", "Lettonie", "Lituanie", "Luxembourg", "Malte", "Pays-Bas", "Pologne", "Portugal", "TchequeRepublique", "Grande-Bretagne", "Slovaquie", "Slovenie", "Suede","Suisse");

foreach (@europe){
	$query="select count(*) from aerodesi where aerd_desi='$_'"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array;
	# print "$_,$nb<br>";
}

$cal{"JAN"}=1;
$cal{"FEV"}=2;
$cal{"MAR"}=3;
$cal{"APR"}=4;
$cal{"MAI"}=5;
$cal{"JUN"}=6;
$cal{"JUL"}=7;
$cal{"AOU"}=8;
$cal{"SEP"}=9;
$cal{"OCT"}=10;
$cal{"NOV"}=11;
$cal{"DEC"}=12;

while ($texte=~s/'//){};
(@ligne)=split(/\n/,$texte);

print "<pre>";
foreach $ligne (@ligne){
	chop($ligne);
	while ($ligne=~s/  / /){};

	(@mot)=split(/ /,$ligne);

	$nb=0;
	$slot=0;
	$cdg=0;
	$vol="";
	$afaire=0;
	$heure=0;
	$dest="";
	foreach $mot (@mot){
		if (! grep /2005/,$mot){($mot)=split(/\//,$mot);}
		if ((grep /2005/,$mot)&&(! grep /\//,$mot)){

			$jour=substr($mot,0,2);
			$mois=substr($mot,2,3);
			$an=substr($mot,5,4);
			$mois=$cal{"$mois"};
			$date=&nb_jour($jour,$mois,$an);
		}
		if ((grep /2005/,$mot)&&(grep /\//,$mot)){

		
			$jour=substr($mot,0,2);
			$mois=substr($mot,3,2);
			$an=substr($mot,6,4);
			$date=&nb_jour($jour,$mois,$an);
		}
		if ((grep /^BLE/,$mot)||(grep /^AF/,$mot)||(grep /^AXY/,$mot)){
			$vol=$mot;
			$nb=&get("select count(*) from flyhead where fl_date='$date' and fl_vol='$vol'");
		}		
		if ((grep /PAX/,$mot)||(grep /FERRY/,$mot)){last;}
		if (($mot>0)&&($heure==0)&&($cdg==1)){
			$heure=$mot;
			$ligne=~s/ $mot / <b>$mot<\/b> /;
			}
		
		$query="select aerd_trig,aerd_desi from aerodesi where aerd_trig='$mot' and aerd_trig!='PAX' and aerd_trig!='HOC'"; 
		$sth=$dbh->prepare($query);
		$sth->execute();
		($trig,$desi)=$sth->fetchrow_array;
		if (($trig eq "CDG")&&($slot==0)){$cdg=1;}
		if ($trig ne "") {$slot++;}
		$ok=1;
		foreach $pays (@europe){
			if ($desi eq $pays){$ok=0;}
			}
		if (($trig ne "")&&($ok==1)){
			$dest=$trig;
			$ligne=~s/ $trig / <font color=red>$trig<\/font> /;
			$ligne=~s/ $trig\// <font color=red>$trig\/<\/font>/;
		
			$afaire=1;
		}
	}
	print "$ligne ";	
	if (($cdg==1 && $nb==0 && $afaire==1)){
		print "<img src=http://ibs.oasix.fr/ko.jpg>";
		&magique();
	}
	
	if ($nb>0 && $cdg==1 && $afaire==1){
		print "<img src=http://ibs.oasix.fr/ok.gif>";
		# forcage client blue
		# &save("update flyhead set fl_cd_cl=345 where fl_vol='$vol' and fl_date='$date'","aff");
		&info();
	}
	print "<br>";
}
print "</pre>";
print "<br><br>";
print "<form method=post>";
print "<textarea name=texte>";
print "</textarea><input type=submit></form>";


sub magique
{
	$trouve=&get("select count(*) from vol where v_vol='$vol' and v_rot=1 order by v_code");
	if ($trouve==0){return;}
	$query="select v_date_jl,v_cd_cl from vol where v_vol='$vol' and v_rot=1 order by v_code desc limit 1 ";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	($v_date_jl,$v_cd_cl)=$sth3->fetchrow_array;
	$query = "select * from flybody where flb_vol='$vol' and flb_date='$v_date_jl' order by flb_rot";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	$pass=0;
	while (($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=$sth3->fetchrow_array){
		if ($pass==0){
			$aeroport=$flb_tridep;
			$heure_dep=$flb_depart;
			$pass=1;
		}
		else
		{
			$destination=$flb_tridep;
		}
		
		$triret=$flb_triret;
		$heure_ar=$flb_arrivee;
		$vol_ret=$flb_voltr;
	}
		print "<a href=HTTP://ibs.oasix.fr/saivol.php?client=$v_cd_cl&vol=$vol&date='$date'&aeroport=$aeroport&destination=$destination&heure_dep=$heure_dep&heure_ar=$heure_ar&vol_ret=$vol_ret&datejour=$jour&datemois=$mois&datean=$an target=_blank>creer</a>";
}

sub info
{
	$query="select fl_vol,fl_date from flyhead where fl_date='$date' and fl_vol='$vol'";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	($fl_vol,$fl_date)=$sth3->fetchrow_array;
	$query = "select * from flybody where flb_vol='$fl_vol' and flb_date='$fl_date' order by flb_rot";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	$pass=0;
	while (($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=$sth3->fetchrow_array){
		if ($pass==0){
			$aeroport=$flb_tridep;
			$heure_dep=$flb_depart;
			$pass=1;
		}
		else
		{
			$destination=$flb_tridep;
		}
		
		$triret=$flb_triret;
		$heure_ar=$flb_arrivee;
		$vol_ret=$flb_voltr;
	}
	
	if (($dest ne $destination)||($heure+100!=$heure_dep)){
		print "<font color=red>$destination $heure_dep</font>";
	}
}
