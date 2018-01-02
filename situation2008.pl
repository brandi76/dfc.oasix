#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";

$html=new CGI;
print $html->header;

require "./src/connect.src";
print "<title>situation</title>";
print "<b>mega 2 </b><br>";
$amount=0;	

###### MEGA 2 ###############

$sth = $dbh->prepare("select nav_cd_pr,nav_qte from navire2 where nav_date='2008-10-09' and nav_type=1 and nav_nom='MEGA 2'" );
$sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desin=&get("select nep_desi from neptune where nep_codebarre='$nav_cd_pr'");
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	if ($pr_desi eq "") { $pr_desi=$pr_desin;}
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
	if ($pr_prac==0){
		$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'")+0;
		$val=$pr_prac*$nav_qte;	
	}

#     	 print "$nav_cd_pr $pr_desi $nav_qte $pr_prac $val<br>";
    	$total+=$val;
}
print "<br>Valeur de l'inventaire au 9 octobre:$total<br>";
$amount=$total;
$total=0;
$sth = $dbh->prepare("select coc_cd_pr,coc_qte/100 from comcli where coc_no=11545" );
$sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
    	# print "$nav_cd_pr $pr_desi $nav_qte $pr_prac $val<br>";
    	$total+=$val;
}
print "Valeur de la livraison post 30/09:$total<br>";
$amount-=$total;
$total=0;
$sth = $dbh->prepare("select tva_refour,tva_qte from corsica_tva where tva_nom='MEGA 2' and tva_date >='2008-10-01' and tva_date <='2008-10-08'" );
$sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
    	# print "$nav_cd_pr $pr_desi $nav_qte $pr_prac $val<br>";
    	$total+=$val;
}
print "Valeur des vendus du 1 au 8 octobre: $total<br>";
$amount+=$total;

print "Valeur comptable mega 2 au 30/09/08:$amount<br>";



###### MARINA ###############


print "<b>marina </b><br>";
$amount=0;	
	
$sth = $dbh->prepare("select nav_cd_pr,nav_qte from navire2 where nav_date='2008-10-05' and nav_type=1 and nav_nom='MARINA'" );
$sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desin=&get("select nep_desi from neptune where nep_codebarre='$nav_cd_pr'");
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	if ($pr_desi eq "") { $pr_desi=$pr_desin;}
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
	if ($pr_prac==0){
		$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'")+0;
		$val=$pr_prac*$nav_qte;	
	}
    	$total+=$val;
}
print "<br>Valeur de l'inventaire au 5 octobre:$total<br>";
$amount=$total;
# $total=0;
# $sth = $dbh->prepare("select coc_cd_pr,coc_qte/100 from comcli where coc_no=11545" );
# $sth->execute;
# while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
# {
#     	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
#     	$pr_prac=&prac($nav_cd_pr);
# 	$val=$pr_prac*$nav_qte;	
#     	$total+=$val;
# }
# print "Valeur de la livraison post 30/09:$total<br>";
# $amount-=$total;
 $total=0;
 $sth = $dbh->prepare("select tva_refour,tva_qte from corsica_tva where tva_nom='MARINA' and tva_date >='2008-10-01' and tva_date <='2008-10-05'" );
 $sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
    	$total+=$val;
}
print "Valeur des vendus du 1 au 5 octobre: $total<br>";
$amount+=$total;
print "Valeur comptable marina au 30/09/08:$amount<br>";


###### SMERALDA ###############


print "<b>smeralda </b><br>";
$amount=0;	
$navire="SMERALDA";	

$sth = $dbh->prepare("select nav_cd_pr,nav_qte from navire2 where nav_date='2008-10-08' and nav_type=1 and nav_nom='$navire'" );
$sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desin=&get("select nep_desi from neptune where nep_codebarre='$nav_cd_pr'");
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	if ($pr_desi eq "") { $pr_desi=$pr_desin;}
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
	if ($pr_prac==0){
		$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'")+0;
		$val=$pr_prac*$nav_qte;	
	}
    	$total+=$val;
}
print "<br>Valeur de l'inventaire au 8 octobre:$total<br>";
$amount=$total;
 $total=0;
 $sth = $dbh->prepare("select coc_cd_pr,coc_qte/100 from comcli where coc_no=11549" );
 $sth->execute;
 while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
 {
     	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
     	$pr_prac=&prac($nav_cd_pr);
 	$val=$pr_prac*$nav_qte;	
     	$total+=$val;
 }
 print "Valeur de la livraison post 30/09:$total<br>";
 $amount-=$total;
 $total=0;
 $sth = $dbh->prepare("select tva_refour,tva_qte from corsica_tva where tva_nom='$navire' and tva_date >='2008-10-01' and tva_date <='2008-10-07'" );
 $sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
    	$total+=$val;
}
print "Valeur des vendus du 1 au 8 octobre: $total<br>";
$amount+=$total;
print "Valeur comptable $navire au 30/09/08:$amount<br>";

###### MEGA 1 ###############


print "<b>mega 1 </b><br>";
$amount=0;	
$navire="MEGA 1";	
$total=0;
$sth = $dbh->prepare("select nav_cd_pr,nav_qte from navire2 where nav_date='2008-10-08' and nav_type=1 and nav_nom='$navire'" );
$sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desin=&get("select nep_desi from neptune where nep_codebarre='$nav_cd_pr'");
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	if ($pr_desi eq "") { $pr_desi=$pr_desin;}
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
	if ($pr_prac==0){
		$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'")+0;
		$val=$pr_prac*$nav_qte;	
	}
    	$total+=$val;
}
print "<br>Valeur de l'inventaire au 8 octobre:$total<br>";
$amount=$total;
 $total=0;
 $sth = $dbh->prepare("select coc_cd_pr,coc_qte/100 from comcli where coc_no=11544" );
 $sth->execute;
 while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
 {
     	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
     	$pr_prac=&prac($nav_cd_pr);
 	$val=$pr_prac*$nav_qte;	
     	$total+=$val;
 }
 print "Valeur de la livraison post 30/09:$total<br>";
 $amount-=$total;
 $total=0;
 $sth = $dbh->prepare("select tva_refour,tva_qte from corsica_tva where tva_nom='$navire' and tva_date >='2008-10-01' and tva_date <='2008-10-07'" );
 $sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
    	$total+=$val;
}
print "Valeur des vendus du 1 au 7 octobre: $total<br>";
$amount+=$total;
print "Valeur comptable $navire au 30/09/08:$amount<br>";

###### MEGA 4 ###############


print "<b>mega 4 </b><br>";
$amount=0;	
$total=0;
$navire="MEGA 4";	

$sth = $dbh->prepare("select nav_cd_pr,nav_qte from navire2 where nav_date='2008-10-07' and nav_type=1 and nav_nom='$navire'" );
$sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desin=&get("select nep_desi from neptune where nep_codebarre='$nav_cd_pr'");
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	if ($pr_desi eq "") { $pr_desi=$pr_desin;}
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
	if ($pr_prac==0){
		$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$nav_cd_pr'")+0;
		$val=$pr_prac*$nav_qte;	
	}
    	$total+=$val;
}
print "<br>Valeur de l'inventaire au 7 octobre:$total<br>";
$amount=$total;
 $total=0;
 $sth = $dbh->prepare("select coc_cd_pr,coc_qte/100 from comcli where coc_no=11545" );
 $sth->execute;
 while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
 {
     	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
     	$pr_prac=&prac($nav_cd_pr);
 	$val=$pr_prac*$nav_qte;	
     	$total+=$val;
 }
 print "Valeur de la livraison post 30/09:$total<br>";
 $amount-=$total;
 $total=0;
 $sth = $dbh->prepare("select tva_refour,tva_qte from corsica_tva where tva_nom='$navire' and tva_date >='2008-10-01' and tva_date <='2008-10-06'" );
 $sth->execute;
while (($nav_cd_pr,$nav_qte)=$sth->fetchrow_array)
{
    	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$nav_cd_pr'");
    	$pr_prac=&prac($nav_cd_pr);
	$val=$pr_prac*$nav_qte;	
    	$total+=$val;
}
print "Valeur des vendus du 1 au 6 octobre: $total<br>";
$amount+=$total;
print "Valeur comptable $navire au 30/09/08:$amount<br>";

