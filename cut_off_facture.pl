#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";

	print $html->header;
	print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
	<!--
	#saut { page-break-after : right }
	-->
	</style></head><body>";

require "./src/connect.src";
$date_ref='2015-09-30';
$query="select livh_id,livh_base,livh_facture,livh_date_facture from livraison_h where livh_date_facture<='$date_ref'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_id,$livh_base,$livh_facture,$livh_date_facture)=$sth->fetchrow_array)
{
	$es_dt=&get("select es_dt from $livh_base.enso,$livh_base.enthead where es_no_do=enh_no and enh_document='$livh_id' and es_dt>'$date_ref' limit 1","af");
	if ($es_dt eq ""){next;}
	$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	$montant=int($montant*100)/100;
	$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
	$montant+=$frais;
 	print "$livh_id;$livh_base;$livh_facture;'$livh_date_facture;'$es_dt;$montant<br>";
}
print "fin";
