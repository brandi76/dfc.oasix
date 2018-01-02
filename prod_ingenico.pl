#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>temp</title>";
require "./src/connect.src";
# $dbh2 = DBI->connect("DBI:mysql:host=192.168.1.87:database=FLYDEV;","root","",{'RaiseError' => 1});

$query="select tr_cd_pr,pr_desi,floor(tr_prix/100) from trolley,produit where tr_code=180 and pr_cd_pr=tr_cd_pr order by tr_ordre";
$sth=$dbh->prepare($query);
$sth->execute();
while (($tr_cd_pr,$pr_desi,$tr_prix)=$sth->fetchrow_array){
	$desi=&get("select oa_desi from oasix_prod where oa_cd_pr=$tr_cd_pr");
	
	if ($desi eq ""){
		$ligne=substr($pr_desi,1,15);
		$ligne =~ tr /A-Z/a-z/ ;
                $desi=substr($pr_desi,0,1).$ligne;
		$bug=&get("select oa_cd_pr from oasix_prod where oa_desi='$desi'");
# 		if ($bug ne ""){print "<b>bug></b>";}
		# &save ("insert into oasix_prod values ('$tr_cd_pr','$desi')");
# 		print "$tr_cd_pr $pr_desi $desi $tr_prix->". length($desi)."<br>";	
	}
	print "{$tr_cd_pr,\"$desi\",$tr_prix,1,&PANIER},<br>";	

}	 
