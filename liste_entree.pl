#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");


&save("create temporary table cde_tmp (base varchar(20),cde int(8),four int(8),four_desi varchar(80),date_cde date,date_echeance date,montant decimal (8,2),etat int(2),facture varchar(30),livh_date_reglement date,accuse date,primary key (base,cde))");
foreach $client (@bases_client){
  if ($client eq "dfc"){next;}
	&save_liste();
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
			<div class="alert alert-info" >
			<h3>Liste des livraisons 2015</h3>
			</div>
EOF
	print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
	print "<thead>";
	print "<tr style=font-size:0.8em class=\"info\">";
	print "<th>Base</th>";
	print "<th>Commande</th>";
	print "<th>Fournisseur</th>";
	print "<th>Date</th>";
	print "<th>Montant</th>";
	print "</tr>";
	print "</thead>";
	$query="select * from cde_tmp order by four,base";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	$fo_run=-1;
	while(($client,$com2_no,$com2_cd_fo,$fo_nom,$com2_date,$date_echeance,$montant,$etat,$livh_facture,$livh_date_reglement,$accuse)=$sth->fetchrow_array){
		if ($fo_run==-1){$fo_run=$com2_cd_fo;}
		if (($total!=0)&&($com2_cd_fo!=$fo_run)){
				print "<tr style=font-weight:bold><td colspan=4>Total</td><td align=right>$total</td></tr>";
				$total=0;
				$fo_run=$com2_cd_fo;
		}
		print "<tr><td>$client</td><td>$com2_no</td><td>$com2_cd_fo $fo_nom</td><td>$com2_date</td><td align=right>$montant</td></tr>";
		$total+=$montant;
	}
	print "<tr style=font-weight:bold><td colspan=4>Total</td><td align=right>$total</td></tr>";
	print "</table>";

print "		
		</div>
	</div>
</div>";

sub save_liste(){
	$query="select distinct com2_no,com2_cd_fo,com2_date,com2_no_liv from $client.commande where year(com2_date)='2015' order by com2_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com2_date,$com2_no_liv)=$sth->fetchrow_array){
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo'"));
		$query="select livh_facture,livh_lta,livh_date_facture,livh_date_reglement from livraison_h where livh_id='$com2_no_liv'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($livh_facture,$livh_lta,$livh_date_facture,$livh_date_reglement)=$sth2->fetchrow_array;
 		if (($livh_date_facture ne "0000-00-00")&&($livh_date_facture ne "")){$com2_date=$livh_date_facture;}
		if ($com2_no_liv ==0){
		  $montant=&get("select sum(com2_qte*com2_prac)/100 from $client.commande where com2_no='$com2_no'")+0;
		  $montant=int($montant*100)/100;
		}
		else
		{
		  $montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$com2_no_liv'");
		  $montant=int($montant*100)/100;
		  $frais=&get("select livh_cout from dfc.livraison_h where livh_id='$com2_no_liv'")+0;
		  $montant+=$frais;
		}
 		$fo_delai_pai=&get("select fo_delai_pai from fournis where fo2_cd_fo='$com2_cd_fo'","af")+0;
 		$date_echeance=&get("select '$com2_date' + interval $fo_delai_pai day","af");
 		$etat=&get("select etat from $client.commande_info where com_no='$com2_no'")+0;
 		if (($etat>=5)&&($livh_facture ne "")&&($livh_date_facture ne "0000-00-00")&&($etat5 ne "on")){next;}
 		$accuse=&get("select accuse from $client.commande_info where com_no='$com2_no'");
		&save("insert ignore into cde_tmp values('$client','$com2_no','$com2_cd_fo','$fo_nom','$com2_date','$date_echeance','$montant','$etat','$livh_facture','$livh_date_reglement','$accuse')","af");
	}
	
	$query="select distinct com2_no,com2_cd_fo,com2_date,com2_no_liv from $client.commandearch where com2_no_liv!=0 and year(com2_date)='2015'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($com2_no,$com2_cd_fo,$com2_date,$com2_no_liv)=$sth->fetchrow_array){
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from $client.fournis where fo2_cd_fo='$com2_cd_fo'"));
		$query="select livh_facture,livh_lta,livh_date_facture,livh_date_reglement,livh_date from livraison_h where livh_id='$com2_no_liv'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($livh_facture,$livh_lta,$livh_date_facture,$livh_date_reglement,$livh_date)=$sth2->fetchrow_array;
 		if (($livh_date_facture ne "0000-00-00")&&($livh_date_facture ne "")){$com2_date=$livh_date_facture;}
 		if ($com2_date eq "0000-00-00"){$com2_date=$livh_date;}
		$montant=&get("select sum(livb_qte_fac*livb_prix) from dfc.livraison_b where livb_id='$com2_no_liv'");
		$montant=int($montant*100)/100;
		$frais=&get("select livh_cout from dfc.livraison_h where livh_id='$com2_no_liv'")+0;
		$montant+=$frais;
		$fo_delai_pai=&get("select fo_delai_pai from fournis where fo2_cd_fo='$com2_cd_fo'","af")+0;
		$date_echeance=&get("select '$com2_date' + interval $fo_delai_pai day","af");
		$etat=&get("select etat from $client.commande_info where com_no='$com2_no'")+0;
 		if (($etat>=5)&&($livh_facture ne "")&&($livh_date_reglement ne "0000-00-00")){next;}
 		$accuse=&get("select accuse from $client.commande_info where com_no='$com2_no'");
 		&save("insert ignore into cde_tmp values('$client','$com2_no','$com2_cd_fo','$fo_nom','$com2_date','$date_echeance','$montant','$etat','$livh_facture','$livh_date_reglement','$accuse')");
	}
	
}
