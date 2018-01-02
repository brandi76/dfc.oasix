#!/usr/bin/perl
use CGI;
use DBI();

# livré ->at_etat=3
# vol annule ->v_zatt="AN"
$html=new CGI;
require "../oasix/outils_perl2.lib";
$action=$html->param('action');
print $html->header;
print "<html><head><meta http-equiv=\"Pragma\" content=\"no-cache\"><style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style><title>livraison</title></head><body>";
$datedujour=`/bin/date`;
$jour=`/bin/date '+%d'`+0;
$mois=`/bin/date '+%m'`+0;
$an="20".`/bin/date '+%y'`+0;
$noliv=$html->param('noliv');
$code=$html->param('code');
$index=$html->param('index');

for ($i=0;$i<=21;$i++){
	$check=$html->param("check$i");
	if ($check eq "on"){
		push (@liste,$html->param("val$i"));
	}
}

require "./src/connect.src";
$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
{
	$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
}
if ($action eq "lu"){
	&save("update message set mes_lu=1 where mes_index=$index");
	$action="";
}

if ($action eq "sup") ### modification d'un depart
{
	$query="delete from livraison where liv_no=$noliv and liv_code='$code'";
	if (&execute()){ print "<br> <font color=red> $code dans le depart $noliv supprimé </font></br>";}
	&save("update etatap set at_etat=2 where at_code='$code' and at_etat=3");
	$action="go";
}


if ($action eq "supd") ### Suppression d'un depart
{
	$query="select liv_code from livraison where liv_no=$noliv";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code)=$sth->fetchrow_array)
	{
		&save("update etatap set at_etat=2 where at_code='$code' and at_etat=3","af");
	}
	&save("delete from livraison where liv_no=$noliv");
	print "<br> <font color=red>depart $noliv supprimé </font></br>";
	$action="";
}


if ($action eq ""){
	&premiere();
}
if ($action eq "go"){
	if ($noliv eq ""){
		&creation(); # creation du depart
	}
	&table($noliv); # affichage du depart
}
if ($action eq "print"){
	print "<head><style type=\"text/css\">
	<!--
	H4 { page-break-after : right }         
	-->
	</style></head>";
	print "<body>";
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	
	$today=&nb_jour($jour,$mois,$an);
	$today--;
	$nb=&get("select count(*) from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'LFW%' and v_zatt!='AN'");
	if ($nb>0){	
		&bord_liv("LFW");
		print "Fin de page";
		# exit;
		print "</center>";
		print "<h4>.</h4>";  # saut de page
		&bord_liv("LFW");
		print "Fin de page";
		# exit;
		print "</center>";
	
		$paris=1;
	}
	$nb=&get("select count(*) from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'ORY%' and v_zatt!='AN'");
	if ($nb>0){	
		if ($paris==1){print "<h4>.</h4>";}  # saut de page  
		&bord_liv("ORY");
		print "Fin de page";
		print "</center>";
		print "<h4>.</h4>";  # saut de page
		&bord_liv("ORY");
		print "Fin de page";
		print "</center>";
	
		$paris=1;
	}
	$nb=&get("select count(*) from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'LYS%' and v_zatt!='AN'");
	if ($nb>0){	
		if ($paris==1){print "<h4>.</h4>";}  # saut de page  
		&bord_liv("LYS");
		print "Fin de page";
		print "</center>";
		print "<h4>.</h4>";  # saut de page
		&bord_liv("LYS");
		print "Fin de page";
		print "</center>";
	
		$escale=1;
	}
	$nb=&get("select count(*) from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'MRS%' and v_zatt!='AN'");
	if ($nb>0){	
		if (($paris==1)||($escale==1)){print "<h4>.</h4>";}  # saut de page
		&bord_liv("MRS");
		print "Fin de page";
		print "</center>";
		print "<h4>.</h4>";  # saut de page
		&bord_liv("MRS");
		print "Fin de page";
		print "</center>";
		$escale=1;

	}

	if ($paris){
		$nb=&get("select count(*) from geslot where gsl_dtret<=$today+1 and gsl_ind=3 and gsl_triret=\"ORY\"");
                if ($nb>0){
			print "<h4>.</h4>";  # saut de page
			&tableretour($today+1,"ORY");
			print "Fin de page";
			print "</center>";
		}
		$nb=&get("select count(*) from geslot where gsl_dtret<=$today+1 and gsl_ind=3 and gsl_triret=\"LFW\"");
                if ($nb>0){
			print "<h4>.</h4>";  # saut de page
			&tableretour($today+1,"LFW");
			print "Fin de page";
			print "</center>";
		}
	}
	if ($escale){
		$nb=&get("select count(*) from geslot where gsl_dtret<=$today+1 and gsl_ind=3 and gsl_triret=\"LYS\"","af");
                if ($nb>0){
			print "<h4>.</h4>";  # saut de page
			&tableretour($today+1,"LYS");
			print "Fin de page";
			print "</center>";
		}
		$nb=&get("select count(*) from geslot where gsl_dtret<=$today+1 and gsl_ind=3 and gsl_triret=\"MRS\"","af");
                if ($nb>0){
			print "<h4>.</h4>";  # saut de page
			&tableretour($today+1,"MRS");
			print "Fin de page";
			print "</center>";
		}
	}
	if ($paris){
		$query="select v_date_jl from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'ORY%' and v_zatt!='AN' group by v_date_jl";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while (($jour)=$sth3->fetchrow_array){
			$nb=&get("select count(*) from geslot,flybody where gsl_dtvol=$jour and flb_date=gsl_dtvol and flb_vol=gsl_novol and flb_rot=11 and (gsl_trajet like \"/ORY%\" or gsl_trajet like \"ORY%\")","af");
			if ($nb>0){
				print "<h4>.</h4><center>Document Piste Orly exemplaire pour <b>ORLY</b>";  # saut de page
				&tablepiste($jour,"ORY");
				print "Fin de page";
			}
		}
		$query="select v_date_jl from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'LFW%' and v_zatt!='AN' group by v_date_jl";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while (($jour)=$sth3->fetchrow_array){
			$nb=&get("select count(*) from geslot,flybody where gsl_dtvol=$jour and flb_date=gsl_dtvol and flb_vol=gsl_novol and flb_rot=11 and (gsl_trajet like \"/LFW%\" or gsl_trajet like \"LFW%\")");
			if ($nb>0){
				print "<h4>.</h4><center>Document Piste LFW exemplaire pour <b>ORLY</b>";  # saut de page
				&tablepiste($jour,"LFW");
				print "Fin de page";
				print "<h4>.</h4><center>Document Piste LFW exemplaire pour <b>LFW</b>";  # saut de page
				&tablepiste($jour,"LFW");
				print "Fin de page";
			}
		}
	}
	if ($escale) {
		$query="select v_date_jl from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'LYS%' and v_zatt!='AN' group by v_date_jl";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while (($jour)=$sth3->fetchrow_array){
			$nb=&get("select count(*) from geslot,flybody where gsl_dtvol=$jour and flb_date=gsl_dtvol and flb_vol=gsl_novol and flb_rot=11 and (gsl_trajet like \"/LYS%\" or gsl_trajet like \"LYS%\")","af");
			if ($nb>0){
				print "<h4>.</h4><center>Document Piste lyon exemplaire pour <b>LYON</b>";  # saut de page
				&tablepiste($jour,"LYS");
				print "Fin de page";
			}
		}
		$query="select v_date_jl from vol,livraison where liv_no=$noliv and liv_code=v_code and v_rot=1 and v_dest like 'MRS%' and v_zatt!='AN' group by v_date_jl";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		while (($jour)=$sth3->fetchrow_array){
			$nb=&get("select count(*) from geslot,flybody where gsl_dtvol=$jour and flb_date=gsl_dtvol and flb_vol=gsl_novol and flb_rot=11 and (gsl_trajet like \"/MRS%\" or gsl_trajet like \"MRS%\")","af");
			if ($nb>0){
				print "<h4>.</h4><center>Document Piste marseille exemplaire pour <b>MARSEILLE</b>";  # saut de page
				&tablepiste($jour,"MRS");
				print "Fin de page";
			}
		}
	}
}


####  Premiere page
sub premiere{
 	$date=`/bin/date +%d';'%m';'%Y`;
  	($jour,$mois,$an)=split(/;/, $date, 3); 
	$today=&nb_jour($jour,$mois,$an);
	print "<center><h1>Livraison</h1>";
	print "<br><br>";
	$query="select * from message where mes_fin>=now() and mes_dest='alain' order by mes_dest";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($index,$src,$dest,$date,$message)=$sth->fetchrow_array)
	{
		print "<table border=1 width=80% cellspacing=0><tr bgcolor=lightblue><td>de la part de $src pour <b>$dest</b></td><td>Date de validite:$date</td></tr>";
		print "<tr><td><font color=red>$message</td><td><a href=?action=lu&index='$index'>lu</a></td></tr>";
		print "</table><br>";
	}
	print "<form>";
 	print "<table border=0>";
	for($i=0;$i<=21;$i++) {
		$jour=$today+$i;
		$nbvol=&get("select count(*) from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_rot=1 and v_dest like 'LFW%' and v_zatt!='AN'","af");
		if ($nbvol >0){		
			print "<tr><td>ROISSY</td><td><font size=+2>";
			print &jour($jour);
			print "</td><td align=right><font size=+1>";
			print &julian($jour,"");
			print "</td>";
			print "<td><font size=+2>Nb de vol:$nbvol</td>";
			print "<td><input type=checkbox name=cdg$i style=\"width:40px; height:40px;\"></td>";
			print "</tr>\n";
		}
		$nbvol=&get("select count(*) from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_rot=1 and v_dest like 'ORY%' and v_zatt!='AN'");
		if ($nbvol >0){		
			print "<tr><td>ORLY</td><td><font size=+2>";
			print &jour($jour);
			print "</td><td align=right><font size=+1>";
			print &julian($jour,"");
			print "</td>";
			print "<td><font size=+2>Nb de vol:$nbvol</td>";
			print "<td><input type=checkbox name=ory$i style=\"width:40px; height:40px;\"></td>";
			print "</tr>\n";
		}
		$nbvol=&get("select count(*) from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_rot=1 and v_dest like 'LYS%' and v_zatt!='AN'");
		if ($nbvol >0){		
			print "<tr><td>LYON</td><td><font size=+2>";
			print &jour($jour);
			print "</td><td align=right><font size=+1>";
			print &julian($jour,"");
			print "</td>";
			print "<td><font size=+2>Nb de vol:$nbvol</td>";
			print "<td><input type=checkbox name=lys$i style=\"width:40px; height:40px;\"></td>";
			print "</tr>\n";
		}
		$nbvol=&get("select count(*) from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_rot=1 and v_dest like 'MRS%' and v_zatt!='AN'","af");
		if ($nbvol >0){		
			print "<tr><td>MARSEILLE</td><td><font size=+2>";
			print &jour($jour);
			print "</td><td align=right><font size=+1>";
			print &julian($jour,"");
			print "</td>";
			print "<td><font size=+2>Nb de vol:$nbvol</td>";
			print "<td><input type=checkbox name=mrs$i style=\"width:40px; height:40px;\"></td>";
			print "</tr>\n";
		}
	}
	
	$jour=$today;
	
  	print "</table>";
	$sth=$dbh->prepare("select liv_no from livraison group by liv_no order by liv_no desc limit 5");
	$sth->execute();
	while (($noliv)=$sth->fetchrow_array){
		print "<a href=?action=go&noliv=$noliv>$noliv</a><br>";
	}
	print "<input type=text name=noliv size=4><input type=hidden name=action value=go>";
	print "<br><br><input type=submit value='Livraison'>";
	print "</form></body>";
}


sub creation{
	$date=`/bin/date +%d';'%m';'%Y`;
  	($jour,$mois,$an)=split(/;/, $date, 3); 
	$today=&nb_jour($jour,$mois,$an);
	# mise a jour d'atadsql si c'a n'a pas ete fait aujourd'hui
	$query="update atadsql set dt_no=dt_no+1,dt_date=curdate() where dt_cd_dt=104";
	&execute();			
	$flag_creation=0;
	# recuperation du numero de livraison
	$query="select dt_no from atadsql where dt_cd_dt=104";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$noliv=$sth->fetchrow_array;
	for ($i=0;$i<=21;$i++){
		$jour=$today+$i;
		$check=$html->param("cdg$i");
		if ($check eq "on"){
			$query="select v_code from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_dest like 'LFW%' and v_rot=1 and v_zatt!='AN'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($v_code)=$sth->fetchrow_array){
				$query="replace into livraison values ('$noliv','$v_code')";
				&execute();
				$flag_creation=1;
				&save ("update etatap set at_etat=3 where at_code='$v_code' and at_etat=2");
			}
		
		}
		$check=$html->param("ory$i");
		if ($check eq "on"){
			$query="select v_code from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_dest like 'ORY%' and v_rot=1 and v_zatt!='AN'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($v_code)=$sth->fetchrow_array){
				$query="replace into livraison values ('$noliv','$v_code')";
				&execute();
				$flag_creation=1;
				&save ("update etatap set at_etat=3 where at_code='$v_code' and at_etat=2");
			}
		
		}
		$check=$html->param("mrs$i");
		if ($check eq "on"){
			$query="select v_code from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_dest like 'MRS%' and v_rot=1 and v_zatt!='AN'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($v_code)=$sth->fetchrow_array){
				$query="replace into livraison values ('$noliv','$v_code')";
				&execute();
				$flag_creation=1;
				&save ("update etatap set at_etat=3 where at_code='$v_code' and at_etat=2");
			}
		
		}
		$check=$html->param("lys$i");
		if ($check eq "on"){
			$query="select v_code from vol,etatap where v_date_jl=$jour and at_etat=2 and at_code=v_code and v_dest like 'LYS%' and v_rot=1 and v_zatt!='AN'";
			$sth=$dbh->prepare($query);
			$sth->execute();
			while (($v_code)=$sth->fetchrow_array){
				$query="replace into livraison values ('$noliv','$v_code')";
				&execute();
				$flag_creation=1;
				&save ("update etatap set at_etat=3 where at_code='$v_code' and at_etat=2");
			}
		}
	}

	if ($flag_creation==0){
		print "<hr><h3><font color=red>Aucun vol disponible pour un nouveau départ , merci de selectionner un depart valide</font></h3><br>";
	}
}



###### -affichage du depart
sub table{
	my $noliv=$_[0];
	print  "<center><h2>Livraison</h1><a href=?>debut</a>";
	print "<br><font size=+3>$noliv</font> <a href=?action=supd&noliv=$noliv>sup</a><br>";
	print  "<table border=1 cellspacing=0><tr bgcolor=yellow><th>Jour</th><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>No lot</th><th>No appro</th></tr>";
	$sth=$dbh->prepare("select liv_code from livraison where liv_no=$noliv order by liv_code");
	$sth->execute();
	while (($v_code)=$sth->fetchrow_array){
		$query="select v_date_jl,v_vol,v_cd_cl,v_troltype,at_nolot,v_dest from vol,etatap where v_code='$v_code' and v_rot=1 and at_code=v_code and v_zatt!='AN'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($v_date_jl,$v_vol,$v_cd_cl,$v_troltype,$at_nolot,$v_dest)=$sth2->fetchrow_array;
		$query="select lot_conteneur,lot_desi,lot_nbcont,lot_poids from lot where lot_nolot=$v_troltype";
		$sth2=$dbh->prepare($query);
		# print "<tr><td>$query</td></tr>";
		$sth2->execute();
		($gsl_desi,$lot_desi,$lot_nbcont,$lot_poids)=$sth2->fetchrow_array;
		print  "<tr><td>";
		print &jour($v_date_jl);
		print " ";
		print &julian($v_date_jl,"");
		print "<td><b>";
		($cl_nom,$cl_trilot)=split(/;/,$client_dat{$v_cd_cl});
		print  "$fl_cd_cl $cl_nom";
		print  "</td>";
		$cle="(type:".$v_troltype.") ".$gsl_desi." ".$lot_desi;
		print  "<td align=center>$v_vol $v_dest</td><td align=left>type:($v_troltype) $gsl_desi $lot_desi</td>";
		print "<td><b>$cl_trilot $at_nolot</td>";
			
			# if (($fl_cd_cl*1000+$at_nolot)!=$liv_nolot){ 
		print "<td>$v_code</td><td><a href=?action=sup&noliv=$noliv&code=$v_code>sup</a></td>";
		print  "</tr>\n";
		$nbcont+=$lot_nbcont;
		$poids+=$lot_poids;
	}
	print  "</table>\n<table border=0><tr><td align=left>";
	foreach $cle (sort(keys(%listetrol))){
		print "$cle qte:$listetrol{$cle}<br>";
	}
	print "</td></tr></table>";
	if ($poids >1500){$poids="<font color=red size=+2>$poids</font>";}
	print "Nb de conteneur:$nbcont Poids:$poids<br>";
	print "<a href=?action=print&noliv=$noliv>Edition des documents de livraison</a><br>";
}


sub bord_liv{
	my $aero=$_[0];
	$nbcont=0;
	$poids=0;
	print "<center><table border=1 cellspacing=0 cellpadding=10 width=80%><tr><td><font size=-1>Livraison pour <b>$aero</b><br>IBS FRANCE<br>DIEPPE</td><td><font size=-1>MARCHANDISES DETENUES ET CIRCULANT SOUS LE REGIME DE L'ENTREPOT TYPE E<br>REPRIS DANS LA CONVENTION B5779 (ARTICLE 528-2 D.A.C DU C.D.C)</td></tr></table></center>";
	print "<br>DEPART DE DIEPPE No:$noliv";
	print "<br>IMMATRICULATION DU VEHICULE:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CHAUFFEUR:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br><br> A L'ATTENTION DE L'ASSISTANT OBS  FAX <b>01 49 75 82 96</b><br><br>";
	print "Scelle capacitaire:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Emargement:<br><br>";
	print "Date d'edition:$datedujour";  
	print "<br>Date du depart et justificatif (si different):<br><br><center>";  
	$pass=0;
	print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#FFFF66><th>No de certificat</th><th>No du lot</th><th> No du vol</th><th>dest</th><th>conteneur </th><th>Date vol</th><th>charg</th><th>scelles</th><th width=200>Emargement</th></tr>";
	$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_nb_cont,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7,gsl_apcode,gsl_troltype from geslot,livraison where liv_no='$noliv' and gsl_apcode=liv_code and gsl_ind<99 and (gsl_trajet like \"/$aero%\"or gsl_trajet like \"$aero%\")";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_nb_cont,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_apcode,$gsl_troltype)=$sth->fetchrow_array){
		$query="select flb_depart from flybody where flb_date=$gsl_dtvol and flb_vol like \"$gsl_vol\" and flb_rot=11";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($flb_depart)=$sth2->fetchrow_array;
		@plomb=($gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7);
		$nbcont+=$gsl_nb_cont;
		$lot_poids=&get("select lot_poids from lot where lot_nolot='$gsl_troltype'")+0;
		$poids+=$lot_poids;
		# $client=int($gsl_nolot/1000);
		$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1 and v_zatt!='AN'";
		$sth_n=$dbh->prepare($query);
		$sth_n->execute();
		($client)=$sth_n->fetchrow_array;
	
		($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
		$gsl_nolot%=1000;
		$flb_depart/=100;
		$gsl_hrret/=100;
		
		print "<tr><td align=center>$gsl_apcode</td>";
		print "<td>$cl_trilot $gsl_nolot</td>";
		print "<td>$gsl_vol</td>";
		print "<td>$gsl_trajet</td>";
		print "<td align=middle>$gsl_desi</td><td>";
		print &julian($gsl_dtvol,"");
		print "</td><td align=center>";
		print &deci($flb_depart);
		print "</td><td>";
		foreach (@plomb) {if ($_!=0){print "$_<br>";}}
		print "</td><td>&nbsp;</td>";
		
		print "</tr>\n";
		$pass=1
	}
	print "</table>\n";
	if ($pass==0){print "-------------------NIL-----------------------<br>";}
	print "Nombre de conteneur:$nbcont poids:$poids<br>";
}

sub tableretour{
	my $today=$_[0];
	my $aero=$_[1];
	print "<center><table border=1 cellspacing=0 cellpadding=10 width=80%><tr><td><font size=-1>Enlevement de <b>$aero</b><br>IBS FRANCE<br>DIEPPE</td><td><font size=-1>MARCHANDISES DETENUES ET CIRCULANT SOUS LE REGIME DE L'ENTREPOT TYPE E<br>REPRIS DANS LA CONVENTION B5779 (ARTICLE 528-2 D.A.C DU C.D.C)</td></tr></table></center>";
	print "<br>RETOUR DU:<b>";
	print &julian($today,"");
	print "</b><br>Date d'edition:$datedujour";  
	print "<br><br><center>";  
	$pass=0;
	print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#FFCC33><th>No de certificat</th><th>No du lot </th><th> No du vol</th><th>dest</th><th>conteneur </th><th>Date retour</th><th>dechargement</th><th>scelles</th><th width=200>Emargement</th></tr>";
	$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_apcode from geslot where gsl_dtret<=$today and gsl_ind=3 and gsl_triret=\"$aero\"";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_apcode)=$sth->fetchrow_array){
		$query="select flb_depart from flybody where flb_date=$gsl_dtvol and flb_vol like \"$gsl_vol\" and flb_rot=11";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($flb_depart)=$sth2->fetchrow_array;
		@plomb=($gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7);
		
		$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1 and v_zatt!='AN'";
		$sth_n=$dbh->prepare($query);
		$sth_n->execute();
		($client)=$sth_n->fetchrow_array;
	
		# $client=int($gsl_nolot/1000);
		($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
		$gsl_nolot%=1000;
		$flb_depart/=100;
		$gsl_hrret/=100;
		
		print "<tr><td align=center>$gsl_apcode</td>";
		print "<td>$cl_trilot $gsl_nolot</td>";
		print "<td>$gsl_vol</td>";
		print "<td>$gsl_trajet</td>";
		print "<td align=middle>$gsl_desi</td><td>";
		print &julian($gsl_dtret,"");
		print "</td><td align=center>";
		print &deci($gsl_hrret);
		print "</td><td>&nbsp;</td>";
		print "</td><td>&nbsp;</td>";
		print "</tr>\n";
		$pass=1;
	}
	print "</table>\n";
	if ($pass==0){print "-------------------NIL-----------------------<br>";}

}

# PISTE 
sub tablepiste{
	my $today=$_[0];
	my $aero=$_[1];
	
	print "<center><br><table border=1 cellspacing=0 width=80%><tr><td>                                                         
	IBS FRANCE AGREMENT SURETE AGREMENT EC-06-276-76-01-DN<br>LISTE D'EMARGEMENT SURETE DU ";                    
	print &julian($today,"");
	print " Pour <b>$aero</b></td></tr></table><br><h2>";
	print &jour($today);
	print " ";
	print &julian($today,"");
	print "</h2></center></center>\n";
	print "<br>Avant d'apposer votre visa dans la case emargement :</br>verifier la coherence des elements portes sur l'etiquette avec le document a signer</br>verifier le nombre et les numeros de plombs des contenants avec le document a signer</br>";
	print "<b>Nom du Chauffeur:</b><br><br><center>";
	$pass=0;  
	print "<table border=1 cellspacing=0 cellpadding=0><tr bgcolor=pink><th><font size=-1>Compagnie</th><th>Trajet</th><th>No de lot</th><th>No de certificat</th><th>vol</th><th><font size=-2>Conteneur</th><th>Heure <br>(local)</th><th>Plombs</th><th><font size=-1>Controle sureté chargeur</th><th><font size=-1>Controle sureté compagnie</th><th>Commentaire</th></tr>";
	@liste=();
	$query="select gsl_nolot,flb_depart from geslot,flybody where gsl_dtvol=$today and flb_date=gsl_dtvol and flb_vol=gsl_novol and flb_rot=11 and (gsl_trajet like \"/$aero%\" or gsl_trajet like \"$aero%\")";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($lot,$heure)=$sth->fetchrow_array){
		push (@liste,"$heure;$lot;depart");
	}
	$query="select gsl_nolot,gsl_hrret from geslot where gsl_dtret=$today and gsl_triret=\"$aero\"";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($lot,$heure)=$sth->fetchrow_array){
		push (@liste,"$heure;$lot;retour");
	}
	@liste=sort{ $a <=> $b}(@liste);
	foreach (@liste){
		($heure,$lot,$sens)=(split/;/,$_);
		$query="select gsl_nolot,gsl_novol,gsl_dtret,gsl_dtvol,gsl_hrret,gsl_triret,gsl_trajet,gsl_desi,gsl_nb_cont,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7,gsl_apcode from geslot where gsl_nolot=$lot";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($gsl_nolot,$gsl_vol,$gsl_dtret,$gsl_dtvol,$gsl_hrret,$gsl_triret,$gsl_trajet,$gsl_desi,$gsl_nb_cont,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_apcode)=$sth->fetchrow_array;
		$query="select flb_depart from flybody where flb_date=$gsl_dtvol and flb_vol like \"$gsl_vol\" and flb_rot=11";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($flb_depart)=$sth2->fetchrow_array;
		@plomb=($gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7);
	
		# $client=int($gsl_nolot/1000);
		
		$query="select cl_cd_cl from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1 and v_zatt!='AN'";
		$sth_n=$dbh->prepare($query);
		$sth_n->execute();
		($client)=$sth_n->fetchrow_array;
	
		print "<tr><td><font size=-2><b>";
		($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
		print $cl_nom;
		print "</td>";
		print "<td><font size=-2>$gsl_trajet</td>";
		$gsl_nolot%=1000;
		print "<td>$cl_trilot $gsl_nolot</td><td align=center>$gsl_apcode</td><td>$gsl_vol</td><td align=center>$gsl_desi</td>";
		 $flb_depart=$flb_depart/100;
		if ($sens eq "depart"){
			print "<td align=center>";
			print "<b>";
			print &deci($flb_depart);
			print "</td><td>";
			foreach (@plomb) {if ($_!=0){print "$_<br>";}}
			print "&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
		}
		else {
			print "<td align=center>";
			print "<b>";
			$gsl_hrret/=100;
			print &deci($gsl_hrret);
			print "</td>";
			print "<td>&nbsp;<br>Retour<br>&nbsp;</td>";
			print "<td>&nbsp;</td><td>&nbsp;</td>\n";
	
		}
		print "<td>&nbsp;</td></tr>\n";
		$pass=1;
	}
	print "<tr><td>&nbsp;<br>&nbsp;<br>&nbsp;<br></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
	print "<tr><td>&nbsp;<br>&nbsp;<br>&nbsp;<br></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
	print "</table>\n";
	if ($pass==0){print "-------------------NIL-----------------------";}
}



# FONCTION : nb_jour(jour,mois,annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : le jour mois annee (yyyy)
# SORTIE : le nombre de seconde

sub nb_jour{
	my ($jour)=$_[0];
	my ($mois)=$_[1];
	my ($annee)=$_[2];

	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}
sub nb_jour_an
{
	my ($annee)=$_[0];
	my ($n)=0;
	for (my($i)=1970; $i<$annee; $i++) {
		$n += 365; 
		if (&bissextile($i)){$n++;}
	}
	return($n);
}

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
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
