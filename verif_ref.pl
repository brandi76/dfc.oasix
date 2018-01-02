#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
require "./src/connect.src";

$code=$html->param("code");
$base=$html->param("base");

$base1="togo";
$base2="aircotedivoire";

if ($code ne ""){
  if ($base==1){
    &save("update $base1.produit,$base2.produit set $base2.produit.pr_desi=$base1.produit.pr_desi where  $base2.produit.pr_cd_pr=$base1.produit.pr_cd_pr","aff");
  }
  else {
    &save("update $base1.produit,$base2.produit set $base1.produit.pr_desi=$base2.produit.pr_desi where  $base2.produit.pr_cd_pr=$base1.produit.pr_cd_pr","aff");
  }
  
}

print "<form name=maform>";
print "<input type=hidden name=code>";
print "<input type=hidden name=base>";
$query="select $base1.produit.pr_cd_pr,$base1.produit.pr_desi,$base2.produit.pr_desi from $base1.produit,$base2.produit where $base1.produit.pr_cd_pr=$base2.produit.pr_cd_pr and $base1.produit.pr_desi!=$base2.produit.pr_desi";
$sth=$dbh->prepare($query);
$sth->execute;
while (($pr_cd_pr,$desi1,$desi2)= $sth->fetchrow_array) {
    print "$pr_cd_pr $desi1 ";
    print "<input type=button onclick=document.maform.code.value=$pr_cd_pr;document.maform.base.value=1;document.maform.submit()>";
    print "<span style=color:green>$desi2</span>";
    print "<input type=button onclick=document.maform.code.value=$pr_cd_pr;document.maform.base.value=2;document.maform.submit()>";
    print "<br>";
}
print "/<form>";