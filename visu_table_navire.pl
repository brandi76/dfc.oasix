#!/usr/bin/perl
use CGI;
use DBI();

require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
$html=new CGI;
print $html->header;

require "./src/connect.src";
$query="select distinct date_mini,nofact_mini,semaine,coef1,coef2,coef3,coef4 from table_navire where ta_navire='MEGA 2' ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($date_mini,$nofact_mini,$semaine,$coef1,$coef2,$coef3,$coef4)=$sth->fetchrow_array){
	print "Date de la Derniere facture :$date_mini<br>";
	print "No de facture mini :$nofact_mini<br>";
	print "semaine:$semaine<br>";
	print "coef s:$coef1<br>";
	print "coef s+1:$coef2<br>";
	print "coef s+2:$coef3<br>";
	print "coef s+3:$coef4<br>";
	
}

print "<table border=1 cellspacing=0>";
print &ligne_tab("<b>","produit","designation","max vendu s-4 s-1","ventes prevues s","ventes prevues s+1","ventes prevues s s+1","ventes s+2","ventes prevues s+2 s+3","ventes prevues s+4 s+5","stock plancher","inventaire","qte livrée","vendu","stock_navire","alivrer");
$query="select ta_navire,ta_cd_pr,stockmini_suivsuiv,date_mini,stockmini_suiv,prev,coef1,coef2,vs,coef3,coef4,max,vsp1,nofact_mini,vsp2,stockmini,ecart,liv,stock_plancher,inv,vendu,semaine,alivrer,stock_navire,date_modif from table_navire where ta_navire='MEGA 2' and ta_cd_pr=10093764 order by ta_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
while (($ta_navire,$ta_cd_pr,$stockmini_suivsuiv,$date_mini,$stockmini_suiv,$prev,$coef1,$coef2,$vs,$coef3,$coef4,$max,$vsp1,$nofact_mini,$vsp2,$stockmini,$ecart,$liv,$stock_plancher,$inv,$vendu,$semaine,$alivrer,$stock_navire,$date_modif)=$sth->fetchrow_array)
 	{
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$ta_cd_pr'");
	print &ligne_tab("","$ta_cd_pr","<font size=-3>$pr_desi","$max","$vs","$vsp1","$prev","$vsp2","$stockmini_suiv","$stockmini_suivsuiv","$stock_plancher","$inv","$liv","$vendu","$stock_navire","$alivrer");
 }		
print "</table>";