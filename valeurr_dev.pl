#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");

$date_ref="2015-12-31";
$client="togo";
$query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_cd_pr=100117";
$sth=$dbh->prepare($query);
$sth->execute();
($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array;
%stock=&stock_comptabledev($pr_cd_pr,'',"quick");
$stck=$stock{"pr_stre"};
if ($stck <0){next;}
if ($stck==0){next;}
$sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
$entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
$stck-=$entree;
$stck+=$sortie;
$total=$stck*$pr_prac;
$total_gen+=$total;
print "$pr_cd_pr $pr_desi stock:$stck  entree:$entree sortie:$sortie<br>";


$client="togo_2015";
$query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_cd_pr=100005";
$sth=$dbh->prepare($query);
$sth->execute();
($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array;
%stock=&stock_comptabledev($pr_cd_pr,'',"quick");
$stck=$stock{"pr_stre"};
if ($stck <0){next;}
if ($stck==0){next;}
$sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
$entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
$stck-=$entree;
$stck+=$sortie;
$total=$stck*$pr_prac;
$total_gen+=$total;
print "$pr_cd_pr $pr_desi stock:$stck  entree:$entree sortie:$sortie<br>";

			
sub stock_comptabledev {
	my($prod)=$_[0];
	my($stock,$non_sai,$pastouch,$max,$pastouch2,$retourdujour,$errdep);
	my(%stock);
	my($query) = "select * from $client.produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	my($produit)=$sth->fetchrow_hashref;
	$stock{"vol"}=$produit->{'pr_stvol'}/100;
	$query = "select sum(erdep_qte) from $client.errdep where erdep_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$errdep=$sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	$stock{"pr_stre"}=$stock{"stre"}-$stock{"casse"}+$stock{"diff"}+$stock{"errdep"}; # stock comptable
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100; # entrepot
	return(%stock);
}


;1