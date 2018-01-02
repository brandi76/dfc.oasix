#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
print "<title> Sinf aero</title>";
print "planning blue sur 4 semaines<br>";
print "planning axy escale<br>";


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
$cal{"FEB"}=2;
$cal{"MAR"}=3;
$cal{"APR"}=4;
$cal{"AVR"}=4;
$cal{"MAI"}=5;
$cal{"MAY"}=5;
$cal{"JUN"}=6;
$cal{"JUI"}=6;
$cal{"JUL"}=7;
$cal{"AOU"}=8;
$cal{"AUG"}=8;
$cal{"SEP"}=9;
$cal{"OCT"}=10;
$cal{"NOV"}=11;
$cal{"DEC"}=12;

while ($texte=~s/'//){};

# while ($texte=~s/  / /){};
(@ligne)=split(/\n/,$texte);

print "<pre>";
foreach $ligne (@ligne){
	chop($ligne);
	while ($ligne=~s/\t/ /){};
	while ($ligne=~s/  / /){};
	while ($ligne=~s/ AXY / AXY/){};
	if (grep /200[0-9]/,$ligne){while ($ligne=~s/ //){}}

	(@mot)=split(/ /,$ligne);

	$nb=0;
	$slot=0;
	$cdg=0;
	$vol="";
	$afaire=0;
	$heure=0;
	$dest="";
	foreach $mot (@mot){
		if (! grep /200./,$mot){split(/\//,$mot);}
		# print "*$mot*";
		if (((grep /200./,$mot)||(grep /JAN[0-9][0-9]/,$mot)||(grep /FE.[0-9][0-9]/,$mot)||(grep /MAR[0-9][0-9]/,$mot)||(grep /A.R[0-9][0-9]/,$mot)||(grep /MA.[0-9][0-9]/,$mot)||(grep /JU.[0-9][0-9]/,$mot)||(grep /JUIN[0-9][0-9]/,$mot)||(grep /AOU[0-9][0-9]/,$mot)||(grep /AUG[0-9][0-9]/,$mot)||(grep /SEP[0-9][0-9]/,$mot)||(grep /OCT[0-9][0-9]/,$mot)||(grep /NOV[0-9][0-9]/,$mot)||(grep /DEC[0-9][0-9]/,$mot))&&((! grep /\//,$mot)&&(! grep /CDG/,$ligne)&&(! grep /PAX/,$ligne))){
                        # print "*$mot*";
			$jour=substr($mot,0,2);
			$mois=substr($mot,2,3);
			$an=substr($mot,5,4);
			if (grep/JUIN[0-9]/,$mot){
				$an=substr($mot,7,4);
			}	
			if ($an<2000){$an+=2000;}
			$mois=$cal{"$mois"};
			$date=&nb_jour($jour,$mois,$an);
			print "<hr color=red><bR><font color=red>$jour $mois $an</font><br>";
		}
		if ((grep /LUNDI/,$mot)||(grep /MARDI/,$mot)||(grep /MERCREDI/,$mot)||(grep /JEUDI/,$mot)||(grep /VENDREDI/,$mot)||(grep /SAMEDI/,$mot)||(grep /DIMANCHE/,$mot)) {
			$jour=$mot[2];
			$mois=substr($mot[3],0,3);
			$an=2000+$mot[4];
			$mois=$cal{"$mois"};
			$date=&nb_jour($jour,$mois,$an);
			print "<hr color=red><bR><font color=red>$jour $mois $an</font><br>";
		}

		if ((grep /200./,$mot)&&(grep /\//,$mot)){

			$jour=substr($mot,0,2);
			$mois=substr($mot,3,2);
			$an=substr($mot,6,4);
			$date=&nb_jour($jour,$mois,$an);
		}
		if ((grep /^BLE/,$mot)||(grep /^AF/,$mot)||(grep /^AXY/,$mot)||(grep /^BJ[0-9]/,$mot)){
			$vol=$mot;
			$nb=&get("select count(*) from flyhead where fl_date='$date' and fl_vol='$vol'","af");
		}		
		if ((grep /PAX/,$mot)||(grep /FERRY/,$mot)||(grep /FRY/,$mot)){last;}
		if (($mot>0)&&($heure==0)&&($cdg==1)){
			$mot=~s/://;
			$decalheure=0;
			if (($date>=13233)&&($date<=13450)){$decalheure=100;}   # ETE 2006
			if (($today>=13597)&&($today<=13814)){$decalheure=2;}   # ETE 2007
			if (($today>=13968)&&($today<=14178)){$decalheure=2;}   # ETE 2008
			if (($today>=14332)&&($today<=14542)){$decalheure=2;}   # ETE 2009
			if (($today>=14696)&&($today<=14913)){$decalheure=2;}   # ETE 2010
			if (($today>=15060)&&($today<=15277)){$decalheure=2;}   # ETE 2011

			$heure=&cal_heure($mot+$decalheure);
			$ligne=~s/ $mot / <b>$mot<\/b> /;
			$heure_dep=$mot+100;
			}
		
		$query="select aerd_trig,aerd_desi from aerodesi where aerd_trig='$mot' and aerd_trig!='PAX' and aerd_trig!='HOC'"; 
		$sth=$dbh->prepare($query);
		$sth->execute();
		($trig,$desi)=$sth->fetchrow_array;
		if ((($trig eq "CDG")||($trig eq "LYS")||($trig eq "MRS"))&&($slot==0)){
		$cdg=1;
		$aeroport=$trig;
		}
		if ($trig ne "") {$slot++;}
		$ok=1;
		foreach $pays (@europe){
			if ($desi eq $pays){$ok=0;}
			}
		if ($desi eq "Portugal"){
			$ok=1;
		}
		if (($trig ne "")&&($ok==1)){
			$dest=$trig;
			$ligne=~s/ $trig / <font color=red>$trig<\/font> /;
			$ligne=~s/ $trig\// <font color=red>$trig\/<\/font>/;
			$destination=$trig;		
			$afaire=1;
		}
	}
	print "$ligne";	
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
print "<textarea name=texte cols=80 rows=20>";
print "</textarea><input type=submit></form>";


sub magique
{
	$desi=&get("select aerd_desi from aerodesi where aerd_trig='$destination'"); 
	$trouve=&get("select count(*) from vol where v_vol='$vol' and v_rot=1 order by v_code");
	if ($trouve==0){
	
		if ($desi eq "Portugal"){$v_cd_cl=545;}
		print "<a href=HTTP://ibs.oasix.fr/saivol.php?client=$v_cd_cl&vol=$vol&date='$date'&aeroport=$aeroport&destination=$destination&heure_dep=$heure_dep&heure_ar=''&vol_ret=''&datejour=$jour&datemois=$mois&datean=$an target=_blank>creer</a>";
		return;
		}
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
		if ($desi eq "Portugal"){$v_cd_cl=545;}
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
	
	if (($dest ne $destination)||($heure!=$heure_dep)){
		print "<font color=green>$dest</font><font color=red> $destination</font>";
		print "<font color=green> $heure</font><font color=red> $heure_dep</font>";
	}
}
sub cal_heure {
	my ($var)=@_[0];
	if ($var eq ""){return;}
	if ($var eq "&nbsp;"){return;}
	
	my ($dec)=@_[1];
	$var=$var+$dec;
	if ($var>2400){$var-=2400;}
	if ($var<0){$var+=2400;}
	return($var);
}
