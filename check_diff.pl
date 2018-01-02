#!/usr/bin/perl
use CGI;
use DBI();
# use CGI::Carp qw(fatalsToBrowser); 
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header;
require "./src/connect.src";
print "<title>Listing alcool</title><body>";
$action=$html->param("action");
$option=$html->param("option");
$prod1=$html->param("prod1");
$prod2=$html->param("prod2");

if ($action eq ""){
	$query="select pr_cd_pr,pr_desi,pr_stre/100,pr_diff/100,pr_deg,pr_pdn from produit where pr_ventil=6  and pr_diff !=0  and pr_cd_pr>1000000 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_diff,$pr_deg,$pr_pdn)=$sth->fetchrow_array){
		print "$pr_cd_pr;$pr_desi;$pr_stre;$pr_diff;<br>";
# 		$query="select pr_cd_pr,pr_desi,pr_stre/100,pr_diff/100 from produit where pr_deg='$pr_deg' and pr_pdn='$pr_pdn' and pr_cd_pr!=$pr_cd_pr and pr_diff<0";
# 		$sth2=$dbh->prepare($query);
# 		$sth2->execute();
# 		while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_diff)=$sth2->fetchrow_array){
# 			print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$pr_cd_pr;$pr_desi;$pr_stre;$pr_diff;<br>";
# 		}
		
	
	}
	$query="select pr_cd_pr,pr_desi,pr_stre/100,pr_diff/100 from produit where pr_ventil=6 and pr_cd_pr<=1000000 and pr_diff !=0  and pr_cd_pr not in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1) order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_diff)=$sth->fetchrow_array){
		print "$pr_cd_pr;$pr_desi;$pr_stre;$pr_diff;<br>";
	
	}

	print "*******************<br>";
	$query="select pr_cd_pr,pr_desi,pr_stre/100,pr_diff/100 from produit where pr_ventil=6 and pr_cd_pr<=1000000  and pr_diff !=0 and pr_cd_pr in (select distinct tr_cd_pr from trolley,lot where tr_code=lot_nolot and lot_flag=1) order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_diff)=$sth->fetchrow_array){
		print "$pr_cd_pr;$pr_desi;$pr_stre;$pr_diff;<br>";
	
	}

}

if ($action eq "modif"){
	$query="select pr_cd_pr,pr_desi,pr_stanc,pr_stre,pr_diff,pr_deg,pr_pdn from produit where pr_cd_pr=$prod1 or pr_cd_pr=$prod2";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stanc,$pr_stre,$pr_diff,$pr_deg,$pr_pdn)=$sth->fetchrow_array){
		print "$pr_cd_pr;$pr_desi;$pr_stanc;$pr_stre;$pr_diff;$pr_deg,$pr_pdn<br>";
		
		if ($pass==0){$pr_deg1=$pr_deg;$pr_pdn1=$pr_pdn;$pass=1;$diff=$pr_diff;}
		else {
		if (($pr_deg!=$pr_deg1)||($pr_pdn!=$pr_pdn1)) {
		print "erreur";
		}
		}
	}
	if ($option eq "go") {
			&save("update produit set pr_stanc=pr_stanc+$diff where pr_cd_pr=$prod1","aff");
			&save("update produit set pr_stre=pr_stre+$diff where pr_cd_pr=$prod1","aff");
			&save("update produit set pr_diff=pr_diff-$diff where pr_cd_pr=$prod1","aff");
			
			&save("update produit set pr_stanc=pr_stanc-$diff where pr_cd_pr=$prod2","aff");
			&save("update produit set pr_stre=pr_stre-$diff where pr_cd_pr=$prod2","aff");
			&save("update produit set pr_diff=pr_diff+$diff where pr_cd_pr=$prod2","aff");

			}

}