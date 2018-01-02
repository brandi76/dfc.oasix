#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;

print $html->header;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";

$vol=$html->param('vol');
$date=$html->param('date');
$action=$html->param('action');
require "./src/connect.src";
$type=&get("select fl_troltype from flyhead where fl_date='$date' and fl_vol='$vol'");
if ($action eq "modif"){
	$query="select tr_cd_pr,tr_qte/100 from trolley where tr_code=$type ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
		if ($html->param($pr_cd_pr)!=$qte){
			$qte=$html->param($pr_cd_pr)*100;
			&save("replace into ecartrol values ($type,$pr_cd_pr,$qte,'')","af");
		}
		else
		{
			$ecart=&get("select ecr_qte/100 from ecartrol where ecr_cdtrol=$type and ecr_cd_pr=$pr_cd_pr");
			if ($ecart ne ""){
 				&save("delete from ecartrol where ecr_cdtrol=$type and ecr_cd_pr=$pr_cd_pr","af");
			} 
		}		
	}
	$action="";
}		

if ($action eq ""){
	$colorline="white";
	print "<center><h3>$vol trolley type:$type</h3><form>";
	print "<table cellspacing=0 border=1><tr><th>Produit</th><th>Départ</th></th><th>Qte<br>Standard</th><th>Qte<br>réel</th></tr>";
	$query="select tr_cd_pr,pr_desi,floor(tr_qte/100) from trolley,produit where tr_code=$type and tr_cd_pr=pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$qte)=$sth->fetchrow_array){
		$qter=$qte;
		$ecart=&get("select floor(ecr_qte/100) from ecartrol where ecr_cdtrol=$type and ecr_cd_pr=$pr_cd_pr");
		if ($ecart ne ""){
			$colorline="red";
			$qter=$ecart;
		}
		print "<tr bgcolor=$colorline><td>".$pr_cd_pr."</td><td>".$pr_desi."</td>";
		$color="black";
		print "<td align=right><font color=$color>".$qte."</td>";
		print "<td align=right><input type=text name=".$pr_cd_pr." value=".$qter." size=3 </td>";
		print "</tr>";
		$index++;
		if ($colorline eq "white"){$colorline="&ffffff";} else {$colorline="white";}
	}
	print "</table><br><input type=hidden name=action value=modif><input type=hidden name=vol value='$vol'><input type=hidden name=date value='$date'><input type=submit value=modification></form>";
	print "<form><br><input type=hidden name=action value=creation><input type=hidden name=vol value='$vol'><input type=hidden name=date value='$date'><input type=submit value=creation></form>";
}

if ($action eq "creation"){
	&creation();
}

sub creation()
{

	$liv_vol=$vol;
	$liv_date=$date;
	$nodepart=1;

	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime(time);    
	$annee=substr($annee,1,2)+2000;
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);
	$date2=$jour.";".$mois.";".$annee;
  	# $date2=`/bin/date +%d';'%m';'%Y`;
	($jour,$mois,$an)=split(/;/, $date2, 3); 
	chop($an);
	$today=&nb_jour($jour,$mois,$an);
	$datesimple="1".substr($an,2,2).$mois.$jour;

	# &save("update atadsql set dt_no=dt_no+1,dt_date=curdate() where dt_cd_dt=100");
	# recuperation du numero de depart
	# $query="select dt_no from atadsql where dt_cd_dt=100";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# $nodepart=$sth->fetchrow_array;
	
	# $nb_enr=&get("select count(*) from listevol where liv_vol='$liv_vol' and liv_date='$date'","af")+0;
	# if ($nb_enr==0){
		#&save("replace into listevol values ('$nodepart','$date','$liv_vol','0','','')","af");
	#}
	#else
	#{
	#	$deps=&get("select liv_dep from listevol where liv_vol='$liv_vol' and liv_date='$date'");
	#	print "<font color=red>vol $fl_vol $date deja dans le depart $deps<br>";
		# exit;
	#}
	$nodepart=0;
	$no_lot=&get("select gsl_nolot from geslot where gsl_nolot<300 and gsl_ind=0 order by gsl_nolot limit 1");
	
	#  maj de atadsql
	#&save("update atadsql set dt_desi=dt_desi+1 where dt_cd_dt=210","af");  # numero appro
	# recuperation du numero d'appro
	#$query="select dt_desi from atadsql where dt_cd_dt=210";
	#$sth2=$dbh->prepare($query);
	#$sth2->execute();
	#($appro)=$sth2->fetchrow_array;
	$appro="25596";
	print "**$appro**";
	$query="select fl_troltype,fl_cd_cl from flyhead where fl_date='$liv_date' and fl_vol='$liv_vol' limit 1";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fl_troltype,$fl_cd_cl)=$sth2->fetchrow_array;

	$query="select flb_arrivee,flb_datetr,flb_tridep,flb_triret from flybody where flb_vol='$liv_vol' and flb_date='$liv_date' order by flb_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$trajet="";
	# boucle sur flybody pour avoir le trajet
	while ((@flb)=$sth2->fetchrow_array){
		$flb_arrivee=$flb[0];
		$flb_datetr=$flb[1];
		$flb_tridep=$flb[2];
		$flb_triret=$flb[3];
		
		$trajet=$trajet.$flb_tridep."/";
		}
	$trajet=$trajet.$flb_triret;
	
	$query="select flb_datetr,flb_rot,flb_voltr from flybody where flb_vol='$liv_vol' and flb_date='$liv_date' and (flb_rot%10)=1 order by flb_rot";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	# reboucle sur flybody pour les rotations
	while (($flb2_datetr,$flb2_rot,$flb2_voltr)=$sth2->fetchrow_array){
		$rot=int($flb2_rot/10);	
		# $cl_cd_cl=int($no_lot/1000);
		# $troltype=int($no_lot/100);
		$date=&julian($flb2_datetr,"DDMMYY");
		# maj de vol
		&save("replace into vol values ('$appro','$rot','$flb2_voltr','$date','0','','0','$trajet','$fl_cd_cl','','','0','$fl_troltype','$flb2_datetr','')","af");
		# maj caisse
		&save("replace into caisse values ('$appro','$rot','0','0','0','0','0','0','0','0','0','0','0','','','0')","af");
	}

	# maj de listevol
	&save("update listevol set liv_nolot='$no_lot' where liv_date='$liv_date' and liv_vol='$liv_vol' and liv_dep='$nodepart'","af");
	
	# maj de flyhead
	&save("update flyhead set fl_apcode='$appro',fl_nolot=$no_lot where fl_date='$liv_date' and fl_vol='$liv_vol'","af");
	
	# new recuperation des infos trolley type
	$query="select lot_conteneur,lot_nbplomb,lot_nbcont from lot where lot_nolot='$fl_troltype'";
	$sth_n=$dbh->prepare($query);
	$sth_n->execute();
	($lot_conteneur,$lot_nbplomb,$lot_nbcont)=$sth_n->fetchrow_array;
	
	# maj de geslot
	&save("update geslot set gsl_apcode='$appro',gsl_ind=5,gsl_nodep='$nodepart',gsl_noret=0,gsl_novol='$liv_vol',gsl_dtvol='$liv_date',gsl_troltype='$fl_troltype',gsl_hrret='$flb_arrivee',gsl_dtret='$flb_datetr',gsl_triret='$flb_triret',gsl_trajet='$trajet',gsl_alc='0',gsl_tab='0',gsl_nb_cont='$lot_nbcont',gsl_desi='$lot_conteneur',gsl_nbpb='$lot_nbplomb' where gsl_nolot='$no_lot'","af");
	
	# maj etatap
	$troltype{$fl_troltype}++;
	$tiroir=$fl_troltype."_".$troltype{$fl_troltype};
	&save("replace into etatap values('$appro',2,'$datesimple',0,'','$tiroir','$nodepart','0','$no_lot')","af");
	
	# maj apjour	
	&save("replace into apjour values('$datesimple','$appro')","af");
	$cree=0;
	$query="select tr_ordre,tr_cd_pr,tr_qte,tr_prix from trolley where tr_code='$fl_troltype' order by tr_ordre";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	# boucle sur trolley
	while (($tr_ordre,$tr_cd_pr,$tr_qte,$tr_prix)=$sth2->fetchrow_array){
		$query="select ecr_qte from ecartrol where ecr_cdtrol='$fl_troltype' and ecr_cd_pr='$tr_cd_pr'";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($ecr_qte)=$sth3->fetchrow_array;
		if ($ecr_qte ne ''){$tr_qte=$ecr_qte;}
		# maj appro
		&save("replace into appro values('$appro','$tr_ordre','$tr_cd_pr','$tr_prix','$tr_qte','2','$fl_cd_cl')","af");
		$cree++;
		# maj produit
		&save("update produit set pr_stvol=pr_stvol+$tr_qte where pr_cd_pr='$tr_cd_pr'","af");
		# maj sortie
		&save("replace into sortie values('$tr_cd_pr','$appro','$tr_qte')","af");
	}	
	
	if ($cree==0){print "<font color=red> Attention bon d appro vierge : appro=$appro </font><br>";}
	else {print "creation effectuée lot N:$no_lot";}
}


# -E validtaion des qte

                	
