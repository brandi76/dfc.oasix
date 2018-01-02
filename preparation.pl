#!/usr/bin/perl
use CGI;
use DBI();
       
$html=new CGI;
require "../oasix/outils_perl2.lib";
$action=$html->param('action');
if ($action ne "tpe"){
	print $html->header;
	print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
	<!--
	#saut { page-break-after : right }         
	-->
	</style></head><body>";
}
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$today=&nb_jour($jour,$mois,$an);
if ($today==-1){$today=$html->param('today');}
$nbjour=$html->param('nbjour');
$nodepart=$html->param('nodepart');
$pr_cd_pr=$html->param('produit');
$vol=$html->param('vol');
$date_vol=$html->param('date_vol');


if ($action eq "backup"){
	&backup();
	$action="";
}
for ($i=-3;$i<=21;$i++){
	$check=$html->param("check$i");
	if ($check eq "on"){
		push (@liste,$html->param("val$i"));
	}
}

require "./src/connect.src";
# &save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
{
	$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
}


if ($action eq "force"){$res=`/home/fly/run/force-transfertp`;$action=""}

##### >rm traitement de releve de marchandise
if ($action eq "sup") ### modification d'un depart
{
	$query="delete from listevol where liv_dep=$nodepart and liv_vol='$vol' and liv_date=$date_vol and liv_aprec='' and liv_nolot=''";
	if (&execute()){ print "<br> <font color=red> $vol dans le depart $nodepart supprimé </font></br>";}
	&go();
}


if ($action eq "supd") ### Suppression d'un depart
{
	$query="delete from listevol where liv_dep=$nodepart and liv_aprec='' and liv_nolot=''";
	if (&execute()){ print "<br> <font color=red>depart $nodepart supprimé </font></br>";}

	$action="";

}


#### ""  Premiere page
if ($action eq ""){
#  	print "<h2><font color=red>Ajouter le vol au depart de marseille du 4 mai (sylvain message d'aujourd'hui )</font></h2>";
 	$date=`/bin/date +%d';'%m';'%Y`;
  	($jour,$mois,$an)=split(/;/, $date, 3); 
	$today=&nb_jour($jour,$mois,$an);
	# print "<font color=red><h2>Pour aujourd'hui mardi 29 mars -->mercredi, jeudi +escale depart 651 (départ déjà créée faire le relevé de marchandise, + commande corsica";
	# print " commande 7874 (deja créée faire bon de preparation) je passerai vers 15 heures, bon courage sylvain</h2></font>";
	print "<center><h1>Preparation</h1>";
	$sth=$dbh->prepare("select dt_desi from atadsql where dt_cd_dt=300 ");
	$sth->execute();
	print "<a href=?action=force>maj:</a>".$sth->fetchrow_array;
	print "<br><br>";
	# print "<b>Date des retours </b>";
	print "<form>";
	# &select_date();
 	print "<table border=0>";
	for($i=-3;$i<=21;$i++) {
		$jour=$today+$i;
		print "<tr><td><font size=+2>";
		print &jour($jour);
		print "</td><td align=right><font size=+2>";
		print &julian($jour,"");
		print "</td>";
		# $sth=$dbh->prepare("select count(*) from flyhead,flybody where fl_date=$jour and fl_apcode=0 and flb_tridep!='LYS' and flb_tridep!='MRS' and flb_rot=11 and fl_vol=flb_vol and flb_date=fl_date");
		 $sth=$dbh->prepare("select count(*) from flyhead,flybody where fl_date=$jour and fl_apcode=0 and flb_rot=11 and fl_vol=flb_vol and flb_date=fl_date");
	
		$sth->execute();
		($nbvol)=$sth->fetchrow_array;
		print "<td>Nb de vol:$nbvol</td>";
		if ($nbvol>-1){print "<td><input type=hidden name=val$i value=$jour><input type=checkbox name=check$i style=\"width:40px; height:40px;\"></td>";}
		else {print "<td>&nbsp;</td>";}
		print "</tr>\n";
	}
	
	# $jour=$today+7-($today%7);
	$jour=$today;
	
	# print "<tr><td><font size=+2>";
	# print "escale";
	# print "</td><td align=right><font size=+2>";
	# print &julian($jour,"");
	# print " au ";
	# print &julian($jour+10,"");
	# print "</td>";
	# $sth=$dbh->prepare("select count(*) from flyhead,flybody where fl_date>=$jour and fl_date<$jour+10 and fl_apcode=0 and flb_tridep!='CDG' and flb_tridep!='ORY' and flb_rot=11 and fl_vol=flb_vol and flb_date=fl_date");
	# $sth->execute();
	# ($nbvol)=$sth->fetchrow_array;
	# print "<td>Nb de vol:$nbvol</td>";
	# if ($nbvol>-1){print "<td><input type=hidden name=escale value=$jour><input type=checkbox name=checkescale style=\"width:40px; height:40px;\"></td>";}
	# else {print "<td>&nbsp;</td>";}
	# print "</tr>\n";

  	print "</table>";
	$sth=$dbh->prepare("select liv_dep from listevol group by liv_dep order by liv_dep desc limit 5");
	$sth->execute();
	while (($nodepart)=$sth->fetchrow_array){
		print "<a href=?action=go&nodepart=$nodepart>$nodepart</a><br>";
	}
	print "<input type=text name=nodepart size=4><input type=hidden name=action value=go>";
	print "<br><br><input type=submit value='creation d un départ'>";
	print "<br><br><font size=-2><a href=?action=backup>Creer un point de restauration</a></font>";
#  	print "<h2><font color=red>Ajouter le vol au depart de marseille du 4 mai (sylvain message d'aujourd'hui )</font></h2>";

	print "</form></body>";
}

###### -->go Gestion de listevol
if ($action eq "go"){&go();}

###### -->pt Gestion de listevol
if ($action eq "pt")
{
	$sth=$dbh->prepare("select liv_vol,liv_date from listevol where liv_dep=$nodepart and liv_nolot=0");
	$sth->execute();
	while (($liv_vol,$liv_date)=$sth->fetchrow_array){
		$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_nolot,fl_apcode from flyhead where fl_date=$liv_date and fl_vol='$liv_vol'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nolot,$fl_apcode)=$sth2->fetchrow_array;
		# if ($fl_troltype<10000){
			# dossier unifié
			$query="select gsl_nolot,gsl_apcode from geslot where gsl_nolot<200 and gsl_ind=10 and gsl_troltype=$fl_troltype order by gsl_nolot limit 1";
			# print "$query<br>";
		# }
		# else
	# 	{	
			# dossier personnalisé
		# 	$query="select gsl_nolot,gsl_apcode from geslot where floor(gsl_nolot/100)=$fl_troltype and gsl_ind=10 order by gsl_nolot limit 1";
	# 	}
		
		# $query="select gsl_nolot,gsl_apcode from geslot where floor(gsl_nolot/100)=$fl_troltype and gsl_ind=10 limit 1";
		# print $query;
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($gsl_nolot,$gsl_apcode)=$sth2->fetchrow_array;
		if ($gsl_nolot ne ""){ #majgeslot
			$query="select flb_tridep from flybody where flb_date=$liv_date and flb_vol='$liv_vol' and flb_rot=11";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$parcours=$sth2->fetchrow_array;
			
			$query="select flb_arrivee,flb_triret,flb_datetr from flybody where flb_date=$liv_date and flb_vol='$liv_vol' order by flb_rot";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			
			while (($arrivee,$triret,$datetr)=$sth2->fetchrow_array){
				$parcours=$parcours."/".$triret;
				$flb_arrivee=$arrivee;
				$flb_triret=$triret;
				$flb_datetr=$datetr;
			}
			$query="update listevol set liv_aprec='$gsl_apcode',liv_nolot='$gsl_nolot' where liv_dep=$nodepart and liv_vol='$liv_vol' and liv_date='$liv_date'";
			&execute();
			$query="update geslot set gsl_ind=11,gsl_pb1=0,gsl_pb2=0,gsl_pb3=0,gsl_pb4=0,gsl_pb5=0,gsl_pb6=0,gsl_pb7=0,gsl_nodep=$nodepart,gsl_noret=0,gsl_novol='$fl_vol',gsl_dtvol=$fl_date,gsl_troltype=$fl_troltype,gsl_hrret='$flb_arrivee',gsl_dtret='$flb_datetr',gsl_triret='$flb_triret',gsl_trajet='$parcours' where gsl_nolot=$gsl_nolot"; 
			&execute();
			$query="update flyhead set fl_nolot=$gsl_nolot,fl_apcode='' where fl_vol='$liv_vol' and fl_date='$liv_date'";
			&execute();
			$query="delete from retjour where rj_appro='$gsl_apcode'"; # permet de retirer le bon des retours du jour
			&execute();
		
		}
	}
go();
}

if ((($action eq "rmprint")||($action eq "rm"))&&($today eq "")) ### SAISIE de la DATE des retours
{
	print "<center><h1>$nodepart</h1>";
	print "<br><br> Date des retours<br><form>";
	&select_date();
	print "<input type=hidden name=action value=$action><input type=hidden name=nodepart value=$nodepart><br><br>";
	print "<input type=submit value=go>";
	exit;
} 	

##### >rm traitement de releve de marchandise
if ($action eq "rms") ### RELEVE DE mARCHANDISE
{
	$qte=&get("select count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0")+0;
	if ($qte==0){
		print "<font color=red> Impossible bon d'appro edité</font>";
		exit;
	}
	

	if ($action eq "rm"){
# 		$query="delete from ecartrol"; # remise à zero des ecarts automatique
# 		&execute();
	}
	
	$query="select fl_troltype,count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 group by fl_troltype";

	$sth=$dbh->prepare($query);	
	$sth->execute();

	@liste=();
	while (($fl_troltype,$nb)=$sth->fetchrow_array){
		if ($fl_troltype!=12){push (@liste,"$fl_troltype;$nb");}
	}
	$sth=$dbh->prepare("select pr_desi,pr_type,pr_codebarre from produit where pr_sup!=1 and pr_sup!=4 and pr_sup!=2 and pr_type!=15 order by pr_cd_pr");
	$sth->execute();

	$titre=1;
	
	while (($pr_cd_pr,$pr_desi,$pr_type,$pr_codebarre)=$sth->fetchrow_array){
		if ($pr_codebarre eq '') {
			$pr_codebarre=0;
		}
		%stock=&stock($pr_codebarre,$today,"retour");
		$stock_navire=$stock{"stock"};

		%stock=&stock($pr_cd_pr,$today,"retour");
		$pr_stre=$stock{"stock"};
		$total=0;
		foreach (@liste){
			($troltype,$nb)=split(/;/,$_);
			$sth2=$dbh->prepare("select sum(tr_qte)/100 from trolley where tr_code=$troltype and tr_cd_pr=$pr_cd_pr");
			$sth2->execute();
			($qte)=$sth2->fetchrow_array;
			$sth2=$dbh->prepare("select ecr_qte/100 from ecartrol where ecr_cdtrol=$troltype and ecr_cd_pr=$pr_cd_pr");
			$sth2->execute();
			($ecr_qte)=$sth2->fetchrow_array;
			if ($ecr_qte eq ""){$ecr_qte=$qte;}
			$ecr_qte+=0;
			$total+=$ecr_qte*$nb;
		}
		
		$pascig=1;
		if ($pr_type==3){ # cigarette
			$aprep{$pr_cd_pr}=$total;
			$reste{$pr_cd_pr}=$pr_stre;
			$pascig=0;
		}
		if (($total!=0)&&($total>$pr_stre)&&($pascig)){  # cigarette gestion à part
			if ($titre){
				print "<table border=1 cellspacing=0>";
				print "<tr><td>&nbsp;</td><td>&nbsp;</td>";
				print "<th>Depart </th><th>Stock</th></tr>";
				$titre=0;
			}
			print "<tr><td>$pr_cd_pr</td><td><a href=?action=ajuste&produit=$pr_cd_pr&nodepart=$nodepart&today=$today>$pr_desi</a></td>";
			$pr_stre+=0;
			print "<td align=right><font color=red>$total</td><td align=right>$pr_stre</td><td>$pr_codebarre</td><td align=right>$stock_navire</td></tr>";
		}
	
	}

	print "</table>";

	if ($titre){
		$manquant_cig=0;
		$box=($reste{130100}-$aprep{130100})*2+$reste{130320}; # (reste pack box apres sortie) par 2 plus stock single
		$light=($reste{130105}-$aprep{130105})*2+$reste{130120};
		if (($box<$aprep{130320})||($light<$aprep{130120})){$manquant_cig=1;} # manquant si le stock single apres depart pack est inferieur au depart single
		if ($manquant_cig){ print "probleme cigarette";}
		else {$action="rmprint";}  # pas de probleme de stock
	}
}



##### >rm traitement de releve de marchandise
if ($action eq "rm") ### RELEVE DE mARCHANDISE
{
	$qte=&get("select count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0")+0;
	if ($qte==0){
	    print "<font color=red> Impossible bon d'appro edité</font>";
	    exit;
	}
# 	$query="delete from ecartrol"; # remise à zero des ecarts automatique
# 	&execute();
	
	$query="select fl_troltype,count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 group by fl_troltype";

	$sth=$dbh->prepare($query);	
	$sth->execute();

	@liste=();
	while (($fl_troltype,$nb)=$sth->fetchrow_array){
		if ($fl_troltype!=12){push (@liste,"$fl_troltype;$nb");}
	}
	$sth=$dbh->prepare("select distinct pr_desi,pr_type,pr_codebarre from produit,trolley,lot where tr_cd_pr=pr_cd_pr and tr_code=lot_nolot and lot_flag=1 order by tr_ordre");
	$sth->execute();

	$titre=1;
	    while (($pr_cd_pr,$pr_desi,$pr_type,$pr_codebarre)=$sth->fetchrow_array){
		    
		if ($pr_codebarre eq '') {
			$pr_codebarre=0;
		}
# 		$stock=&stock($pr_codebarre,$today,"retour");
# 		$stock_navire=$stock{"stock"};

		%stock=&stock($pr_cd_pr,$today,"retour");
		$pr_stre=$stock{"stock"};
		$total=0;
# 		foreach (@liste){
# 			($troltype,$nb)=split(/;/,$_);
# 			$sth2=$dbh->prepare("select sum(tr_qte)/100 from trolley where tr_code=$troltype and tr_cd_pr=$pr_cd_pr");
# 			$sth2->execute();
# 			($qte)=$sth2->fetchrow_array;
# 			$sth2=$dbh->prepare("select ecr_qte/100 from ecartrol where ecr_cdtrol=$troltype and ecr_cd_pr=$pr_cd_pr");
# 			$sth2->execute();
# 			($ecr_qte)=$sth2->fetchrow_array;
# 			if ($ecr_qte eq ""){$ecr_qte=$qte;}
# 			$ecr_qte+=0;
# 			$total+=$ecr_qte*$nb;
# 		}
		
		$pascig=1;
		if ($pr_type==3){ # cigarette
			$aprep{$pr_cd_pr}=$total;
			$reste{$pr_cd_pr}=$pr_stre;
			$pascig=0;
		}
# 		if (($total!=0)&&($total>$pr_stre)&&($pascig)){  # cigarette gestion à part
 		if ($pascig){  # cigarette gestion à part
			$pr_stre*=100;
			$flag=1;
			while ($flag==1){
			    $flag=0;
			    foreach (@liste){
				($troltype,$nb)=split(/;/,$_);
				$tr_qte=&get("select tr_qte from trolley where tr_cd_pr='$pr_cd_pr' and tr_code='$troltype'")+0;
				if (($tr_qte)>0){
				    $qtemini=$nb*100;
#   				     print "$pr_cd_pr $qtemini $pr_stre $nb $troltype<br>";
				    if ($qtemini >$pr_stre) {
					$exist=&get("select count(*) from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol='$troltype'");
					if ($exist==0){
					    &save("replace into ecartrol values ('$troltype','$pr_cd_pr','0','')","af");
					}
				    }
				    else
				    {
					$ecr_qte=&get("select ecr_qte from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol='$troltype'")+0;
					if ($ecr_qte < $tr_qte)
					{
					    $ecr_qte+=100;
					    &save("replace into ecartrol values ('$troltype','$pr_cd_pr','$ecr_qte','*')","af");
					    $flag=1;
					    $pr_stre-=$nb*100;
					}
				    }
				}
			    }
			}
		}
    
	
# 	if ($pr_stre ==0){
# 	    foreach (@liste){
# 		($troltype,$nb)=split(/;/,$_);
# 		$tr_qte=&get("select tr_qte from trolley where tr_cd_pr='$pr_cd_pr' and tr_code='$troltype'");
# 		if (($tr_qte+0)>0){
# 		    &save("replace into ecartrol values ('$troltype','$pr_cd_pr','0','')","aff");
# 		}
# 	    }
# 	}
# 			$pr_stre+=0;
# 			print "<td align=right><font color=red>$total</td><td align=right>$pr_stre</td><td>$pr_codebarre</td><td align=right>$stock_navire</td></tr>";
# 		}
	
	}

	print "</table>";

	if ($titre){
		$manquant_cig=0;
		$box=($reste{130100}-$aprep{130100})*2+$reste{130320}; # (reste pack box apres sortie) par 2 plus stock single
		$light=($reste{130105}-$aprep{130105})*2+$reste{130120};
		if (($box<$aprep{130320})||($light<$aprep{130120})){$manquant_cig=1;} # manquant si le stock single apres depart pack est inferieur au depart single
		if ($manquant_cig){ print "probleme cigarette";}
		else {$action="rmprint";}  # pas de probleme de stock
	}
}










##### ecart edition des ecarts par rapport au trolley type
 if ($action eq "ecart")
{
	print "<h2>$nodepart</h2><br>";
	$query="select fl_troltype,count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 and fl_troltype>99 group by fl_troltype";
	
	$sth=$dbh->prepare($query);	
	$sth->execute();
	@liste=();
	while (($fl_troltype,$nb)=$sth->fetchrow_array){
		push (@liste,"$fl_troltype;$nb");
	}
	print "<table border=1 cellspacing=0><tr><th>&nbsp;</th>";           	
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$desi=&get("select lot_desi from lot where lot_nolot=$type");
		print "<th align=center>$type $desi:$nb</th>";
	}
	
        &save("create temporary table liste_temp (li_type int(5) NOT NULL,PRIMARY KEY (li_type))");

	  foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 &save("insert into liste_temp values ('$type')");
	  }
    


print "</tr><tr><td><b>Parfums hommes</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=3 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=3","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=3","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}
	print "</tr><tr>";	
	$sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from ecartrol,trolley,produit where ecr_cd_pr=tr_cd_pr and pr_cd_pr=tr_cd_pr and tr_tiroir=3 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_desi</td>";
		foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=3")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			      $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			      $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			      if ($qtem eq $qte0){print "<td align=center>$qte0</td>";}else{print "<td align=center><b>$qtem</b>/$qte0</td>";}
			 }
		}	
	}
	

	print "</tr><tr><td><b>Parfums femmes 1</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=1 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=1","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=1","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
	print "</tr><tr>"; 
	$sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from ecartrol,trolley,produit where ecr_cd_pr=tr_cd_pr and pr_cd_pr=tr_cd_pr and tr_tiroir=1 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_desi</td>";
		foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=1")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			      $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			      $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			      if ($qtem eq $qte0){print "<td align=center>$qte0</td>";}else{print "<td align=center><b>$qtem</b>/$qte0</td>";}
			 }
		}	
	}
	print "</tr><tr><td><b>Parfums femmes 2</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=2 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=2","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=2","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
	$sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from ecartrol,trolley,produit where ecr_cd_pr=tr_cd_pr and pr_cd_pr=tr_cd_pr and tr_tiroir=2 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_desi</td>";
		foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=2")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			      $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			      $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			      if ($qtem eq $qte0){print "<td align=center>$qte0</td>";}else{print "<td align=center><b>$qtem</b>/$qte0</td>";}
			 }
		}	
	}
	

	print "</tr><tr><td><b>Cosmetiques</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=4 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=4","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=4","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
	  $sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from ecartrol,trolley,produit where ecr_cd_pr=tr_cd_pr and pr_cd_pr=tr_cd_pr and tr_tiroir=4 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_desi</td>";
		foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=4")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			      $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			      $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			      if ($qtem eq $qte0){print "<td align=center>$qte0</td>";}else{print "<td align=center><b>$qtem</b>/$qte0</td>";}
			 }
		}	
	}
		
	print "</tr><tr><td><b>Boutiques</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=5 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=5","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=5","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
        $sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from ecartrol,trolley,produit where ecr_cd_pr=tr_cd_pr and pr_cd_pr=tr_cd_pr and tr_tiroir=5 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_desi</td>";
		foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=5")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			      $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			      $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			      if ($qtem eq $qte0){print "<td align=center>$qte0</td>";}else{print "<td align=center><b>$qtem</b>/$qte0</td>";}
			 }
		}	
	}
	print "</tr><tr><td><b>Alcool/Cig</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=6 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=6","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=6","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
        $sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from ecartrol,trolley,produit where ecr_cd_pr=tr_cd_pr and pr_cd_pr=tr_cd_pr and tr_tiroir=6 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_desi</td>";
		foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=6")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			      $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			      $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			      if ($qtem eq $qte0){print "<td align=center>$qte0</td>";}else{print "<td align=center><b>$qtem</b>/$qte0</td>";}
			 }
		}	
	}
	
        print "</tr>";	

	print "</table>";
}	

##### ecart edition de la liste a mettre
 if ($action eq "ecart_li")
{
	print "<h2>$nodepart</h2><br>";
	$query="select fl_troltype,count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 and fl_troltype>99 group by fl_troltype";
	
	$sth=$dbh->prepare($query);	
	$sth->execute();
	@liste=();
	while (($fl_troltype,$nb)=$sth->fetchrow_array){
		push (@liste,"$fl_troltype;$nb");
	}
	print "<table border=1 cellspacing=0><tr><th>&nbsp;</th>";           	
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$desi=&get("select lot_desi from lot where lot_nolot=$type");
		print "<th align=center>$type $desi:$nb</th>";
	}
	
        &save("create temporary table liste_temp (li_type int(5) NOT NULL,PRIMARY KEY (li_type))");

	  foreach (@liste) {
			 ($type,$nb)=split(/;/,$_);
			 &save("insert into liste_temp values ('$type')");
	  }
    


print "</tr><tr><td><b>Parfums hommes</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=3 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=3","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=3","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}
	print "</tr><tr>";	
	$sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from trolley,produit where pr_cd_pr=tr_cd_pr and tr_tiroir=3 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$flag=1; # pas logique mais c'est pour tout afficher sans casser l'algo
 		foreach (@liste) {
 		    ($type,$nb)=split(/;/,$_);
 		    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
		    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
		    if (($qtem eq "")||($qtem==$qte0)){$flag=1;}
		}    
		if ($flag==1){
		    print "<tr><td>$pr_desi</td>";
		    foreach (@liste) {
			($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=3")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			    $qtem=&get("select count(*) from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
			    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			    if ($qtem==0){$qtem=$qte0;}
			    else
			    {
			    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			    }
			    print "<td align=center>$qtem</td>";
			 }
		    }
		}
	}
	

	print "</tr><tr><td><b>Parfums femmes 1</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=1 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=1","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=1","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
	print "</tr><tr>"; 
	$sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from trolley,produit where pr_cd_pr=tr_cd_pr and tr_tiroir=1 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$flag=1;
		foreach (@liste) {
		    ($type,$nb)=split(/;/,$_);
		    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
		    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
		    if (($qtem eq "")||($qtem==$qte0)){$flag=1;}
		}    
		if ($flag==1){
		    print "<tr><td>$pr_desi</td>";
		    foreach (@liste) {
			($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=1")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			    $qtem=&get("select count(*) from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
			    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			    if ($qtem==0){$qtem=$qte0;}
			    else
			    {
			    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			    }
			    print "<td align=center>$qtem</td>";
			 }
		    }
		}
	}
	print "</tr><tr><td><b>Parfums femmes 2</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=2 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=2","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=2","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
	$sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from trolley,produit where pr_cd_pr=tr_cd_pr and tr_tiroir=2 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$flag=1;
		foreach (@liste) {
		    ($type,$nb)=split(/;/,$_);
		    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
		    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
		    if (($qtem eq "")||($qtem==$qte0)){$flag=1;}
		}    
		if ($flag==1){
		    print "<tr><td>$pr_desi</td>";
		    foreach (@liste) {
			($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=2")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			    $qtem=&get("select count(*) from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
			    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			    if ($qtem==0){$qtem=$qte0;}
			    else
			    {
			    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			    }
			    print "<td align=center>$qtem</td>";
			 }
		    }
		}
	}
	

	print "</tr><tr><td><b>Cosmetiques</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=4 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=4","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=4","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
	  $sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from trolley,produit where pr_cd_pr=tr_cd_pr and tr_tiroir=4 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$flag=1;
		foreach (@liste) {
		    ($type,$nb)=split(/;/,$_);
		    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
		    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
		    if (($qtem eq "")||($qtem==$qte0)){$flag=1;}
		}    
		if ($flag==1){
		    print "<tr><td>$pr_desi</td>";
		    foreach (@liste) {
			($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=4")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			    $qtem=&get("select count(*) from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
			    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			    if ($qtem==0){$qtem=$qte0;}
			    else
			    {
			    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			    }
			    print "<td align=center>$qtem</td>";
			 }
		    }
		}
	}
		
	print "</tr><tr><td><b>Boutiques</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=5 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=5","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=5","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
        $sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from trolley,produit where pr_cd_pr=tr_cd_pr and tr_tiroir=5 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$flag=1;
		foreach (@liste) {
		    ($type,$nb)=split(/;/,$_);
		    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
		    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
		    if (($qtem eq "")||($qtem==$qte0)){$flag=1;}
# 		    print "$pr_desi-$qtem-$qte0-<br>";
		}    
		if ($flag==1){
		    print "<tr><td>$pr_desi</td>";
		    foreach (@liste) {
			($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=5")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			    $qtem=&get("select count(*) from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
			    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			    if ($qtem==0){$qtem=$qte0;}
			    else
			    {
			    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			    }
			    print "<td align=center>$qtem</td>";
			 }
		    }
		}
	}
	print "</tr><tr><td><b>Alcool/Cig</b></td>";
	foreach (@liste) {
		($type,$nb)=split(/;/,$_);
		$nombre=&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=6 and tr_cd_pr not in (select ecr_cd_pr from ecartrol where ecr_cdtrol=$type)","af");
		$nombre+=&get("select sum(ecr_qte)/100 from ecartrol,trolley where ecr_cdtrol=$type and ecr_cdtrol=tr_code and ecr_cd_pr=tr_cd_pr and tr_tiroir=6","af");
		$normal=0+&get("select sum(tr_qte)/100 from trolley where tr_code=$type and tr_tiroir=6","af");
		if ($nombre == $normal){print "<td align=center>$nombre</td>";} else {print "<td align=center><b>$nombre</b>/$normal</td>";}
	}	
        $sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi from trolley,produit where pr_cd_pr=tr_cd_pr and tr_tiroir=6 and tr_code in (select li_type from liste_temp) order by tr_ordre");
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		$flag=0;
		foreach (@liste) {
		    ($type,$nb)=split(/;/,$_);
		    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
		    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
		    if (($qtem eq "")||($qtem==$qte0)){$flag=1;}
		}    
		if ($flag==1){
		    print "<tr><td>$pr_desi</td>";
		    foreach (@liste) {
			($type,$nb)=split(/;/,$_);
			 $flag=&get("select count(*) from trolley where tr_cd_pr='$pr_cd_pr' and tr_code=$type and tr_tiroir=6")+0;      
			 if ($flag==0){
			      print "<td bgcolor=#efefef>&nbsp;</td>";
			 }
			 else
			 {
			    $qtem=&get("select count(*) from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af");
			    $qte0=&get("select tr_qte/100 from trolley where tr_code=$type and tr_cd_pr=$pr_cd_pr","af")+0;
			    if ($qtem==0){$qtem=$qte0;}
			    else
			    {
			    $qtem=&get("select ecr_qte/100 from ecartrol where ecr_cd_pr=$pr_cd_pr and ecr_cdtrol=$type","af")+0;
			    }
			    print "<td align=center>$qtem</td>";
			 }
		    }
		}
	}
        print "</tr>";	

	print "</table>";
}	



## >rmprint Edition du releve de marchandise
if (($action eq "rmprint")&&($today ne "")) ### ImPRESSION DU RELEVE DE mARCHANDISE
{
	print "<center><a href=?>debut</a><h1>$nodepart</h1>";
	$query="select fl_troltype,count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 group by fl_troltype";
	$sth=$dbh->prepare($query);	
	$sth->execute();
	# print $query;
	@liste=();
	while (($fl_troltype,$nb)=$sth->fetchrow_array){
		if (($fl_troltype!=3303)&&($fl_troltype!=3353)&&($fl_troltype!=3302)){push (@liste,"$fl_troltype;$nb");}
	}
$index_deb=0;
	  $index_fin=99999;
	  $sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi,pr_codebarre from produit,trolley,lot where pr_cd_pr=tr_cd_pr and tr_code=lot_nolot and lot_flag=1 and tr_qte>0  order by tr_ordre");
	&rmprint();	    

}


###### >modif maj du fichier ecartrol
if ($action eq "modif") ### modification des quantitées
{
	$nbref=$html->param('nbref');	
	$zero=$html->param('zero');
	for ($i=0;$i<$nbref;$i++){
		$trolley=$html->param("trolley$i");
		$qte=$html->param("modif$i")*100;
		if ($zero eq "on"){$qte=0;};
		$pr_cd_pr=$html->param("produit$i");
		$query="replace into ecartrol values ('$trolley','$pr_cd_pr','$qte','')";
		$sth2=$dbh->prepare($query);
		$sth2->execute() or die (print $query);
	}
	$action="ajuste";
}

###### ajuste saisie des quantitées à modifier
if ($action eq "ajuste") ### >Ajustement des quantite
{
	$query="select fl_troltype,count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 group by fl_troltype";
	$sth=$dbh->prepare($query);	
	$sth->execute();
	while (($fl_troltype,$nb,$fl_cd_cl)=$sth->fetchrow_array){
		if (($fl_troltype!=3303)&&($fl_troltype!=3353)&&($fl_troltype!=3302)){push (@liste,"$fl_troltype;$nb");}
	}
	$sth=$dbh->prepare("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
	$sth->execute();
	$pr_desi=$sth->fetchrow;

	%stock=&stock($pr_cd_pr,$today,"retour");
	$pr_stre=$stock{"stock"};
	
	$total=0;
	
	
	print "<form name=modif method=post><table border=1 cellspacing=0><caption><b>$pr_cd_pr $pr_desi</b></caption>";
	print "<tr><th>Compagnie</td><th>Trolley type</td><th>Qte standard</th><th>Qte modifiée</th><th>Nombre</th><th>Total à preparer</th><th>Stock</th><th>Ecart</th></tr>";
	$total=0;
	$i=0;
	foreach (@liste){
		($troltype,$nb,$cl_cd_cl)=split(/;/,$_);
		# $cl_cd_cl=int($troltype/10);
		# ($cl_nom)=split(/;/,$client_dat{$cl_cd_cl});
		
		%stock=&stock($pr_cd_pr,$today,"retour");
		$pr_stre=$stock{"stock"};
		$sth2=$dbh->prepare("select sum(tr_qte)/100 from trolley where tr_code=$troltype and tr_cd_pr=$pr_cd_pr");
		$sth2->execute();
		($qte)=$sth2->fetchrow_array;
		$qte+=0;
		if ($qte==0){next;};
		print "<tr><td>___</td><td align=center>$troltype</td>";
		print "<td align=right>$qte</td>";
		$sth2=$dbh->prepare("select ecr_qte/100 from ecartrol where ecr_cdtrol=$troltype and ecr_cd_pr=$pr_cd_pr");
		$sth2->execute();
		($ecr_qte)=$sth2->fetchrow_array;
		if ($ecr_qte eq ""){$ecr_qte=$qte;}
		$ecr_qte+=0;
		print "<td align=center><input type=hidden name=produit$i value=$pr_cd_pr><input type=hidden name=trolley$i value=$troltype>";
		print "<input type=text name=modif$i size=3 value=$ecr_qte Onfocus=document.modif.modif$i.select()></td>";
		print "<td align=right><b>$nb</td>";
		$total_li=$ecr_qte*$nb;
		print "<td align=right>$total_li</td></tr>";
		$total+=$total_li;
		$i++;
	}
	$ecart=$pr_stre-$total;
	if ($total==0){$ecart=0;} # gère le probleme des stocks negatif
	if ($ecart<0){$color="pink";}else{$color="white";};
	print "<tr bgcolor=$color><th colspan=5>Total</th><td align=right>$total</td><th align=right>$pr_stre</td><td align=right>$ecart</td></tr>";
	print "</table><br><center><input type=hidden name=nodepart value=$nodepart><input type=hidden name=today value=$today><input type=hidden name=nbref value=$i>";
	print "<input type=hidden name=action value=modif>Tout à zero <input type=checkbox name=zero> <input type=submit value=\"valider les modifications\"></form>";
	if ($ecart>=0){print "<br><a href=?action=rms&nodepart=$nodepart&today=$today>Relevé de marchandise</a><br>";}
	print "</body>";
}


##### >tpe creation du fichier des tpe
# obsolete
if ($action eq "tpe")
{
	open (FILE,">/mnt/windows_bocal/perl/tampon/tpefile.txt");
	print FILE "DEPART;$nodepart;\r\n";
	# $query="select liv_nolot,gsl_apcode from listevol,geslot,lot where liv_dep=$nodepart and gsl_nolot=liv_nolot and floor(gsl_nolot/100)=lot_nolot and lot_nbtpe>0";
	$query="select liv_nolot,gsl_apcode from listevol,geslot,lot where liv_dep=$nodepart and gsl_nolot=liv_nolot and gsl_nolot=liv_nolot and lot_nolot=gsl_troltype and lot_nbtpe>0";

	$sth=$dbh->prepare($query);	
	$sth->execute();
	while (($liv_nolot,$gsl_apcode)=$sth->fetchrow_array){
		print FILE "TPE;$gsl_apcode;$liv_nolot;0;\r\n";
		print FILE "Z;$gsl_apcode;               \r\n";
		$query="select ap_cd_pr,ap_prix,LEFT(pr_desi, 16),pr_codebarre,floor(ap_qte0/100) from appro,produit where ap_code='$gsl_apcode' and ap_cd_pr=pr_cd_pr";		
		$sth2=$dbh->prepare($query);	
		$sth2->execute();
		while (($ap_cd_pr,$ap_prix,$ba_desi,$ba_code,$ap_qte0)=$sth2->fetchrow_array){
			if ($ap_cd_pr==110940){
				print FILE "110940;$ba_code;$ba_desi;$ap_prix;;;;;;;;;;0;0;$ap_qte0;0\r\n";
			}
			if ($ap_cd_pr==110950){
				print FILE "110950;$ba_code;$ba_desi;$ap_prix;;;;;;;;;;0;0;$ap_qte0;0\r\n";
			}
			# if ($ba_code==68857514817){print FILE "$ap_cd_pr;$ba_code;$ba_desi;$ap_prix;;;;;;;;;;0;0;$ap_qte0;0\r\n";}# cerruti homme
			# if ((length($ba_code)==12)&&(substr($ba_code,0,1) eq '0')){$ba_code='0'.$ba_code;}
			if (length($ba_code)==12){$ba_code='0'.$ba_code;}
			if (length($ba_code)==11){$ba_code='00'.$ba_code;}
			$ba_code=substr($ba_code,0,12);
			if (length($ba_code)!=12){$ba_code=$ap_cd_pr;}
			print FILE "$ap_cd_pr;$ba_code;$ba_desi;$ap_prix;;;;;;;;;;0;0;$ap_qte0;0\r\n";
				
			if ($ap_cd_pr==180100){
				print FILE "180100;336544000386;$ba_desi;$ap_prix;;;;;;;;;;0;0;$ap_qte0;0\r\n";
			}
			if ($ap_cd_pr==220115){
				print FILE "220115;334890054400;$ba_desi;$ap_prix;;;;;;;;;;0;0;$ap_qte0;0\r\n";
			}

		}
		print FILE "D;978;EUR;2;1\r\n";
		print FILE "D;190;USD;2;     0.7751\r\n";
		print FILE "D;198;GBP;2;     1.5350\r\n";
		print FILE "D;214;CHF;2;     0.6650\r\n";
		print FILE "D;230;CFP;2;     0.0084\r\n";
		print FILE "D;248;AUD;2;     0.5350\r\n";
		print FILE "D;251;CFA;2;     0.0015\r\n";
		$query="select v_rot,v_vol,v_dest,cl_nom from vol,client where v_code='$gsl_apcode' and v_cd_cl=cl_cd_cl";		
		$sth2=$dbh->prepare($query);	
		$sth2->execute();
		while (($v_rot,$v_vol,$v_dest,$nom)=$sth2->fetchrow_array){
			$cl_nom=$nom;
			print FILE "V;$v_rot;$v_vol;";
			print FILE substr($v_dest,0,7);
			if ($gsl_code<"5000"){
				print FILE ";0;0;1;0;0.00";
			}
			else {
				print FILE ";1;1960;1;0;0.00";
			}
			
			print FILE "\r\n";
		}
		print FILE "E;0;$cl_nom VAB;;;;;MERCI DE VOTRE VISITE;A BIENTOT;;0\r\n";
		print FILE "END;\r\n";
	}
close (FILE);
print "Location: /import_tpe_bocal.php\n\n";
}


sub table{
my $nodepart=$_[0];
print "<br><font size=+3>$nodepart</font> <a href=?action=supd&nodepart=$nodepart>sup</a><br>";
print  "<table border=1 cellspacing=0><tr bgcolor=yellow><th>Jour</th><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>No lot</th><th>No appro</th></tr>";
$query="select liv_vol,liv_date,liv_nolot from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol order by fl_troltype";
# print $query;
$sth=$dbh->prepare($query);
# print "select liv_vol,liv_date,liv_nolot from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol order by fl_troltype";

$sth->execute();
while (($liv_vol,$liv_date,$liv_nolot)=$sth->fetchrow_array){
	$validapp=0;
	# print "-$liv_nolot-";
	$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_nolot,fl_apcode from flyhead where fl_date=$liv_date and fl_vol='$liv_vol'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nolot,$fl_apcode)=$sth2->fetchrow_array;
	$query="select lot_conteneur,lot_desi from lot where lot_nolot=$fl_troltype";
	$sth2=$dbh->prepare($query);
	# print "<tr><td>$query</td></tr>";
	$sth2->execute();
	($gsl_desi,$lot_desi)=$sth2->fetchrow_array;
	print  "<tr><td>";
	print &jour($fl_date);
	print " ";
	print &julian($fl_date,"");
	print "<td><b>";
	($cl_nom,$cl_trilot)=split(/;/,$client_dat{$fl_cd_cl});
	print  "$fl_cd_cl $cl_nom";
	print  "</td>";
	 if (! grep /$fl_troltype/,@liste_type) {push(@liste_type,$fl_troltype);}
	$cle="(type:".$fl_troltype.") ".$gsl_desi." ".$lot_desi;
	if ($fl_nolot==0){$listetrol{"$cle"}+=1;}
	print  "<td align=center>$fl_vol</td><td align=left>type:($fl_troltype) $gsl_desi $lot_desi</td>";
	if ($fl_nolot!=0 ){
		print "<td><b>$cl_trilot $fl_nolot</td>";
		
		# if (($fl_cd_cl*1000+$fl_nolot)!=$liv_nolot){ 
		if ($fl_nolot!=$liv_nolot){ 
			
			# bug
			# $query="update listevol set liv_nolot=$fl_troltype*100+$fl_nolot where liv_vol='$liv_vol' and liv_date=$liv_date and liv_dep=$nodepart";
			print "bug $query";
			print "*$fl_nolot<-->$liv_nolot*";
			# $sth2=$dbh->prepare($query);
			# $sth2->execute();
			}
		}
	else {
		print "<td>&nbsp;</td>";
		$rm=1;#flag pour mettre le lien releve de marchandise
		}
	if ($fl_apcode ne '0'){
			 print "<td><a href=edite_appro.pl?lot=$fl_apcode>$fl_apcode</a> <a href=edite_appro_new.pl?lot=$fl_apcode>new</a></td>";
# 			 print "<td><a href=lot.pl?$liv_nolot=on&lot_nolot=".int($liv_nolot/100)."&action=modiflot>plomb</a></td><td><a href=?action=etiquette&appro='$fl_apcode'&nodepart='$nodepart'>etiquette</a></td>";
	}
	else
	{
		$validapp=1;
		if ($fl_nolot==0){
			print "<td>&nbsp;</td><td><a href=?action=sup&nodepart=$nodepart&vol=$liv_vol&date_vol=$liv_date>sup</a></td>";
		}
		else 
		{
			print "<td>&nbsp;</td><td>&nbsp;</td>";
		}
	}
	print  "</tr>\n";
}
print  "</table>\n<table border=0><tr><td align=left>";
foreach $cle (sort(keys(%listetrol))){
	print "$cle qte:$listetrol{$cle}<br>";
}
print "</td></tr></table>";
# $rm=1; # forcage affichage des liens
if ($rm){
	# print "<a href=?action=pt&nodepart=$nodepart&today=$today>Pas touché</a><br>";
	print "<a href=?action=rm&nodepart=$nodepart&today=$today>Releve de marchandise</a><br>";
	print "<a href=?action=ecart&nodepart=$nodepart&today=$today>Edition des ecarts par rapport au standard</a><br>";
	print "<a href=?action=ecart_li&nodepart=$nodepart&today=$today>Edition de la listes par tiroir</a><br>";

}
print "<a href=?action=rmprint&nodepart=$nodepart&today=$today>Réédition du Relevé de marchandise</a><br>";
print "<a href=?action=etiquette2&nodepart=$nodepart>Etiquette</a><br>";
print "<a href=avisdep.pl?nodepart=$nodepart>Avis de départ et bon d'appro</a><br>";
# print "<a href=?action=tpe&nodepart=$nodepart>Tpe</a><br>";
# print "<a href=gere_ecart.pl?nodepart=$nodepart>Saisie des ecarts</a><br>";

# print "<br><a href=edite_appro.pl>Réédition d'un seul bon d'appro</a>";
print "<br>";
print "<br>";
print "<a href=avisdep.pl?nodepart=$nodepart&printer=11>Avis de départ et bon d'appro sur imprimante de secours</a><br>";
print "<br>";
foreach (@liste_type){
      if ($validapp){
		print "<a href=validapp.pl?depart=$nodepart&type=$_>Modification du trolley type $_</a><br>";
	  }
	  else {
		print "Modification du trolley type $_ (non actif appro déjà créé)<br>";
	  }
}
print "<br>Fin de page</br>";
}





if ($action eq "etiquette"){
	$appro=$html->param('appro');
	$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_nolot,fl_apcode from flyhead where fl_apcode=$appro";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nolot,$fl_apcode)=$sth2->fetchrow_array;
	$no_lot=$fl_nolot;
	$query="select flb_depart from flybody where flb_date=$fl_date and flb_vol='$fl_vol' and flb_rot=11";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($flb_depart)=$sth2->fetchrow_array;
	$query="select gsl_nolot,gsl_apcode,gsl_desi,gsl_trajet,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7,gsl_nb_cont from geslot where gsl_apcode=$appro";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($gsl_nolot,$gsl_apcode,$gsl_desi,$gsl_trajet,$gsl_nbpb,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_nb_cont)=$sth2->fetchrow_array;
	$query="select cl_trilot from client where cl_cd_cl='$fl_cd_cl'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($cl_trilot)=$sth2->fetchrow_array;
	&print_etiq();	
}

if ($action eq "etiquette2"){
	$nodepart=$html->param('nodepart');
	$sth=$dbh->prepare("select liv_vol,liv_date from listevol where liv_dep='$nodepart' order by liv_date,liv_vol");
	$sth->execute();
	$point=$nburk=0;
	while (($liv_vol,$liv_date)=$sth->fetchrow_array){
		$query="select fl_date,fl_vol,fl_cd_cl,fl_nbrot,fl_troltype,fl_nolot,fl_apcode from flyhead where fl_date=$liv_date and fl_vol='$liv_vol'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nolot,$fl_apcode)=$sth2->fetchrow_array;
		# $no_lot=$fl_cd_cl*1000+$fl_nolot;
		$no_lot=$fl_nolot;
		$query="select flb_depart from flybody where flb_date=$liv_date and flb_vol='$liv_vol' and flb_rot=11";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($flb_depart)=$sth2->fetchrow_array;
		
		$query="select gsl_nolot,gsl_apcode,gsl_desi,gsl_trajet,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7,gsl_nb_cont from geslot where gsl_nolot=$no_lot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($gsl_nolot,$gsl_apcode,$gsl_desi,$gsl_trajet,$gsl_nbpb,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_nb_cont)=$sth2->fetchrow_array;
		$query="select cl_trilot from client where cl_cd_cl='$fl_cd_cl'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($cl_trilot)=$sth2->fetchrow_array;
		&print_etiq();	
	
	}

}

sub print_etiq{
	print "<html><head>
	<Meta http-equiv=\"Pragma\" content=\"no-cache\">
	<style type=\"text/css\">
	<!--
	#saut { page-break-after : right }         
	-->
	</style></head>";

	for ($j=1;$j<=$gsl_nb_cont;$j++){
		if ($fl_vol eq "2J301B"){$gsl_trajet="ABJ/OUA/ABJ";}
		print "<font size=+3>$cl_trilot-$no_lot</font><font size=+3>&nbsp;$gsl_desi<br></font>vol:<font size=+2>$fl_vol </font>$gsl_trajet<font size=+3><br>";
		print &julian($fl_date)."<br>CHGT ";
		print &deci3($flb_depart/100);
		print "<br></font><font size=+2>appro:$fl_apcode";
		if ($j==1){print " dossier";}
		print "<br>plombs:";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			print ${gsl_pb."$i"}." ";
		}
		print " </font>";
		print "<br>";
		print "<div id=saut></div>";
	}
	if (($fl_troltype==6)||($fl_troltype==7)){
		print "<font size=+5>Business<br>POS 125<div id=saut></div>ECO<br>POS 623<br><div id=saut></div></font>";
	}
	if ($fl_troltype==13){
		print "<font size=+5>Vin Regional<br>POS 673<div id=saut></div></font>";
	}
	  if ($fl_vol eq "I5301_int"){
		print "<font size=+5>VOLS REGIONAUX<div id=saut></div></font>";
	}	
if ($fl_troltype==14){
		print "<font size=+5>Business<br>POS 125<div id=saut></div>ECO<br>POS 623<br><div id=saut></div></font>";
 		print "<font size=+5>Champagne<br>POS 673<div id=saut></div></font>";
	}


}
sub go{
	print  "<center><h2>Preparation</h1><a href=?>debut</a>";
	if ($nodepart eq ""){
		# mise a jour d'atadsql si c'a n'a pas ete fait aujourd'hui
		# $query="update atadsql set dt_no=dt_no+1,dt_date=curdate() where dt_cd_dt=100 and dt_date!=curdate()";
		$query="update atadsql set dt_no=dt_no+1,dt_date=curdate() where dt_cd_dt=100";
		&execute();			
		$flag_creation=0;
		# recuperation du numero de depart
		$query="select dt_no from atadsql where dt_cd_dt=100";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$nodepart=$sth->fetchrow_array;
		foreach (@liste){
			$query="select fl_vol,fl_nolot from flyhead where fl_date=$_ and fl_apcode='0'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			# print "$query<br>";
			while (($fl_vol,$fl_nolot)=$sth->fetchrow_array){
				$query="select count(*) from listevol where liv_vol='$fl_vol' and liv_date='$_'";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($nb_enr)=$sth2->fetchrow_array+0;
				if ($nb_enr==0){
					$query="replace into listevol values ('$nodepart','$_','$fl_vol','$fl_nolot','','')";
					&execute();
					$flag_creation=1;
				}
				else
				{
					$deps=&get("select liv_dep from listevol where liv_vol='$fl_vol' and liv_date='$_'");
					print "<font color=red>vol $fl_vol $_ deja dans le depart $deps<br>";
				}
			}
		}
		if ($html->param("checkescale") eq "on" ){
			my($jour)=$html->param("escale");
			$query="select fl_vol,fl_nolot,fl_date from flyhead,flybody where fl_date>=$jour and fl_date<$jour+10 and fl_apcode=0 and flb_tridep!='CDG' and flb_tridep!='ORY' and flb_rot=11 and fl_vol=flb_vol and flb_date=fl_date";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($fl_vol,$fl_nolot,$fl_date)=$sth->fetchrow_array){
				$query="select count(*) from listevol where liv_vol='$fl_vol' and liv_date='$fl_date'";
				$sth2=$dbh->prepare($query);
				$sth2->execute();
				($nb_enr)=$sth2->fetchrow_array+0;
				if ($nb_enr==0){
					$query="replace into listevol values ('$nodepart','$fl_date','$fl_vol','$fl_nolot','','')";
					&execute();
					$flag_creation=1;
				}
			}
		}				
		if ($flag_creation==0){
			print "<hr><h3><font color=red>Aucun vol disponible pour un nouveau départ , merci de selectionner un depart valide</font></h3><br>";
		}
	}
	
	&table($nodepart);
	print  "</body>";
}


# FONCTION : deci2(nombre)
# DESCRIPTION : retourne un chiffre avec2 chiffres apres la virgule 
# ENTREE : Un nombre 
# SORTIE : Un chaine
sub deci3 {
	my ($var)=@_[0];
	my ($chaine,$deci);
	$var = "".$var;
	($ENT,$DEC) = split(/\./,$var);
	#$deci = $var-int($var);
	$deci = ("0.".$DEC)+0;
	$deci = int($deci*100);
	
	#$deci=int(($var-int($var))*100);
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	$var=int($var);
	$chaine=$var.".".$deci;
	return($chaine);
}


 sub rmprint()
{

$sth->execute();
$totalremettre=0;
$totalsortir=0;		
	print "<table border=1 cellspacing=0>";
	print "<tr bgcolor=#FFFF66><td>&nbsp;</td><td>&nbsp;</td>";
	print "<th>Retour</th><th>Depart</th><th>Sortir</th><th>Remettre</th><th>Dispo</th><th>cond.</th><th>plat</th><th>Carton</th><th>Detail</th><th>Check</th></tr>";
	
	while (($pr_cd_pr,$pr_desi,$pr_codebarre)=$sth->fetchrow_array){
		$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
		$sth2->execute();
		($car_carton,$car_pal)=$sth2->fetchrow_array;
	
		%stock=&stock($pr_cd_pr,$today,"retour");
		$pr_stre=$stock{"stock"};
		# print "$today $pr_cd_pr $pr_stre<br>";
		$total=0;
		$flag=1; # permet de lister les produits meme si le depart est à zero
		foreach (@liste){
			($troltype,$nb)=split(/;/,$_);
			$sth2=$dbh->prepare("select sum(tr_qte)/100 from trolley where tr_code=$troltype and tr_cd_pr=$pr_cd_pr");
			$sth2->execute();
			($qte)=$sth2->fetchrow_array;
			$sth2=$dbh->prepare("select ecr_qte/100 from ecartrol where ecr_cdtrol=$troltype and ecr_cd_pr=$pr_cd_pr");
			$sth2->execute();
			($ecr_qte)=$sth2->fetchrow_array;
			if ($ecr_qte eq ""){$ecr_qte=$qte;}
			else {$flag=1;}
			$ecr_qte+=0;
			$total+=$ecr_qte*$nb;
		}
	
		if (($total!=0)||($flag==1)){
			$digit_f=$pr_codebarre%1000000+1000000;
			$digit_f=substr($digit_f,3,4);
			$digit_p=int($pr_codebarre/10000);

			print "<tr><td>$pr_cd_pr ";
			# print "<b>$digit_f";
			print "</td><td><a href=fiche_produit.pl?pr_cd_pr=$pr_cd_pr&action=visu>$pr_desi</a></td>";
			$pr_stre+=0;
			print "<td align=right><a href=verif_rm_retour.pl?nodepart=$nodepart&today=$today&pr_cd_pr=$pr_cd_pr&action=retour>";
			print $stock{'retourdujour'};
			print "</a>";
			$sortir=$remettre="&nbsp;";
			$delta=$total-$stock{'retourdujour'};
			$stock_ent=$pr_stre-$stock{'retourdujour'};
			if ($pr_cd_pr==130100){$delta+=$deltabox;}
			if ($pr_cd_pr==130105){$delta+=$deltalight;}
			print "</td><td align=right><a href=verif_rm.pl?nodepart=$nodepart&today=$today&pr_cd_pr=$pr_cd_pr&action=depart>$total</a></td>";
			if ($delta>0){
				if (($delta>$stock_ent)&&($pr_cd_pr==130320)){
					$pair=($delta-$stock_ent)%2;
					$deltabox=($delta+$pair-$stock_ent)/2;
					$delta=$stock_ent-$pair;
				}
				if (($delta>$stock_ent)&&($pr_cd_pr==130120)){
					$pair=($delta-$stock_ent)%2;
					$deltalight=($delta+$pair-$stock_ent)/2;
					$delta=$stock_ent-$pair;
				}
		
				$sortir=$delta;
			}
			else{$remettre=0-$delta;}
			if ($sortir<0){$remettre=0-$sortir;$sortir=0;} # bug sur cigarette a remettre
			print "</td><td align=right><font color=red>$sortir</font></td>";
			$totalsortir+=$sortir;
			print "</td><td align=right><font color=green>$remettre</font></td>";
			$totalremettre+=$remettre;			
			$pr_stre-=$delta+$stock{'retourdujour'};
			print "<td align=right>$pr_stre</td><td align=right>$car_carton</td>";
			$detail=$pr_stre;
			$plat=$carton="&nbsp;";
			if (($car_carton!=0)&&($pr_stre >0)){
				$carton=int($pr_stre/$car_carton);
				$detail=$pr_stre%$car_carton;
				if ($car_pal!=0){
					$plat=int($carton/$car_pal);
					$carton=$carton%$car_pal;
				}
			}
			print "<td align=right>$plat</td><td align=right>$carton</td><td align=right><b>$detail</td>";
			print "<td>&nbsp;</td></tr>";
		}
	
	}
print "<tr><td colspan=4><b>Total</b></td><td align=right>$totalsortir</td><td  align=right>$totalremettre</td></tr>";	
print "</table>";
}
