#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;


$navire=$html->param("navire");
$action=$html->param("action");
$option=$html->param("option");
$famille=$html->param("famille");
$four=$html->param("four");
$ca=$html->param("ca");

$sous_famille=$html->param("sous_famille");
while ($sous_famille=~s/_/ /){};
while ($sous_famille=~s/"//){};
while ($famille=~s/"//){};

$mois=$html->param("mois");

if ($famille eq "tout"){$famille="%";}
if ($sous_famille eq "tout"){$sous_famille="%";}
if ($mois eq "tout_06"){$mois="6%";}
if ($mois eq "tout_07"){$mois="7%";}
if ($mois eq "tout_08"){$mois="8%";}

if ($navire eq "tout"){$navire="%";}
if ($four eq ""){$four="%";}

require "./src/connect.src";

print "<title>statistique mensuel</title>";
if ($action eq ""){
	print "<body><center><h1>statistique mensuel</h1><br><form>";
	print "<table border=2 width=70% cellspacing=0><tr><td align=center>";
	print "<br> Choix d'un navire</h1><br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br>Navire<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
  	print "<option SELECTED value=tout>TOUT\n";
    	print "</select><br>\n";
    	$sth = $dbh->prepare("select vdu_mois from vendu_corsica_mois group by vdu_mois");
    	$sth->execute;
   	print "<br>mois <br><select name=mois>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
  	print "<option SELECTED value=tout_06>TOUT 2006\n";
  	print "<option value=tout_07>TOUT 2007\n";
  	print "<option value=tout_08>TOUT 2008\n";
    	print "</select><br>\n";
  
    	$sth = $dbh->prepare("select vdu_famille from vendu_corsica_mois group by vdu_famille");
    	$sth->execute;
   	print "<br>Famille <br><select name=famille>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
  	print "<option SELECTED value=tout>TOUT\n";
    	print "</select><br>\n";
    	$sth = $dbh->prepare("select vdu_sous_famille from vendu_corsica_mois group by vdu_sous_famille");
    	$sth->execute;
   	print "<br>Sous famille<br> <select name=sous_famille>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
   	print "<option SELECTED value=tout >TOUT\n";
	print "</select><br>\n";
	print "Fournisseur<br><input type=text name=four><br>";
	print "Classement par CA ";
	print "<input type=checkbox name=ca>";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=ranking></form>";
    	print "<form>";
    	print "</td></tr></table><br><center><a href=courbe_corsica.pl>Histogramme<br></a><br>";
	print "<table border=2 width=70% cellspacing=0><tr><td align=center>";
    	$sth = $dbh->prepare("select vdu_mois from vendu_corsica_mois group by vdu_mois");
    	$sth->execute;
   	print "<br>mois <br><select name=mois>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
  	print "<option SELECTED value=tout>TOUT\n";
    	print "</select><br>\n";
    	print "<br><br><form><input type=hidden name=action value=recap><input type=submit value=recap></form>";
    	print "<form>";
 	print "</td></tr></table>";
    	print "</body>"; 
}
# pour importation voir maj_vendu_corsica
if ($action eq "visu"){
print "<table border=1 cellspacing=0><tr bgcolor=#009999><th>ranking</th><th>code produit</th><th>designation</th><th>qte vendue</th><th>Ca</th><th>sous_famille</th><th>part</th></tr>";
# demander par giulia le 15/10/07 10095942 kenzo promo ete 2007
# $query="select vdu_cd_pr,vdu_type,vdu_navire,sum(vdu_qte) as qte,floor(sum(vdu_vte)/vdu_qte),vdu_famille,vdu_sous_famille,pr_desi,pr_sup from vendu_corsica_mois,produit where vdu_mois like '$mois' and vdu_navire like '$navire' and vdu_famille like '$famille' and  vdu_sous_famille like '$sous_famille' and pr_four like '$four' and vdu_cd_pr=pr_cd_pr and vdu_cd_pr!=10095942 group by vdu_cd_pr order by qte desc";
 $query="select vdu_cd_pr,vdu_type,vdu_navire,sum(vdu_qte) as qte,sum(vdu_vte),vdu_famille,vdu_sous_famille,pr_desi,pr_sup from vendu_corsica_mois,produit where vdu_mois like '$mois' and vdu_navire like '$navire' and vdu_famille like '$famille' and  vdu_sous_famille like '$sous_famille' and pr_four like '$four' and vdu_cd_pr=pr_cd_pr and vdu_cd_pr!=10095942 group by vdu_cd_pr order by qte desc";

if ($ca eq "on"){
# 	$query="select vdu_cd_pr,vdu_type,vdu_navire,sum(vdu_qte),floor(sum(vdu_vte)/vdu_qte) as qte ,vdu_famille,vdu_sous_famille,pr_desi,pr_sup from vendu_corsica_mois,produit where vdu_mois like '$mois' and vdu_navire like '$navire' and vdu_famille like '$famille' and  vdu_sous_famille like '$sous_famille' and pr_four like '$four' and vdu_cd_pr=pr_cd_pr and vdu_cd_pr!=10095942 group by vdu_cd_pr order by qte desc";
	$query="select vdu_cd_pr,vdu_type,vdu_navire,sum(vdu_qte),sum(vdu_vte) as qte ,vdu_famille,vdu_sous_famille,pr_desi,pr_sup from vendu_corsica_mois,produit where vdu_mois like '$mois' and vdu_navire like '$navire' and vdu_famille like '$famille' and  vdu_sous_famille like '$sous_famille' and pr_four like '$four' and vdu_cd_pr=pr_cd_pr and vdu_cd_pr!=10095942 group by vdu_cd_pr order by qte desc";

}	

#  print $query;
$sth=$dbh->prepare($query);
$sth->execute();
$i=1;
while (($pr_cd_pr,$type,$navire,$qte,$ca,$famille,$sous_famille,$pr_desi,$pr_sup)=$sth->fetchrow_array){
	$color="white";
	if ($sous_famille eq "HOMME"){
		$color="#ff9966";
		$homme+=$qte;
	}
	# $marge=&get("select (nep_prx_vte-nep_prac)/100 from neptune where nep_codebarre='$pr_cd_pr'")*$qte;
	print "<tr bgcolor=$color><td>$i</td></td><td>$pr_cd_pr</td><td>$pr_desi </td><td>$qte</td><td align=right>$ca</td><td>$sous_famille</td>";
	# print "<td>$marge</td>";
	$nb++;
	$vendu+=$qte;
	$vente[$i]=$qte+$vente[$i-1];
	if ($pr_sup==3){print "<td>new</td>"};

	# print "<td>$i $vente[$i]</td>";
	$i++;
	print "</tr>";
}
print "</table>";
$quart=int($nb/4);
print "nombre de reference:$nb<br>";
print "nombre de piece vendus:$vendu<br>";
if ($famille eq "PARFUMS"){
	print "Homme:$homme<br>";
	$femme=$vendu-$homme;
	$pour=int ($femme*100/$vendu);
	print "Femme:$femme $pour%<br>";
}

$pour=int ($vente[$quart]*100/$vendu);
print "nombre de piece vendus par le top 25% des produits :$vente[$quart] $pour%<br>";
}
  
if ($action eq "recap"){
	#####               QUANTITE
	print "<center><h1>$mois</h1><br>";
	print "base prix,vendu neptune<br>";
	$sth = $dbh->prepare("select vdu_navire from vendu_corsica_mois where vdu_mois=$mois group by vdu_navire");
	$sth->execute;
	print "<table border=1 cellspacing=0><caption>quantite</caption><tr bgcolor=#009999><th>&nbsp</th>";
	while ($bateau = $sth->fetchrow_array) {
		push (@navire,$bateau);
		print "<th>$bateau</th>";
	}
	print "<th>Total</th></tr>";
	$sth = $dbh->prepare("select vdu_famille,vdu_sous_famille from vendu_corsica_mois where vdu_mois=$mois group by vdu_famille,vdu_sous_famille order by vdu_famille,vdu_sous_famille");
	$sth->execute;
	while (($famille,$sous_famille) = $sth->fetchrow_array) {
		if (($famille ne $famille_old)&&($famille_old ne "")){
			print "<tr bgcolor=#009999><td><b>$famille_old</td>";
			$total=0;
			foreach (@navire) {
				$val=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille_old' and vdu_mois=$mois group by vdu_famille","af");
				print "<td align=right><b>$val</td>";
				$total+=$val;
			}
			print "<td align=right><b>$total</td></tr>";
		}
		$famille_old=$famille;
		print "<tr><td>$famille $sous_famille</td>";
		$total=0;
		foreach (@navire) {
			$val=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille' and vdu_sous_famille='$sous_famille' and vdu_mois=$mois group by vdu_famille,vdu_sous_famille","af");
			print "<td align=right>$val</td>";
			$total+=$val;
		}
		print "<td align=right><b>$total</td></tr>";
	}
	print "<tr bgcolor=#009999><td><b>$famille_old</td>";
	$total=0;
	foreach (@navire) {
		$val=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille_old' and vdu_mois=$mois group by vdu_famille","af");
		print "<td align=right><b>$val</td>";
		$total+=$val;
	}
	print "<td align=right><b>$total</td></tr>";
	print "</table>";
	
	print "<br><br>";
	
	#####               MARGE

	
	$famille_old="";
	print "<table border=1 cellspacing=0><caption>marge</caption><tr bgcolor=#009999><th>&nbsp</th>";
	foreach (@navire){
		print "<th>$_</th>";
	}
	print "<th>Total</th></tr>";
	$sth = $dbh->prepare("select vdu_famille,vdu_sous_famille from vendu_corsica_mois where vdu_mois=$mois group by vdu_famille,vdu_sous_famille order by vdu_famille,vdu_sous_famille");
	$sth->execute;
	while (($famille,$sous_famille) = $sth->fetchrow_array) {
		if (($famille ne $famille_old)&&($famille_old ne "")){
			print "<tr bgcolor=#009999><td><b>$famille_old</td>";
			$total=0;
			foreach (@navire) {
				$val=int(0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille_old' and vdu_mois=$mois","af"));
				print "<td align=right><b>$val</td>";
				$total+=$val;
			}
			print "<td align=right><b>$total</td></tr>";
		}
		$famille_old=$famille;
		$sous_famille_sql=$sous_famille;
		while($sous_famille_sql=~s/ /_/){};
		print "<tr><td><a href=?action=marge_detail&mois=$mois&famille=\"$famille\"&sous_famille=\"$sous_famille_sql\">$famille $sous_famille</a></td>";
		$total=0;
		foreach (@navire) {
			$val=int(0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille' and vdu_sous_famille='$sous_famille' and vdu_mois=$mois","af"));
			print "<td align=right>$val</td>";
			$total+=$val;
		}
		print "<td align=right><b>$total</td></tr>";
	}
	print "<tr bgcolor=#009999><td><b>$famille_old</td>";
	$total=0;
	foreach (@navire) {
		$val=int(0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille_old' and vdu_mois=$mois ","af"));
		print "<td align=right><b>$val</td>";
		$total+=$val;
	}
	print "<td align=right><b>$total</td></tr>";
	print "<tr><td><b>Total</td>";
	$total=0;
	foreach (@navire) {
		$val=int(0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois where vdu_navire='$_' and vdu_mois=$mois","af"));
		print "<td align=right><b>$val</td>";
		$total+=$val;
		}
	print "<td align=right><b>$total</td></tr>";
	print "</table>";
	#####               FOURNISSEUR QTE
		print "<br><br>";

	print "<table border=1 cellspacing=0><caption>fournisseur parfum piece </caption><tr bgcolor=#009999><th>&nbsp</th>";
	foreach (@navire){
		print "<th>$_</th>";
	}
	print "<th>Total</th></tr>";
	$sth = $dbh->prepare("select pr_four from vendu_corsica_mois,produit where vdu_mois=$mois and vdu_famille='PARFUMS' and vdu_cd_pr=pr_cd_pr and pr_four!=0 group by pr_four");
	$sth->execute;
	while (($four) = $sth->fetchrow_array) {
		$total=0;
		$total_qte_p=0;
		$total_qte_f=0;
		$four_desi=&get("select fo2_add from fournis where fo2_cd_fo='$four'");
		($four_desi)=split(/\*/,$four_desi);
		print "<tr><td>$four_desi</td>";
		foreach (@navire) {
			$qte_total=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_mois=$mois and vdu_famille='PARFUMS'","af");
			if ($qte_total==0){$qte_total=1;}
			$qte_four=0+&get("select sum(vdu_qte) from vendu_corsica_mois,produit where vdu_navire='$_' and vdu_famille='PARFUMS' and vdu_mois=$mois and vdu_cd_pr=pr_cd_pr and pr_four='$four'","af");
			$rap=int($qte_four*10000/$qte_total)/100;
			print "<td align=right>$rap%</td>";
			$total_qte_p+=$qte_total;
			$total_qte_f+=$qte_four;

		}
		if ($total_qte_p==0){$total_qte_p=1;}
		$rap=int($total_qte_f*10000/$total_qte_p)/100;
		print "<td align=right><b>$rap%</td></tr>";

		print "</tr>";
	}

	print "</table>";
		
	#####               FOURNISSEUR MARGE
	print "<br><br>";

	print "<table border=1 cellspacing=0><caption>fournisseur parfum marge </caption><tr bgcolor=#009999><th>&nbsp</th>";
	foreach (@navire){
		print "<th>$_</th>";
	}
	print "<th>Total</th></tr>";
	$sth = $dbh->prepare("select pr_four from vendu_corsica_mois,produit where vdu_mois=$mois and vdu_famille='PARFUMS' and vdu_cd_pr=pr_cd_pr and pr_four!=0 group by pr_four");
	$sth->execute;
	while (($four) = $sth->fetchrow_array) {
		$total=0;
		$total_qte_p=0;
		$total_qte_f=0;
		$four_desi=&get("select fo2_add from fournis where fo2_cd_fo='$four'");
		($four_desi)=split(/\*/,$four_desi);
		print "<tr><td>$four_desi</td>";
		foreach (@navire) {
			$qte_total=0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois where vdu_navire='$_' and vdu_mois=$mois and vdu_famille='PARFUMS'","af");
			if ($qte_total==0){$qte_total=1;}
			$qte_four=0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois,produit where vdu_navire='$_' and vdu_famille='PARFUMS' and vdu_mois=$mois and vdu_cd_pr=pr_cd_pr and pr_four='$four'","af");
			$rap=int($qte_four*10000/$qte_total)/100;
			print "<td align=right>$rap%</td>";
			$total_qte_p+=$qte_total;
			$total_qte_f+=$qte_four;

		}
		if ($total_qte_p==0){$total_qte_p=1;}
		$rap=int($total_qte_f*10000/$total_qte_p)/100;
		print "<td align=right><b>$rap%</td></tr>";

		print "</tr>";
	}

	print "</table>";

	#####               DIVERS
	print "<br><br>";
	
	$famille_old="";
	print "<table border=1 cellspacing=0><caption>divers</caption><tr bgcolor=#009999><th>&nbsp</th>";
	foreach (@navire){
		print "<th>$_</th>";
	}
	print "<th>Total</th></tr>";
	$sth = $dbh->prepare("select vdu_famille from vendu_corsica_mois where vdu_mois=$mois group by vdu_famille order by vdu_famille");
	$sth->execute;
	while (($famille) = $sth->fetchrow_array) {
		$total=0;
		print "<tr><td>Vente equipage $famille</td>";
		foreach (@navire) {
			$equipage=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille' and vdu_mois=$mois and vdu_type!=\"PUBLIC\"","af");
			$totalite=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille' and vdu_mois=$mois","af");
			if ($totalite==0){$totalite=1;}
			$rap=int($equipage*10000/$totalite)/100;
			
			print "<td align=right>($equipage) $rap%</td>";
			$total+=$equipage;
		}
		print "<td align=right><b>$total</td></tr>";
	}
	$sth = $dbh->prepare("select vdu_famille from vendu_corsica_mois where vdu_mois=$mois group by vdu_famille order by vdu_famille");
	$sth->execute;
	while (($famille) = $sth->fetchrow_array) {
		$total=0;
		$total_ca=0;
		$total_fa=0;
		print "<tr><td>Marge $famille</td>";
		foreach (@navire) {
			$ca_famille=0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='$famille' and vdu_mois=$mois","af");
			$ca_total=0+&get("select sum(vdu_vte-vdu_prac) from vendu_corsica_mois where vdu_navire='$_' and vdu_mois=$mois","af");
			if ($ca_total==0){$ca_total=1;}
			$rap=int($ca_famille*10000/$ca_total)/100;
			
			print "<td align=right>$rap%</td>";
			$total_fa+=$ca_famille;
			$total_ca+=$ca_total;
		
		}
		if ($total_ca==0){$total_ca=1;}
		$rap=int($total_fa*10000/$total_ca)/100;
		print "<td align=right><b>$rap%</td></tr>";
	}
	print "<tr><td>Parfum homme</td>";
	foreach (@navire) {
		$ca_homme=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='PARFUMS' and vdu_sous_famille='HOMME' and vdu_mois=$mois","af");
		$ca_parfum=0+&get("select sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_famille='PARFUMS' and vdu_mois=$mois","af");
		if ($ca_parfum==0){$ca_parfum=1;}
		$rap=int($ca_homme*10000/$ca_parfum)/100;
		
		print "<td align=right>$rap%</td>";
	}
	print "</tr>";
	print "</table>";
	

}
if ($action eq "marge_detail"){
	#####               MARGE
	$sth = $dbh->prepare("select vdu_navire from vendu_corsica_mois where vdu_mois=$mois and vdu_famille='$famille' and vdu_sous_famille='$sous_famille' group by vdu_navire");
	$sth->execute;
	print "<table border=1 cellspacing=0><caption>marge detail</caption><tr bgcolor=#009999><th rowspan=2>&nbsp</th><th rowspan=2>achat</th><th rowspan=2>prix (moy)</th><th rowspan=2>qte</th><th rowspan=2>marge brut</th>";
	while ($bateau = $sth->fetchrow_array) {
		push (@navire,$bateau);
		print "<th colspan=2>$bateau</th>";
	}
	print "</tr><tr bgcolor=#009999>";
	foreach (@navire){
		print "<th>qte</th><th>marge</th>";
	}
	print "</tr>";

	$query="select vdu_cd_pr,pr_desi,sum(vdu_prac),sum(vdu_vte),sum(vdu_qte) from vendu_corsica_mois,produit where vdu_cd_pr=pr_cd_pr and vdu_mois=$mois and vdu_famille='$famille' and vdu_sous_famille='$sous_famille' group by vdu_cd_pr order by vdu_cd_pr";
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($vdu_cd_pr,$pr_desi,$sum_prac,$sum_vte,$sum_qte) = $sth->fetchrow_array) {
		print "<tr><td>$vdu_cd_pr $pr_desi</td>";
		$prac=0;
		$pvte=0;
		if ($sum_qte!=0){
			$prac=int($sum_prac*100/$sum_qte)/100;
			$pvte=int($sum_vte*100/$sum_qte)/100;
		}
		$marge=$sum_vte-$sum_prac;
		print "<td align=left>$prac</td>";
		print "<td align=left>$pvte</td>";
		print "<td align=left>$sum_qte</td>";
		print "<td align=left>$marge</td>";
		$marge_cu+=$marge;
		$total=0;
		foreach (@navire) {
			$query="select sum(vdu_prac),sum(vdu_vte),sum(vdu_qte) from vendu_corsica_mois where vdu_navire='$_' and vdu_cd_pr='$vdu_cd_pr' and vdu_mois=$mois";
			$sth2 = $dbh->prepare($query);
			$sth2->execute;
			($sum_prac,$sum_vte,$sum_qte) = $sth2->fetchrow_array;
			$marge=$sum_vte-$sum_prac;
			print "<td align=right>$sum_qte</td><td align=right>$marge</td>";
			$total+=$val;
		}
		print "</tr>";
	}
	print "<tr><td><b>Total</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=left><b>$marge_cu</b></td></tr>";
	print "</table>";
}
        