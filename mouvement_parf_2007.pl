#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
require "./src/connect.src";
&save("create temporary table produitsyl (pr_cd_pr bigint(20) NOT NULL,pr_0107 int(11) NOT NULL,pr_3009 int(11) NOT NULL,pr_entree int(11) NOT NULL,pr_sortie int(11) NOT NULL,pr_vente int(11) NOT NULL,pr_ext int(11) NOT NULL,pr_air0107 int(11) NOT NULL,pr_air3009 int(11) NOT NULL,PRIMARY KEY (pr_cd_pr))");

$query="select pr_cd_pr,pr_desi,pr_stre/100,pr_casse/100,pr_diff/100,pr_prac/100,pr_sup,pr_codebarre from produit7 where (pr_type=1 or pr_type=5) and pr_sup!=5";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_casse,$pr_diff,$pr_prac,$pr_sup,$pr_codebarre)=$sth->fetchrow_array)
{
	$errdep=&get("select sum(erdep_qte) from errdep7 where erdep_cd_pr=$pr_cd_pr");
	$pr_stre=$pr_stre-$pr_casse+$pr_diff+$errdep; # stock comptable
	if ($pr_stre<=0){next;}
	if ($pr_prac==0) {next;}
	if ($pr_sup==5){next;}
	
	$pr_stre*=100;
	if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
	$pr_stre+=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr","af")+0;
	&save("replace into produitsyl values ($pr_cd_pr,$pr_stre,'0','0','0','0','0','0','0')","af");
}
$query="select pr_cd_pr,pr_desi,pr_stre/100,pr_casse/100,pr_diff/100,pr_prac/100,pr_sup,pr_codebarre from produitsep where (pr_type=1 or pr_type=5) and pr_sup!=5";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_casse,$pr_diff,$pr_prac,$pr_sup,$pr_codebarre)=$sth->fetchrow_array)
{
	$pr_stre=$pr_stre-$pr_casse+$pr_diff; # stock comptable
	if ($pr_stre<=0){next;}
	
	if ($pr_prac==0) {next;}
	if ($pr_sup==5){next;}
	# $total+=$pr_stre;
	# print "$pr_cd_pr;$pr_stre<br>";
	$pr_stre*=100;
	if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
	$pr_0107=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_stre+=&get("select pr_3009 from produitsyl where pr_cd_pr=$pr_cd_pr");
	&save("replace into produitsyl values ($pr_cd_pr,$pr_0107,$pr_stre,'0','0','0','0','0','0')","af");
}

# entree
$query="select enb_cdpr,pr_desi,sum(enb_quantite/100),pr_prac/100,pr_prx_rev/100,pr_codebarre from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and (pr_type=1 or pr_type=5) and pr_sup!=5 and enh_date>13513 and enh_date<13787 and pr_desi not like 'teste%' group by enb_cdpr"; 
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$qte,$prac,$pr_rem,$pr_codebarre)=$sth->fetchrow_array){
	#print "$pr_cd_pr;$pr_desi;$qte<br>";
	#if ($pr_rem >0){$pr_prac=$pr_prac-($pr_prac*$pr_rem/100);print "*"}
	# $total+=$qte;
	# print "$pr_cd_pr;$qte<bR>";
	$pr_entree=100*$qte;
	if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
	$pr_0107=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_3009=&get("select pr_3009 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_entree+=&get("select pr_entree from produitsyl where pr_cd_pr=$pr_cd_pr");
	&save("replace into produitsyl values ($pr_cd_pr,$pr_0107,$pr_3009,$pr_entree,'0','0','0','0','0')");
}

# livraison navire
$query="select pr_cd_pr,sum(coc_qte/100),pr_codebarre from infococ2,comcli,produit where ic2_cd_cl=500 and coc_in_pos=5 and coc_no=ic2_no and ic2_date>=1070100 and ic2_date<1071000 and coc_cd_pr=pr_cd_pr and coc_qte!=0 and pr_desi not like 'testeur%' and (pr_type=1 or pr_type=5) and pr_sup!=5 and pr_prac!=0 group by coc_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte,$pr_codebarre)=$sth->fetchrow_array){
	$pr_sortie=100*$qte;
	if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
	$pr_0107=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_3009=&get("select pr_3009 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_entree=&get("select pr_entree from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
        $pr_sortie+=&get("select pr_sortie from produitsyl where pr_cd_pr=$pr_cd_pr");
	&save("replace into produitsyl values ($pr_cd_pr,$pr_0107,$pr_3009,$pr_entree,$pr_sortie,'0','0','0','0')");

}


# vente avion
$query="select pr_cd_pr,sum(ro_qte)/100,pr_codebarre from rotation,vol,produit where ro_code=v_code and v_rot=1 and ro_cd_pr=pr_cd_pr and v_date_jl>='13514' and v_date_jl<='13787' and (pr_type=1 or pr_type=5) group by ro_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte,$pr_codebarre)=$sth->fetchrow_array){
	$pr_vente=100*$qte;
	if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
	$pr_0107=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_3009=&get("select pr_3009 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_entree=&get("select pr_entree from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
       	$pr_sortie=&get("select pr_sortie from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
       	$pr_vente+=&get("select pr_vente from produitsyl where pr_cd_pr=$pr_cd_pr");
        $total+=$qte;
	&save("replace into produitsyl values ($pr_cd_pr,$pr_0107,$pr_3009,$pr_entree,$pr_sortie,$pr_vente,'0','0','0')");
}

# client exterieur
$query="select pr_cd_pr,sum(coc_qte/100),pr_codebarre from infococ2,comcli,produit where ic2_cd_cl!=500 and coc_in_pos=5 and coc_no=ic2_no and ic2_date>=1070100 and ic2_date<1071000 and coc_cd_pr=pr_cd_pr and coc_qte!=0 and pr_desi not like 'testeur%' and (pr_type=1 or pr_type=5) and pr_sup!=5 group by coc_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$qte,$pr_codebarre)=$sth->fetchrow_array){
	$pr_ext=100*$qte;
	if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
	$pr_0107=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_3009=&get("select pr_3009 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_entree=&get("select pr_entree from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
        $pr_sortie=&get("select pr_sortie from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
	$pr_vente=&get("select pr_vente from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
       	$pr_ext+=&get("select pr_ext from produitsyl where pr_cd_pr=$pr_cd_pr");
	&save("replace into produitsyl values ($pr_cd_pr,$pr_0107,$pr_3009,$pr_entree,$pr_sortie,$pr_vente,$pr_ext,'0','0')","af");

}


# bon en l'air
# il faut soustraire au stock du 3112 les ventes pre-3112
# il faut soustraire au stock du 3009 les ventes pre-3009

$query="select infr_code from inforetsql,vol where infr_date>'2006-12-31' and infr_code=v_code and v_rot=1 and  FROM_UNIXTIME(v_date_jl*24*60*60,'%Y-%m-%d')<='2006-12-31'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code)=$sth->fetchrow_array){
	$query="select ro_cd_pr,sum(ro_qte)/100,pr_codebarre from rotation,produit where ro_code=$v_code and ro_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_sup!=5 group by ro_cd_pr";
  	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$qte,$pr_codebarre)=$sth2->fetchrow_array){
		$pr_air0107=100*$qte;
		if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
		$pr_0107=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_3009=&get("select pr_3009 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_entree=&get("select pr_entree from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_sortie=&get("select pr_sortie from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_vente=&get("select pr_vente from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_ext=&get("select pr_ext from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_air0107+=&get("select pr_air0107 from produitsyl where pr_cd_pr=$pr_cd_pr");
		&save("replace into produitsyl values ($pr_cd_pr,$pr_0107,$pr_3009,$pr_entree,$pr_sortie,$pr_vente,$pr_ext,$pr_air0107,'0')","af");
	}
}
$query="select infr_code from inforetsql,vol where infr_date>'2007-09-30' and infr_code=v_code and v_rot=1 and  FROM_UNIXTIME(v_date_jl*24*60*60,'%Y-%m-%d')<='2007-09-30'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code)=$sth->fetchrow_array){
	$query="select ro_cd_pr,sum(ro_qte)/100,pr_codebarre from rotation,produit where ro_code=$v_code and ro_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5) and pr_sup!=5 group by ro_cd_pr";
  	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$qte,$pr_codebarre)=$sth2->fetchrow_array){
		$pr_air3009=100*$qte;
		if (($pr_cd_pr <10000000)&&($pr_codebarre>10000000)){$pr_cd_pr=$pr_codebarre;}
		$pr_0107=&get("select pr_0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_3009=&get("select pr_3009 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_entree=&get("select pr_entree from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_sortie=&get("select pr_sortie from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_vente=&get("select pr_vente from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_ext=&get("select pr_ext from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_air0107=&get("select pr_air0107 from produitsyl where pr_cd_pr=$pr_cd_pr")+0;
		$pr_air3009+=&get("select pr_air3009 from produitsyl where pr_cd_pr=$pr_cd_pr");
		&save("replace into produitsyl values ($pr_cd_pr,$pr_0107,$pr_3009,$pr_entree,$pr_sortie,$pr_vente,$pr_ext,$pr_air0107,$pr_air3009)","af");
	}
}


$query="select pr_cd_pr,pr_0107/100,pr_3009/100,pr_entree/100,pr_sortie/100,pr_vente/100,pr_ext/100,pr_air0107/100,pr_air3009/100 from produitsyl";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_0107,$pr_3009,$pr_entree,$pr_sortie,$pr_vente,$pr_ext,$pr_air0107,$pr_air3009)=$sth->fetchrow_array)
{
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
	$pr_ecart=&get("select sum(tjo_qte)/100 from trace_jour,produit where tjo_cd_pr=pr_cd_pr and pr_codebarre=$pr_cd_pr and tjo_date>='2007-01-01' and tjo_date<='2007-09-17' and tjo_type=9")+0;
       	$pr_ecart-=&get("select sum(tjo_qte)/100 from trace_jour,produit where tjo_cd_pr=pr_cd_pr and pr_codebarre=$pr_cd_pr and tjo_date>='2007-01-01' and tjo_date<='2007-09-17' and tjo_type=5");

        $ecart=$pr_3009-($pr_0107+$pr_entree-$pr_sortie-$pr_vente+$pr_ecart-$pr_ext);
# 	if (($pr_ecart<0)&&($ecart>0)){
# 		$temp=$pr_ecart;
# 		$pr_ecart+=$ecart;
# 		$ecart+=$temp;
# 		}
	print "$pr_cd_pr;$pr_desi;$pr_0107;$pr_3009;$pr_entree;$pr_sortie;$pr_vente;$pr_ext;$pr_ecart;$pr_air0107;$pr_air3009;$ecart<br>";
	if ($ecart==0){$nb++;}
}
print "<b>$nb";

