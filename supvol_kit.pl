print "<title>suppression d'une chaine de vol</title><center>";
print "<div class=titrefixe>suppression d'une chaine de vol</div>";
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$nbsem=$html->param('nbsem');
$action=$html->param('action');
$vol=$html->param('vol');
$joursem=$html->param('joursem');
$today=&nb_jour($jour,$mois,$an);

require "./src/connect.src";

if ($action eq ""){
	print "<center> Premiere date<br><form>";
	require ("form_hidden.src");
	&select_date();
	print "<br>no de vol:<input type=text name=vol><br>";
	print "<br>nombre de semaine:<input type=text name=nbsem size=3><br>";
 	print "<br>Jour de la semaine:<select name=joursem>";
 	print "<option value='Lundi'>Lundi";
 	print "<option value='Mardi'>Mardi";
 	print "<option value='Mercredi'>Mercredi";
 	print "<option value='Jeudi'>Jeudi";
 	print "<option value='Vendredi'>Vendredi";
 	print "<option value='Samedi'>Samedi";
 	print "<option value='Dimanche'>Dimanche";
 	print "</option>";

  	print "<input type=hidden name=action value=affiche>";
	print "<br><br><input type=submit></form>	";
}	
if ($action eq "sup"){
	$query="select * from flyhead where fl_vol='$vol' and fl_date>=$today and fl_date<=$today+7*$nbsem order by fl_date";  
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ((@flyhead)=$sth->fetchrow_array)
	{
	 	if (&jour($flyhead[0]) ne $joursem){next;}
		if ($flyhead[9]>0) {next;}

		 &save("delete from flybody where flb_date='$flyhead[0]' and flb_vol='$flyhead[1]'","aff");
		 &save("delete from flyhead where fl_date='$flyhead[0]' and fl_vol='$flyhead[1]'","aff");

	}	
	$action="affiche";
}



if ($action eq "affiche"){
	$query="select * from flyhead where fl_vol='$vol' and fl_date>=$today and fl_date<=$today+7*$nbsem order by fl_date";  
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table>";
	while ((@flyhead)=$sth->fetchrow_array)
	{
	 	if (&jour($flyhead[0]) ne $joursem){next;}
		print "<tr><td>($flyhead[0]) ",&jour($flyhead[0])," ",&julian($flyhead[0])," $flyhead[1]";
		if ($flyhead[9]>0) {print " Deja traité , ne sera pas supprimé";}
		print "</td></tr>";
	}	
	print "</table>";
	print "<form>";
	require ("form_hidden.src");
	print "<input type=hidden name=datejour value='$jour'>";
	print "<input type=hidden name=datemois value='$mois'>";
	print "<input type=hidden name=datean value='$an'>";
	print "<input type=hidden name=nbsem value='$nbsem'>";
	print "<input type=hidden name=vol value='$vol'>";
	print "<input type=hidden name=joursem value='$joursem'>";
	print "<input type=hidden name=action value='sup'>";
	print "<input type=submit value='suppression'>";
	print "</form>";
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
	if ($val <8) {return;}
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
# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine);
	if ($var <8){ # vol regulier
		%semaine=(1,"Lundi",2,"Mardi",3,"Mercredi",4,"Jeudi",5,"Vendredi",6,"Samedi",0,"Dimanche");
	}
	else {
		%semaine=(4,"Lundi",5,"Mardi",6,"Mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	}
	
	return $semaine{$var%7};
}
sub select_date
{
 	$date=`/bin/date +%d';'%m';'%Y`;
  	(@dates)=split(/;/, $date, 3); 
  	$select_jour[$dates[0]]="selected"; 
  	$select_mois[$dates[1]]="selected"; 
  	$firstyear=$dates[2];
  	print "<select name=datejour>"; 
 	for($i=1;$i<=31;$i++) {print "<option value=\"$i\" $select_jour[$i]>$i</option>\n";} 
 	print "</select>"; 
  	@cal=("","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  	print "<select name=datemois>";
 	for($i=1;$i<=12;$i++) { print "<option value=\"$i\" $select_mois[$i]>$cal[$i]</option>\n"; } 
  	print "</select> <select name=datean>"; 
	for($i=$firstyear;$i<=($firstyear+1);$i++) { print "<option value=$i>$i</option> ";} 
 	print "</select>"; 
} 
sub cal_heure {
	my ($var)=@_[0];
	if ($var eq ""){return;}
	if ($var eq "&nbsp;"){return;}
	
	my ($dec)=@_[1];
	$var=$var+$dec;
	if ($var>24){$var-=24;}
	if ($var<0){$var+=24;}
	return(&deci($var));
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

;1
