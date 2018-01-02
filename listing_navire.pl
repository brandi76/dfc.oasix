#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$today=&nb_jour($jour,$mois,$an);

print $html->header;


print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "<body link=black>";


require "./src/connect.src";

$query="select nav_nom from navire order by nav_boutique,nav_nom";
$sth=$dbh->prepare($query);
$sth->execute();
while (($nom)=$sth->fetchrow_array){
	push (@navire,$nom);
}

print "<table border=1 cellspacing=0><tr><td colspan=2>&nbsp;</td>";
foreach $nom (@navire) {
	print "<th><font size=-1>";
	for ($i=0;$i<length($nom);$i++){
		$digit=substr($nom,$i,1);
	 	print "$digit<br>";
	}
	print "</font></th>";
}
print "</tr>";
$nbnavire=$#navire+1;
print "<tr><th>Code dieppe/ Code barre</th><th>Désignation</th><th colspan=$nbnavire>stock mini</th><th>Code neptune</th><th>Particularité</th><th>Stock</th><th>En cde</th></tr>";

$query="select nav_cd_pr from navire2 where nav_type=0 group by nav_cd_pr order by nav_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr)=$sth->fetchrow_array){
	$query="select pr_desi,pr_sup from produit where pr_cd_pr='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($pr_desi,$pr_sup)=$sth2->fetchrow_array;

	$query="select nep_cd_pr from neptune where nep_codebarre='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($nep_cd_pr)=$sth2->fetchrow_array;
	print "<td>$pr_cd_pr</td><td>$pr_desi</td>";
	foreach (@navire) {
		$query="select nav_qte from navire2 where nav_nom='$_' and nav_type=0 and nav_cd_pr='$pr_cd_pr'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($qte)=$sth2->fetchrow_array+0;
		if ($qte==0){$qte="<font color=red size=+1>X</font>";}
		print "<td align=right>$qte</td>";
	}	
	if ($nep_cd_pr eq ""){$nep_cd_pr="<font color=red size=+1>X</font>";}
	print "<td align=right>$nep_cd_pr</td>";
	$part="&nbsp;";
	$query="select count(*) from trolley,produit where tr_cd_pr=pr_cd_pr and tr_code=100 and pr_codebarre='$pr_cd_pr'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($nb)=$sth2->fetchrow_array;
	if ($nb >0){$part="catalogue aérien";}
	if ($pr_sup==1){$part.="supprimé";}
	if ($pr_sup==2){$part.="délisté du listing avion";}
	if ($pr_sup==3){$part.=" new";}
	if ($pr_sup==4){$part.="<font color=red>hors catalogue destockage</font>";}
	if ($pr_sup==5){$part.="suivi paul";}
	if ($pr_sup==6){$part.="délisté paul";}

	print "<td>$part</td>";
	%stock=&stock($pr_cd_pr,'','quick');
	$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot + enlair
	if ($pr_sup==4){	
		# recherche si un produit avec le meme code barre existe dans les references 6 chioffres
		$query="select pr_cd_pr from produit where pr_codebarre=$pr_cd_pr and pr_cd_pr<1000000";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$prodavion=$sth2->fetchrow_array;
		if ($prodavion ne ""){
			# pour les produit navire qui ont une coorespondance avec un code avion on ajoute le stock avion
			%stock=&stock($prodavion,'','quick');
			$pr_stre+=$stock{"pr_stre"};
		}
	}
	print "<td align=right>$pr_stre</td>";
	$query="select floor(sum(com2_qte)/100) from commande where com2_cd_pr=$pr_cd_pr";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($qte_commande)=$sth2->fetchrow_array+0;
	print "<td align=right>$qte_commande</td>";
		
	print "</tr>";
}
print "</table>fin";
	