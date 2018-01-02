#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";

$query="SELECT
  table_schema AS NomBaseDeDonnees, 
  ROUND(SUM( data_length + index_length ) / 1024 / 1024, 2) AS BaseDonneesMo 
FROM information_schema.TABLES
GROUP BY TABLE_SCHEMA order by  BaseDonneesMo";
my($sth)=$dbh->prepare($query);
$sth->execute();
while (($base,$taille)=$sth->fetchrow_array){
print "$taille Mo  $base<br>";
$total+=$taille;
}
print "$total Mo";
$total=0;
$query="SELECT
 TABLE_NAME,
 ROUND(((DATA_LENGTH + INDEX_LENGTH - DATA_FREE) / 1024 / 1024), 2) AS TailleMo 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'togo' order by TailleMo";
my($sth)=$dbh->prepare($query);
$sth->execute();
while (($base,$taille)=$sth->fetchrow_array){
print "$taille Mo  $base<br>";
$total+=$taille;
}
print "$total Mo";
 