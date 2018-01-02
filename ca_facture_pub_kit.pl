

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

$jour=$html->param("premieredatejour");
$mois=$html->param("premieredatemois");
$an=$html->param("premieredatean");
$premiere=$an."-".$mois."-".$jour;
$jour=$html->param("dernieredatejour");
$mois=$html->param("dernieredatemois");
$an=$html->param("dernieredatean");
$derniere=$an."-".$mois."-".$jour;


if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "<br>Premiere date ";
	&select_date("premiere");
	print "<br><br>Derniere date ";
	&select_date("derniere");
	# print "<br><br>Avec les Boutiques <input type=checkbox name=boutique>";
	# print "<br>Groupement par produit <input type=checkbox name=option><br>";
	print "<br><input type=hidden name=action value=go>";
	print "<br><input type=submit>";
	print "</form>";
}

if ($action eq "go"){
	# &save("create temporary table cde_tmp (base varchar(20),four int(8),id int(8),facture varchar(30),date_fature date,date_echance date,montant decimal (8,2),delai int(5),reglement decimal (8,2))");
	$query="select * from facture_pub where no_facture>0 and date>='$premiere' and date<='$derniere' and montant!=0 order by fournisseur,no_facture";
	# print $query;
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
	print "<th>Marque</th>";
	print "<th>No facture</th>";
	print "<th>Date </th>";
	print "<th>Montant </th>";
	print "</tr>";
	print "</thead>";
	$total=0;
	while (($base,$mag,$fournisseur,$marque,$no_facture,$date,$montant,$pdf,$date_mail,$groupement)=$sth->fetchrow_array){
		if ($fournisseur ne $four_run){
			if ($total !=0){
				print "<tr><td colspan=6><strong>Total </strong></td><td align=right><strong>$total</strong></tr>";
			}
		$four_run=$fournisseur;
		$total=0;	
		}	
		($fo_nom,$null)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$fournisseur'"));
		print "<tr><td>$base</td><td>$mag</td><td>$fournisseur $fo_nom</td><td>$marque</td><td bgcolor=$color>$no_facture</td><td>$date</td><td align=right>$montant</td></tr>";
		$total+=$montant;
		$total_gen+=$montant;
		print "</tr>";
	}
	if ($total !=0){
			print "<tr><td colspan=6><strong>Total </strong></td><td align=right><strong>$total</strong></tr>";
		}
	print "</table>";
	print "<h3>Total:$total_gen</h3>";
}
print "		
		</div>
	</div>
</div>";
