#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";

print $html->header;
print "<html><head><Meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body><title>integrite</title>";

require "./src/connect.src";

$option=$html->param("option");
print $option;
# produit avec enso
$query="select sum(es_qte_en-es_qte) from enso ";
$sth=$dbh->prepare($query);
$sth->execute();
($mvt_enso)=$sth->fetchrow_array;
$query="select sum(pr_stanc-pr_stre) from produit ";
$sth=$dbh->prepare($query);
$sth->execute();
($mvt_produit)=$sth->fetchrow_array;
print " fichier enso <---> produit :";
# $mvt_enso=0;  # ici
if ($mvt_enso==(-$mvt_produit)){print "ok<br>";}
else
{
	print "<br><font color=red>Probleme entre enso et produit</font>";
	print "<br>enso:$mvt_enso;";
	print "<br>produit:$mvt_produit;<br>";
	@liste=();
	$query="select es_cd_pr,sum(es_qte_en-es_qte) from enso group by es_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_cd_pr,$mvt_enso)=$sth->fetchrow_array){
		$query="select pr_desi,pr_stanc,pr_stre from produit where pr_cd_pr=$es_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi,$pr_stanc,$pr_stre)=$sth2->fetchrow_array;
		
		if (($pr_stanc+$mvt_enso)!=$pr_stre){
			push (@liste,$es_cd_pr);
			$stock_douane=($pr_stanc+$mvt_enso)/100;
			$pr_stre/=100;
			print "$es_cd_pr;$pr_desi * stock douane:$stock_douane pr_stre:$pr_stre <br>";
			if ($option eq "maj_pr_stre"){
			  $query="update produit set pr_stre=$stock_douane*100 where pr_cd_pr=$es_cd_pr";
			    print "$query<br>";
			    $sth5=$dbh->prepare($query);
			  $sth5->execute();
			}
		}
	}
	$query="select pr_cd_pr,pr_desi,pr_stanc,pr_stre from produit";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stanc,$pr_stre)=$sth->fetchrow_array){
		$query="select sum(es_qte_en-es_qte) from enso where es_cd_pr=$pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($mvt_enso)=$sth2->fetchrow_array;
		if (($pr_stre!=($pr_stanc+$mvt_enso))&&(! grep /$pr_cd_pr/,@liste)){
			$stock_douane=($pr_stanc+$mvt_enso)/100;
			$pr_stre/=100;
			print "$pr_cd_pr;$pr_desi stock douane:$stock_douane pr_stre:$pr_stre <br>";
			if ($option eq "maj_pr_stre"){
			  $query="update produit set pr_stre=$stock_douane*100 where pr_cd_pr=$pr_cd_pr";
			    print "$query<br>";
			    $sth5=$dbh->prepare($query);
			  $sth5->execute();
			}
	}
	
	}
}


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
	print "<br><font color=red>Qte Cumulée $qte_sortie<-->$qte_stvol<br>";
	$query="select so_cd_pr,sum(so_qte)/100 from sortie group by so_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($so_cd_pr,$qte_sortie)=$sth->fetchrow_array){
		$query="select pr_desi,pr_stvol/100 from produit where pr_cd_pr=$so_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($pr_desi,$pr_stvol)=$sth2->fetchrow_array;
		if ($pr_desi eq ""){$pr_desi="inconnu";}
		$pr_stvol+=0;
		if ($pr_stvol!=$qte_sortie){
			push (@liste,$so_cd_pr);	
			print "$so_cd_pr;$pr_desi pr_stvol:$pr_stvol qte_sortie:$qte_sortie <br>";
			if ($option eq "maj_pr_stvol"){
				$query="update produit set pr_stvol=$qte_sortie*100 where pr_cd_pr=$so_cd_pr";
				$sth5=$dbh->prepare($query);
				$sth5->execute();
			}
			$query="select so_appro,so_qte/100 from sortie where so_cd_pr=$so_cd_pr";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($so_appro,$so_qte)=$sth2->fetchrow_array){
				print "fichier sortie:$so_appro $so_qte<br>";
			}
			
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
			print "* $pr_cd_pr;$pr_desi pr_stvol:$pr_stvol qte_sortie:$qte_sortie <br>";
			 # $query="update produit set pr_stvol=$qte_sortie*100 where pr_cd_pr=$pr_cd_pr";
			 # $sth5=$dbh->prepare($query);
			 # $sth5->execute();
		
				
			}
	
	}
	print "</font>";
}
# sortie avec appro

$query="select sum(ap_qte0)/100 from appro where ap_cd_pos=2";
$sth=$dbh->prepare($query);
$sth->execute();
($qte_sortie_appro)=$sth->fetchrow_array;
print "fichier sortie <---> Appro :";
if ($qte_sortie==$qte_sortie_appro){print "ok<br>";}
else
{
	@liste=();
	print "	$qte_sortie *<-->$qte_sortie_appro<br>";
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
$query="select at_code from etatap where at_etat=2 or at_etat=3";
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
	if ((($at_etat!=2)&&($at_etat!=3))&&(! grep /$at_code/,@liste)){
		print "<font color=red>$so_appro dans le fichier sortie mais avec at_etat=$at_etat</font><br>";
		$err=1;
	}
}
foreach (@liste){
	$query="select count(*) from sortie where so_appro='$_'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($qte)=$sth2->fetchrow_array+0;
	if ($qte==0){
		print "<font color=red>$_ etat 2 ou 3 mais pas dans le fichier sortie</font><br>";
		$err=1;
	}
}
if ($err==0){print " fichier sortie <---> etatap : ok<br>";}



# geslot avec etatap

@liste=();
$err=0;
$query="select gsl_apcode from geslot where gsl_ind=3 or gsl_ind=5";
$sth=$dbh->prepare($query);
$sth->execute();
while (($gsl_apcode)=$sth->fetchrow_array){

	$query="select at_nolot,at_etat from etatap where at_code='$gsl_apcode'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($at_nolot,$at_etat)=$sth2->fetchrow_array;
	if (($at_etat!=2)&&($at_etat!=3)){print "gsl_apcode:$gsl_apcode at_nolot:$at_nolot at_etat:$at_etat gsl_ind:$gsl_ind<br>";}
	push (@liste,$gsl_apcode);	
	$err=1;
}
$query="select at_code,at_nolot from etatap where at_etat=2";
$sth=$dbh->prepare($query);
$sth->execute();
while (($at_code,$at_nolot)=$sth->fetchrow_array){
	# $query="update geslot set gsl_apcode=$at_code where gsl_nolot=$at_nolot";
	# $sth2=$dbh->prepare($query);
	# $sth2->execute();
	$query="select gsl_ind from geslot where gsl_apcode='$at_code' and gsl_nolot='$at_nolot'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($gsl_ind)=$sth2->fetchrow_array;
	if ((($gsl_ind!=3)||($gsl_ind!=5))&&(! grep /$at_code/,@liste)){
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
	# print "$query<bR>";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_nolot,$fl_apcode,$fl_cd_cl)=$sth2->fetchrow_array;
	if ($gsl_nolot>200){$fl_nolot=$fl_cd_cl*1000+$fl_nolot;}
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
	if ($gsl_ind==5){next;}	
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
	if (($at_etat!=2)&&($at_etat!=3)){	
		print "ns_code:$ns_code * at_etat:$at_etat<br>";
		$err=1;
	}
}

if ($err==0){print " fichier etatap <---> non_sai : ok<br>";}

# produit avec ventil_d

$err=0;
$query="select pr_cd_pr,pr_ventil,pr_douane,pr_desi from produit,enso where pr_cd_pr=es_cd_pr group by pr_cd_pr "; # on se limite au produit qui bouge
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_ventil,$pr_douane,$pr_desi)=$sth->fetchrow_array){
	$query="select vent_code from ventil_d where vent_ndp_sh='$pr_douane'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($vent_code)=$sth2->fetchrow_array;
	if (($vent_code ne $pr_ventil)||($pr_ventil eq "")){
		# print "<font color=red> probleme de code ventilation $pr_cd_pr $pr_desi pr_douane:$pr_douane pr_ventil:$pr_ventil<br></font>";
	}
} 
if ($err==0){print " fichier produit <---> ventil_d : ok<br>";}

# vol avec caissesql
$err=0;
$query="select ca_code,ca_rot from caissesql where ca_total!=0 and ca_code>19000";
$sth=$dbh->prepare($query);
$sth->execute();
while (($ca_code,$ca_rot)=$sth->fetchrow_array){
	$query="select count(*) from vol where v_code='$ca_code' and v_rot='$ca_rot'"; 
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($nb)=$sth2->fetchrow_array+0;
	if ($nb==0){
		$err=1;
		print "<font color=red>";
		$query="select v_vol,v_date,v_cd_cl from vol where v_code=$ca_code and v_rot=1"; 
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($vol,$date,$client)=$sth2->fetchrow_array;

		print "caisse:$ca_code $ca_rot inconnu vol$vol $date $client<br>";
	}
}
print "</font>";
# rotation avec caisse option
if ($option eq "oui"){
$err=0;
$query="select ap_code,sum(ro_qte*ap_prix)/10000 from appro,rotation where ap_code=ro_code and ap_cd_pr=ro_cd_pr and ap_code>18000 group by ro_code";
$sth=$dbh->prepare($query);
$sth->execute();
while (($ap_code,$val)=$sth->fetchrow_array){
	$query="select sum(ca_fly)/100 from caisse where ca_code=$ap_code"; 
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ca_fly)=$sth2->fetchrow_array;
	if ($ca_fly!=$val){
		$err=1;
		print "<font color=red>";
		print "appro:$ap_code valeur fichier rotation:$val caisse:$ca_fly<br>";
		# $dbh->do("update caisse set ca_fly=$val*100 where ca_code=$ap_code and ca_rot=1");
	}
}
 $query="select ca_code,sum(ca_fly)/100 from caisse where ca_code>18000 group by ca_code";
 $sth=$dbh->prepare($query);
 $sth->execute();
 while (($ca_code,$ca_fly)=$sth->fetchrow_array){
 	if (($ca_fly%100)==0){next;}
 	$query="select count(*) from appro where ap_code='$ca_code'";
  	$sth2=$dbh->prepare($query);
 	$sth2->execute();
 	($nb)=$sth2->fetchrow_array;
 	
 	if ($nb==0){	
 		print "$ca_code introuvable<br>";
 		next;
 	}
 	$query="select sum(ro_qte*ap_prix)/10000 from appro,rotation where ap_code=ro_code and ap_cd_pr=ro_cd_pr and ap_code=$ca_code group by ro_code";
  	$sth2=$dbh->prepare($query);
 	$sth2->execute();
 	($val)=$sth2->fetchrow_array;
 	$val+=0;
 	if ($ca_fly!=$val){
 	 	$err=1;
 		print "<font color=red>";
 		print $query;
 		print "* appro:$ca_code valeur fichier rotation:$val caisse:$ca_fly<br>";
 		# $dbh->do("update caisse set ca_fly=0 where ca_code=$ca_code and ca_rot=1");
 	 }
 }
 if ($err==0){print " fichier rotation <---> caisse : ok<br>";}
}

# caissesql avec caisse
$query="SELECT ca_code FROM `caissesql` WHERE ca_code NOT IN (SELECT ca_code FROM caisse)";
 $sth=$dbh->prepare($query);
 $sth->execute();
 while (($ca_code)=$sth->fetchrow_array){
	 print "$ca_code dans caissesql mais pas dans caisse <br>";
 }

# stock a virgule
 $query="select pr_cd_pr,pr_desi from produit where pr_stre%100 !=0 and pr_ventil!=15";
 $sth=$dbh->prepare($query);
 $sth->execute();
 while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
 	%stock=&stock($pr_cd_pr);
	print "$pr_cd_pr $pr_desi ".$stock{"stock"}."<br>";
	 # if ($pr_cd_pr >1000000000){&save("update produit set pr_stanc=pr_stanc*100,pr_stre=pr_stre*100 where pr_cd_pr='$pr_cd_pr'","aff");}
}



print "<br>fin";

