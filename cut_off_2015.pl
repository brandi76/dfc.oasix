#!/usr/bin/perl
use CGI;
use DBI();
       
$html=new CGI;
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$date_ref="2015-12-31";
@bases_client=("camairco_2015","togo_2015","aircotedivoire_2015","tacv_2015");
foreach $client (@bases_client) {
	$total=$total_gen=0;
	$qte=$nb=0;
	# print "<table>";
	$query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
		 $sth=$dbh->prepare($query);
		 $sth->execute();
		 while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
		 {
			 %stock=&stock_comptable($pr_cd_pr,'',"quick");
			 $stck=$stock{"pr_stre"};
			 $sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			 $entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			 $stck-=$entree;
			 $stck+=$sortie;
			  if ($stck <=0){next;}
			 $total=$stck*$pr_prac;
			 	# print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$stck</td><td>$pr_prac</td><td>$total</td></tr>";
		
			 $total_gen+=$total;
			 $nb++;
			 $qte+=$stck;
		 }
	# print "</table>";
		 print "$client $total_gen  nb:$nb qte:$qte <br>";
}	


	
if ($action eq "detail_stock"){
	$client=$html->param("client");
	$query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "stock comptable $client $date_ref<br>";
	print "<table><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
	{
		if ($client ne "cameshop"){
			# $query="select qte,prac from stock_mensuel where base='$client' and code='$pr_cd_pr' and date='$date_ref'";
			# $sth2=$dbh->prepare($query);
			# $sth2->execute();
			# ($stck,$pr_prac)=$sth2->fetchrow_array;
			 %stock=&stock_comptable($pr_cd_pr,'',"quick");
			 $stck=$stock{"pr_stre"};
			if ($stck <0){next;}
			if ($stck==0){next;}
			 $sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			 $entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			 $stck-=$entree;
			 $stck+=$sortie;
		 }	
		else {
			$query="select boutique+reserve,prac from $client.stock where code='$pr_cd_pr' and date='$date_ref'";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($stck,$pr_prac)=$sth2->fetchrow_array;
		}		
		$total=$stck*$pr_prac;
		$total_gen+=$total;
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>$total</td></tr>";
			
	}
	print "</table>";
	print "<b>total:$total_gen</b>";
}


sub stock_comptable {
	my($prod)=$_[0];
	my($stock,$non_sai,$pastouch,$max,$pastouch2,$retourdujour,$errdep);
	my(%stock);
	my($query) = "select * from $client.produit where pr_cd_pr=$prod";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	my($produit)=$sth->fetchrow_hashref;
	$stock{"vol"}=$produit->{'pr_stvol'}/100;
	$query = "select sum(erdep_qte) from $client.errdep where erdep_cd_pr=$prod and erdep_depart<=20151231";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$errdep=$sth->fetchrow*100;
	$stock{"errdep"}=$errdep/100;
	$stock{"casse"}=$produit->{'pr_casse'}/100;
	$stock{"diff"}=$produit->{'pr_diff'}/100;
	$stock{"stre"}=$produit->{'pr_stre'}/100;
	$stock{"pr_stre"}=$stock{"stre"}-$stock{"casse"}+$stock{"diff"}+$stock{"errdep"}; # stock comptable
	$stock=$produit->{'pr_stre'}-$produit->{'pr_stvol'}-$produit->{'pr_casse'}+$produit->{'pr_diff'}+$non_sai-$stock{'pastouch'}+$errdep;
	$stock{"stock"}=$stock/100; # entrepot
	return(%stock);
}


;1
