#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

open(FILE1,"find /mnt/windows/AGENDA1/ -name \"*.CIB\" |");
@liste_dat = <FILE1>;
close(FILE1);

print $html->header;
require "./src/connect.src";

foreach (@liste_dat){
	print "$_<br>";
	$fichier=$_;
	$infr_caissepn,$infr_caisseth,$total=0;
	
open(FILE1,"$fichier");
@cib_dat = <FILE1>;
close(FILE1);


foreach (@cib_dat){
	($type,$val1,$val2)=split(/;/,$_);
	if ($type eq "Z"){
		$val1=~s/\///;
		$appro=$val1;
		}
	if ($type eq "7"){
		$val1=~s/\+//;
		$total+=$val1;
		}
	}
$appro+0;
if ($appro <10000){next;}
if ($appro >100000){next;}


$query="select infr_code,infr_date,infr_nom,infr_caissepn,infr_caisseth,infr_comment from inforet where infr_code=$appro";
# print $query;
$sth=$dbh->prepare($query);

$sth->execute();
($infr_code,$infr_date,$infr_nom,$infr_caissepn,$infr_caisseth,$infr_comment,$v_cd_cl)=$sth->fetchrow_array;

$query="select v_cd_cl from vol where v_code=$appro";
# print $query;
$sth=$dbh->prepare($query);
$sth->execute();
$v_cd_cl="";
($v_cd_cl)=$sth->fetchrow_array;
if ($v_cd_cl eq ""){next;}
if ($v_cd_cl != 123){next;}
if ($infr_caissepn!=0){
print $fichier,";",$appro,";",$total/100,";",$infr_caissepn/100,";";
if ($infr_caissepn==$total){print "*;";$ok++}
$nb++;
print "<br>";
}
	}

print "<br>$ok $nb";
# -E importation du fichier cib