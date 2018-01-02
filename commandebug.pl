#!/usr/bin/perl
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
use DBI();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=togo;","web","admin",{'RaiseError' => 1});

use CGI;
$html=new CGI;
print $html->header();

$liv_id=335;

# &save("update commande set com2_no_liv=$liv_id where com2_no='$com_no'");

$query="select * from commande where com2_no_liv='$liv_id'";

	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($com2_no,$com2_cd_fo,$com2_cd_pr,$com2_qte,$com2_prac,$com2_type,$com2_date,$com2_no_liv,$com2_liv)=$sth2->fetchrow_array){
	    &save("replace into commandearch values ('$com2_no','$com2_cd_fo','$com2_cd_pr','$com2_qte','$com2_prac','0','$com2_date','0','$liv_id')","aff");
	  }
	  
	  $query="select distinct(com2_no) from commande where com2_no_liv='$liv_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($com2_no)=$sth2->fetchrow_array){
		  &save("update commande_info set etat=5 where com_no=$com2_no","aff");
	  }
	   $query="select com2_no,com2_cd_pr from commande where com2_no_liv='$liv_id'";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($com2_no,$com2_cd_pr)=$sth2->fetchrow_array){
	  	  &save("delete from commande where com2_no='$com2_no' and com2_cd_pr='$com2_cd_pr'","aff");
	  }
	  
