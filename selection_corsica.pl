#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);

print $html->header;

$action=$html->param("action");
$four=$html->param("four");
if ($four eq ""){$four=$html->param("fourmanu");}

print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
print "<body link=black>";


require "./src/connect.src";
if ($action eq ""){
	print "<center><h1>Selection de produit corsica</h1><br><br>";
	print "<form>";
  	print "<br>choisir un fournisseur<br><br><select name=four><option value=''></option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from ordre,fournis,produit where pr_cd_pr=ord_cd_pr and pr_four=fo2_cd_fo group by fo2_cd_fo order by fo2_add");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
  	
  	print "</select><br><input type=text name=fourmanu size=4><br><input type=hidden name=action value=go><input type=submit value='envoie'></form>"; 
	

	
}


if (($action eq "go")||($action eq "modif")){
	$query="select nav_nom from navire order by nav_boutique,nav_nom";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($nom)=$sth->fetchrow_array){
		push (@navire,$nom);
	}
	print "<form><table border=1 cellspacing=0><tr><td colspan=2>&nbsp;</td>";
	foreach $nom (@navire) {
		print "<th><font size=-1>";
		for ($i=0;$i<length($nom);$i++){
			$digit=substr($nom,$i,1);
	 		print "$digit<br>";
		}
	}
	print "</font></th>";
	print "</tr>";
	$nbnavire=$#navire+1;
	$query="select pr_cd_pr,pr_desi from produit where pr_four='$four' and ((pr_cd_pr >100000000 and (pr_type=1 or pr_type=5 or pr_type=0)) or (pr_cd_pr <100000000 and (pr_type!=1 and pr_type!=5))) and pr_sup!=1 and pr_sup!=4 and pr_sup!=2 and pr_four!=0 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td>";
	
		foreach $nom (@navire) {
			
			$qte=&get("select nav_qte from navire2 where nav_nom='$nom' and nav_type=0 and nav_cd_pr=$pr_cd_pr")+0;
			if ($action eq "modif"){
				$index=$pr_cd_pr.';'.$nom;
				$qte_new=$html->param($index)+0;
				if ($qte_new==$qte){$next;}
				&save("replace into navire2 values('$nom','$pr_cd_pr',now(),0,'$qte_new')");
				# print "$query<br>";
				$qte=&get("select nav_qte from navire2 where nav_nom='$nom' and nav_type=0 and nav_cd_pr=$pr_cd_pr")+0;
		
			}	 
			print "<td align=right><input type=text name=\"".$pr_cd_pr.";".$nom."\" value=$qte size=4></td>";
		}
		print "</tr>";
	}
	print "</table><br><input type=hidden name=four value=$four><input type=hidden name=action value=modif><input type=submit></form>";
}	

# -E selection des produits corsica