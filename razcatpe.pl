#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$mois=$html->param("mois");
$client=$html->param("client");
$action=$html->param("action");
$index=$html->param("index");
$montant=$html->param("montant");
$option=$html->param("option");
print "<title>Recap de caisse</title>";
if ($action eq "lu"){
	&save("update message set mes_lu=1 where mes_index=$index");
	$action="";
}
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head><body>";

#$action="go";
#$client=123;
#$mois=604;
if ($action eq "validation de la facture"){
	# print "insert into recapclient values ('$client','$mois',now())";
	$dbh->do("replace into recapclient values ('$client','$mois',now(),'$montant')");
	$action="go";
}
if ($mois eq ""){
	($null,$null,$null,$null,$mois,$annee,$null,$null,$null) = localtime(time);    
	$mois=$mois*100+$annee;
}	
# if ($mois <100){$mois=`/bin/date +%m%y`+1099;} 

if ($action eq ""){&premiere();}
if ($action eq "go"){
	&go();
}

if ($action eq "client"){&clien();}
sub premiere{

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client value=10><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";
}


sub clien{
$query="select distinct cl_cd_cl,cl_nom from vol,client where v_cd_cl=cl_cd_cl order by v_cd_cl";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
	print "$cl_cd_cl $cl_nom <br>";
}
}
sub go{
$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
$sth=$dbh->prepare($query);
$sth->execute();
($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;

print "Mois:$mois   Client:$cl_nom <br>";

$query="select v_code from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 order by v_code";
 #print $query;

# print $query;
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1 bordercolor=black cellspacing=0 style=\"border: solid;\"><tr><th>no Ref</th><th>Date</th><th>Tronçon</th><th>PNC</th><th>Ca brinks</th><th>Vol</th><th>Destination</th><th><font size=-2>Chiffre d'affaire tpe</th><th><font size=-2>tpe esp</th><th><font size=-2>tpe carte</th><th><font size=-2>tpe gratuite</th><th><font size=-2>tpe voucher</th><th><font size=-2>Chiffre d'affaire constaté </th><th><font size=-2>Démarque</th><th>Total Caisse</th>";
print"</tr>\n";
$total_compn=0;
while (($code)=$sth->fetchrow_array){
	$query="select count(*) from vol where v_code='$code' group by v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($nbrot)=$sth2->fetchrow_array;
		
	$query="select v_code,v_rot,v_vol,v_date,v_dest from vol where v_code='$code' order by v_rot";
	$sthb=$dbh->prepare($query);
	$sthb->execute();
	while (($v_code,$v_rot,$v_vol,$v_date,$v_dest)=$sthb->fetchrow_array){
	if ($v_code ne $code_tampon){
		if ($color eq ""){$color='#BFEFEF';} 
		else {$color="";}
		$code_tampon=$v_code;
	}
	print "<tr bgcolor=$color ><td align=right nowrap>$v_code</td><td align=right nowrap>$v_date</td><td align=right nowrap>$v_rot</td><td><font size=-1>&nbsp;<nobr>";
	$eq_tri="";
	$query="select eq_cc,eq_equipage from equipagesql where eq_code='$v_code' and eq_rot='$v_rot'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($eq_cc,$eq_tri)=$sth2->fetchrow_array;
	print &pnc($eq_cc)." ";
	(@equipe)=split(/;/,$eq_tri);
	foreach (@equipe){
		print &pnc($_)." "; 
	}
	
	$recettes=&get("select ca_esp+ca_cb+ca_diners+ca_voucher+ca_am+ca_master from caisse where ca_code='$v_code' and ca_rot='$v_rot'");
	print "</td><td align=right nowrap>";
	print $recettes;
	print "</td>";
	# vol
	print "<td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
	if ($v_rot==1){
		$ca_fly="";
		$query="select sum(ca_esp+ca_cb+ca_diners+ca_voucher+ca_am+ca_master) from caisse where ca_code='$v_code' group by ca_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ca_recettes)=$sth2->fetchrow_array;
		$ca_recettes+=0;
		$query="select sum((ap_qte0/100-ecpn_qte)*ecpn_prix/100) from ecartpn,appro where ecpn_code='$v_code' and ap_cd_pr=ecpn_cd_pr and ap_code='$v_code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ecart_pn)=$sth2->fetchrow_array;
	
		$query="select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code' and ret_type!=1 group by ret_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ecart_fly)=$sth2->fetchrow_array;
		
		 # print "<td>*$ca_fly*$ecart_fly*$ecartpn*</td>";
	
		$vente_pn=$ca_fly-$ecart_fly+$ecartpn;
		$ecart_caisse=$ca_recettes-$vente_pn;
	
		$manquante=0;
# 		if ($ca_recettes==0 && $vente_pn>0){
# 			$manquante=$vente_pn;
# 			$ecart_caisse=0;
# 		}
		if ($ca_recettes==0 && $ca_fly>0){
 			$manquante=$ca_fly;
 			$ecart_caisse=0;
		}

		if (($ecart_fly<0)&&($ecart_caisse<0)){
			if ($ecart_fly>$ecart_caisse){
				$vente_pn+=$ecart_fly;
				$ecart_caisse-=$ecart_fly;
				$ecart_fly=0;
			}
			else
			{
				$vente_pn+=$ecart_caisse;
				$ecart_fly-=$ecart_caisse;
				$ecart_caisse=0;
			}
		}	
		if (($ecart_fly>0)&&($ecart_caisse>0)){
			if ($ecart_fly<$ecart_caisse){
				$vente_pn+=$ecart_fly;
				$ecart_caisse-=$ecart_fly;
				$ecart_fly=0;
			}
			else
			{
				$vente_pn+=$ecart_caisse;
				$ecart_fly-=$ecart_caisse;
				$ecart_caisse=0;
			}
		}	
	
		print "<td rowspan=$nbrot align=right nowrap>*";
		# Vendu des tpe
		$vente_pn =&get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro=$v_code");
		print &deci($vente_pn);
		
		# ajout le 18 juin 2009
		$query="select sum(oac_esp),sum(oac_cb+oac_diners+oac_am),sum(oac_gratuite),sum(oac_voucher) from oasix_caisse where oac_appro='$v_code' group by oac_appro";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($oac_esp,$oac_carte,$oac_gratuite,$oac_voucher)=$sth2->fetchrow_array;
		$oac_esp+=0;
		$oac_carte+=0;
		$oac_gratuite+=0;
		$oac_voucher+=0;
		$total_esp+=$oac_esp;
		$total_carte+=$oac_carte;
		$total_gratuite+=$oac_gratuite;
		$total_voucher+=$oac_voucher;
		print "</td><td rowspan=$nbrot align=right>";
		print &deci($oac_esp);
		print "</td><td rowspan=$nbrot align=right>";
		print &deci($oac_carte);
		print "</td><td rowspan=$nbrot align=right>";
		print &deci($oac_gratuite);
		print "</td><td rowspan=$nbrot align=right>";
		print &deci($oac_voucher);
		
		############
		
		print "</td><td rowspan=$nbrot align=right nowrap>";
		# chiffre d affaire constater
		$ca_fly=&get("select sum((ret_qtepnc-ret_retour)*ret_prix) from retoursql where ret_code=$v_code");
		print &deci($ca_fly);
		print "</td>";
		print "<td rowspan=$nbrot align=right nowrap>";
		$ecart_fly=$vente_pn-$ca_fly;
		print &deci($ecart_fly);
		print "</td><td rowspan=$nbrot align=right nowrap><a href=saicaissecap.pl?appro=$v_code target=_blank>";
		print $ca_recettes;
		print "</a></td>";
		$total_vpn+=$vente_pn;	
		$total_vfly+=$ca_fly;	
		$total_efly+=$ecart_pn;	
		$total_epn+=$ecart_fly;	
		$total_caisse+=$ca_recettes;	
		$total_compn+=$compn;	

		$total_ecart+=$ecart_caisse;	
		$total_manq+=$manquante;	
	}

	print "</tr>\n";
}
}
print "<tr><th colspan=7>TOTAL</th>";
print "<th  align=right>";
print &deci($total_vpn);
print "</th><th align=right>";

print &deci($total_esp);
print "</th><th align=right>";
print &deci($total_carte);
print "</th><th align=right>";
print &deci($total_gratuite);
print "</th><th align=right>";
print &deci($total_voucher);

print "</th><th align=right>";
print &deci($total_vfly);
print "</th><th align=right>";
print &deci($total_epn);
print "</th><th align=right>";
print &deci($total_caisse);
print "</th>";
print "</tr>\n</table>";
}
sub pnc{
	my $pnc=$_[0];
	if ($pnc eq "") { return;}
	my $query="select hot_tri from hotesse where (hot_mat='$pnc' or hot_tri='$pnc') and hot_cd_cl='$client'";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	(my $hot_tri)=$sth->fetchrow_array;
	if ($hot_tri eq ""){return "<a href=equipage.pl?client=$client&appro=$v_code&rot=$v_rot><font color=red>$pnc</font></a>";}
	else{
		return($hot_tri);
	}
}


# -E recap des caisses fly
