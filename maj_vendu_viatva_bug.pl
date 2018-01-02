#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;

require "./src/connect.src";
               
                
                
&save("delete from vendu_corsica_mois where vdu_mois=806 and vdu_navire='MEGA 1' ","aff");
$query="select tva_nom,date_format(tva_date,'%y%m') as cle,tva_refour,tva_type,sum(tva_qte),tva_prac,sum(tva_prixv),tva_famille,tva_sfamille from corsica_tva where tva_nom='MEGA 1' and tva_date >='2008-06-01' and tva_date <='2008-06-31' group by tva_nom,cle,tva_type,tva_cd_pr";
print "$query<br>";
$sth=$dbh->prepare($query);
$sth->execute();
while (($navire,$mois,$pr_cd_pr,$type,$qte,$prac,$vte,$famille,$sous_famille)=$sth->fetchrow_array)
{
	 $vtsb+=$vte;
	 $mois+=0;
	 $prac*=$qte;	
 	 $qte_old=0+&get("select vdu_qte from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $qte+=$qte_old;
	 $prac_old=0+&get("select vdu_prac from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $prac+=$prac_old;
	 $vte_old=0+&get("select vdu_vte from vendu_corsica_mois where vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr' and vdu_type='$type' and vdu_mois=$mois","af");
	 $vte+=$vte_old;
  	 &save("replace into vendu_corsica_mois values ('$mois','$pr_cd_pr','$type','$navire','$qte','$famille','$sous_famille','$prac','$vte')","aff");
 }
 print "*$vtsb*";
