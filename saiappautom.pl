#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

print $html->header;

$code=$html->param('code');
require "./src/connect.src";

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head><body>";

if ($code ne ""){
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
	$query="select ap_cd_pr,pr_desi,ap_qte0/100,ap_prix/100 from appro,produit where ap_cd_pr=pr_cd_pr and ap_code='$code'";
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
	
	print "<div id=saut></div>";		
	print "</body></html>";
# $total*=100;
# $query="update caisse set ca_fly=$total where ca_code='$code' and ca_rot=1;";

#&save($query);
# $query="delete from non_sai where ns_code='$code'";
#&save($query);


}
else
{
	print "Reedition<br><form>Appro<input type=text name=code><input type=submit></form>";
}
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
