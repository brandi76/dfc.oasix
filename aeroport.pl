#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";

$html=new CGI;
print $html->header;
require "./src/connect.src";
print "<title>aeroport</title><body><center><br><form> Aeroport <input type=text size=3 name=tri><br><br><input type=submit value=go></form>";

if ($html->param("tri")ne""){
	$tri=$html->param("tri");
	$query="select aerd_desi from aerodesi where aerd_trig='$tri'";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($aerd_desi)=$sth->fetchrow_array;
	$query="select aero_desi,aero_type from aeroport where aero_tri='$tri'";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($aero_desi,$aero_type)=$sth->fetchrow_array;
	
	print "<h3>$aero_desi $aerd_desi ";
	$datedujour=&nb_jour(`/bin/date '+%d'`+0,`/bin/date '+%m'`+0,"20".`/bin/date '+%y'`+0);
        $dateref=$datedujour-100;
	$nb=&get("select count(*) from vol where v_dest like '%/$tri/%' and v_date_jl>=$dateref","af");
	print "$nb<br>";
	$desi=&get("select eu_desi from europe where eu_desi='$aerd_desi'","af");
	
	if ( $desi ne ""){print "<img src=http://ibs.oasix.fr/images/europe.jpg";} 
}

