#!/usr/bin/perl
use CGI;
use DBI();
 require "../oasix//home/intranet/cgi-bin/outils_perl2.lib";

 open (MAIL, ">/mnt/server-file/download/auxigaf_jour.txt");   
 print MAIL  "SUBJECT:fiche solde du stock société IBS france\n";

print MAIL  "Content-type: text/html\n\n";
print MAIL  "<html><body>";


require "./src/connect.src";
&journal();
close(MAIL);



sub detail {
	$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_type=1 or pr_type=5) and pr_sup=0  order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$totalgen=0;
	print MAIL  " <h3>Société Ibs France </h3><br><br>stock au ";
	print MAIL  `date`;
	print MAIL  "<br><table><tr><th>Code</th><th>produit</th><th>qte</th><th>prix</th><th>total</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
	{
		if ($pr_prac==0){next;}
		%stock=&stock($pr_cd_pr,'',"");
		# $stck=$stock{"pr_stre"};
		$stck=$stock{"stock"}+0;
		if ($stck==0){next;}
		$total=$stck*$pr_prac+0;
		$total_gen+=$total;
		print MAIL "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$stck</td><td align=right>$pr_prac</td><td align=right>";
		print MAIL &deci($total,2,0);
		print MAIL "</td></tr>";
	}
	print MAIL  "<tr><th>total</th><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=right>";
	print MAIL  &deci($total_gen,2,0);
	print MAIL  "</td></tr></table>";
}


sub journal {
	print MAIL "<center><h1>FICHE SOLDE DU STOCK</h1><br><br>\n";
	print MAIL "Veuillez trouver ci-joint la fiche solde du stock du jour<br>\n";

	$datesimple=`/bin/date +%Y%m%d`;
	$query="select sum(es_qte*pr_prac)/10000 from enso,produit where es_dt=$datesimple and pr_cd_pr=es_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$entree=int($sth->fetchrow_array);
	$stock_ancien=&get("select dt_no from atadsql where dt_cd_dt=500");
# 	$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_type=1 or pr_type=5 or pr_type=3 or pr_ventil=15 or pr_ventil=16 or pr_cd_pr=1223935 or pr_cd_pr=120185 or pr_cd_pr=120170 or pr_cd_pr=120040 or pr_cd_pr=1223076 or pr_cd_pr=1221370 or pr_cd_pr=1222845 or pr_cd_pr=1220068 or pr_cd_pr=1225490 or pr_cd_pr=1225488 or pr_cd_pr=1222945 or pr_cd_pr=260615 or pr_cd_pr=1219970 or pr_cd_pr=120920 or pr_cd_pr=1222851 or pr_cd_pr=1221470 or pr_cd_pr=1222845 or pr_cd_pr=1225488 or pr_cd_pr=400095)  order by pr_cd_pr";
$query="select pr_cd_pr,pr_desi,pr_prac/100,pr_ventil from produit where (pr_type=1 or pr_type=5  or pr_ventil=15 or pr_ventil=16 or pr_cd_pr=1223935 or pr_cd_pr=120185 or pr_cd_pr=120170 or pr_cd_pr=120040 or pr_cd_pr=1223076 or pr_cd_pr=1221370 or pr_cd_pr=1222845 or pr_cd_pr=1220068 or pr_cd_pr=1225490 or pr_cd_pr=1225488 or pr_cd_pr=1222945 or pr_cd_pr=260615 or pr_cd_pr=1219970 or pr_cd_pr=120920 or pr_cd_pr=1222851 or pr_cd_pr=1221470 or pr_cd_pr=1222845 or pr_cd_pr=1225488 or pr_cd_pr=400095 or pr_cd_pr=1220700 or pr_cd_pr=1221086 or pr_cd_pr=1221082 or pr_cd_pr=198029 or pr_cd_pr=1220644 or pr_cd_pr=120054) and pr_cd_pr!=1231050 and pr_cd_pr!=1242613 order by pr_ventil,pr_cd_pr";
	
	$sth=$dbh->prepare($query);
	$sth->execute;
	$totalgen=0;
	while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
	{
		%stock=&stock($pr_cd_pr,'',"");
		$stck=$stock{"stock"};
		# $cde_encours=&get("select sum(es_qte)/100 from enso where es_no_do>=8309 and es_cd_pr='$pr_cd_pr'")+0;
		# $stck+=$cde_encours;
		if ($stck<=0){next;}
		$total=$stck*$pr_prac;
		$total_gen+=$total;
	}
	$newstock=$total_gen;
	$sortie=$stock_ancien-$newstock+$entree;
	if ($entree <0){$sortie=$sortie-$entree;$entree=0;}
	if ($sortie<0){$entree=$entree-$sortie;$sortie=0;}	
	print MAIL   "édition du ";
	print MAIL   `date`;
	print MAIL   "<br><br><br><table border=1 cellspacing=0 ><tr><td>Solde en debut de journée (j-1)</td><td align=right>$stock_ancien</td></tr>\n";
	print MAIL   "<tr><td>montant des entrees</td><td align=right>";
	print MAIL int($entree);
	print MAIL "</td></tr>\n";
	print MAIL   "<tr><td>montant des sorties</td><td align=right>";
	print MAIL int($sortie);
	print MAIL "</td></tr>\n";
	print MAIL "<tr><td>solde en fin de journee</td><td align=right>";
	print MAIL int($newstock);
	print MAIL "</td></tr>\n";
	print MAIL   "<tr><td>montant du stock plancher</td><td align=right>250000</td></tr>\n";
	print MAIL   "</table>";
	print MAIL   "<br><br><br>";
	print MAIL   "Le délégué madataire<br> Mme Mouny  Mr Brandicourt<br>\n";
	print MAIL   "<br><br><br></center>Fich.Solde.St. - / -Doc. n° bis";
	$maj="ok";
	if ($maj eq "ok") {
		$query="update atadsql set dt_no=$newstock where dt_cd_dt=500";
		$sth=$dbh->prepare($query);
		$sth->execute;
		
	}
	print MAIL   "</body></html>";
}
