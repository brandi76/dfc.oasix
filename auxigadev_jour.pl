#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl.lib";

$html=new CGI;
print $html->header;

print "<html><body>";


require "./src/connect.src";
&detail();

sub detail {
	$query="select pr_cd_nat,pr_cd_prod,pr_desi,(pr_stre+pr_prusd)/100,pr_prx_rev/100 from produit where pr_prx_rev>0 and pr_prx_rev<99999999 and (pr_stre+pr_prusd)>0 and (pr_stre+pr_prusd)<99999999  order by pr_cd_prod";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$totalgen=0;
	print " <h3>Société Bis France </h3><br><br>stock au ";
	print `date`;
	print $query;

	print "<br><table><tr><th>Code</th><th>produit</th><th>qte</th><th>prix</th><th>total</th></tr>";
	while (($pr_cd_nat,$pr_cd_pr,$pr_desi,$stock,$prix)= $sth->fetchrow_array) {
		$total=$prix*$stock;
		$totalgen+=$total;
	       	print "<tr><td>$pr_cd_nat</td><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stock</td><td align=right>$prix</td><td align=right>";
	       	print &deci2($total,2,0);
		print "</td></tr>";
	}
	print "<tr><th>total</th><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=right>";
	print &deci2($totalgen,2,0);
	print "</td></tr></table>";
}


sub journal {
	print "<center><h1>FICHE SOLDE DU STOCK</h1><br><br>";
	print "Veuillez trouver ci-joint la fiche solde du stock du jour<br>";

	$query="select dt_no from atad where dt_cd_dt=500";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$ref=$sth->fetchrow_array;
	$query="select dt_no from atad where dt_cd_dt=501";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$stock=$sth->fetchrow_array;

	$query="select sum(facd_qte*pr_prx_rev)/10000 from facdata,produit where facd_no>'$ref' and facd_cd_pr%1000000=pr_cd_prod and pr_cd_nat<7";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$sortie=int($sth->fetchrow_array);
	
	$query="select sum((pr_stre+pr_prusd)/100*pr_prx_rev/100) from produit where pr_prx_rev>0 and pr_prx_rev<99999999 and (pr_stre+pr_prusd)>0 and (pr_stre+pr_prusd)<99999999 and pr_cd_nat<100 order by pr_cd_prod";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$newstock=int($sth->fetchrow_array);
	$entree=$newstock-$stock+$sortie;
	print "édition du ";
	print `date`;
	print "<br><br><br><table border=1><tr><td>Solde en debut de journée</td><td align=right>$stock</td></tr>";
	print "<tr><td>montant des entrees</td><td align=right>$entree</td></tr>";
	print "<tr><td>montant des sorties</td><td align=right>$sortie</td></tr>";
	print "<tr><td>solde en fin de journee</td><td align=right>$newstock</td></tr>";
	print "<tr><td>monatnt du stock plancher</td><td align=right>240000</td></tr>";
	print "</table>";
	print "<br><br><br>";
	print "Le délégué madataire<br> Mme Reine  Mr Levasseur<br>";
	print "<br><br><br></center>Fich.Solde.St. - / -Doc. n°30 bis";
	$query="select max(facd_no) from facdata";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$max=$sth->fetchrow_array;

	if ($maj eq "ok") {
		$query="update atad set dt_no='$max' where dt_cd_dt=500";
		$sth=$dbh->prepare($query);
		$sth->execute;
		
		$query="update atad set dt_no='$newstock' where dt_cd_dt=501";
		$sth=$dbh->prepare($query);
		$sth->execute;
	}
	print "</body></html>";
}
