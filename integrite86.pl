#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";

print $html->header;
print "<html><head><Meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body>INTEGRITE 86<br>";

require "./src/connect.src";

# sortie avec pr_stvol
$query="select sum(so_qte)/100 from sortie ";
$sth=$dbh->prepare($query);
$sth->execute();
($qte_sortie)=$sth->fetchrow_array;
$query="select sum(pr_stvol)/100 from produit ";
$sth=$dbh->prepare($query);
$sth->execute();
($qte_stvol)=$sth->fetchrow_array;
print " fichier sortie <---> pr-stvol :";
if ($qte_sortie==$qte_stvol){print "ok<br>";}
else
{
	@liste=();
	print "	$qte_sortie<-->$qte_stvol<br>";
	$query="select so_cd_pr,sum(so_qte)/100 from sortie group by so_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($so_cd_pr,$qte_sortie)=$sth->fetchrow_array){
		$query="select pr_desi,pr_stvol/100 from produit where pr_cd_pr=$so_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi,$pr_stvol)=$sth2->fetchrow_array;
		if ($pr_stvol!=$qte_sortie){
			push (@liste,$so_cd_pr);	
			print "$so_cd_pr;$pr_desi pr_stvol:$pr_stvol qte_sortie:$qte_sortie <br>";
		}
	}
	$query="select pr_cd_pr,pr_desi,pr_stvol/100 from produit";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stvol)=$sth->fetchrow_array){
		$qte_sortie=0;
		$query="select sum(so_qte)/100 from sortie where so_cd_pr=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_sortie)=$sth2->fetchrow_array;
		$qte_sortie+=0;
		if (($pr_stvol!=$qte_sortie)&&(! grep /$pr_cd_pr/,@liste)){
			print "$pr_cd_pr;$pr_desi pr_stvol:$pr_stvol qte_sortie:$qte_sortie <br>";
			}
	
	}
}
# sortie avec appro

$query="select sum(ap_qte0)/100 from appro where ap_cd_pos=2";
$sth=$dbh->prepare($query);
$sth->execute();
($qte_sortie_appro)=$sth->fetchrow_array;
print " fichier sortie <---> Appro :";
if ($qte_sortie==$qte_sortie_appro){print "ok<br>";}
else
{
	@liste=();
	print "	$qte_sortie<-->$qte_sortie_appro<br>";
	$query="select so_appro,sum(so_qte)/100 from sortie group by so_appro";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($so_appro,$qte_sortie)=$sth->fetchrow_array){
		$query="select sum(ap_qte0)/100 from appro where ap_code='$so_appro' and ap_cd_pos=2";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ap_qte0)=$sth2->fetchrow_array+0;
		if ($ap_qte0!=$qte_sortie){
			push (@liste,$so_appro);	
			print "ap_code:$so_appro ap_qte0:$ap_qte0 qte_sortie:$qte_sortie <br>";
		}
	}
	$query="select ap_code,sum(ap_qte0)/100 from appro where ap_cd_pos=2 group by ap_code";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ap_code,$ap_qte0)=$sth->fetchrow_array){
		$query="select sum(so_qte)/100 from sortie where so_appro='$ap_code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte_sortie)=$sth2->fetchrow_array+0;
		if (($ap_qte0!=$qte_sortie)&&(! grep /$ap_code/,@liste)){
			print "ap_code:$ap_code ap_qte0:$ap_qte0 qte_sortie:$qte_sortie <br>";
		}
	}

}

# sortie avec etatap
$err=0;
$query="select at_code from etatap where at_etat=2";
$sth=$dbh->prepare($query);
$sth->execute();
($at_code)=$sth->fetchrow_array;
@liste=();
$query="select sum(so_qte)/100 from sortie where so_appro='$at_code'";
$sth=$dbh->prepare($query);
$sth->execute();
($qte_sortie)=$sth->fetchrow_array;
if (($qte_sortie==0)||($qte_sortie eq '')){
	push (@liste,$at_code);	
	print "$at_code absent dans le fichier sortie<br>";
	$err=1;
}
$query="select so_appro from sortie group by so_appro";
$sth=$dbh->prepare($query);
$sth->execute();
while (($so_appro)=$sth->fetchrow_array){
	$query="select at_etat from etatap where at_code='$so_appro'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($at_etat)=$sth2->fetchrow_array;
	if (($at_etat!=2)&&(! grep /$at_code/,@liste)){
		print "$at_code dans le fichier sortie mais avec at_etat=$at_etat<br>";
		$err=1;
	}
}
if ($err==0){print " fichier sortie <---> etatap : ok<br>";}



# geslot avec etatap

@liste=();
$err=0;
$query="select gsl_apcode from geslot where gsl_ind=3";
$sth=$dbh->prepare($query);
$sth->execute();
while (($gsl_apcode)=$sth->fetchrow_array){

	$query="select at_nolot,at_etat from etatap where at_code='$gsl_apcode'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($at_nolot,$at_etat)=$sth2->fetchrow_array;
	if ($at_etat!=2){print "gsl_apcode:$gsl_apcode at_nolot:$at_nolot at_etat:$at_etat gsl_ind:$gsl_ind<br>";}
	push (@liste,$gsl_apcode);	
	$err=1;
}
$query="select at_code,at_nolot from etatap where at_etat=2";
$sth=$dbh->prepare($query);
$sth->execute();
while (($at_code,$at_nolot)=$sth->fetchrow_array){
	$query="select gsl_ind from geslot where gsl_apcode='$at_code' and gsl_nolot='$at_nolot'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($gsl_ind)=$sth2->fetchrow_array;
	if (($gsl_ind!=3)&&(! grep /$at_code/,@liste)){
		$query="select ns_code from non_sai  where ns_code='$at_code' ";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ns_code)=$sth2->fetchrow_array;
		if ($ns_code ne $at_code){print "at_code:$at_code at_nolot:$at_nolot at_etat:$at_etat gsl_ind:$gsl_ind<br>";}
		}
	$err=1;
}
if ($err==0){print " fichier geslot <---> etatap : ok<br>";}

# geslot avec flyhead

@liste=();
$err=0;
$query="select gsl_nolot,gsl_apcode from geslot where gsl_ind=3";
$sth=$dbh->prepare($query);
$sth->execute();
while (($gsl_nolot,$gsl_apcode)=$sth->fetchrow_array){
	$query="select fl_nolot,fl_apcode,fl_cd_cl from flyhead,geslot where fl_vol=gsl_novol and fl_date=gsl_dtvol and fl_apcode='$gsl_apcode'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_nolot,$fl_apcode,$fl_cd_cl)=$sth2->fetchrow_array;
	$fl_nolot=$fl_cd_cl*1000+$fl_nolot;
	if ($fl_nolot!=$gsl_nolot){	
		print "gsl_nolot:$gsl_nolot gsl_apcode:$gsl_apcode fl_nolot:$fl_nolot";
		print " fl_apcode:$fl_apcode<br>";
		$err=1;
	}
}
if ($err==0){print " fichier geslot ---> flyhead : ok<br>";}

# etatap avec apjour

@liste=();
$err=0;
$query="select at_code,at_date from etatap where at_etat=2";
$sth=$dbh->prepare($query);
$sth->execute();
while (($at_code,$at_date)=$sth->fetchrow_array){
	$query="select aj_date from apjour where aj_code='$at_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($aj_date)=$sth2->fetchrow_array;
	if (! (($aj_date==$at_date)||($aj_date==$at_date+1000000))){	
		print "at_code:$at_code at_date:$at_date aj_date:$aj_date<br>";
		$err=1;
	}
}
if ($err==0){print " fichier etatap ---> apjour : ok<br>";}

# etatap avec non_sai

@liste=();
$err=0;
$query="select at_code from etatap where at_etat=2" ;
$sth=$dbh->prepare($query);
$sth->execute();
while (($at_code)=$sth->fetchrow_array){
	$query="select gsl_ind from geslot where gsl_apcode='$at_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($gsl_ind)=$sth2->fetchrow_array;
	if ($gsl_ind==3){next;}	
	$query="select ns_code from non_sai where ns_code='$at_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ns_code)=$sth2->fetchrow_array;
	if ($ns_code!=$at_code){	
		print "at_code:$at_code ns_code:$ns_code<br>";
		$err=1;
	}
}
$query="select * from non_sai";
$sth=$dbh->prepare($query);
$sth->execute();
while (($ns_code)=$sth->fetchrow_array){
	$query="select at_etat from etatap where at_code='$ns_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($at_etat)=$sth2->fetchrow_array;
	if ($at_etat!=2){	
		print "ns_code:$ns_code at_etat:$at_etat<br>";
		$err=1;
	}
}

if ($err==0){print " fichier etatap <---> non_sai : ok<br>";}

print "<br>fin";

