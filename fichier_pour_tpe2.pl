#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;

require "./src/connect.src";
                
$trol=307;

$query="select tr_ordre,pr_type,tr_cd_pr,ucase(left(pr_desi,1)),lcase(substring(pr_desi,2,15)),floor(tr_prix/100) from trolley ,produit where tr_code=$trol and tr_cd_pr=pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute;
while (($tr_ordre,$pr_type,$pr_cd_pr,$pr_deb,$pr_desi,$pr_prix)=$sth->fetchrow_array){
 	$pr_desi=$pr_deb.$pr_desi;
 	if ($pr_cd_pr==800150){next;}
 	if ($pr_type==1 and $tr_ordre<180){$type=1;}
 	if ($pr_type==3){$type=0;}
 	if ($pr_type==1 and $tr_ordre>=180){$type=2;}
 	if ($pr_type==2){$type=3;}
 	if ($pr_type==5){$type=4;}
 	if ($pr_type==4){$type=5;}
 	
 	if ($pr_cd_pr==800200){
 		$query="select pr_cd_pr,ucase(left(pr_desi,1)),lcase(substring(pr_desi,2,15)),floor(po_prix/100) from pochon,produit where po_cd_pr=pr_cd_pr";
 		$sth5=$dbh->prepare($query);
 		$sth5->execute();
 		while (($po_cd_pr,$po_deb,$po_desi,$po_prix)=$sth5->fetchrow_array){
 			$po_desi=$po_deb.$po_desi;
			print "{$pr_cd_pr,\"$pr_desi\",$pr_prix;1;&PANIER}<br>";
 		}
 	}
 	else
 	{
		if ($pr_cd_pr==800201){$type=4;$pr_desi="Lunette";$pr_prix=15;}
		print "{$pr_cd_pr,\"$pr_desi\",$pr_prix;1;&PANIER},<br>";
 	}
}
