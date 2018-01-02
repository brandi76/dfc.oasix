print "<title>bascule de stock</title>";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

$action=$html->param("action");
$four=$html->param("four");
$option=$html->param("option");

require "./src/connect.src";

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
#     $save("update atadsql set dt_no=dt_no+1 where dt_cd_dt=207");
    $query="select dt_no from atadsql where dt_cd_dt=207";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    ($no)=$sth2->fetchrow_array;
    print "Date d'entree:$date<br>";
    print "Numero d'entree:$no<br>";
#     &save("replace into enthead values ('$no','$datejl','$scelle','$provenance','$document','$lieu')");
  
    $query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_type from trolley,lot,produit where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr=pr_cd_pr and (pr_type!=1 and pr_type!=5 and pr_type!=4 and pr_type!=2 and pr_type!=15)";
    $sth=$dbh->prepare($query);
    $sth->execute();
    print "<table border=1 cellspacing=0><caption><h3>Entrée rapide</h3></caption><tr><th>Code produit</th><th>Désignation</th><th>Qte à entrer</th><th>reste</th><th>Check</th></tr>";
    while (($pr_cd_pr,$pr_sup,$pr_desi,$pr_type)=$sth->fetchrow_array)
    {
	$qte=$html->param("$pr_cd_pr")+0;
	if ($qte==0){ next;}
	%stock=&stock($pr_cd_pr,'','');
	$pr_stre=$stock{"stock"}+0;  # stock reel entrepot 
	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
	print "<td align=right>";
	&carton($pr_cd_pr,$qte);
	print "</td><td align=right>";
	$pr_stre+=$qte;
	&carton($pr_cd_pr,$pr_stre);
	print "</td><td><input type=checkbox></tr>";
	$qte*=100;
 	&save("replace into enso values ('$pr_cd_pr','$no','$dateenso','0','$qte','10')");
 	&save("update produit set pr_stre=pr_stre+$qte where pr_cd_pr='$pr_cd_pr'");
 	&save("replace into entbody values ('$no','$pr_cd_pr','$qte')");
    }
    print "</table><br><br>";

}


sub table{
	print "<br>";
	print "<form>";
	require ("form_hidden.src");
	print "<table border=1 cellspacing=0><tr><th>code</th><th>Designation</th><th>stock entrepot</th><th>Qte à entrer</th></tr>";
	$query="select distinct pr_cd_pr,pr_sup,pr_desi,pr_type from trolley,lot,produit where tr_code=lot_nolot and lot_flag=1 and tr_cd_pr=pr_cd_pr and (pr_type!=1 and pr_type!=5 and pr_type!=4 and pr_type!=2 and pr_type!=15)";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_sup,$pr_desi,$pr_type)=$sth->fetchrow_array)
	{
#   		print "$pr_cd_pr<br>";
		%stock=&stock($pr_cd_pr,"$today","retour");
		$stockentrepot=$stock{"stock"};	
		print "<tr><td>$pr_cd_pr</td><td>$pr_type $pr_desi</td><td align=right>$stockentrepot</td><td align=center><input type=text name=$pr_cd_pr size=3></td><td>";
		print "</td></tr>";
	}
	print "</table><br>";
	print "<input type=hidden name=action value=ok><input type=submit value='ok pour l entrée'></form><br><br>";
	

}	
;1
# -E entrée rapide
