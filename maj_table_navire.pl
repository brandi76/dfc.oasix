#!/usr/bin/perl
use CGI;
use DBI();

require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
require "./src/connect.src";
&save("delete from table_navire");
 $query="select nav_nom from navire";
 $sth=$dbh->prepare($query);
 $sth->execute();
 while (($navire)=$sth->fetchrow_array)
  	{
 	print "$navire \n";
	$query="select nav_cd_pr from navire2 where nav_nom='$navire' and nav_type=0";
 	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr)=$sth2->fetchrow_array){
# 		 print "$pr_cd_pr\n";
  		%calcul=&table_navire($navire,$pr_cd_pr);
 	}
  }		
