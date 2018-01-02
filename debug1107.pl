#!/usr/bin/perl

use CGI;
use DBI();
require "../oasix/outils_perl2.pl";


# compare le fichier brut oasix avec les valeurs qui apparaissent dans la recap
$html=new CGI;
print $html->header;
$action=$html->param("action");
require "./src/connect.src";


$query="select oa_serial,oa_date_import,oa_rotation,oa_type,oa_col2,oa_col3,oa_rotation,oa_ind,oa_col1 from oasix where (oa_type='p' or oa_type='c') and oa_date_import >'2011-07-01' order by oa_serial,oa_date,oa_rotation,oa_ind ";
$sth = $dbh->prepare($query);
$sth->execute;
while (($oa_serial,$oa_date_import,$oa_rotation,$oa_type,$oa_col2,$oa_col3,$oa_rotation,$oa_ind,$oa_ticket) = $sth->fetchrow_array) {
	# print "<font color=green>$oa_serial,$oa_date_import,$oa_rotation,*$oa_type*,$oa_col2,$oa_col3,$oa_rotation,$oa_ind<->$val</font><br>";
	push (@tab,"$oa_serial,$oa_date_import,$oa_rotation,$oa_type,$oa_col2,$oa_col3,$oa_rotation,$oa_ind");
		
	if ($oa_type eq 'c'){
		$val2+=$oa_col2;
		$pass=1;
		$oa_seriala=$oa_serial;
		$oa_date_importa=$oa_date_import;
	}

	if ($oa_type eq 'p'){
		if ($pass==1){
			if ($val!=$val2){
				foreach (@tab){
					print "$_<br>";
				}
				print "<b>";
				print &get("select oaa_appro from oasix_appro where oaa_serial='$oa_seriala' and oaa_date='$oa_date_importa'","af");
				print " tpe:";
				print &get("select oa_num from oasix_tpe where oa_serial='$oa_seriala' ","af");
				print "</b><br><hr width=100%>";
			}
			$val=0;
			$val2=0;
			$pass=0;
			@tab=();
			push (@tab,"$oa_serial,$oa_date_import,$oa_rotation,$oa_type,$oa_col2,$oa_col3,$oa_rotation,$oa_ind");
			
		}
		$val+=$oa_col3;
	}
	if ($oa_type eq 'P'){
		$val+=$oa_col3;
	}
}

if (($val!=0)&&($val!=$val2)) {
			print "fin de boucle<br>";
			foreach (@tab){
				print "$_<br>";
			}
			print "<b>";
			print &get("select oaa_appro from oasix_appro where oaa_serial='$oa_seriala' and oaa_date='$oa_date_importa'","af");
			print "tpe:";
			print &get("select oa_num from oasix_tpe where oa_serial='$oa_seriala' ","af");
			print "</b><br><hr width=100%>";
	
		}
