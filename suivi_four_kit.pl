require "./src/connect.src";
$action=$html->param("action");
if ($action eq "go") {
	$query="select distinct pr_four from produit,navire2 where nav_nom='MEGA 2' and nav_type=0 and (pr_sup=0 or pr_sup=3) and (pr_type=1 or pr_type=5) and nav_cd_pr=pr_cd_pr order by pr_four";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_four)=$sth->fetchrow_array){
		$fo2_livraison=&get("select fo2_livraison from fournis where fo2_cd_fo=$pr_four");
	        $new_info=$html->param("$pr_four");
	        # print "*$new_info*";
	        if ($new_info ne $fo2_livraison){
	        	while ($new_info=~s/\'//){};
	        	&save("update fournis set fo2_livraison='$new_info',fo2_identification=now() where fo2_cd_fo='$pr_four'","ff");
	        }
	}
}	

$query="select distinct pr_four from produit,navire2 where nav_nom='MEGA 2' and nav_type=0 and (pr_sup=0 or pr_sup=3) and (pr_type=1 or pr_type=5) and nav_cd_pr=pr_cd_pr order by pr_four";
$sth=$dbh->prepare($query);
$sth->execute();
print "<form>";
require ("form_hidden.src");

print "<table border=1 cellspacing=0><tr><th>fournisseur</th><th>Info</th><th>date de Commande</th><th>% manquant</th></tr>";
while (($pr_four)=$sth->fetchrow_array){
	print "<tr><td><div class=petit>$pr_four ";
	$query="select fo2_add,fo2_livraison,fo2_identification from fournis where fo2_cd_fo=$pr_four";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($fo_nom,$fo2_livraison,$fo2_identification)=$sth2->fetchrow_array;
	($fo_nom)=split(/\*/,$fo_nom);
	$date_cde=&get("select max(com2_date) from commande where com2_cd_fo='$pr_four'")+0;
	$date_cde=substr($date_cde,2,6);
	print "$fo_nom</div></td><td><input type=text size=30 name=$pr_four value='$fo2_livraison'><div class=trespetit>($fo2_identification)</div></td><td>$date_cde</td>";
	$manquant=&get("select count(*) from produit,navire2 where nav_nom='MEGA 2' and nav_type=0 and (pr_sup=0 or pr_sup=3) and (pr_type=1 or pr_type=5) and nav_cd_pr=pr_cd_pr and pr_four=$pr_four and pr_stre<2000");
       	$ref=&get("select count(*) from produit,navire2 where nav_nom='MEGA 2' and nav_type=0 and (pr_sup=0 or pr_sup=3) and (pr_type=1 or pr_type=5) and nav_cd_pr=pr_cd_pr and pr_four=$pr_four");
        $pour=int($manquant*100/$ref);
        print "<td>$pour%</td></tr>";
	print "</tr>"; 
}
print "</table>";
print "<input type=hidden name=action value=go>";
print "<input type=submit value=Modification></form>";
;1