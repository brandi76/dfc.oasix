#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";

print "<table border=1><tr><th>Base</th><th>Bl</th><th>Date facture</th><th>No facture</th><th>Fournisseur</th><th>Montant</th><th>Date entrée</th></tr>";
$query="select livh_id,livh_base,livh_date_facture,livh_facture,livh_four from livraison_h where year(livh_date_facture)=2015 and month(livh_date_facture)>6";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_id,$livh_base,$livh_date_facture,$livh_facture,$livh_four)=$sth->fetchrow_array){
	$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
	  $montant=int($montant*100)/100;
	  $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
	  $montant+=$frais;
	  if ($montant==0){next;}
	$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
	($fo_nom)=split(/\*/,$fo_add);
				  
	$date_entree=&get("select enh_date from $livh_base.enthead where enh_document='$livh_id'");
	if ($date_entree eq ""){ 
		print "<tr><td>$livh_base</td><td>$livh_id</td><td>$livh_date_facture</td><td>$livh_facture</td><td>$fo_nom</td><td align=right>$montant</td><td>NIL</td></tr>";
		$total+=$montant;
	}
	else{
		$date_entree=&julian($date_entree,"YYYY-MM-DD");
		($an)=split(/-/,$date_entree);
		if ($an >2015){
			print "<tr><td>$livh_base</td><td>$livh_id</td><td>$livh_date_facture</td><td>$livh_facture</td><td>$fo_nom</td><td align=right>$montant</td><td>$date_entree</td></tr>";
			$total+=$montant;
		}
	}
}
print "</table>";
print "Total:$total<br>";
