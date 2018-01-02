#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
require "./src/connect.src";


$navire="MEGA 2";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

$navire="MEGA 3";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

$navire="MEGA 4";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

$navire="VICTORIA";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

$navire="VERA";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

$navire="REGINA";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

$navire="MEGA 1";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

$navire="MARINA";
$date1="2006-12-31";
# $date2="2007-10-03";
&go();

foreach $cle (keys(%atotalp)){
	print "$cle;$atotalp{$cle};";
	print "$atotal{$cle};";
	print "$atotalv{$cle}<br>";
}

sub go {
	$totalp=$total=$totalv=$nbparf=0;
	print "<h3>$navire</h3>";
	print "<table border=1 cellspacing=0>";
	$sth=$dbh->prepare("select nav_cd_pr,nav_qte from navire2 where nav_nom='$navire' and nav_date='$date1' and nav_type=1 and nav_qte>0");
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh2->prepare($query2);
		$sth3->execute();
		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}
		$val=$pr_prac*$qte;	
		if ($pr_prac==0){
			$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$pr_cd_pr'")+0;
			$val=$pr_prac*$qte;	
			if ($pr_prac==0){
				$pr_prac="---";$val=0;
			}
		}
		 print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$pr_prac</td><td>$qte</td><td>$val</td></tr>";
		$pr_sup=&get("select pr_sup from produit where pr_cd_pr='$pr_cd_pr'");
		$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
		if ($pr_type==1 or $pr_type==5){
			$totalp+=$val;
			if ($pr_sup!=5){$nbparf+=$qte;}
		}
		else{
			$total+=$val;
		}
	}
	$sth=$dbh->prepare("select nav_cd_pr,nav_qte from navire2 where nav_nom='$navire' and nav_date='$date2' and nav_type=7 and nav_qte>0");
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
		$query2="select pr_prac/100,pr_prx_rev/100 from produit where pr_cd_pr='$pr_cd_pr'";
		$sth3=$dbh->prepare($query2);
		$sth3->execute();
		($pr_prac,$pr_rem)=$sth3->fetchrow_array;
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);}
		$val=$pr_prac*$qte;	
		if ($pr_prac==0){
			$pr_prac=&get("select nep_prac/100 from neptune where nep_codebarre='$pr_cd_pr'")+0;
			$val=$pr_prac*$qte;	
			if ($pr_prac==0){
				$pr_prac="---";$val=0;
			}
		}
		# print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$pr_prac</td><td>$qte</td><td>$val</td></tr>";
		$pr_type=&get("select pr_type from produit where pr_cd_pr='$pr_cd_pr'");
		if ($pr_type==1 or $pr_type==5){
			$totalp+=$val;
		}
		else{
			$total+=$val;
		}
		$totalv+=$val;
	}
	print "</table>";	
	print "total parfum:$totalp;$nbparf<br>";
	print "total autre:$total;<br>";
	print "total vente:$totalv;<br>";
	$atotalp{$navire}=$totalp;
	$atotal{$navire}=$total;
	$atotalv{$navire}=$totalv;
}