#!/usr/bin/perl
use CGI;
use DBI();

# fevrier 2011
# permet de valider les ventes lorsque l'on a fait saiappauato avant de saisir le retour , ne mrche que si saiappauto est à zero


$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

print $html->header;

$action=$html->param('action');
require "./src/connect.src";

# print "<h1> Prevenir sylvain , merci</h1>";
# exit;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head><body>";

# premier passage maj du stock
if (&lock("$0") == 0 ){
	print "Sécurité double click merci de réessayer dans 10 secondes";
	# securite double click
	exit;
}

# $query="select * from non_sai";
# $sth=$dbh->prepare($query);
# $sth->execute();
$datesimple=`/bin/date +%y%m%d`;
# while (($code)=$sth->fetchrow_array){
	$code="24491";
	$query="select gsl_ind from geslot where gsl_apcode='$code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ind)=$sth2->fetchrow_array;
	if ($ind==10){next;} # pas touche
	$query="select ap_cd_pr,pr_desi,ap_qte0/100,ap_prix/100 from appro,produit where ap_cd_pr=pr_cd_pr and ap_code='$code' ";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($ap_cd_pr,$pr_desi,$ap_qte0,$ap_prix)=$sth2->fetchrow_array){
		$query="select sum(ret_qtepnc-ret_qte),sum(ret_qtepnc-ret_retour)*100 from retoursql where ret_code='$code' and ret_cd_pr=$ap_cd_pr";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($ret_ecart,$ret_vendu)=$sth3->fetchrow_array;
		if ($ret_vendu!=0){
			$query="replace into rotation values('$code','1','$ap_cd_pr',$ret_vendu)";
			&execute();
			$query="replace into enso values('$ap_cd_pr','$code','$datesimple','$ret_vendu','0','1')";
			&execute();
		}
		if ($ret_ecart!=0){
			$query="select at_depart from etatap where at_code='$code'";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			($at_depart)=$sth3->fetchrow_array;
			$query="replace into errdep values('$ap_cd_pr','$at_depart','$code','$ret_ecart')";
			&execute();
		}
		
		#$query="update produit set pr_stre=pr_stre-'$ret_vendu',pr_stvol=pr_stvol-('$ap_qte0'*100) where pr_cd_pr='$ap_cd_pr'";
		
		$query="update produit set pr_stre=pr_stre-'$ret_vendu' where pr_cd_pr='$ap_cd_pr'";
		
		&execute();
		$query="delete from sortie where so_cd_pr='$ap_cd_pr' and so_appro='$code'";
		&execute();
		$query="update appro set ap_cd_pos=5 where ap_code='$code' and ap_cd_pr='$ap_cd_pr'";
		&execute();

	}	
	$query="replace into retourdo values('$code')";
	&execute();
	$query="update etatap set at_etat=5,at_date=$datesimple where at_code='$code'";
	&execute();

# }

# 2 eme passage edition 
# $query="select * from non_sai";
# $sth=$dbh->prepare($query);
# $sth->execute();
# while (($code)=$sth->fetchrow_array){
	$code="24491";
	$query="select gsl_ind from geslot where gsl_apcode='$code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ind)=$sth2->fetchrow_array;
	if ($ind==10){next;} # pas touche
	$total=0;
	print "BON D'APPRO NUMERO :$code<br>";
	print "================================<br>";
	$query="select v_code,v_date,v_dest,v_cd_cl,cl_nom from vol,client where v_code='$code' and v_cd_cl=cl_cd_cl order by v_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($v_rot,$v_date,$v_dest,$v_cd_cl,$cl_nom)=$sth2->fetchrow_array){
		print "$v_cd_cl $cl_nom $v_rot $v_date $v_dest<br>";
	}	
	print "<pre>
------------------------------------------------------------
code  ! Designation              !qtedep!qtevdu!prix !total!
------------------------------------------------------------
";
	$query="select ap_cd_pr,pr_desi,ap_qte0/100,ap_prix/100 from appro,produit where ap_cd_pr=pr_cd_pr and ap_code='$code' order by ap_ordre";
	# ici pas fait pas tiroir
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($ap_cd_pr,$pr_desi,$ap_qte0,$ap_prix)=$sth2->fetchrow_array){
		$query="select sum(ro_qte)/100 from rotation where ro_code='$code' and ro_cd_pr=$ap_cd_pr group by ro_cd_pr";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($ro_qte)=$sth3->fetchrow_array;
		$total_li=$ap_prix*$ro_qte;
		$total+=$total_li;
		print &taillefixe($ap_cd_pr,6)."!";
		print &taillefixe($pr_desi,25)."!";
		print &taillefixe($ap_qte0,6)."!";
		print &taillefixe($ro_qte,6)."!";
		print &taillefixe($ap_prix,5)."!";
		print &taillefixe($total_li,5)."!";
		print "<br>";
	}	
print "------------------------------------------------------------
                                          TOTAL        :$total</pre>";               
$total*=100;
$query="update caisse set ca_fly=$total where ca_code='$code' and ca_rot=1;";
&execute();
$query="delete from non_sai where ns_code='$code'";
&execute();

print "<div id=saut></div>";		
# }

print "</body></html>";

# FONCTION : taillefixe(???)
# affichage en taille fixe
sub taillefixe {
		my ($char)=$_[0];
		my ($len)=$_[1];
		my ($i)=0;
		my ($chaine)="";
		$_=$char;
		if (! /[a-z,A-Z]/) # astuce test si numerique
		{ # numerique
			while ($char=~s/ //g){};
			for ($i=($len-length($char));$i>0;$i--){
				$chaine=$chaine." ";
			}
			$chaine=$chaine.$char;
			
		}
		else
		{ # non numerique
			for ($i=0;$i<=$len;$i++){
				$car=substr($char,$i,1);
				if ($car eq " "){$car=" ";}
				if ($car eq ""){$car=" ";}
				$chaine=$chaine.$car;
			}
		}
		return($chaine);
}
sub execute {
        # print "$query<br>";
	$dbh->do("insert into query values ('',QUOTE(\"$query\"),'$0','$ENV{'REMOTE_ADDR'}',now())");
	my($sth2)=$dbh->prepare($query);
	return($sth2->execute());
}