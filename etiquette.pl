#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

require "./src/connect.src";
print $html->header;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
$nodepart=$html->param('nodepart');
$sth=$dbh->prepare("select liv_vol,liv_date from listevol where liv_dep=$nodepart");
$sth->execute();
print "<table border=1 cellpadding=20 width=100%><tr>";
$point=0;
while (($liv_vol,$liv_date)=$sth->fetchrow_array){
	$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_nolot,fl_apcode from flyhead where fl_date=$liv_date and fl_vol='$liv_vol'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nolot,$fl_apcode)=$sth2->fetchrow_array;
	$no_lot=$fl_troltype*100+$fl_nolot;
	$query="select flb_depart from flybody where flb_date=$liv_date and flb_vol='$liv_vol' and flb_rot=11";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($flb_depart)=$sth2->fetchrow_array;
	
	$query="select gsl_nolot,gsl_apcode,gsl_desi,gsl_trajet,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7,gsl_nbcont from geslot where gsl_nolot=$no_lot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($gsl_nolot,$gsl_apcode,$gsl_desi,$gsl_trajet,$gsl_nbpb,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_nbcont)=$sth2->fetchrow_array;
	$query="select cl_trilot from client where cl_cd_cl='$fl_cd_cl'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($cl_trilot)=$sth2->fetchrow_array;
	$no_lot=$gsl_nolot%1000;
	print "************************$gsl_nbcont";
	for ($j=0;$j<=$gsl_nbcont;$j++){
		print "<td width=50% height=520><font size=+5>$cl_trilot $no_lot $gsl_desi<br></font><font size=+3>$fl_vol $gsl_dest<br>$gsl_trajet<br>";
		print "$fl_date CHGT ";
		print &deci2($flb_depart/100);
		print "<br>appro:$fl_apcode<br></font><font size=+2>plombs:";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			print ${gsl_pb."$i"}." ";
		}
		print " </font></td>";
		$point++;
		if ($point==2){ 
			print "</tr><tr>";
		}
		if ($point==4){ 
			print "</tr></table>";
			print "<div id=saut></div>";
			print "<table cellpadding=20 border=1 width=100%><tr>";
			$point=0;
		}
	}

}
print "</tr></table>";