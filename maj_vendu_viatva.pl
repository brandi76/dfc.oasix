#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;

require "./src/connect.src";
               
$an=$html->param("an");
$mois=$html->param("mois");
$action=$html->param("action");
$moisref=($an-2000)*100+$mois;
$debut=$an."-".$mois."-01";
$fin=$an."-".$mois."-31";
                
if ($action eq ""){
print "<pre>mise à jour des vendues 'vendu_corsica_mois' avec le fichier corsica_tva
<form>année <input type=text name=an>
mois  <input type=text name=mois>
<input type=hidden name=action value=go>
<input type=submit ></form> ";

}
else
{                
                
                
&save("delete from vendu_corsica_mois where vdu_mois=$moisref","aff");
$query="select tva_nom,tva_desi,date_format(tva_date,'%y%m') as cle,tva_refour,tva_type,sum(tva_qte),tva_prac,sum(tva_prixv),tva_famille,tva_sfamille from corsica_tva where tva_date>='$debut' and tva_date<='$fin' group by tva_nom,cle,tva_type,tva_refour";
#  print $query;
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire,$tva_desi,$mois,$pr_cd_pr,$type,$qte,$prac,$vte,$famille,$sous_famille)=$sth->fetchrow_array)
{
# 	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
# 	if ($pr_desi eq "" ){
# 		while ($tva_desi=~s/\'//){};
# 		&save("insert into produit value ('$pr_cd_pr','$tva_desi','0','0','0','0','0','0','4','0','0','5','0','$prac','0','0','0','0','0','0','0','0','12','0','0','$pr_cd_pr')","aff");
# 	}
	 $mois+=0;
# 	 $qte_anc=$qte;
# 	 print "$pr_cd_pr,$qte<br>";
	 $prac*=$qte;	
	 $qte_old=0+&get("select vdu_qte from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $qte+=$qte_old;
	 $prac_old=0+&get("select vdu_prac from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $prac+=$prac_old;
	 $vte_old=0+&get("select vdu_vte from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $vte+=$vte_old;
# 	 if (($qte >400)&&($navire eq "REGINA")&&($famille eq "PARFUMS")){
# 	 print "select vdu_qte from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois";
# 	 print "*$qte_old $qte_anc*";
	 
# 	 exit;}

 	 &save("replace into vendu_corsica_mois values ('$mois','$pr_cd_pr','$type','$navire','$qte','$famille','$sous_famille','$prac','$vte')","af");
 }
 
$verif=&get("select sum(tva_prixv) from corsica_tva where tva_date >='$debut' and tva_date <='$fin'");
$verif2=&get("select sum(vdu_vte) from vendu_corsica_mois where vdu_mois=$moisref ");
if ($verif==$verif2){print "importation effectuée avec succès";}else{print "<font color=red>erreur importation</font>";}

}
