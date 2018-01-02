#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
require "./src/connect.src";

$lta=$html->param("lta");
if ($lta eq ""){
 print "<p style=background:lavender>Ancun No de Lta</p>";
}
else
{
  print "<h3>$lta</h3>";
  $query="select livh_id,livh_base,livh_four,livh_facture,livh_date_lta from dfc.livraison_h where livh_lta='$lta'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  print "<table border=1 cellspacing=0><tr><th>Bl</th><th>Base</th><th>Fournisseur</th><th>Facture</th><th>Date livraison</th></tr>";
  while (($livh_id,$livh_base,$livh_four,$livh_facture,$livh_date_lta)=$sth->fetchrow_array){
    ($fo_nom,$null)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$livh_four'"));
    print "<tR><td>$livh_id</td><td>$livh_base</td><td>$livh_four $fo_nom</td><td>$livh_facture</td><td>$livh_date_lta</td></tr>";
    $client=$livh_base;
  }
  print "</table>";
  print "<table border=0>";
  $file="/var/www/$client.oasix/doc/lta_".$lta."_fact_fo.pdf";
  if (-f $file){
  print "<tr><td align=right>Facture fournisseur</td><td><a href=http://$client.oasix.fr/doc/lta_".$lta."_fact_fo.pdf><img src=/images/pdf.jpg></a></td></tr>";
  $ok=1;
  }
  $file="/var/www/$client.oasix/doc/lta_".$lta."_fact_tr.pdf";
  if ( -f $file){
  print "<tr><td align=right>Facture Transitaire</td><td><a href=http://$client.oasix.fr/doc/lta_".$lta."_fact_tr.pdf><img src=/images/pdf.jpg></a></td></tr>";
  $ok=1;
  }
  $file="/var/www/$client.oasix/doc/lta_".$lta.".pdf";
  if (-f $file){
  print "<tr><td align=right>Lta</td><td><a href=http://$client.oasix.fr/doc/lta_".$lta.".pdf><img src=/images/pdf.jpg></a></td></tr>";
  $ok=1;
  }
  print "</table>";
  if (! $ok){print "<p style=background:lavender>Aucun document disponible</p>";}
}
print "<br><input type=button value=fermer onclick=window.close()>";

;1