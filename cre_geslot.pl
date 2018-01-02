#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";

$lot=$html->param("lot");
$action=$html->param("action");

require "./src/connect.src";
if ($action eq ""){
	print "<html><body><h1> CREATION MODIFICATION DE LOT </h1><br>";
	print "<form>No de lot ?:<input type=texte name=lot size=6><input type=submit name=action value=go></form>" ;
	print "</body></html>";
}
if (($action eq "go")&&($lot<9999)&&($lot>1000)){
	$query="select * from geslot where gsl_nolot>$lot*100 and gsl_nolot<($lot*100)+99 order by gsl_nolot desc limit 1";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array;
	$gsl_nolot++;
	$gsl_pb1=$gsl_pb2=$gsl_pb3=$gsl_pb4=$gsl_pb5=$gsl_pb6=$gsl_pb7=0;
	$gsl_ind=6;
	$gsl_apcode="";
	$query="replace into geslot values('$gsl_nolot','$gsl_ind','$gsl_dtret','$gsl_novol','$gsl_dtvol','$gsl_troltype','$gsl_pb1','$gsl_pb2','$gsl_pb3','$gsl_pb4','$gsl_pb5','$gsl_pb6','$gsl_pb7','$gsl_hrret','$gsl_triret','$gsl_apcode','$gsl_nb_cont','$gsl_desi','$gsl_trajet','$gsl_alc','$gsl_tab','$gsl_nodep','$gsl_noret','$gsl_nbpb','$gsl_tpe')";
	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute;
	$lot=$gsl_nolot;
}	
if ($action eq "saiplomb"){
	$pb1=$html->param("pb1")+0;
	$pb2=$html->param("pb2")+0;
	$pb3=$html->param("pb3")+0;
	$pb4=$html->param("pb4")+0;
	$pb5=$html->param("pb5")+0;
	$pb6=$html->param("pb6")+0;
	$pb7=$html->param("pb7")+0;
	if ($pb1>0){
		$query="update geslot set gsl_pb1=$pb1,gsl_pb2=$pb2,gsl_pb3=$pb3,gsl_pb4=$pb4,gsl_pb5=$pb5,gsl_pb6=$pb6,gsl_pb7=$pb7,gsl_ind=0 where gsl_nolot=$lot";
		$sth=$dbh->prepare($query);
		$sth->execute;
		}
	$action="go";
}

if ($action eq "go"){
	$query="select * from geslot where gsl_nolot=$lot";
	$sth=$dbh->prepare($query);
	$sth->execute;
	($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array;
	print "<b>$gsl_nolot</b><br>";
	print "<form>";
	print "plomb1 <input type=text name=pb1 value=$gsl_pb1><br>";
	print "plomb2 <input type=text name=pb2 value=$gsl_pb2><br>";
	print "plomb3 <input type=text name=pb3 value=$gsl_pb3><br>";
	print "plomb4 <input type=text name=pb4 value=$gsl_pb4><br>";
	print "plomb5 <input type=text name=pb5 value=$gsl_pb5><br>";
	print "plomb6 <input type=text name=pb6 value=$gsl_pb6><br>";
	print "plomb7 <input type=text name=pb7 value=$gsl_pb7><br>";
	print "<input type=hidden name=lot value=$lot>";
	print "<input type=submit name=action value=saiplomb></form>";
}

if ($action eq "saiplomb"){
	$query="update geslot set gsl_pb1=$pb1,gsl_pb1=$pb1,gsl_pb1=$pb1,gsl_pb1=$pb1,gsl_pb1=$pb1,gsl_pb1=$pb1,gsl_pb1=$pb1,gsl_ind=0 where gsl_nolot=$lot";
	$sth=$dbh->prepare($query);
	$sth->execute;
}

