#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "../oasix/simple.lib";

print $html->header;
require "./src/connect.src";

$query="select cl_cd_cl,cl_nom from client ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array)
{
	$client_dat{$cl_cd_cl}=$cl_nom;
}

$action=$html->param("action");
$index=$html->param("index");
print "<body onload=document.index.index.focus()><form name=index>Index <input type=text name=index><br><input type=submit><input type=hidden name=action value=go></form><br><table border=1>";
if ($action eq "go"){
	$query="select gsl_nolot,gsl_ind,gsl_apcode,gsl_novol,gsl_dtret,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4 from geslot where gsl_ind=$index";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($gsl_nolot,$gsl_ind,$gsl_apcode,$gsl_vol,$gsl_dtret,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4)=$sth->fetchrow_array){
		# $client=int($gsl_nolot/1000);
		$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";
		$sth_n=$dbh->prepare($query);
		$sth_n->execute();
		($client)=$sth_n->fetchrow_array;

		if ($client!=$cl_cd_cl){
			print "<tr><th colspan=8>";
			print $client_dat{$client};
			print "</td></tr>";
			$cl_cd_cl=$client;
		}
		print "<tr><td>$gsl_nolot</td><td> $gsl_vol</td><td> $gsl_apcode</td><td> $gsl_pb1</td><td> $gsl_pb2</td><td> $gsl_pb3</td><td> $gsl_pb4</td><td> ";
		print &julian($gsl_dtret,"");
		print "</td></tr>";
		}
}
print "</table></body>";
# -E Liste des lots en l'air