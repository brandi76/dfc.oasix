

print "<form>";
require ("form_hidden.src");
print "<center> produit <input type=text name=pr_cd_pr><input type=submit></form><center>";

$pr_cd_pr=$html->param("pr_cd_pr");
if ($pr_cd_pr ne ""){
	&save("create temporary table mvt_tmp (pr_cd_pr bigint(20) NOT NULL,ref int(11) NOT NULL,date date NOT NULL,sortie int(11) NOT NULL,entree int(11),type int(11) NOT NULL )");

	$query="select * from enso where es_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array)
	{
		if ($es_dt > 20000000){$es_dt=substr($es_dt,2,6);}
		$es_qte/=100;
		$es_qte_en/=100;
		
		&save("insert into mvt_tmp value ('$es_cd_pr','$es_no_do','$es_dt','$es_qte','$es_qte_en','$es_type')");
	}
	$stock_depart=&get("select pr_stanc/100 from produit where pr_cd_pr='$pr_cd_pr'")+0;
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
	print "<div class=titre>$pr_cd_pr $pr_desi</div>";
	print "Stock depart:$stock_depart<br>";
	# %stock=&stock($pr_cd_pr,"","","debug");
	$query="select erdep_depart,erdep_qte from errdep where erdep_cd_pr='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($erdep_depart,$erdep_qte)=$sth->fetchrow_array){
	    if ($erdep_depart>20000000){
			$liv_date=$erdep_depart;
			# $liv_date2=substr($liv_date,0,4)."-",substr($liv_date,4,2)."-",substr($liv_date,6,2);
			# print "*** $liv_date2****";
		 }
		else {
			$liv_date=&get("select liv_date from listevol where liv_dep='$erdep_depart'");
			if ($liv_date!=0){
				$liv_date=&julian($liv_date,"YYYY/mm/DD");
				$liv_date=~s/\//-/g;
			}	
		}
		&save("insert into mvt_tmp values ('$pr_cd_pr','$erdep_depart','$liv_date','0','$erdep_qte','2')","af");	
	}
	
	&save("insert into mvt_tmp select so_cd_pr,so_appro,aj_date-1000000,so_qte/100,0,3 from sortie,apjour where so_cd_pr='$pr_cd_pr' and so_appro=aj_code");	
	&save("insert into mvt_tmp select ret_cd_pr,ret_code,infr_date,ret_retour,0,4 from retoursql,non_sai,inforetsql where ns_code=ret_code and ns_code=infr_code and ret_cd_pr='$pr_cd_pr'");	
	$stock=$stock_depart;
	print "<center><table border=1 cellspacing=0><tr><th>Date</th><th>Ref</th><th>Sortie</th><th>Entree</th><th>Type</th><th>Stock</th></tr>";
	$query="select * from mvt_tmp where pr_cd_pr='$pr_cd_pr' order by date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array)
	{
		$stock=$stock+$es_qte_en-$es_qte;
		if ($es_type eq "1"){$es_type="Vente a bord";}
		if ($es_type eq "2"){$es_type="Ecart";}
		if ($es_type eq "3"){$es_type="Bon en l'air";}
		if ($es_type eq "4"){$es_type="Bon retour en attente saiappauto";}
		if ($es_type eq "10"){$es_type="Entree";}
		if ($es_type eq "5"){$es_type="Vendu";}
		print "<tr><td>$es_dt</td><td>$es_no_do</td><td align=right>$es_qte</td><td  align=right>$es_qte_en</td><td>$es_type</td><td>$stock</td></tr>";
	}	
	print "</table></center>";
	%stock=&stock($pr_cd_pr,"","","debu");
	print "<strong>Stock entrepot:$stock{'stock'}</strong>";
}
;1