#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
print "planning cdg axy couleur<br>";
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

# while ($texte=~s/  / /){};
(@ligne)=split(/\n/,$texte);

print "<pre>";
foreach $ligne (@ligne){
	chop($ligne);
	while ($ligne=~s/  / /){};
	@mot=();
	(@mot)=split(/ /,$ligne);

	$nb=0;
	$slot=0;
	$cdg=0;
	$vol="";
	$afaire=0;
	$heure=0;
	$dest="";
	if (grep /\//,$mot[10]){
		($null,$mot[10])=split(/\//,$mot[10]);
	}
	if (grep /200/,$mot[0]){
		$jour=substr($mot[0],0,2);
		$mois=substr($mot[0],3,2);
		$an=substr($mot[0],6,4);
		$date=&nb_jour($jour,$mois,$an);
	}		
	while ($mot[1]=~s/ //){};
	while ($mot[1]=~s/\t//){};
 	$vol=$mot[1];	
	# print "$jour $mois $an";
 	$nb=&get("select count(*) from flyhead where fl_date='$date' and fl_vol='$vol'");
 	if ($mot[2]>0){
 			($h,$m)=split(/H/,$mot[2]);
 			$heure=$h.$m;
 			$ligne=~s/ $mot[2] / <b>$mot[2]<\/b> /;
 			$cdg=1;
 	}
	if (($mot[10] eq "")&&($mot[2]>0)){
		
		print "<font color=green>";
		$i=$#mot;
		while (($mot[10] eq "") && ($i>0)){
			$mot[10]=$mot[$i--];
		}
	}
 	# print "*$mot[10]*";	
	while ($mot[10]=~s/ //){};
	while ($mot[10]=~s/\t//){};

	$query="select aerd_trig,aerd_desi from aerodesi where aerd_trig='$mot[10]'"; 
	# print $query;
	$sth=$dbh->prepare($query);
 	$sth->execute();
	($trig,$desi)=$sth->fetchrow_array;
	$ok=1;
	foreach $pays (@europe){
 		if ($desi eq $pays){$ok=0;}
 	}
	if (($trig ne "")&&($ok==1)){
 			$dest=$trig;
 			$ligne=~s/ $trig / <font color=red>$trig<\/font> /;
 			$ligne=~s/$trig\// <font color=red>$trig\/<\/font>/;
 		
 			$afaire=1;
	}
 	print "$ligne </font>";	
 	if (($cdg==1 && $nb==0 && $afaire==1)){
 		print "<img src=http://ibs.oasix.fr/ko.jpg>";
 		&magique();
 	}
 	
 	if ($nb>0 && $cdg==1 && $afaire==1){
 		print "<img src=http://ibs.oasix.fr/ok.gif>";
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
	
	if (($dest ne $destination)||($heure!=$heure_dep+100)){
		print "<font color=red>$destination $heure_dep</font>";
	}
}
