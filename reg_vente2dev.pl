#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

print $html->header;
require "./src/connect.src";

$date=`/bin/date +%d';'%m';'%Y`;
chop($date);
($jour,$mois,$an)=split(/;/, $date, 3); 

$max=$an*10000+$mois*100;
if ($jour>15){$max+=100;}
print $max;
$refmois=((($mois-1)*100)-2000)+$an;

# $an=2005;
# $mois=11;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "<body>";
print "<center><h3>IBS FRANCE ZI ROUXMENILS BOUTEILLE<br>COMPTABILITE MATIERE</h3></center>";
print "Mois de ",&cal($mois-1)," Numero d'entrepositaire agree:FR00116S0031<br>";
print "Edition du $jour ",&cal($mois)," $an<br>";
$query="delete from rglv2";
require "./src/connect.src";
$query="select es_cd_pr,es_no_do,es_dt,es_qte,es_qte_en,es_type from enso where es_type!=5 and es_qte_en=0 and es_no_do>10000";
$sth=$dbh->prepare($query);
$sth->execute();
while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array){
	$query="select v_date_jl,v_cd_cl,v_dest from vol where v_code='$es_no_do' and v_rot=1";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($date,$v_cd_cl,$v_dest)=$sth2->fetchrow_array;
	$es_dt=&julian($date,"YYYYMMDD");
	if ($es_dt>$max){next;}
	$query="select pr_ventil,pr_pdn,pr_deg,pr_douane from produit where pr_cd_pr='$es_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($vent_code,$pr_pdn,$pr_deg,$prb_ndp_sh)=$sth2->fetchrow_array;
	$query="replace into ventil_sql values ('$vent_code','$prb_ndp_sh')";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	if ($vent_code<1){next;}
	if ($vent_code>22){next;}
	if ($vent_code==10){next;}
	$alc=0;
	$pdn=$es_qte*$pr_pdn;
	if (($vent_code>=6)&&($vent_code<=9)){
		$alc=$es_qte*$pr_pdn*$pr_deg/10000;
	}
	$dest=substr($v_dest,4,3);
	$query="select aero_type from aeroport where aero_tri='$dest'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($type)=$sth2->fetchrow_array;
	$type+=0;
	if ($type==0){$type=3;}
	if ($type==1){$type=3;}
	$query="select rglv2_vente,rglv2_ca,rglv2_pdn,rglv2_alc from rglv2 where rglv2_mois='$refmois' and rglv2_cd_cl='$v_cd_cl' and rglv2_type=$type and rglv2_douane='$vent_code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($rglv2_vente,$rglv2_ca,$rglv2_pdn,$rglv2_alc)=$sth2->fetchrow_array;
	$rglv2_vente+=$es_qte;
	$rglv2_pdn+=$pdn;
	$rglv2_alc+=$alc;
	$query="select ap_prix from appro where ap_code='$es_no_do' and ap_cd_pr='$es_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ap_prix)=$sth2->fetchrow_array;
	$rglv2_ca+=($es_qte*$ap_prix/10000);
	$query="replace into rglv2 values ('$refmois','$type','$v_cd_cl','$vent_code','$rglv2_vente','$rglv2_ca','$prb_ndp_sh','$rglv2_pdn','','$rglv2_alc','')";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
}
$query="select * from rglv2 order by rglv2_ndp";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1><tr><th>rglv2_mois</th><th>rglv2_type</th><th>rglv2_cd_cl</th><th>rglv2_douane</th><th>rglv2_vente</th><th>rglv2_ca</th><th>rglv2_ndp</th><th>rglv2_pdn</th><th>rglv2_alc</th></tr>";
while (($rglv2_mois,$rglv2_type,$rglv2_cd_cl,$rglv2_douane,$rglv2_vente,$rglv2_ca,$rglv2_ndp,$rglv2_pdn,$rglv2_pdb,$rglv2_alc,$rglv2_zatt)=$sth->fetchrow_array){
	$rglv2_pdn/=1000;
	if ($rglv2_douane==1){$rglv2_pdn/=100;} # hectolitre
	if (($rglv2_douane>=6)&&($rglv2_douane<=9)){
		$rglv2_alc/=100000;
	} # hectolitre alcool pur
	if (($rglv2_ndp!=$ndptampon)&&($total_pdn!=0)){
		print "<tr><td align=right>&nbsp;</td><td align=right>&nbsp;</td><td align=right>&nbsp;</td><td align=right>&nbsp;</td>";
		print "<td align=right><b>$total_qte</td><td align=right>&nbsp;</td><td align=right>&nbsp;</td><td align=right><b>$total_pdn</b></td><td align=right><b>$total_alc</b></td></tr>";
		$ndptampon=$rglv2_ndp;
		$total_pdn=0;
		$total_alc=0;
		$total_qte=0;
	}
	$query="select type_desi from typedesi where type_code=$rglv2_douane";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($type_desi)=$sth2->fetchrow_array;
	$rglv2_douane.=" ".$type_desi;
	$rglv2_pdn=$rglv2_pdn/100;
	
	$rglv2_vente/=100;
	$total_pdn+=$rglv2_pdn;
	$total_alc+=$rglv2_alc;
	$total_qte+=$rglv2_vente;

	print "<tr><td align=right>$rglv2_mois</td><td align=right>$rglv2_type</td><td align=right>$rglv2_cd_cl</td><td align=right>$rglv2_douane</td><td align=right>$rglv2_vente</td><td align=right>$rglv2_ca</td><td align=right>$rglv2_ndp</td><td align=right>$rglv2_pdn</td><td align=right>$rglv2_alc</td></tr>";
}
print "</table><div id=saut></div>";

# edition papier

open(FILE,">/mnt/server-file/dcg.txt");
$query="select * from rglv2 order by rglv2_cd_cl,rglv2_ndp";
$sth=$dbh->prepare($query);
$sth->execute();
$mois=$mois-1;
while (($rglv2_mois,$rglv2_type,$rglv2_cd_cl,$rglv2_douane,$rglv2_vente,$rglv2_ca,$rglv2_ndp,$rglv2_pdn,$rglv2_pdb,$rglv2_alc,$rglv2_zatt)=$sth->fetchrow_array){
	if ($rglv2_cd_cl!=$cl_cd_cl){&titre();}
	$rglv2_pdn/=1000;
	if ($rglv2_douane==1){$rglv2_pdn/=100;} # hectolitre
	if (($rglv2_douane>=6)&&($rglv2_douane<=9)){
		$rglv2_alc/=100000;
	} # hectolitre alcool pur
	$query="select type_desi from typedesi where type_code=$rglv2_douane";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($type_desi)=$sth2->fetchrow_array;
	$rglv2_douane.=" ".$type_desi;
	
	$rglv2_pdn=int($rglv2_pdn/100);
	if ((($rglv2_pdn%100)>50)||($rglv2_pdn==0)){$rglv2_pdn++};
	$rglv2_alc=int($rglv2_alc);
	if ((($rglv2_alc%1)>50)||($rglv2_alc==0)){$rglv2_alc++};

	$rglv2_vente/=100;
	$total_pdn+=$rglv2_pdn;
	$total_alc+=$rglv2_alc;
	$total_qte+=$rglv2_vente;
	$uni_sup=$rglv2_pdn;
	$regime=9672;
	if (($rglv2_douane>=6)&&($rglv2_douane<=9)){$uni_sup=$rglv2_alc;}
	if ($rglv2_douane>=19){$uni_sup=$rglv2_vente;$regime=9600}
	$ligne++;
  	 
  	print FILE "$ligne           $mois/$an         $regime     $xx2     $rglv2_ndp   ";
  	print FILE &taillefixe($rglv2_ca,8);
  	$total_ca+=$rglv2_ca;
  	print FILE " ";
  	print FILE &taillefixe($rglv2_pdn,8);
  	print FILE " ";
  	print FILE &taillefixe($uni_sup,8);
  	print FILE "        93   EU
  	
";
}
close(FILE);
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

sub pied {
	print FILE "\n\n\n
	                                     TOTAL  :$total_ca";
	$total_ca=0;
}
sub titre {
	if ($total_ca>0){&pied();}
	# print "<div id=saut></div>";
	if ($ligne>0){
		for ($i=$ligne*2;$i<26;$i++){
			print FILE "\n";
		}
	}
	$ligne=0;
	$query="select cl_cd_cl,cl_nom from client where cl_cd_cl='$rglv2_cd_cl'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($cl_cd_cl,$cl_nom)=$sth2->fetchrow_array;
	if ($rlv_type==4){$xx5="COM 9";$xx2="QV";$xx17="EXPEDITION  CLIENT"}else{$xx5="EX 9 ";$xx2="QW";;$xx17="EXPORTATION CLIENT"}
print FILE "






   $xx5   20 $mois  76 0116           B5779               39396646000015
                                                         IBS FRANCE
                                                         76209 DIEPPE
  $xx17 $cl_nom          1/1
      
      
      
      
      
      
      
      
      
      
";
}

# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/MM/DD
# SORTIE : la date formatée

sub julian {
	my ($val)=$_[0];
	my ($option)=$_[1];
	$val=$val*60*60*24;
	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime($val);    
	$annee=substr($annee,1,2);
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);

	$option=lc($option);
	if (lc($option) eq "")
	{
		($option = "dd/mm/yyyy");
	}
	$option=~s/mm/$mois/;
	$option=~s/dd/$jour/;
	$option=~s/yyyy/20$annee/;
	$option=~s/yy/$annee/;
 	return($option);
}
# FONCTION : cal(mois,option)
# DESCRIPTION : retourne le mois en clair soit au format cours ex janv(pas d'option) soit au format long (option=l)

sub cal {
	my ($mois)=$_[0]+0;
	if ($mois eq 0){$desi="Décembre";}
	if ($mois eq 1){$desi="Janvier";}
	if ($mois eq 2){$desi="Fevrier";}
	if ($mois eq 3){$desi="Mars";}
	if ($mois eq 4){$desi="Avril";}
	if ($mois eq 5){$desi="Mai";}
	if ($mois eq 6){$desi="Juin";}
	if ($mois eq 7){$desi="Juillet";}
	if ($mois eq 8){$desi="Aout";}
	if ($mois eq 9){$desi="Septembre";}
	if ($mois eq 10){$desi="Octobre";}
	if ($mois eq 11){$desi="Novembre";}
	if ($mois eq 12){$desi="Décembre";}
        return ($desi);
}


# -E Compta matiere	
