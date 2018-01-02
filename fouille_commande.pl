#!/usr/bin/perl
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
use DBI();
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
use CGI;
$html=new CGI;
print $html->header();
$code=$html->param("code");
$base=$html->param("base");
push(@bases_client,"corsica");
print "<form>";
&form_hidden();
print "Base ";
print "<select name=base>";
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	print "<option value=$client";
	print ">$client</option>";
}
	print "</select>";

print "Code produit <input name=code><br>";
print "<input type=hidden name=action value=go>";
print "<input type=submit>";
print "</form>";
if ($code ne ""){
	$query="select * from $base.enso where es_cd_pr=$code and es_qte_en>0 order by es_dt";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array){
		$es_qte_en/=100;
		print "date:$es_dt no d'entree:$es_no_do qte:$es_qte_en ";
		$enh_document=&get("select enh_document from $base.enthead where enh_no='$es_no_do'");
		print "Bordereau de livraison:$enh_document";
		$query="select distinct com2_no from $base.commande where com2_no_liv='$enh_document'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($com_no)=$sth2->fetchrow_array){
			print " Commande: $com_no";
		}
		$query="select distinct com2_no from $base.commandearch where com2_no_liv='$enh_document'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($com_no)=$sth2->fetchrow_array){
			print " Commande: $com_no";
		}
		print "<br><hr></hr>";
	}
}