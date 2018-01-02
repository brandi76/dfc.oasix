require "./src/connect.src";
print "<title>Pas touché</title>";
$action=$html->param("action");
$retour=$html->param("retour");
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
$today=&nb_jour($jour,$mois,$an);

if ($action eq "reintegration"){
	$query="select gsl_nolot from geslot where gsl_ind=10 order by gsl_troltype";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while ($gsl_nolot=$sth->fetchrow_array){
		if ($html->param("$gsl_nolot") eq "on") { 
			$appro=&get("select gsl_apcode from geslot where gsl_nolot='$gsl_nolot'");
			&save("update geslot set gsl_ind=0,gsl_pb1=0,gsl_pb2=0,gsl_pb3=0,gsl_pb4=0,gsl_pb5=0,gsl_pb6=0,gsl_pb7=0 where gsl_nolot='$gsl_nolot'","af");
			if ($retour eq "on") {
			   	&save("update retjour set rj_date=$today where rj_appro=$appro","af");
			}
		}
	}
}

print "<center>";
print "<form>";
require ("form_hidden.src");
print "<br><table border=1 cellspacing=0><tr bgcolor=#5580ab><th>No de lot</th><th>Désignation</th><th>Appro</th><th>Type de lot</th><th>&nbsp;</th></tr>";
$query="select gsl_nolot,gsl_apcode,gsl_desi,gsl_troltype,gsl_ind from geslot where (gsl_ind=10 or gsl_ind=11 )order by gsl_troltype";
$sth=$dbh->prepare($query);
$sth->execute();
# print "$query<br>";


while (($gsl_nolot,$gsl_apcode,$gsl_desi,$gsl_troltype,$gsl_ind)=$sth->fetchrow_array){
	$lot_desi=&get("select lot_desi from lot where lot_nolot=$gsl_troltype");
	if ($gsl_ind==11){
		$depart=&get ("select max(liv_dep) from listevol where liv_nolot='$gsl_nolot'");
		print "<tr bgcolor=#efefef><td>$gsl_nolot</td><td>$gsl_desi $lot_desi</td><td>$gsl_apcode</td><td>$gsl_troltype</td><td>En cours d'affectation<br>depart $depart</td></tr>";
	}
	else  {
		if ($gsl_apcode eq ""){$gsl_apcode="<font color=red>Erreur</font>";}
		print "<tr><td>$gsl_nolot</td><td>$gsl_desi $lot_desi</td><td>$gsl_apcode</td><td>$gsl_troltype</td><td><input type=checkbox name=$gsl_nolot></td></tr>";
        }
}
print "</table>";
print "<br> Pour la selection : <input type=submit name=action value=reintegration> inclure la marchandise dans le retour <input type=checkbox name=retour>";
print "</form>";