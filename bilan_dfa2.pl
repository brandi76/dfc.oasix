#!/usr/bin/perl
use DBI();
use CGI();
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
$html=new CGI;
print $html->header();
&param();

&save("create temporary table dfa_tmp (id int(8) AUTO_INCREMENT, es_no_do int(8),es_cd_pr bigint(14), no_de_bl  int(8),four int(8) ,date date,local int(2),montant decimal(8,2),primary key (id))");

 # $query="select code,sum(qte) from corsica.inventaire_manu where (date='2017-01-04 00:00:00'  and pdv='depot') or (date(date)='2017-01-04' and pdv='boutique1') or (date(date)='2017-01-03' and pdv='boutique2') group by code";
# $query="select code,qte from corsica.stock_2016";
$query="select code,sum(qte) from corsica.inventaire_manu where date(date)='2016-01-04' group by code";

$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$qte)=$sth->fetchrow_array){
	($prix,$pr_four,$pr_desi)=&get("select pr_prac/100,pr_four,pr_desi from corsica.produit where pr_cd_pr='$code'");
	$val=$prix*$qte;
	
	print "$code;$pr_desi;$qte;$prix;$val<br>";
	$stock{$pr_four}+=$val;
}
foreach $cle (keys(%stock)){
	$fo2_add=&get("select fo2_add from corsica.fournis where fo2_cd_fo='$cle'");
	($fo2_add)=split(/\*/,$fo2_add);
	print "$cle $fo2_add $stock{$cle} $total<br>";	
	$total+=$stock{$cle}
}
print "total:$total";
