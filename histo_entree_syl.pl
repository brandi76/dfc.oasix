#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";

	$query="select enb_cdpr,pr_desi,sum(enb_quantite/100),pr_prac/100,pr_prx_rev/100 from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and (pr_type=1 or pr_type=5) and pr_sup!=5 and enh_date>13513 and enh_date<13787 group by enb_cdpr"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$qte,$prac,$pr_rem)=$sth->fetchrow_array){
		print "$pr_cd_pr;$pr_desi;$qte<br>";
		if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);print "*"}
		$total+=$qte*$prac;
	}
	$query="select enh_no,enh_date,sum(enb_quantite/100*(pr_prac-(pr_prac*pr_prx_rev/10000))/100) from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and (pr_type=1 or pr_type=5) and pr_sup!=5 and enh_date>13513 and enh_date<13787 group by enh_no order by enh_no"; 
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($enh_no,$enh_date,$montant)=$sth->fetchrow_array){
		print "$enh_no; ";
		$four=&get("select fo2_add from fournis,entbody,produit where pr_four=fo2_cd_fo and pr_cd_pr=enb_cdpr and enb_no='$enh_no'");
		($four)=split(/\*/,$four);
		print "$four ;";
		print &julian($enh_date,"YYMMDD");
		print " ;$montant<br>";
	}

	
#	print "<b>".&julian(&get("select min(enh_date) from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and (pr_type=1 or pr_type=5) and pr_sup!=5 and enh_date>13513 and enh_date<13787 group by enb_cdpr"))."</b>"; 

print $total;