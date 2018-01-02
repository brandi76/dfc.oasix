#!/usr/bin/perl
use DBI();
use CGI();
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
$html=new CGI;
print $html->header();
&param();

&save("create temporary table dfa_tmp (id int(8) AUTO_INCREMENT, es_no_do int(8),no_de_bl  int(8),four int(8) ,date date,local int(2),montant decimal(8,2),primary key (id))");

$query="select distinct es_no_do,date(es_dt) from corsica.enso where es_type=10";
$sth=$dbh->prepare($query);
$sth->execute();
while (($es_no_do,$date)=$sth->fetchrow_array){
	$enh_document=&get("select enh_document from corsica.enthead where enh_no=$es_no_do");
	($livh_four,$livh_date)=&get("select livh_four,livh_date from dfc.livraison_h where livh_id='$enh_document'");
	$local=&get("select fo2_identification from corsica.fournis where fo2_cd_fo=$livh_four ");
	$montant=&get("select sum(livb_qte_ent*livb_prix) from dfc.livraison_b where livb_id='$enh_document'");
	$montant=int($montant*100)/100;
	$qte=&get("select sum(livb_qte_ent) from dfc.livraison_b where livb_id='$enh_document'");
	
	# $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$enh_document'")+0;
	# $montant+=$frais;
	# print "no_de_douane:$es_no_do no_de_bl:$enh_document  four:$livh_four date:$date local:$local montant:$montant<br>";
	if ($livh_four==2810){
		print "$es_no_do $enh_document',$livh_four,'$date $local $montant $qte<br>";
		# &save("insert into dfa_tmp (es_no_do,no_de_bl,four,date,local,montant) values ('$es_no_do','$enh_document',$livh_four,'$date','$local','$montant')");
	}
}
=pod
# *************************
print "<h3>DFC</h3><br>";
$premiere="2015-01-01";
$derniere="2015-12-31";
print "<table><tr><th>Fournisseur</th><th>Stock</th><th>Achat</th><th>Vente</th><th>Stock</th></tr>";
$query="select distinct(four) from dfa_tmp where date<'2017-01-01' and local=0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_four)=$sth->fetchrow_array){
	$montant=&get("select sum(montant) from dfa_tmp where date<'2016-01-01' and four=$livh_four")+0;
	$fo2_add=&get("select fo2_add from corsica.fournis where fo2_cd_fo=$livh_four");
	($fo2_add)=split(/\*/,$fo2_add);
	$ca=&get("select sum(prac*qte) from corsica.panier_caisse,corsica.ticket_caisse,corsica.produit where date>='$premiere' and date<'$derniere'  and vendeuse!='sylvain' and ticket_date=date and ticket_vendeuse=vendeuse and ticket_pdv=pdv and no_cde=ticket_no and ticket_sup=0 and code=pr_cd_pr and pr_four=$livh_four ","af");
	$stock=$montant-$ca;
	print "<tr>";
	print "<td>$four $fo2_add</td>";
	print "<td align=right>0";
	print "</td>";
	print "<td align=right>$montant</td><td align=right>$ca</td><td align=right>$stock</td></tr>";
	$total_achat+=$montant;
	$total_ca+=$ca;
	$total_stock+=$stock;
	$total_avant+=$stock2015{$livh_four};
	$stock2015{$livh_four}=$stock;
}
print "<tr><td><strong>2015</td><td align=right><strong>$total_avant</strong></td><td align=right><strong>$total_achat</strong></td><td align=right><strong>$total_ca</strong></td><td align=right><strong>$total_stock</strong></td>";
print "</table>";

$total_achat=$total_stock=$total_ca=$total_avant=0;
$total_stock2015=$total_stock;
$premiere="2016-01-04";
$derniere="2017-01-04";
print "<table><tr><th>Fournisseur</th><th>Stock</th><th>Achat</th><th>Vente</th><th>Stock</th></tr>";
$query="select distinct(four) from dfa_tmp where date<='2017-01-04' and local=0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_four)=$sth->fetchrow_array){
	$montant=&get("select sum(montant) from dfa_tmp where date>='2016-01-04' and date<='2017-01-04' and four=$livh_four")+0;
	$fo2_add=&get("select fo2_add from corsica.fournis where fo2_cd_fo=$livh_four");
	($fo2_add)=split(/\*/,$fo2_add);
	$ca=&get("select sum(prac*qte) from corsica.panier_caisse,corsica.ticket_caisse,corsica.produit where date>='$premiere' and date<'$derniere'  and vendeuse!='sylvain' and ticket_date=date and ticket_vendeuse=vendeuse and ticket_pdv=pdv and no_cde=ticket_no and ticket_sup=0 and code=pr_cd_pr and pr_four=$livh_four ","af");
	$stock=$montant-$ca+$stock2015{$livh_four};;
	print "<tr>";
	print "<td>$four $fo2_add</td>";
	print "<td align=right>";
	print $stock2015{$livh_four};
	print "</td>";
	print "<td align=right>$montant</td><td align=right>$ca</td><td align=right>$stock</td></tr>";
	$total_achat+=$montant;
	$total_ca+=$ca;
	$total_stock+=$stock;
	$total_avant+=$stock2015{$livh_four};
}
print "<tr><td><strong>2016</td><td align=right><strong>$total_avant</strong></td><td align=right><strong>$total_achat</strong></td><td align=right><strong>$total_ca</strong></td><td align=right><strong>$total_stock</strong></td>";
print "</table>";
$total_achat=$total_stock=$total_ca=$total_avant=0;
%stock2015={};


print "<h3>LOCAL</h3><br>";
$premiere="2015-01-01";
$derniere="2015-12-31";
print "<table><tr><th>Fournisseur</th><th>Stock</th><th>Achat</th><th>Vente</th><th>Stock</th></tr>";
$query="select distinct(four) from dfa_tmp where date<'2017-01-01' and local=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_four)=$sth->fetchrow_array){
	$montant=&get("select sum(montant) from dfa_tmp where date<'2016-01-01'  and four=$livh_four")+0;
	$fo2_add=&get("select fo2_add from corsica.fournis where fo2_cd_fo=$livh_four");
	($fo2_add)=split(/\*/,$fo2_add);
	$ca=&get("select sum(prac*qte) from corsica.panier_caisse,corsica.ticket_caisse,corsica.produit where date>='$premiere' and date<'$derniere'  and vendeuse!='sylvain' and ticket_date=date and ticket_vendeuse=vendeuse and ticket_pdv=pdv and no_cde=ticket_no and ticket_sup=0 and code=pr_cd_pr and pr_four=$livh_four ","af");
	$stock=$montant-$ca;
	print "<tr>";
	print "<td>$four $fo2_add</td>";
	print "<td align=right>0";
	print "</td>";
	print "<td align=right>$montant</td><td align=right>$ca</td><td  align=right>$stock</td></tr>";
	$total_achat+=$montant;
	$total_ca+=$ca;
	$total_stock+=$stock;
	$total_avant+=$stock2015{$livh_four};
	$stock2015{$livh_four}=$stock;
}
print "<tr><td><strong>2015</td><td align=right><strong>$total_avant</strong></td><td align=right><strong>$total_achat</strong></td><td align=right><strong>$total_ca</strong></td><td align=right><strong>$total_stock</strong></td>";
print "</table>";

$total_achat=$total_stock=$total_ca=$total_avant=0;
$total_stock2015=$total_stock;
$premiere="2016-01-01";
$derniere="2016-12-31";
print "<table><tr><th>Fournisseur</th><th>Stock</th><th>Achat</th><th>Vente</th><th>Stock</th></tr>";
$query="select distinct(four) from dfa_tmp where date<'2017-01-01' and local=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_four)=$sth->fetchrow_array){
	$montant=&get("select sum(montant) from dfa_tmp where date>='2016-01-01' and date<'2017-01-01' and four=$livh_four")+0;
	$fo2_add=&get("select fo2_add from corsica.fournis where fo2_cd_fo=$livh_four");
	($fo2_add)=split(/\*/,$fo2_add);
	$ca=&get("select sum(prac*qte) from corsica.panier_caisse,corsica.ticket_caisse,corsica.produit where date>='$premiere' and date<'$derniere'  and vendeuse!='sylvain' and ticket_date=date and ticket_vendeuse=vendeuse and ticket_pdv=pdv and no_cde=ticket_no and ticket_sup=0 and code=pr_cd_pr and pr_four=$livh_four ","af");
	$stock=$montant-$ca+$stock2015{$livh_four};
	print "<tr>";
	print "<td>$four $fo2_add</td>";
	print "<td align=right>";
	print $stock2015{$livh_four};
	print "</td>";
	print "<td align=right>$montant</td><td align=right>$ca</td><td  align=right>$stock</td></tr>";
	$total_achat+=$montant;
	$total_ca+=$ca;
	$total_stock+=$stock;
	$total_avant+=$stock2015{$livh_four};
}
print "<tr><td><strong>2016</td><td align=right><strong>$total_avant</strong></td><td align=right><strong>$total_achat</strong></td><td align=right><strong>$total_ca</strong></td><td align=right><strong>$total_stock</strong></td>";
print "</table>";




