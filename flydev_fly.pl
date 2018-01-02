#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";

print $html->header;
print "<html><head><Meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body>";

require "./src/connect.src";
require "./src/connect.src";

$query="select * from geslot ";
$sth=$dbhdev->prepare($query);
$sth->execute();
while (($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array){
	$query="select gsl_nolot from geslot where gsl_nolot='$gsl_nolot'";
	$sth2=$dbh->prepare($query);
	if ($sth2->execute()<1){
		$query="insert into geslot values ($gsl_nolot,$gsl_ind,$gsl_dtret,'$gsl_novol',$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,'$gsl_triret','$gsl_apcode',$gsl_nb_cont,'$gsl_desi','$gsl_trajet',$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		print $gsl_nolot."<br>";
	}

}

	
