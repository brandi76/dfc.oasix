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
print "<table border=1 cellspacing=0>";
print "<tr><td>&nbsp;</td><td>&nbsp;</td>";
print "<th>Dispo</th><th>cond.</th><th>plat</th><th>Carton</th><th>Detail</th><th>Check</th></tr>";
&table(0,9999);
# &table(180,1000);
# &table(0,80);

#print "</table>";
#print "<div id=saut>.</div>";
#print "<table border=1 cellspacing=0>";
#print "<tr><td>&nbsp;</td><td>&nbsp;</td>";
#print "<th>Dispo</th><th>cond.</th><th>plat</th><th>Carton</th><th>Detail</th><th>Check</th></tr>";
#&table(80,180);
#&table(2101,9999);
print "</table>";


sub table{
	$premier=$_[0];
	$dernier=$_[1];
	$sth=$dbh->prepare("select distinct ord_cd_pr,pr_desi,pr_codebarre from ordre,produit,trolley,lot where ord_cd_pr=pr_cd_pr and ord_cd_pr=tr_cd_pr and tr_code=lot_nolot and lot_flag=1 and tr_qte>-1  and ord_ordre>=$premier and ord_ordre<$dernier order by ord_ordre");
	$sth=$dbh->prepare("select distinct pr_cd_pr,pr_desi,pr_codebarre from produit,ordre where pr_cd_pr=ord_cd_pr order by ord_ordre");

	$sth->execute();
	
	while (($pr_cd_pr,$pr_desi,$pr_codebarre)=$sth->fetchrow_array){
		$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
		$sth2->execute();
		($car_carton,$car_pal)=$sth2->fetchrow_array;
	
		%stock=&stock($pr_cd_pr);
		$pr_stre=$stock{"stock"};
		if ($six>0) {
			$pr_stre=$pr_stre - ($six*(&get("select tr_qte from trolley where tr_code=6 and tr_cd_pr='$pr_cd_pr'")+0)/100);
		}
		if ($sept>0) {
			$pr_stre=$pr_stre - ($sept*(&get("select tr_qte from trolley where tr_code=7 and tr_cd_pr='$pr_cd_pr'")+0)/100);
		}
		
		# print "$today $pr_cd_pr $pr_stre<br>";
		$total=0;
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
		$pr_stre+=0;
		print "<td align=right>$pr_stre</td><td align=right>$car_carton</td>";
		$detail=$pr_stre;
		$plat=$carton="&nbsp;";
		if ($car_carton!=0){
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
	$sth=$dbh->prepare("select pr_cd_pr,pr_desi,pr_codebarre from produit where pr_cd_pr not in (select ord_cd_pr from ordre)");

	$sth->execute();
	
	while (($pr_cd_pr,$pr_desi,$pr_codebarre)=$sth->fetchrow_array){
		$sth2=$dbh->prepare("select car_carton,car_pal from carton where car_cd_pr='$pr_cd_pr'");
		$sth2->execute();
		($car_carton,$car_pal)=$sth2->fetchrow_array;
	
		%stock=&stock($pr_cd_pr);
		$pr_stre=$stock{"stock"};
		if ($six>0) {
			$pr_stre=$pr_stre - ($six*(&get("select tr_qte from trolley where tr_code=6 and tr_cd_pr='$pr_cd_pr'")+0)/100);
		}
		if ($sept>0) {
			$pr_stre=$pr_stre - ($sept*(&get("select tr_qte from trolley where tr_code=7 and tr_cd_pr='$pr_cd_pr'")+0)/100);
		}
		
		# print "$today $pr_cd_pr $pr_stre<br>";
		$total=0;
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
		$pr_stre+=0;
		print "<td align=right>$pr_stre</td><td align=right>$car_carton</td>";
		$detail=$pr_stre;
		$plat=$carton="&nbsp;";
		if ($car_carton!=0){
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
;1








