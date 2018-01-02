#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();

$an_run=`/bin/date '+%Y'`;
chop($an_run);

$an=$html->param("an");
if ($an eq ""){
	print "<form>";
	&form_hidden();
	print "Année <input type=text name=an value=$an_run>";
	print "<br><input type=submit>";
	print "</form>";
}	
	
else {
	&save("create temporary table marge_tmp (cat varchar(30),montant decimal (8,2),achat decimal (8,2), primary key (cat))");
	$query="select facture.cde_id,cmd_web.client_id,montant from dutyfreeambassade.facture,dutyfreeambassade.cmd_web where year(facture.date)='$an' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cde_id,$client_id,$montant)=$sth->fetchrow_array){
		$client=$client_id;
		$client=~s/C//;
		$cat="Corps Diplomatique";
		if ($client >2000000){
			$cat="export";
		}
		if ($client=="9062901"){
			$cat="Boutique";
		}	
		if ($cat eq "Corps Diplomatique"){next;}
		$achat=0;
		$query="select  produit_id,prep from dutyfreeambassade.panier_web where cde_id='$cde_id'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($code,$qte)=$sth->fetchrow_array){
			$prix_achat=&get("select max(prix_unite) from dutyfreeambassade.produit_four where ref_dfa='$code'")+0;
			$achat+=$prix_achat*$qte;
		}
	
		&save("insert ignore into marge_tmp values ('$cat',0,0)");
		&save("update marge_tmp set montant=montant+$montant achat=achat+$achat where cat='$cat'","af");
		
	}	
	$query="select * from marge_tmp";	
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cat,$montant)=$sth->fetchrow_array){
		print "$cat,$montant<bR>";
	}
}
;1