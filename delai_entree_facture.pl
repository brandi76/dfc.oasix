#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();

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

if ($action eq ""){
	&save("create temporary table cde_tmp (base varchar(20),four int(8),delai_p int(8),delai int(8),montant decimal(8,2))");
	$query="select * from livraison_h where livh_date >='2015-06-01' and livh_base!='corsica'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
		$fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
		if (&get("select year(adddate('$livh_date_facture',$fo_delai))")+0<2016){next;};
		$date_echeance=&get("select adddate('$livh_date_facture',$fo_delai)");
		$date_entree_julian=&get("select enh_date from $livh_base.enthead  where enh_document='$livh_id'");
		if ($date_entree_julian eq ""){next;}
		$date_entree=&julian($date_entree_julian,"YYYY-MM-DD");
		#print "$livh_id*$date_echeance*$date_entree*$date_entree_julian<br>";
		$delai=&get("select datediff('$date_echeance','$date_entree')")+0;
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		&save("insert into cde_tmp values ('$livh_base','$livh_four','$fo_delai','$delai','$montant')","af");
	}
	print "<div class=\"alert alert-info\">";
	print "<h3>Delai Echeance Entrée 2016</h3>";
	print "	</div>";
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Base</th>";
	print "<th>Fournisseur</th>";
	print "<th>Delai de paiement</th>";
	print "<th>Delai Echeance Entree</th>";
	print "<th>Montant</th>";
	print "<th>Montant BL*nb jour</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from cde_tmp order by four,base";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($livh_base,$livh_four,$delai_p,$delai,$montant)=$sth->fetchrow_array){
		if (($livh_four ne $four_run)&&($total>0)){
			$moyenne=$moyenne_mont=0;
			if (($nb!=0)&&($total_mont!=0)){
				$moyenne=int($total*100/$nb)/100;
				$moyenne_mont=int($total_xnb*100/$total_mont)/100;
			}
			print "<tr style=font-weight:bold><td>_</td><td colspan=2>$fo_nom</td><td align=right>$moyenne</td><td align=right>$total_mont</td><td align=right>$moyenne_mont</td></tr>";
			$total=0;
			$total_mont=0;
			$total_xnb=0;
			$nb=0;
		}	
		$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		($fo_nom)=split(/\*/,$fo_add);
		print "<tr><td>$livh_base</td><td>$fo_nom</td>";
		print "<td>$delai_p</td>";
		$montantxnb=$montant*$delai;
		print "<td>$delai</td><td align=right>$montant</td><td align=right>$montantxnb</td></tr>";
		$total+=$delai;
		$total_mont+=$montant;
		$total_xnb+=$montantxnb;
		$somme_xnb+=$montantxnb;
		$somme_mont+=$montant;
		$nb++;
		$four_run=$livh_four;
	}
	print "<tr style=font-weight:bold><td>Moyenne</td><td colspan=2>$fo_nom</td><td align=right>$moyenne</td></tr>";
	print "</table>";
	$moyenne=int($somme_xnb*100/$somme_mont)/100;
	print "<h3>&Sigma; (montant B/L * nb jour) / &Sigma; montant B/L= $moyenne</h3>";
}
print "		
		</div>
	</div>
</div>";
