$marque=$html->param("marque");
$libelle=$html->param("libelle");

print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
print "<thead>";
print "<tr class=\"success\"><th>Marque</th><th colspan=2>Produit</th><th>Prix corsica</th><th>Prix Sephora</th><th>Ecart</th></tr>";
print "</thead>";
	
$query="select marque,pr_cd_pr,pr_desi,pr_prx_vte,pr_acquit from corsica.produit,corsica.produit_desi where pr_cd_pr=code and  pr_acquit>100 order by marque,pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($marque,$pr_cd_pr,$pr_desi,$pr_prx_vte,$pr_acquit)=$sth->fetchrow_array){
	print "<tr><td>$marque</td><td>$pr_cd_pr</td><td>$pr_desi</td><td  align=right>$pr_prx_vte";
	$prix=&get("select prix from sephora_ref where ref='$pr_acquit'");
	$ecart=0;
	$ecart=($pr_prx_vte-$prix)*100/$prix if $prix!=0;
	$color="";
	$color="red" if $ecart>0;
	print "<td align=right>$prix</td><td align=right style=color:$color>";
	$nb++;
	printf("%.2f %",$ecart);
	printf "</td></tr>";
}
print "</table>";
print "Nb de produit:$nb";
print "</div></div></div>";
