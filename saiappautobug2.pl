#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

# juin 2011 suite a un saiappauto alors qu ela saisie n'etait pas termine
# il faut modifier a la main le fichier caisse

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

$code="24892";
$datesimple=`/bin/date +%y%m%d`;

$query="select ap_cd_pr,pr_desi,ap_qte0/100,ap_prix/100 from appro,produit where ap_cd_pr=pr_cd_pr and ap_code='$code' and ap_cd_pos=5";
$sth2=$dbh->prepare($query);
$sth2->execute();
while (($ap_cd_pr,$pr_desi,$ap_qte0,$ap_prix)=$sth2->fetchrow_array){
	$query="select sum(ret_qtepnc-ret_qte),sum(ret_qtepnc-ret_retour)*100 from retoursql where ret_code='$code' and ret_cd_pr=$ap_cd_pr";
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	($ret_ecart,$ret_vendu)=$sth3->fetchrow_array;
	if ($ret_vendu!=0){
		$qte_anc=&get("select es_qte from enso where es_cd_pr='$ap_cd_pr' and es_no_do='$code'")+0;
		if ($qte_anc==0){
			print "$ap_cd_pr $qte_anc $ret_vendu <br>";
			$query="replace into rotation values('$code','1','$ap_cd_pr',$ret_vendu)";
			&execute();
			$query="replace into enso values('$ap_cd_pr','$code','$datesimple','$ret_vendu','0','1')";
			&execute();
			$query="update produit set pr_stre=pr_stre-'$ret_vendu' where pr_cd_pr='$ap_cd_pr'";
			&execute();
		}
	}
}	
	# $query="replace into retourdo values('$code')";
	# &execute();
	# $query="update etatap set at_etat=5,at_date=$datesimple where at_code='$code'";
	# &execute();


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