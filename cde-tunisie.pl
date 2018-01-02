#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";


print $html->header;
$action=$html->param("action");
$nv=$html->param("nv");
$p=$html->param("p");
$trolley=$html->param("trolley");

if ($action eq "go"){
	
	print "<b>Taux de vente</b><br>Total des produits vendus divisé par le total des produits mis à bord<br>";
	print "Periode 1 janvier à aujourd'hui<br>";
	print "Compagnie: tous les clients<br>";
	print "Critere: caisse différente de zéro<br>";

	print "<b>Consommation</b><br>Total des produits vendus pendant le délai de livraison<br>";

	  
require "./src/connect.src";
$query="select tr_cd_pr,tr_qte from trolley where tr_code=$trolley";
$sth=$dbh->prepare($query);
$sth->execute();
while (($tr_cd_pr,$tr_qte)=$sth->fetchrow_array){
	push @ordre,"$tr_cd_pr;$tr_qte";
	}
print "<table border=1 cellspacing=0 cellpadding=0><caption align=center><font size=+3>$trolley</caption><tr><th>Produit</th><th>Fournisseur</th><th>Dotation</th><th>Delai</th><th>Taux de vente</th><th>Consommation</th><th>Pic</th><th>Cde</th></tr>";
foreach (@ordre){
	($tr_cd_pr,$tr_qte)=split(/;/,$_);
	$query="select pr_desi,pr_four from produit where pr_cd_pr=$tr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_desi,$pr_four)=$sth->fetchrow_array;
	print "<tr><td>$tr_cd_pr $pr_desi</td><td>$pr_four ";
	$query="select fo2_add,fo2_delai from fournis where fo2_cd_fo=$pr_four";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo2_add,$fo2_delai)=$sth->fetchrow_array;
	($nom)=split(/\*/,$fo2_add);
	print "$nom</td><td align=right>",$tr_qte/100,"</td><td align=right>$fo2_delai</td>";
	$query="select sum(ap_qte0) from appro,inforet where ap_cd_pr=$tr_cd_pr and ap_code=infr_code and infr_caisseth>0 and ap_code>'15000'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$ap_qte0=$sth->fetchrow_array;
	$query="select sum(ro_qte) from rotation,inforet where ro_cd_pr=$tr_cd_pr and ro_code=infr_code and infr_caisseth>0 and ro_code>'15000'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$ro_qte=$sth->fetchrow_array;
	if ($ap_qte0==0){$ap_qte0=1;}
	$vv=int($ro_qte*100/$ap_qte0);
	print "<td align=right>$vv%</td>";
	$dl=$fo2_delai/7;
	$d=$tr_qte/100;	
	$consommation=int($nv*$d*$vv*$dl/100);
	print "<td align=right>$consommation</td>";
	$pic=int($p*$d);
	print "<td align=right>$pic</td>";
	print "<td align=right>",$consommation+$pic,"</td>";
	print "</tr>";
}
print "</table><br><br>";
}
	print "
	<form>
	Trolley type:<input type=text name=trolley value=$trolley><br>
	Nombre de vol en l'air:<input type=text name=p value=$p><br>
	Nombre de vol par semaine:<input type=text name=nv value=$nv><br>
	<input type=submit value=go>
	<input type=hidden name=action value=go>
	</form>
	";
	
	
# -E Liste des commandes pour la tunisie