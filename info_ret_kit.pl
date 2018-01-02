$jour=$html->param("jour");
$mois=$html->param("mois");
$annee=$html->param("annee");
$action=$html->param("action");



print "<title>Liste des retours saisies</title>";
if ($action eq ""){&premiere();}
if ($action eq "go"){&go();}

sub premiere{
        print "<form>";
        require ("form_hidden.src");
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an="20".`/bin/date '+%y'`;
	print "<center><h1>Liste des retours saisies</h1><br>Date : Jour <input type=text name=jour value=$jour> Mois <input type=text name=mois value=$mois> Annee <input type=text name=annee value=$an><br>";
	print " <input type=submit>"; 
	print "<input type=hidden name=action value=go>";
	print "</form>";	

}
sub go{
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	
	
	$today=&nb_jour($jour,$mois,$annee);
	print  "<body>";
	print  "<center>\n";
	print  "<div class=titre>Saisie du ";
	print  &jour($today);
	print  " ";
	$today=&julian($today,"YYYY-MM-DD");
	print  $today;
	print  "</div><br>\n";
	print  "<table border=1 cellspacing=0 cellpadding=0><tr ><th>Compagnie</th><th>Trajet</th><th>vol</th><th>No de lot</th><th>type</th><th>Ca</th></tr>";
	# $query="select gsl_nolot,gsl_dtret,gsl_novol,gsl_hrret,gsl_trajet,gsl_desi,gsl_apcode from geslot where (gsl_ind=3 or gsl_ind=5) and ((gsl_dtvol<'$today') or (gsl_dtvol='$today' and gsl_hrret<'$heure'*100)) order by gsl_apcode";
	$query="select v_vol,at_nolot,v_dest,v_date,v_cd_cl,infr_caisseth,v_troltype from vol,etatap,inforetsql where infr_date='$today' and infr_code=v_code and v_rot=1 and v_code=at_code order by v_troltype";
	# print "<td>$query</td>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_vol,$at_nolot,$v_dest,$v_date,$v_cd_cl,$infr_caisseth,$v_troltype)=$sth->fetchrow_array){
		
		$query="select cl_cd_cl from client where cl_cd_cl=$v_cd_cl";
		$sth_n=$dbh->prepare($query);
		$sth_n->execute();
		($client)=$sth_n->fetchrow_array;
		print  "<tr>";
		print "<td>";
		($cl_nom,$cl_trilot)=split(/;/,$client_dat{$client});
		print  $cl_nom;
		print  "</td>";
		print  "<td>$v_dest</td>";
		print "<td>$v_vol</td>";
		print "<td>$at_nolot</td>";
		print "<td>$v_troltype</td>";
		print "<td align=right>$infr_caisseth</td>";
		print  "</tr>\n";
		$total+=$infr_caisseth;
	}
	print  "<tr><td colspan=5><b>Total</b></td><td align=right><b>$total<b></td></tr></table>\n<br>";
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
# FONCTION : deci2(variable)
# DESCRIPTION : retourne un chiffre avec2 chiffres apres la virgule 
# ENTREE : le nom de la variable 
# SORTIE : 
sub deci3 {
	my ($var)=@_[0];
	my ($chaine,$deci,$ent,$dec);
	# ${$var}=${$var}/100 ;
	${$var} = "".${$var};
	($ent,$dec) = split(/\./,${$var});
	$deci = ("0.".$dec)+0;
	$deci = int($deci*100);
	
	if ($deci<0){$deci*=-1;}
	if ($deci == 0){$deci="00";}
	else{
		if ($deci < 10){$deci="0".$deci;}
	}
	${$var}=int(${$var});
	${$var}=${$var}.".".$deci;
}
# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine)=(4,"Lundi",5,"Mardi",6,"Mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	return "$semaine{$var%7}";
}

sub avisret{
$nb=$html->param("nb");
for ($i=1;$i<=$nb;$i++){
	$check=$html->param("check$i");
	if ($check eq "on"){
		$appro=$html->param("appro$i");
		$query="select count(*) from geslot where (gsl_ind=3 or gsl_ind=5) and gsl_apcode=$appro";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($nb_row)=$sth->fetchrow_array;
		if ($nb_row >0){$ok=1;}

	}
}
if ($ok==1) { 
	# permet de prendre un numero uniquement si c'est un nouveau avis de retour
	$query="select dt_no from atadsql where dt_cd_dt=101";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($no_retour)=$sth->fetchrow_array;
	$no_retour++;
	$query="update atadsql set dt_no=$no_retour where dt_cd_dt=101";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	for ($i=1;$i<=$nb;$i++){
		$check=$html->param("check$i");
		if ($check eq "on"){
			$appro=$html->param("appro$i");
			 # $query="replace into geslot select * from geslot where gsl_apcode='$appro'"; 
			 # $sth=$dbh->prepare($query);
			 # $sth->execute();
			 $query="update geslot set gsl_ind=5 where gsl_apcode='$appro'";
			 $sth=$dbh->prepare($query);
			 $sth->execute();
		}
	}
	print "."; 
}


$jour=`/bin/date '+%d'`;
$mois=`/bin/date '+%m'`;
$an="20".`/bin/date '+%y'`;
chop($jour);
chop($mois);
chop($an);
print "<pre>
IBS FRANCE
BP143 76204 DIEPPE
02.32.14.02.88


                   PAR TELECOPIE 02 32 14 06 81


De la part de IBS FRANCE
Destinataire : Douane de Dieppe
Retour No: $no_retour  du $jour/$mois/$an

Messieurs,
Merci de bien vouloir noter le numéro des bons d'approvisionnement
pour le retour de notre camion</pre><table cellspacing=0 border=1><tr><th>No du lot</th><th>No bon</th><th>No de vol</th><th>Dest</th><th>Conteneur</th><th>Alcool</th><th>Tabac</th></tr>";
for ($i=1;$i<=$nb;$i++){
	$check=$html->param("check$i");
	if ($check eq "on"){
		$appro=$html->param("appro$i");
		$query="select gsl_nolot,gsl_trajet,gsl_novol,gsl_desi,gsl_alc/100,gsl_tab/100,gsl_nb_cont from geslot where gsl_apcode=$appro";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($gsl_nolot,$gsl_trajet,$gsl_novol,$gsl_desi,$gsl_alc,$gsl_tab,$gsl_nb_cont)=$sth->fetchrow_array;
		print "<tr><td>$gsl_nolot</td><td>";		
		print "$appro</td><td>";		
		print "$gsl_novol</td><td>";		
		print "$gsl_trajet</td><td>";		
		print "$gsl_desi</td><td>";		
		print "$gsl_alc</td><td>";		
		print "$gsl_tab</td></tr>";
		$nbcont+=$gsl_nb_cont;		
	}
}

print "</table><br>Nombre de conteneur:$nbcont<br><pre><br>Nous vous en remercions, et vous prions d'agreer, Messieurs, nos sinceres salutations";
 }
;1
# -E Avis de retour
