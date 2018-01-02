#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");


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

	# &save("create temporary table cde_tmp (base varchar(20),four int(8),id int(8),facture varchar(30),date_fature date,date_echance date,montant decimal (8,2),delai int(5),reglement decimal (8,2))");
	$query="select * from facture_pub where no_facture>0 order by no_facture";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
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
	print "<th>Mag</th>";
	print "<th>Fournisseur</th>";
	print "<th>No facture</th>";
	print "<th>Date </th>";
	print "</tr>";
	print "</thead>";
	while (($base,$mag,$fournisseur,$marque,$no_facture,$date,$montant,$pdf,$date_mail,$groupement)=$sth->fetchrow_array){
		if ($no_anc eq ""){$no_anc=$no_facture-1;}
		if ($no_facture!=$no_anc+1){$color="pink";}else{$color="";}
		$no_anc=$no_facture;
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$fournisseur'"));
		print "<tr><td>$base</td><td>$mag</td><td>$fournisseur $fo_nom</td><td bgcolor=$color>$no_facture</td><td>$date</td></tr>";
		print "</tr>";
	}
	print "</table>";
}
print "		
		</div>
	</div>
</div>";
