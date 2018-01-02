print "<title>bascule de stock</title>";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

$action=$html->param("action");
$four=$html->param("four");
$option=$html->param("option");

require "./src/connect.src";

@mini=("120682","121100","120050","120051","120669");
@match=("120920","1225490","1220068","400095","1223076");

if ($action eq ""){
	&table();
}


if ($action eq "ok"){
    $date=`/bin/date +%d/%m/%y`;
    print "le $date<br>";
    $dateenso=`/bin/date +%Y%m%d`;
    $jour=`/bin/date '+%d'`;
    $mois=`/bin/date '+%m'`;
    $an=`/bin/date '+%Y'`;
    chop($jour);
    chop($mois);
    chop($an);
    chop($dateenso);
    chop($date);
    $datejl=nb_jour($jour,$mois,$an);
    print "Date de la bascule:$date<br>";
  
    $query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_type from trolley,lot,produit where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr=pr_cd_pr and pr_type=15";
    $sth=$dbh->prepare($query);
    $sth->execute();
    print "<table border=1 cellspacing=0><caption><h3>Entrée rapide</h3></caption><tr><th>Code produit</th><th>Désignation</th><th>Qte à entrer</th><th>reste</th><th>Check</th></tr>";
    for($i=0;$i<$#mini;$i++){
	$pr_cd_pr=$mini[$i];
	$qte=$html->param("$pr_cd_pr")+0;
	if ($qte==0){ next;}
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$pr_cd_pr");
	$qte*=100;
	$pr_sub=$match[$i];
	&maj_stck();
	$qte/=-100;
	%stock=&stock($pr_cd_pr,'','');
	$pr_stre=$stock{"stock"}+0;  # stock reel entrepot 
	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
	print "<td align=right>";
	&carton($pr_cd_pr,$qte);
	print "</td><td align=right>";
	&carton($pr_cd_pr,$pr_stre);
	print "</td><td><input type=checkbox></tr>";
    }
    print "</table><br><br>";

}


sub table{
	print "<br>";
	print "<form>";
	require ("form_hidden.src");
	print "<table border=1 cellspacing=0><tr><th>code</th><th>Designation</th><th>stock entrepot</th><th>Qte à entrer</th></tr>";
	for($i=0;$i<$#mini;$i++){
	    $pr_cd_pr=$mini[$i];
	    $query="select pr_desi,pr_deg,pr_pdn,pr_ventil from produit where pr_cd_pr=$pr_cd_pr";
	    $sth=$dbh->prepare($query);
	    $sth->execute();
	    ($pr_desi,$pr_deg,$pr_pdn,$pr_ventil)=$sth->fetchrow_array;
	    $pr_sub=$match[$i];
	    $query="select pr_desi,pr_deg,pr_pdn,pr_ventil from produit where pr_cd_pr=$pr_sub";
	    $sth=$dbh->prepare($query);
	    $sth->execute();
	    ($sub_desi,$sub_deg,$sub_pdn,$sub_ventil)=$sth->fetchrow_array;
	    %stock=&stock($pr_cd_pr,"$today","retour");
	    $stockentrepot=$stock{"stock"};	
	    %stocksub=&stock($pr_sub,"$today","retour");
	    $stockentrepotsub=$stocksub{"stock"};	
	    print "<tr><td>$pr_cd_pr<br>$pr_sub</td><td>$pr_ventil $pr_deg $pr_pdn $pr_desi<br>$sub_ventil $sub_deg $sub_pdn $sub_desi</td><td align=right>$stockentrepot<br>$stockentrepotsub</td><td align=center><input type=text name=$pr_cd_pr size=3></td><td>";
	    print "</td></tr>";
	}
	print "</table><br>";
	print "<input type=hidden name=action value=ok><input type=submit value='ok pour la bascule rapide'></form><br><br>";
}	
sub maj_stck {
	$query="select count(*) from enso where es_cd_pr=$pr_cd_pr and es_dt=curdate()+0 and es_type=24";
	my($sth)=$dbh->prepare($query);
	$sth->execute();
	($nb)=$sth->fetchrow_array+0;
	if ($nb>0) { 
		print "<font color=red>$pr_cd_pr $pr_desi une seule bascule de stock autorisé par jour </font><br>";
		return();
	}

	$query="update produit set pr_stre=pr_stre-$qte where pr_cd_pr='$pr_sub';";
# 	print "$query<br>";
 	$sth=$dbh->prepare($query);
 	$sth->execute();

	$query="insert into enso values ('$pr_sub','',curdate()+0,'$qte','0','24')";	
# 	print "$query<br>";
 	$sth=$dbh->prepare($query);
 	$sth->execute();
	
	$query="update produit set pr_stre=pr_stre+$qte where pr_cd_pr='$pr_cd_pr';";
# 	print "$query<br>";
 	$sth=$dbh->prepare($query);
 	$sth->execute();
        $qte=0-$qte;
	$query="insert into enso values ('$pr_cd_pr','',curdate()+0,'$qte','0','24')";	
# 	print "$query<br>";
 	$sth=$dbh->prepare($query);
 	$sth->execute();
}


;1
# -E bascule rapide
