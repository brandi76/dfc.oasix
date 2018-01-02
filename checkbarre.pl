#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;

# print $html->header;
require "./src/connect.src";
print $html->header();
$query="select pr_cd_pr,pr_desi,pr_codebarre from produit where pr_codebarre>0 and pr_codebarre<999999999999 and pr_cd_pr<100000000";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_codebarre)=$sth->fetchrow_array){
	 $query="select ba_code from barre where ba_cd_pr='$pr_cd_pr'";
	 $sth2=$dbh->prepare($query);
	 $sth2->execute();
	 ($pr_codebarre)=$sth2->fetchrow_array;
	 $pr_codebarre+=0;
	if ($pr_codebarre <100000000){next;}
		


$pr_codebarre*=10;
$check=$pr_codebarre%10;
$oper=1;
$somme=0;
for ($i=12;$i>0;$i--){
	$digit=int($pr_codebarre/10**$i)%10;
	$somme+=$digit*$oper;
	if ($oper==1){$oper=3;}else{$oper=1;}
# 	print "$digit*$somme;";
}
$somme%=10;
$somme=(10-$somme)%10;
if ($check!=$somme){
	
	$pr_codebarre=int($pr_codebarre/10);
	
	# $pr_codebarre.=$somme;
# $query="update produit set pr_codebarre='$pr_codebarre' where pr_cd_pr='$pr_cd_pr'";
#$sth3=$dbh->prepare($query);
#$sth3->execute();

print "$pr_cd_pr $pr_desi $pr_codebarre $check $somme<br>";}
}