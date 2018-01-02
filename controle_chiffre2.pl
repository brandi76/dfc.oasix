#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");


# @base_liste=("togo","aircotedivoire","camairco","tacv","cameshop");
@base_liste=("togo");
$query="select code,qte from stock_mensuel where base='togo' and date='2015-08-31'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code,$qte)=$sth->fetchrow_array){
	$entree=&get("select qte from achat_mensuel where base='togo' and code=$code and an=2015 and mois=9")+0;
	$vendu=&get("select qte from vendu_mensuel where base='togo' and code=$code and an=2015 and mois=9")+0;
	$stock_fin=&get("select qte from stock_mensuel where base='togo' and code=$code and date='2015-09-31'")+0;
	if ($stock_fin==$qte+$entree-$vendu){next;}
	print "$code*$qte*$entree*$vendu*$stock_fin<br>";
}
