#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=dutyfreeconcept.com:database=6192_tmp;","6192_sb","passe123",{'RaiseError' => 1});

$query="select test from essai";
my($sth)=$dbh->prepare($query);
$sth->execute();

$res=$sth->fetchrow_array;
print "$res*";
