print "<title>Inventaire aerien</title>";
require "./src/connect.src";

$action=$html->param('action');
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
$six=$html->param('six');
$sept=$html->param('sept');

print "<center>";
print "<form> ";
require ("form_hidden.src");

print `date`;

&save("create temporary table inv_tmp (fa_cat int(4),pr_cd_pr int(12),pr_desi varchar(40),pr_stre decimal (8,2),pr_st_vol int(8),pr_casse int(8),pr_refour varchar(12))");
$sth=$dbh->prepare("select pr_cd_pr,pr_desi,pr_refour from produit order by pr_desi");
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_refour)=$sth->fetchrow_array){
#         $actif=&get("select count(*) from trolley,lot where tr_code=lot_nolot and lot_flag=1 and tr_qte>0 and tr_cd_pr='$pr_cd_pr'")+0;
#         if ($actif==0){next;}
	%stock=&stock($pr_cd_pr);
	$pr_stre=$stock{"stock"};
	$pr_st_vol=int($stock{"vol"});
	$pr_casse=int($stock{"casse"});
	$vendu=&get("select sum(ro_qte)/100 from rotation where ro_cd_pr='$pr_cd_pr'")+0;
	if (($vendu==0)&&($pr_stre==0)){next;}
	$actif=&get("select sum(tr_qte) from trolley,lot where tr_code=lot_nolot and tr_cd_pr='$pr_cd_pr' and lot_flag=1")+0;
	if (($actif==0)&&($pr_stre==0)){next;}
    
	$fa_cat=&get("select fa_cat from dfc.famille,dfc.produit_plus where pr_cd_pr='$pr_cd_pr' and pr_famille=fa_id")+0;  
	&save("insert into inv_tmp values ('$fa_cat','$pr_cd_pr','$pr_desi','$pr_stre','$pr_st_vol','$pr_casse','$pr_refour')");
}

print "<table border=1 cellspacing=0>";
print "<tr><td>&nbsp;</td><td>&nbsp;</td>";
print "<th>Dispo</th><th>cond.</th><th>Carton</th><th>Detail</th><th>Magasin</th><th>En l'air</th><th>Casse</th>Total</th></tr>";

$sth=$dbh->prepare("select pr_cd_pr,pr_desi,pr_stre,pr_st_vol,pr_casse  from inv_tmp order by fa_cat,pr_desi,pr_refour");
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_st_vol,$pr_casse,$pr_refour)=$sth->fetchrow_array){
	$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
	$sth2->execute();
	($car_carton,$car_pal)=$sth2->fetchrow_array;
	$total=0;
	print "<tr><td>$pr_cd_pr</td><td>$pr_desi <b>$pr_refour</b></td>";
	$pr_stre+=0;
	print "<td align=right>$pr_stre</td><td align=right>$car_carton</td>";
	$detail=$pr_stre;
	$carton="&nbsp;";
	if ($car_carton!=0){
		$carton=int($pr_stre/$car_carton);
		$detail=$pr_stre%$car_carton;
		if ($car_pal!=0){
			$plat=int($carton/$car_pal);
			$carton=$carton%$car_pal;
		}
	}
	print "<td align=right>$carton</td><td align=right><b>$detail</td>";
	print "<td>&nbsp;</td>";
	print "<td align=right>$pr_st_vol</td>";
	print "<td align=right>$pr_casse</td>";
	print "</tr>";
}

print "</table>";

;1








