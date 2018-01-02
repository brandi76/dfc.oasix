#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
# print "<h1>EN MAINTENANCE POUR QUELQUE MINUTE</h1>";
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
if ($mois eq ""){$mois=`/bin/date +%m%y`-100;} 
if ($mois <100){$mois=`/bin/date +%m%y`+1099;} 

if ($action eq ""){&premiere();}
if ($action eq "go"){
	&go();
	if ($client==338){&gomini();}
	if ($client==339){&gomini();}
	if ($client==234){&gomini();}
	if ($client==345){&gocatering();}

}

if ($action eq "client"){&clien();}
sub premiere{
	$query="select * from message where mes_fin>=now() and mes_lu!=1 and (mes_dest='philippe') order by mes_dest";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($index,$src,$dest,$date,$message)=$sth->fetchrow_array)
	{
		print "<table border=1 cellspacing=0><tr bgcolor=lightblue><td>de la part de $src pour <b>$dest</b></td><td>Date de validite:$date</td></tr>";
		print "<tr><td><font color=red>$message</td><td><a href=?action=lu&index='$index'>lu</a></td></tr>";
		print "</table><br>";
	}

print "<center>Recap<br><form>Mois (MMAA):<input type=text name=mois value='$mois'><br>";
print " <a href=recap.pl?action=client>Code client:</a><input type=text name=client><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";
print "<br>Liste des 15 dernieres recaps validées<br><br>";
print "<table border=1 cellspacing=0 width=70%><tr><th>Mois validé</th><th>Date de validation</th><th>Client</th></tr>";
$query="select date,mois,cl_nom from recapclient,client where cl_cd_cl=client order by date desc limit 15";	
$sth=$dbh->prepare($query);
$sth->execute();
while (($date,$mois,$cl_nom)=$sth->fetchrow_array){
	print "<tr><td>date:$mois</td><td>$date</td><td>$cl_nom</td></tr>";
}
print "</table><br><br>";
print "<br>Liste des recaps validées<br><br>";
print "<table border=1 cellspacing=0 width=70%><tr><th>Mois validé</th><th>Date de validation</th><th>Client</th></tr>";
$query="select date,mois,cl_nom from recapclient,client where cl_cd_cl=client order by cl_cd_cl,date desc";	
$sth=$dbh->prepare($query);
$sth->execute();
while (($date,$mois,$cl_nom)=$sth->fetchrow_array){
	print "<tr><td>date:$mois</td><td>$date</td><td>$cl_nom</td></tr>";
}
print "</table>";

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

$query="select v_code from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1  and v_troltype>100 order by v_code";
# print $query;
if ($option eq "catering"){
	$query="select v_code from vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 and v_troltype=12 order by v_code";
}

  print $query;
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1 bordercolor=black cellspacing=0 style=\"border: solid;\"><tr><th>Bon</th><th>Date</th><th>Rot</th><th>Type</th><th>Commentaire</th><th>PNC</th><TH>Caisse</th><TH>Stim</th><th>Vol</th><th>Destination</th>";
# print "<th><font size=-2>Chiffre d'affaire</th>";
print "<th><font size=-2>Chiffre d'affaire constaté par DFC</th><th><font size=-2>Valeur de la marchandise manquante constatée au départ</th>";
# print "<th><font size=-2>Valeur de la marchandise manquante constaté au retour</th>";
print "<th>Total Caisse</th>";
if ($client==338){print "<th>Commission prise</th>";}
print"<th >Ecart caisse</th><th><font size=-2>Valeur des caisses manquantes</th></tr>\n";
$total_compn=0;
while (($code)=$sth->fetchrow_array){
	$query="select count(*) from vol where v_code='$code' group by v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($nbrot)=$sth2->fetchrow_array;
		
	$query="select v_code,v_rot,v_vol,v_date,v_dest,v_troltype from vol where v_code='$code' order by v_rot";
	$sthb=$dbh->prepare($query);
	$sthb->execute();
	while (($v_code,$v_rot,$v_vol,$v_date,$v_dest,$v_troltype)=$sthb->fetchrow_array){
	if ($v_code ne $code_tampon){
		if ($color eq ""){$color='#BFEFEF';} 
		else {$color="";}
		$code_tampon=$v_code;
	}
	$etat=&get("select at_etat from etatap where at_code='$v_code'");
	if ($etat<5){$color="pink";}
	print "<tr bgcolor=$color ><td align=right nowrap>$v_code</td><td align=right nowrap>$v_date</td><td align=right nowrap>$v_rot</td><td>$v_troltype</td>";
	print "<td>";
 	$commentaire=&get("select com_reponse from commentaire where com_appro=$v_code and com_rot=$v_rot");
	print $commentaire;
	print "</td>";	
        print "<td><font size=-1>&nbsp;<nobr>";
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
	$query="select ca_total,ca_papi from caissesql where ca_code='$v_code' and ca_rot='$v_rot'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
	if ($ca_recettes eq ""){
		$query="select ca_recettes/100,ca_cheque/100 from caisse where ca_code='$v_code' and ca_rot='$v_rot'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
	}
	
	$ca_recettes-=$ca_papi;
	# enlever le 1 aout 2011 suite demande pp (stim et pas papi)
	# $ca_recettes-=$ca_papi;
	# enlever le 1 septembre 2011 suite mail pp 

	
	# $fondcaisse=&get("select ap_qte0*ap_prix/10000 from appro where ap_code='$v_code' and ap_cd_pr=800205")+0;
	# $ca_recettes-=$fondcaisse;
	# ca_recettes=caissesql.ca_total ou caisse.ca_recettes-fondcaisse;
	print "</td><td align=right nowrap>";
	print &deci($ca_recettes);
	print "</td><td align=right nowrap>";
	#stim
	print &deci($ca_papi);
	$total_papi+=$ca_papi;
	# vol
	print "<td align=right nowrap>$v_vol</td><td align=right nowrap>$v_dest</td>";
	if ($v_rot==1){
		$ca_fly="";
		$query="select sum(ca_fly/100) from caisse where ca_code='$v_code' group by ca_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ca_fly)=$sth2->fetchrow_array;
		# ca_fly= caisse.ca_fly
		
		$query="select sum(ca_total),sum(ca_papi) from caissesql where ca_code='$v_code' group by ca_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
		$ca_recettes-=$ca_papi;
		# $ca_recettes-=$ca_papi;

		
		if ($ca_recettes eq ""){
			# print "<td>*";
			$query="select sum(ca_recettes/100),sum(ca_cheque/100) from caisse where ca_code='$v_code' group by ca_code";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($ca_recettes,$ca_papi)=$sth2->fetchrow_array;
			# print "$ca_recettes</td>";
		}
	        # $ca_fly-=$ca_papi; enlever le 1 aout 2011 suite demande pp (stim et pas papi)
			# ca_fly= caisse.ca_fly-ca_papi (caisse.ca_cheque);
		
		# $ca_recettes-=$ca_papi; enlever le 1 aout 2011 suite demande pp (stim et pas papi)
		# $fondcaisse=&get("select ap_qte0*ap_prix/10000 from appro where ap_code='$v_code' and ap_cd_pr=800205")+0;
		#$ca_recettes-=$fondcaisse;
		#$ca_fly-=$fondcaisse;
		# ca_fly= caisse.ca_fly-caisse.ca_papi-fondcaisse
		
		# vol non imputable à la compagnie
		$query="select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code' and ret_type=1 group by ret_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($vol)=$sth2->fetchrow_array;
		$ca_fly-=$vol;
		# ca_fly= caisse.ca_fly-caisse.ca_papi-fondcaisse-(ecart entre retourssql.retourpnc et retourssql.retourpreparateur et type=1 ecart interne) 
		
		# if ($v_code eq "18341"){$ca_fly-=347;}		
	
		#$query="select sum((ap_qte0/100-ecpn_qte)*ecpn_prix/100) from ecartpn,appro where ecpn_code='$v_code' and ap_cd_pr=ecpn_cd_pr and ap_code='$v_code'";
		# modifié le 240210 pour la recap burkina suite tableua de giulia
		$query="select ecpn_prix from ecartpn where ecpn_code='$v_code'";
		
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ecart_pn)=$sth2->fetchrow_array;
	
		$query="select sum((ret_retourpnc-ret_retour)*ret_prix) from retoursql where ret_code='$v_code' and ret_type!=1 group by ret_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($ecart_fly)=$sth2->fetchrow_array;
		
		#  print "<td>*$ca_fly*$ecart_fly*$ecartpn*</td>";
	
		$vente_pn=$ca_fly-$ecart_fly+$ecartpn; # retiré le 15 septembre 2011 pas raison d'ecart
		$vente_pn=$ca_fly;
		$ecart_fly=0;
		$ecart_caisse=$ca_recettes-$vente_pn;
		# ca_recettes=caissesql.ca_total ou caisse.ca_recettes-fondcaisse;
		
		$manquante=0;
# 		
		
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
	
		# print "<td rowspan=$nbrot align=right nowrap>";
		$query="select * from ventilcasql where vta_code='$v_code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($vta_code,$vta_rot1,$vta_flag1,$vta_rot2,$vta_flag2,$vta_rot3,$vta_flag3,$vta_rot4,$vta_flag4)=$sth2->fetchrow_array;
		if ($vta_rot1!=0){
			if ($vta_flag1==1){print "<font color=red>";}
		#	print "rot1:$vta_rot1</font><br>";
		}
		if ($vta_rot2!=0){
			if ($vta_flag2==1){print "<font color=red>";}
			# print "rot2:$vta_rot2</font><br>";
		}
		if ($vta_rot3!=0){
			if ($vta_flag3==1){print "<font color=red>";}
			# print "rot3:$vta_rot3</font><br>";
		}
		if ($vta_rot4!=0){
			if ($vta_flag1==1){print "<font color=red>";}
			# print "rot4:$vta_rot4</font><br>";
		}
		# ecart
		
		$ca_fly-=$ecart_pn;
		
		if ($ecart_pn+0!=0){
		    if ($ecart_fly+0 >=$ecart_pn){
			$ecart_fly-=$ecart_pn;
  			$ecart_pn=0;
			}
			else
			{
  			$ecart_pn-=$ecart_fly;
 			$ecart_fly=0;
			}
		}
		
		
		# ca_fly= caisse.ca_fly-caisse.ca_papi-fondcaisse
		# -ecart entre retourssql.retourpnc et retourssql.retourpreparateur et type=1 ecart interne
		# - ecartpn.ecpnprix ??
		
		# vente_pn=ca_fly
		# - ecart entre retourssql.retourpnc et retourssql.retourpreparateur et type!=1
		# - ecartpn.ecpnprix ??
		# print &deci($vente_pn);
		# print "</td>";

		print "<td rowspan=$nbrot align=right nowrap>";
		# ici chiffre d affaire constater
		print &deci($ca_fly);
		print "</td>";
		print "<td rowspan=$nbrot align=right nowrap>";
		print &deci($ecart_pn);
		print "</td>";
		# print "<td rowspan=$nbrot align=right nowrap>";
		# print &deci($ecart_fly);
		# print "</td>";
		print "<td rowspan=$nbrot align=right nowrap>";
		print &deci($ca_recettes);
		print "</td><td rowspan=$nbrot align=right nowrap>";
		# modifier le 15 sep 2011		
		$ecart_caisse=$ca_recettes+$ca_papi-$ca_fly;		
		# $ecart_caisse+=$ca_papi;
		print &deci($ecart_caisse);
		print "</td><td rowspan=$nbrot align=right nowrap>";
		print &deci($manquante);
		print "</td>";
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
print &deci($total_papi);
print "<th colspan=2>&nbsp;</th>";
# print "<th  align=right>";
# print &deci($total_vpn);
# print "</th>";
print "<th align=right>";
print &deci($total_vfly);
print "</th><th align=right>";
print &deci($total_efly);
# print "</th><th align=right>";
# print &deci($total_epn);
print "</th><th align=right>";
print &deci($total_caisse);
print "</th><th align=right>";
if ($client==338){
	print &deci($total_compn);
	print "</th><th align=right>";
}
print &deci($total_ecart);
print "</th><th align=right>";
print &deci($total_manq);
print "</th></tr>\n</table>";
print "<br><Table border=0>";
print "<tr><td><b>Chiffre d'affaire:</td><td align=right><b>";
print &deci($total_vfly);
print "</td></tr>\n";
print "<tr><td>Commissions $cl_com1%</td><td align=right>";
if (cl_com1 eq ""){$cl_com1=100;}
$com=$total_vfly*$cl_com1/100;
print &deci($com);
print "</td></tr>";
if ($client==338){
	print "<tr><td>Commission PNC </td><td align=right>";
	print &deci($total_compn);
	print "</td></tr>";
	}
print "<tr><td>Produits manquants</td><td align=right>";
print &deci($total_epn);
print "</td></tr>";
print "<tr><td>Ecart de caisse</td><td align=right>";
print &deci($total_ecart);
print "</td></tr>";
print "<tr><td>Caisses manquantes</td><td align=right>";
print &deci($total_manq);
print "</td></tr>";
print "<tr><td><b>Soldes</td><td align=right><b>";
$solde=$com-$total_epn-$total_compn+$total_ecart-$total_manq;
print &deci($solde);
print "</td></tr>";
print "</table>";
$query="select date,montant from recapclient where client='$client' and mois='$mois'";
$sth=$dbh->prepare($query);
$sth->execute();
($recap_date,$montant)=$sth->fetchrow_array;
$montant+=0;
if ($recap_date eq ""){
print "<form><br>Montant pris en charge <input type=text name=montant> <input type=submit name=action value=\"validation de la facture\"><input type=hidden name=client value=$client>";
print "<input type=hidden name=mois value=$mois></form>";
}
else
{
	print "<br>Montant pris en charge par DFC: $montant<h3><font color=red>validation par philippe Perraud le $recap_date</font></h3>";
}
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

sub gomini{
	print "<div id=saut></div><h1>produit offert à bord</h1><br>";
	print "Mois:$mois   Client:$cl_nom <br>";
	$query="select v_code,v_date,v_vol,v_troltype from vol,etatap where (v_troltype<100) and v_cd_cl='$client' and v_date%10000='$mois' and at_code=v_code and at_etat>0 group by v_code";
	&gominisuite();
	$totalgen=0;
	 print "<div id=saut></div><h1>Commande</h1><br>";
	 print "Mois:$mois   Client:$cl_nom <br>";
	 $query="select v_code,v_date,v_vol,v_troltype from vol,etatap where (v_troltype=10) and v_cd_cl='$client' and v_date%10000='$mois' and at_code=v_code and at_etat>0 group by v_code";
	 &gominisuite();
}

sub gominisuite{
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_date,$v_vol,$v_troltype)=$sth->fetchrow_array){
		print "<b>Vol:$v_vol du $v_date bon appro No:$v_code<br><table border=0 width=500>";
		$query="select ro_cd_pr,pr_desi,floor(ro_qte/100) from rotation,produit where ro_cd_pr=pr_cd_pr and ro_code=$v_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		if ($client==3384){
			$query="select ap_cd_pr,pr_desi,floor(ap_qte0/100) from appro,produit where ap_cd_pr=pr_cd_pr and ap_code=$v_code and ap_qte0>0";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
		}		
		$total=0;
		while (($pr_cd_pr,$pr_desi,$qte)=$sth2->fetchrow_array){
			if ($qte<0) {next;}
			$prix=0;
			print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td>";
			if (($pr_cd_pr==120536)||($pr_cd_pr==120535)||($pr_cd_pr==120050)){$prix=1.75;}
			if (($pr_cd_pr==122069)){$prix=6.95;}
			if (($pr_cd_pr==122072)){$prix=8.90;}
			if (($pr_cd_pr==120669)){$prix=2.25;}
			if (($pr_cd_pr==120420)){$prix=2.25;}
			if (($pr_cd_pr==120669)){$prix=2.25;}
			if (($pr_cd_pr==122074)){$prix=4.24;}
			if (($pr_cd_pr==300002)){$prix=150;}
			
			if (($pr_cd_pr==122073)){$prix=8.50;}
			if (($pr_cd_pr==120053)){$prix=24.60;}
			if (($pr_cd_pr==122071)){$prix=3.35;}
			if (($pr_cd_pr==122082)){$prix=4.95;}
			if (($pr_cd_pr==160180)){$prix=0.49;}
			if (($pr_cd_pr==120571)){$prix=1.85;}
			if (($pr_cd_pr==120452)){$prix=1.85;}
			if (($pr_cd_pr==120450)){$prix=1.85;}
			if (($pr_cd_pr==122070)){$prix=7.25;}
			if (($pr_cd_pr==120693)||($pr_cd_pr==120455)||($pr_cd_pr==120692)||($pr_cd_pr==121100)||($pr_cd_pr==120051)){$prix=2.25;}
			if (($pr_cd_pr==120572)||($pr_cd_pr==120570)||($pr_cd_pr==120682)||($pr_cd_pr==120556)||($pr_cd_pr==120620)||($pr_cd_pr==120400)){$prix=1.85;}
			if (($pr_cd_pr==120673)||($pr_cd_pr==120676)||($pr_cd_pr==120660)||($pr_cd_pr==135300)){$prix=2.05;}
			if ($pr_cd_pr==120052){$prix=16;}
			$mont=$prix*$qte;
			$total+=$mont;
			$color="black";
			if ($prix <=0){$color="red";}
			print "<td align=right><font color=$color>$prix</td><td align=right>$mont</td></tr>";
		}
		print "<tr><th colspan=4>TOTAL</th><th align=right>$total</th></table>";
		$totalgen+=$total;
	}
	print "Total à facturer:$totalgen";
} 


sub gocatering{
	print "<div id=saut></div><h1>catering</h1><br>";
	print "Mois:$mois   Client:$cl_nom <br>";
	$query="select v_vol,v_date from vol,etatap where v_troltype=12 and v_date%10000='$mois' and at_code=v_code and at_etat>0 and v_cd_cl=345 group by v_vol,v_date";
	&gocatsuite();
}

sub gocatsuite{
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1><th>Appro</th><th>vol</th><th>date</th><th>Caisse</th></tr>";
	while (($v_vol,$v_date)=$sth->fetchrow_array){
		print "<tr><td>";
		$query="select v_code from vol where v_vol='$v_vol' and v_date='$v_date' and v_troltype=12 group by v_code";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$ca_recettes=0;
		$vendu_sand=0;
		while (($v_code)=$sth2->fetchrow_array){
			print "$v_code ";
			$query="select sum(ca_total-ca_papi) from caissesql where ca_code='$v_code' group by ca_rot";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			$ca_recettes+=$sth3->fetchrow_array;
			$fondcaisse=&get("select ap_qte0*ap_prix/10000 from appro where ap_code='$v_code' and ap_cd_pr=800205")+0;
			$ca_recettes-=$fondcaisse;
			$query="select sum(ret_qte-ret_retour) from appro,retoursql where ap_code='$v_code' and ap_cd_pr=300122 and ret_code=ap_code and ret_cd_pr=300122";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			$vendu_sand+=$sth3->fetchrow_array;
			#print "$query<br>";
				
		}
		print "<td>$v_vol</td><td>$v_date</td>";
		print "<td align=right nowrap>";
		print &deci($ca_recettes);
		$total+=$ca_recettes;
		$total_sand+=$vendu_sand;
		print "<td>$vendu_sand</td>";	
		
		
		print "</td></tr>";
	}
	print "</table>";
	print "<br><Table border=0>";
	print "<tr><td><b>Chiffre d'affaire:</td><td align=right><b>";
	print &deci($total);
	print "</td></tr>\n";
	print "<tr><td>Commissions $cl_com1%</td><td align=right>";
	$com=$total*$cl_com1/100;
	print &deci($com);
	print "</td></tr>";
	print "<tr><td><b>Soldes</td><td align=right><b>";
	$solde=$com;
	print &deci($solde);
	print "</td></tr>";
	print "<tr><td>Nombre de sandwich vendus</td><td>$total_sand</td></tr>";
	print "</table>";
} 



# -E recap des caisses fly
