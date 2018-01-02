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

if ($action eq ""){
	print "<form>";
	print "Factures dues de l'exercice ";
	$an=&get("select year(curdate())");
	print "<select name=an>";
	for ($i=$an-4;$i<=$an+1;$i++){
		print "<option value=$i>$i</option>";
	}
	print "</select>";
	print "à la date du :";
	&select_date("date_fin");
	print "<br>";
	print "<br><input type=hidden name=action value=go>";
	print "<br><input type=submit>";
	print "</form>";
	exit;
} 

	
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


if ($action eq "go"){
    if ($client eq ""){
		print "<form><select name=client class=\"form-control\">";
		foreach $client (@bases_client){
			if ($client eq "dfc"){next;}
			print "<option value=$client>$client</option>";
		}
		print "</select>";
		print "<button type=\"submit\" class=\"btn btn-success\">Filtrer</button>";
		print "</form>";
		$client="%";
	}
   
	&save("create temporary table cde_tmp (base varchar(20),four int(8),id int(8),facture varchar(30),date_fature date,date_echance date,montant decimal (8,2),delai int(5),reglement decimal (8,2))");
	$query="select * from livraison_h where year(livh_date_facture)='$an_ref' and livh_base like '$client' order by livh_date_facture";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($livh_id,$livh_base,$livh_date,$livh_four,$livh_cout,$livh_cout_desi,$livh_blabla,$livh_facture,$livh_lta,$livh_user,$livh_date_facture,$livh_nom_facture,$livh_date_reglement,$livh_date_lta)=$sth->fetchrow_array){
		$fo_delai=&get("select fo_delai_pai from dfc.fournis where fo2_cd_fo='$livh_four' ")+0;
		# if (&get("select year(adddate('$livh_date_facture',$fo_delai))")+0<2016){next;};
		$echeance=&get("select adddate('$livh_date_facture',$fo_delai)","af");
		# je vire les factures dont l'echance depasse la date de fin
		# if (&get("select datediff('$echeance','$date_fin')")>0){next;};
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$livh_id'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$livh_id'")+0;
		$montant+=$frais;
		if ($montant==0){next;}
		# je vire les factures réglé à avant la date de fin
		if ($livh_id==553){print "select sum(montant) from dfc.reglement where reg_id='$livh_id' and date<='$date_fin'";}

		$reglement=&get("select sum(montant) from dfc.reglement where reg_id='$livh_id' and date<='$date_fin'")+0;
		if ($reglement>=$montant-100){next;}
		if ($an==2015){
				if ($livh_id==553){print "la";}

			#pour 2015 je vire les factures qui n'ont pas eu de reglement	
			$check=&get("select count(*) from dfc.reglement where reg_id='$livh_id'")+0;
			if ($check==0){next;}

		}
		if ($livh_id==553){print "ici";}

		&save("insert into cde_tmp values ('$livh_base','$livh_four','$livh_id','$livh_facture','$livh_date_facture','$echeance','$montant','$fo_delai','$reglement')","af");
	}
	print "<div class=\"alert alert-info\">";
	print "<h3>Liste des factures</h3>";
	print "	</div>";
	
	if ($message ne ""){
		print "<div class=\"alert alert-danger\">";
		print "<h3>$message</h3>";
		print "	</div>";
	}
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Base</th>";
	print "<th>Fournisseur</th>";
	print "<th>Delai paiement</th>";
	print "<th>Bon de livraison</th>";
		print "<th>Facture</th>";
	print "<th>Date Echeance</th>";
	print "<th>Date Facture</th>";
	print "<th>Montant</th>";
	if ($client eq "corsica"){
			print "<th>montant refacturation</td>";
	}
	print "<th>Reglement</th>";
	print "<th>Date entrée</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from cde_tmp order by date_echance";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	$pass=0;
	while (($livh_base,$livh_four,$livh_id,$livh_facture,$date_facture,$date_echeance,$montant,$delai,$reglement)=$sth->fetchrow_array){
		$delai=&get("select datediff('$date_echeance','$date_fin')");
		 if (($delai>30)&&($pass==0)){
			 if ($total >0){
				 print "<tr style=font-weight:bold><td colspan=7>Total delai <=30 </td><td align=right>$total_int</td></tr>";
				 $total_int=0;
				 $pass=1;
			 }
			# $semaine_run=$semaine;
		 }
		$fo_add=&get("select fo2_add from $livh_base.fournis where fo2_cd_fo='$livh_four' ");
		($fo_nom)=split(/\*/,$fo_add);
		$date_entree=&get("select enh_date from $livh_base.enthead where enh_document='$livh_id'")+0; 
		if ($date_entree==0){$date_entree="0000-00-00";}else{$date_entree=&julian($date_entree,"YYYY-MM-DD");}
		print "<tr><td>$livh_base</td><td>$fo_nom</td>";
		print "<td>$delai</td>";
		print "<td>$livh_id</td><td>$livh_facture</td><td class=warning>$date_echeance</td><td>$date_facture</td><td align=right>$montant</td>";
		if ($client eq "corsica"){
			$montant_corse=&get("select total_tva from facture_corse where bl=$livh_id")+0;
			print "<td align=right>$montant_corse</td>";
		}
		print "<td align=right>$reglement</td>";
		print "<td>$date_entree</td>";
		print "</tr>";
		$total+=$montant;
		$total_int+=$montant;
	}
	if (($total >0)&&($pass==1)){
		 print "<tr style=font-weight:bold><td colspan=7>Total delai >30</td><td align=right>$total_int</td></tr>";
		 $total_int=0;
	 }
	print "<tr style=\"font-weight:bold\" class=success><td colspan=7>Total</td><td align=right>$total</td></tr>";
	print "</table>";
}
print "		
		</div>
	</div>
</div>";
