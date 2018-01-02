#!/usr/bin/perl
use DBI();
require("/var/www/cgi-bin/dfc.oasix/src/connect.src");
require "/var/www/cgi-bin/oasix/outils_perl2.pl";
# $html=new CGI;
# print $html->header();

$date_ref=&get("SELECT last_day(date_sub(curdate(),interval 1 day))");
 for ($i=7;$i<9;$i++){
	 $date="2017-$i-01";
	 $date_ref=&get("SELECT last_day('$date')");
	foreach $client (@bases_client) {
		if ($client ne "aircotedivoire"){next;}
		if ($client eq "dfc"){next;}
		if ($client eq "corsica"){next;}
		print "$client\n";
		$query="select pr_cd_pr,pr_desi,pr_prac/100 from $client.produit where pr_prac>0 and pr_prac<30000000 order by pr_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
		{
			%stock=&stock_comptable($pr_cd_pr,'',"quick");
			$stck=$stock{"pr_stre"};
			# if ($stck <0){next;}
			$sortie=&get("select sum(es_qte/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			$entree=&get("select sum(es_qte_en/100) from $client.enso where es_cd_pr='$pr_cd_pr' and es_dt>'$date_ref'");
			$stck-=$entree;
			$stck+=$sortie;
			if ($stck==0){next;}
			save("insert ignore into dfc.stock_mensuel value ('$client','$date_ref','$pr_cd_pr','$stck','$pr_prac')","af");
		}
	}	
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
	$query = "select sum(erdep_qte) from $client.errdep where erdep_cd_pr=$prod";
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
