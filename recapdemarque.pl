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
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         

span.info{
position:relative;
z-index:24;
color:#000;
text-decoration:none
}
 
span.info:hover{
z-index:25;
background-color:#FFF
}
 
span.info span{
display: none
}
 
span.info:hover span{
display:block;
position:absolute;
top:2em; left:2em; width:15em;
border:1px solid #000;
background-color:#FFF;
color:#000;
text-align: justify;
font-weight:none;
padding:5px;
}
-->
</style></head><body>";


print "<title>Recap demarque</title>";
if ($mois eq ""){
	($null,$null,$null,$null,$mois,$annee,$null,$null,$null) = localtime(time);    
	$mois=$mois*100+$annee;
}	
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
	
	$query="select v_code,v_vol,v_date,v_dest,ret_cd_pr,ret_qte,ret_qte-ret_retourpnc,ret_retour,ret_prix from retoursql,vol where v_cd_cl='$client' and v_date%10000='$mois' and v_rot=1 and v_code=ret_code group by v_code,ret_cd_pr order by v_code,ret_cd_pr";
# 	 print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 bordercolor=black cellspacing=0 style=\"border: solid;\"><tr><th>no de Vol</th><th>Dest</th><th>date</th><th>Produit</th><th>";
	print "<span class=\"info\">";
	print "prix de vente";
	print "<span>ret_prix</span></span>";
	print "</th><th>Qte départ</th><th>";
	print "<span class=\"info\">";
	print "Qte vente tpe";
	print "<span>ret_qte-ret_retourpnc</span></span>";
	print "</th><th>";
	print "<span class=\"info\">";
	print "Qte Nb Saisie";
	print "<span>ret_qte-ret_retour</span></span>";
	print "</th><th>Démarque</th><th>Valeur démarque</th></tr>";
	while (($v_code,$v_vol,$v_date,$v_dest,$pr_cd_pr,$qtedep,$qtevdu,$qteret,$prix)=$sth->fetchrow_array){
		if (($v_code ne $tampon)&&($tampon ne "")){
            $total+=0;
			if ($total!=0){
				print "<tr><th colspan=9>Total $tampon $vol $date</th><th>$total";
				$vente_pn =&get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro='$tampon'");
				$ca_fly=&get("select sum((ret_qtepnc-ret_retour)*ret_prix) from retoursql where ret_code='$tampon'");
				$ecart_fly=$vente_pn-$ca_fly;
				if ($ecart_fly!=$total) { print "<font color=red>erreur donnée</font>";}
				print "</th></tr>";
			}
			$liste{"$tampon"}=$total;			
			$totalf+=$total;  
		        $total=0;
			# if (($v_code <= "25840")){&ecart();}
		}
		$tampon=$v_code;
		$vol=$v_vol;
		$date=$v_date;
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'","af");
		$ecart=$qteret-($qtedep-$qtevdu);
		if ($ecart==0){next;}
		$ca=$prix*$ecart;
		$total+=$ca;
		print "<tr><td>$v_vol</td><td>$v_dest</td><td>$v_date</td><td>$pr_desi</td><td>$prix</td><td>$qtedep</td><td>$qtevdu</td><td>$qteret</td><td>$ecart</td><td>$ca</td></tr>";
	}
	if ($tampon ne ""){
		$total+=0;
		if ($total!=0){
			print "<tr><th colspan=9>Total $tampon $vol $date</th><th>$total";
			$vente_pn =&get("select sum(vdu_qte*vdu_prix) from vendusql where vdu_appro='$tampon'");
			$ca_fly=&get("select sum((ret_qtepnc-ret_retour)*ret_prix) from retoursql where ret_code='$tampon'");
			$ecart_fly=$vente_pn-$ca_fly;
			if ($ecart_fly!=$total) { print "<font color=red>erreur donnée</font>";}
			print "</th></tr>";
		}
		
	}
	$totalf+=$total;  
	print "</table>";
	print "<br>total demarque pour l'edition ci-dessus:$totalf<br>";
}

sub ecart {
	$appro=$v_code;
	$nbh=$valec=0;
	%tab={};	
	%prixec={};
	$query="select oac_num,oac_rot from oasix_caisse where oac_appro='$appro'";
	$sthe = $dbh->prepare($query);
	$sthe->execute;
	while (($num,$rot) = $sthe->fetchrow_array) {
	
		$query="select oa_col2,oa_col3,count(*) from oasix,oasix_tpe,oasix_appro where oasix.oa_serial=oasix_tpe.oa_serial and oa_type='p' and oa_col3>0 and oa_date_import=oaa_date and oa_rotation='vente$rot.txt' and oaa_appro=$appro and oa_num=$num and oaa_serial=oasix_tpe.oa_serial group by oa_col2";
		$sth2 = $dbh->prepare($query);
		$sth2->execute;
		while (($desi,$prixx,$qte) = $sth2->fetchrow_array){
			$tab{"$desi"}+=$qte;
			$prixec{"$desi"}=$prixx/100;
		}
		$query="select oa_col2,count(*) from oasix,oasix_tpe,oasix_appro where oasix.oa_serial=oasix_tpe.oa_serial and oa_type='p' and oa_col3<0 and oa_date_import=oaa_date and oa_rotation='vente$rot.txt' and oaa_appro=$appro and oa_num=$num and oaa_serial=oasix_tpe.oa_serial group by oa_col2";
		$sth2 = $dbh->prepare($query);
		$sth2->execute;
		while (($desi,$qte) = $sth2->fetchrow_array){
			$tab{"$desi"}-=$qte;
		}
	}
   	$query="select ret_cd_pr,ret_qte-ret_retourpnc,ret_prix from retoursql where ret_code=$appro";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (($ret_cd_pr,$ret_qte,$ret_prix) = $sth2->fetchrow_array){
	   	$query="select oa_desi from oasix_prod where oa_cd_pr=$ret_cd_pr";
		$sth3 = $dbh->prepare($query);
		$sth3->execute;
		while($desi=$sth3->fetchrow_array){
			# print "$v_code 	$desi<bR>";			
			$tab{"$desi"}=0;
		}
	}	
	foreach $cle (%tab) {
		if ($tab{$cle}!=0) {
			if ($cle eq "The noir"){next;}
			
			# print "<tr><td>$cle $tab{$cle} $prix{$cle}</td></tr>";
			$nbh=$tab{$cle};
			$prx=$prixec{$cle};
			$valec=$nbh*$prx;
			print "<tr bgcolor=#efefef><td>$v_vol</td><td>$v_dest</td><td>$v_date</td><td>$cle</td><td>$prx</td><td>0</td><td>$nbh</td><td>0</td><td>$nbh</td><td>$valec</td></tr>";
			$total+=$valec;
	
		}
	}	
}

