#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);

require "../oasix/outils_perl2.lib";
print   "Content-type: text/html\n\n";
require "./src/connect.src";

push(@bases_client,"cameshop");
push(@bases_client,"dutyfreeambassade");
push(@bases_client,"corsica");

$an="2016";
$mois="9";
&save("create  temporary table if not exists situation_tmp (base varchar(20),an int(4),mois int(2),ca decimal(10,2), achat decimal(10,2))");
 &save("create  temporary table if not exists prac_tmp (code bigint(13),prac decimal(10,2))");
$query="select code from dutyfreeambassade.produit_web";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code)=$sth->fetchrow_array){
	  $pr_prac=&get("select min(prix_unite) from dutyfreeambassade.produit_four where ref_dfa='$code'")+0;
	  &save("insert into prac_tmp values ($code,'$pr_prac')");
}	

for ($i=0;$i<12;$i++){
	$mois+=1;
	if ($mois==13){
		$an++;
		$mois=1;
	}	
	foreach $base (@bases_client){
		if ($base eq "dfc"){next;}
	
		$pass=0;
		if ($base eq "corsica"){&ca_boutique_cor();$pass=1;}
		if ($base eq "dutyfreeambassade"){&ca_dfa();$pass=1;}
		if ($base eq "cameshop"){&ca_boutique_cam();$pass=1;}
		if ($pass==0){&ca();}
	}
}
print "Sorties au prix d'achat <table><tr><td>Base</td>";
$ca=0;
$an="2016";
$mois="9";
for ($i=0;$i<12;$i++){
	$mois+=1;
	if ($mois==13){
		$an++;
		$mois=1;
	}
		print "<td>$an-$mois</td>";
}
print "</tr>";		
$query="select distinct  base from situation_tmp";
$sth=$dbh->prepare($query);
$sth->execute();
while (($base)=$sth->fetchrow_array){
	$an="2016";
	$mois="9";
	print "<tr><td>$base</td>";
	for ($i=0;$i<12;$i++){
		$mois+=1;
		if ($mois==13){
			$an++;
			$mois=1;
		}	
		print "<td> ";
		($ca)=&get("select ca from situation_tmp where base='$base' and an=$an and mois=$mois","af")+0;
		
		print "$ca</td>";
	}
	print "</tr>";
}
print "</table>";

print "Entrees au prix d'achat <table><tr><td>Base</td>";
$query="select distinct  base from situation_tmp";
$sth=$dbh->prepare($query);
$sth->execute();
$ca=0;
$an="2016";
$mois="8";
for ($i=0;$i<12;$i++){
	$mois+=1;
	if ($mois==13){
		$an++;
		$mois=1;
	}
		print "<td>$an-$mois</td>";
}
print "</tr>";		

while (($base)=$sth->fetchrow_array){
	$an="2016";
	$mois="9";
	print "<tr><td>$base</td>";
	for ($i=0;$i<12;$i++){
		$mois+=1;
		if ($mois==13){
			$an++;
			$mois=1;
		}	
		print "<td> ";
		($ca)=&get("select achat from situation_tmp where base='$base' and an=$an and mois=$mois","af")+0;
		
		print "$ca</td>";
	}
	print "</tr>";
}
print "</table>";



sub ca{
	$query="select v_code from $base.vol where year(v_date_sql)=$an and month(v_date_sql)=$mois and v_rot=1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$ca=0;
	while (($v_code)=$sth->fetchrow_array){
		$ca+=&get("select sum(ro_qte*pr_prac)/10000 from $base.rotation,$base.produit where ro_code='$v_code' and ro_cd_pr=pr_cd_pr")+0;
	}
	$achat=&get("select sum(es_qte_en*pr_prac)/10000 from $base.enso,$base.produit where  es_cd_pr=pr_cd_pr and  year(es_dt)=$an and month(es_dt)=$mois")+0;
	&save("insert into situation_tmp values ('$base','$an','$mois','$ca','$achat')","af"); 
}
sub ca_dfa{
	 $achat=&get("select sum(enb_quantite*enb_prac) from $base.entbody,$base.enthead where enb_no=enh_no and year(enh_date)=$an and month(enh_date)=$mois")+0;
	$ca=&get("select sum(prep*prac) from $base.panier_web,prac_tmp where panier_web.produit_id=prac_tmp.code and cde_id in (select cde_id from $base.facture where year(date)=$an and month(date)=$mois) and cde_id not in (select cde_id from $base.suivi_cde where libelle='avoirp')","af")+0;
	&save("insert into situation_tmp values ('$base','$an','$mois','$ca','$achat')","af"); 
}

sub ca_boutique_cam{
	$ca=&get("select sum(ticket_montant) from $base.ticket_caisse_js where ticket_vendeuse!='sylvain' and year(ticket_date)='$an' and month(ticket_date)='$mois' and ticket_sup=0","af");
	$achat=&get("select sum(es_qte_en*pr_prac)/10000 from $base.enso,$base.produit where  es_cd_pr=pr_cd_pr and  year(es_dt)=$an and month(es_dt)=$mois")+0;
	&save("insert into situation_tmp values ('$base','$an','$mois','$ca','$achat')","af"); 
}
sub ca_boutique_cor{
	$ca=&get("select sum(ticket_montant) from $base.ticket_caisse where ticket_vendeuse!='sylvain' and year(ticket_date)='$an' and month(ticket_date)='$mois' and ticket_sup=0","af");
	$achat=&get("select sum(es_qte_en*pr_prac)/10000 from $base.enso,$base.produit where  es_cd_pr=pr_cd_pr and  year(es_dt)=$an and month(es_dt)=$mois")+0;
	&save("insert into situation_tmp values ('$base','$an','$mois','$ca','$achat')","af"); 
}

		
;1
