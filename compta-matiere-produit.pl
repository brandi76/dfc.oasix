#!/usr/bin/perl
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
use DBI();
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
use CGI;
$html=new CGI;
# print $html->header();
$action=$html->param("action");
$code=$html->param("code");

if ($action eq ""){
  print "<form>";
  &form_hidden();
  print "Code produit <input type=text name=code><br>";
  print "<input type=submit>";
  print "<input type=hidden name=action value=go>";
  print "</form>";
}
if ($action eq "go"){
  $query="select * from enso where es_cd_pr='$code' order by date desc";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array){
    print "$es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type<br>";
  }
}    
