#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
require "./outils_corsica.pl";
$html=new CGI;
print $html->header();
$an=2015;
foreach $base (@bases_client){
	if ($base eq "dfc"){next;}
	for ($mois=1;$mois<13;$mois++){
		$query="select es_cd_pr,sum(es_qte_en)/100 from $base.enso where year(es_dt)=$an and month(es_dt)=$mois group by es_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$total=$sth->rows;
		$nb=0;
		while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
			if ($qte==0){next;}
			$pr_prac=&get("select pr_prac/100 from $base.produit where pr_cd_pr=$pr_cd_pr");
			&save("insert ignore into dfc.achat_mensuel values('$base','$an','$mois','$pr_cd_pr','0','$pr_prac')","af");
			&save("update dfc.achat_mensuel set qte=qte+$qte where base='$base' and an='$an' and mois='$mois' and code='$pr_cd_pr'","af");
			$nb++;
			$pour=int(10000*$nb/$total)/100;
		}
		print "$an $mois $base %\n";
	}	
}

$an=2015;
$base="cameshop";
for ($mois=1;$mois<13;$mois++){
		$query="select es_cd_pr,sum(es_qte_en)/100 from $base.enso where year(es_dt)=$an and month(es_dt)=$mois group by es_cd_pr";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$total=$sth->rows;
		$nb=0;
		while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
			if ($qte==0){next;}
			$pr_prac=&get("select pr_prac/100 from $base.produit where pr_cd_pr=$pr_cd_pr");
			&save("insert ignore into dfc.achat_mensuel values('$base','$an','$mois','$pr_cd_pr','0','$pr_prac')","af");
			&save("update dfc.achat_mensuel set qte=qte+$qte where base='$base' and an='$an' and mois='$mois' and code='$pr_cd_pr'","af");
			$nb++;
			$pour=int(10000*$nb/$total)/100;
		}
		print "$an $mois $base %\n";
}	

sub prac_cameshop()
{
	my($code)=$_[0];
	my($prac)=0;
	my($four)=0;
	my($valeur)=0;
	my($sth)=$dbh->prepare("select pr_prac,pr_four from cameshop.produit where pr_cd_pr=$code");
	$sth->execute();
	($prac,$four)=$sth->fetchrow_array;
	$prac=$prac/100;
	my($query)="select valeur from cameshop.remise_four where four='$four' order by rang";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	while (($valeur)=$sth->fetchrow_array){
		$prac=$prac-$valeur*$prac/100;
	}
    $prac=int($prac*100)/100;	
	return($prac);
}

