print "<title>trace ecart</title>";

require "./src/connect.src";

print "<table border=1 cellspacing=0><tr><th>Date</th><th>Type</th><th>Produit</th><th>Designation</th><th>qte</th><th>Nom</th><th>Justificatif</th></tr>";
$produit=$html->param("produit");
if ($produit eq ""){$produit="tjo_cd_pr";}
print "<form>";
require ("form_hidden.src");
print "<input type=text name=produit><input type=submit></form><br>";
$query="select * from trace_jour where tjo_cd_pr=$produit order by tjo_date desc";
$sth=$dbh->prepare($query);
$sth->execute();
while (($tjo_date,$tjo_type,$tjo_cd_pr,$tjo_qte,$tjo_nom,$tjo_justificatif,$tjo_depart)=$sth->fetchrow_array)
{
	if (($tjo_type==9) && (&get("select count(*) from errdep where erdep_cd_pr='$tjo_cd_pr' and erdep_depart='$tjo_depart'","af")==0)){next;}
	$tjo_qte/=100;
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$tjo_cd_pr'");
	if ($tjo_type==5){$tjo_type="casse";}
	if ($tjo_type==9){$tjo_type="ecart";}
	print "<tr><td>$tjo_date</td><td>$tjo_type</td><td>$tjo_cd_pr</td><td>$pr_desi</td><td>$tjo_qte</td><td>$tjo_nom</td><td>$tjo_justificatif</td>";
	print "</tr>";
	if ($i++==50){last;}
}
print "</table>";
;1
