#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$client=$html->param("client");
$an_ref=$html->param("an");

push(@bases_client,"corsica");
push(@bases_client,"cameshop");

$jour=$html->param("date_findatejour");
$mois=$html->param("date_findatemois");
$an=$html->param("date_findatean");
$date_fin=$an."-".$mois."-".$jour;

	
print <<EOF;
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>

</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF

$action="go";
if ($action eq "go"){
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$an_ref=$year-1+1900;
	$an=$year+1900;
	&save("create temporary table cde_tmp (four int(8),delai int(8),achat int(8),encours int(8),pub int(8) ,primary key (four))");
	&save("create temporary table marque_tmp (marque char(30),achat int(8) ,primary key (marque))");
	$query="select * from livraison_h where year(livh_date_facture)='$an_ref'  order by livh_date_facture";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
	    # if ($livh_base eq "corsica"){next;}
		# if ($livh_base eq "cameshop"){next;}
		$fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
		# if (&get("select year(adddate('$livh_date_facture',$fo_delai))")+0<2016){next;};
		$achat=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$achat=int($achat*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$achat+=$frais;
		if ($achat==0){next;}
		&save("insert ignore into cde_tmp values ('$livh_four','$fo_delai','0','0','0')","af");
		&save("update  cde_tmp set achat=achat+$achat where four=$livh_four","af");
		
		$query="select marque,sum(livb_qte_fac*livb_prix) from dfc.livraison_b left join dfc.produit_desi on livb_code=code where livb_id='$livh_id'  group by marque";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($marque,$montant)=$sth2->fetchrow_array){
				$frais_marque=$montant*$frais/$achat if ($achat!=0);
				$montant+=$frais_marque;
				&save("insert ignore into marque_tmp values ('$marque','0')","af");
				&save("update  marque_tmp set achat=achat+'$montant' where marque='$marque'","af");
		}
		
	}
	# $query="select * from livraison_h where year(livh_date_facture)='$an'  order by livh_date_facture";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# $total=0;
	# while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
	    # if ($livh_base eq "corsica"){next;}
		# if ($livh_base eq "cameshop"){next;}
		# $achat=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		# $achat=int($achat*100)/100;
		# $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		# $achat+=$frais;
		# if ($achat==0){next;}
		# &save("insert ignore into cde_tmp values ('$livh_four','$fo_delai','0','0','0')","af");
		# &save("update  cde_tmp set encours=encours+$achat where four=$livh_four","af");
	# }
	
	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des factures</h3>";
	print "	</div>";
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Fournisseur</th>";
	print "<th>Delai paiement</th>";
	print "<th>achat $an_ref</th>";
	print "<th>encours (achat $an_ref*delai/365)</th>";
	print "<th>Publicité $an_ref</th>";
	print "<th>% pub/achat</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from cde_tmp ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	$pass=0;
	while (($livh_four,$livh_delai,$achat,$encours)=$sth->fetchrow_array){
		$pub=int(&get("select sum(montant) from facture_pub where fournisseur=$livh_four and year(date)=$an_ref")+0);
		$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$encours=round($achat*$fo_delai/365);
		print "<tr><td>$livh_four $fo_nom</td>";
		print "<td>$livh_delai</td>";
		print "<td align=right>$achat</td>";
		print "<td align=right>$encours</td>";
		print "<td align=right>$pub</td>";
		if ($achat!=0){$pour=round($pub*100/$achat);}
		print "<td align=right>$pour %</td>";
		print "</tr>";
		$total_achat+=$achat;
		$total_encours+=$encours;
		$total_pub+=$pub;
	}
	if ($total_achat!=0){$pour=round($total_pub*100/$total_achat);}
	print "<tr style=\"font-weight:bold\" class=success><td colspan=2>Total</td><td align=right>$total_achat</td><td align=right>$total_encours</td><td align=right>$total_pub</td><td align=right>$pour %</td></tr>";
    print "<br>";
	$total_achat=0;
	$total_pub=0;
	print "</table>";
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Marque</th>";
	print "<th>achat $an_ref</th>";
	print "<th>Publicité $an_ref</th>";
	print "<th>% pub/achat</th>";
	print "</tr>";
	print "</thead>";
	# &save("insert ignore into marque_tmp  select marque,sum(montant) from facture_pub where  year(date)=$an_ref group by marque");
	$query="select * from marque_tmp ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	$pass=0;
	while (($marque,$montant)=$sth->fetchrow_array){
		$pub=int(&get("select sum(montant) from facture_pub where marque='$marque' and year(date)=$an_ref")+0);
		print "<tr><td>$marque</td>";
		print "<td align=right>$montant</td>";
		print "<td align=right>$pub</td>";
		if ($montant!=0){$pour=round($pub*100/$montant);}
		print "<td align=right>$pour %</td>";
		print "</tr>";
		$total_achat+=$montant;
		$total_pub+=$pub;
	}
	if ($total_achat!=0){$pour=round($total_pub*100/$total_achat);}
	print "<tr style=\"font-weight:bold\" class=success><td colspan=1>Total</td><td align=right>$total_achat</td><td align=right>$total_pub</td><td align=right>$pour %</td></tr>";
	print "</table>";
	print "Liste des pubs dont la marque est enregistrée sous un autre nom que pour le chiffre d'affaire<br>";
	$total=0;
	$query="select marque,sum(montant) from facture_pub where marque not in (select marque from marque_tmp)  and year(date)=$an_ref group by marque";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($marque,$montant)=$sth->fetchrow_array){
		print "$marque,$montant<br>";
		$total+=$montant;
	}	
	print "Total:$total<br>";
}
print "		
		</div>
	</div>
</div>";
