#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");

# @base_liste=("togo","aircotedivoire","camairco","tacv","cameshop");
@base_liste=("togo");
&save("create temporary table ctl_stck_tmp (base varchar(20),j int(8),achat int(8),stock int(8),vendu int(8), primary key (base,j))");
	
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
EOF

print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
print "<thead>";
print "<tr class=\"info\">";
print "<th>Stock mensuel</th>";

for ($i=7;$i<13;$i++){
	$date_ref=&get("select last_day ('2015-$i-01')");
	print "<td align=right>$date_ref</td>";
}
for ($i=1;$i<10;$i++){
	$date_ref=&get("select last_day ('2016-$i-01')");
	print "<td align=right>$date_ref</td>";
}
print "</tr>";
print "</thead>";
foreach $client (@base_liste){
	$j=0;
	print "<tR><td><span style=font-weight:bold>$client</td>";
	for ($i=7;$i<13;$i++){
		$date_ref=&get("select last_day ('2015-$i-01')");
		$stock=&get("select sum(qte*prac) from dfc.stock_mensuel where base='$client' and date='$date_ref'");
		#$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where an=2015 and mois=$i")+0);
		$stock=int($stock);
		print "<td align=right>$stock</td>";
		$stock[$j]+=$stock;
		&save("insert into ctl_stck_tmp (base,j,stock) values ('$client','$j','$stock')");
		$j++;
	}
	for ($i=1;$i<10;$i++){
		$date_ref=&get("select last_day ('2016-$i-01')");
		$stock=&get("select sum(qte*prac) from dfc.stock_mensuel where base='$client' and date='$date_ref'");
		$stock=int($stock);
		#$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where an=2016 and mois=$i")+0);
		print "<td align=right>$stock</td>";
		&save("insert into ctl_stck_tmp (base,j,stock) values ('$client','$j','$stock')","af");
		$stock[$j]+=$stock;
		$j++;
	}
	print "</tr>";
}
print "<tr style=font-weight:bold><td>&nbsp;</td>";
for ($j=0;$j<15;$j++){
	print "<td align=right>".$stock[$j]."</td>";
}
print "</tr>";

print "<thead>";
print "<tr class=\"info\">";
print "<th>Vendu mensuel</th>";

for ($i=7;$i<13;$i++){
	$date_ref=&get("select last_day ('2015-$i-01')");
	print "<td align=right>$date_ref</td>";
}
for ($i=1;$i<10;$i++){
	$date_ref=&get("select last_day ('2016-$i-01')");
	print "<td align=right>$date_ref</td>";
}
print "</tr>";
print "</thead>";
foreach $client (@base_liste){
	$j=0;
	print "<tR><td><span style=font-weight:bold>$client</td>";
	for ($i=7;$i<13;$i++){
		$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where base='$client' and an=2015 and mois=$i")+0);
		$vendu=int($vendu);
		print "<td align=right>$vendu</td>";
		$vendu[$j]+=$vendu;
		&save("update ctl_stck_tmp set vendu='$vendu' where base='$client' and j='$j'");
		$j++;
	}
	for ($i=1;$i<10;$i++){
		$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where base='$client' and an=2016 and mois=$i")+0);
		$vendu=int($vendu);
		print "<td align=right>$vendu</td>";
		$vendu[$j]+=$vendu;
		&save("update ctl_stck_tmp set vendu='$vendu' where base='$client' and j='$j'");
		$j++;
	}
	print "</tr>";
}
print "<tr style=font-weight:bold><td>&nbsp;</td>";
for ($j=0;$j<15;$j++){
	print "<td align=right>".$vendu[$j]."</td>";
}
print "</tr>";

print "<thead>";
print "<tr class=\"info\">";
print "<th>Achat mensuel</th>";

for ($i=7;$i<13;$i++){
	$date_ref=&get("select last_day ('2015-$i-01')");
	print "<td align=right>$date_ref</td>";
}
for ($i=1;$i<10;$i++){
	$date_ref=&get("select last_day ('2016-$i-01')");
	print "<td align=right>$date_ref</td>";
}
print "</tr>";
print "</thead>";
foreach $client (@base_liste){
	$j=0;
	print "<tR><td><span style=font-weight:bold>$client</td>";
	for ($i=7;$i<13;$i++){
		$achat=int(&get("select sum(qte*prac) from achat_mensuel where base='$client' and an=2015 and mois=$i")+0);
		$achat=int($achat);
		print "<td align=right>$achat</td>";
		$achat[$j]+=$achat;
		&save("update ctl_stck_tmp set achat='$achat' where base='$client' and j='$j'");
		$j++;
	}
	for ($i=1;$i<10;$i++){
		$achat=int(&get("select sum(qte*prac) from achat_mensuel where base='$client' and an=2016 and mois=$i")+0);
		$achat=int($achat);
		print "<td align=right>$achat</td>";
		$achat[$j]+=$achat;
		&save("update ctl_stck_tmp set achat='$achat' where base='$client' and j='$j'","af");
		$j++;
	}
	print "</tr>";
}
print "<tr style=font-weight:bold><td>&nbsp;</td>";
for ($j=0;$j<15;$j++){
	print "<td align=right>".$achat[$j]."</td>";
}
print "</tr>";

print "<tr class=\"info\">";
print "<th>Variation</th>";
for ($i=7;$i<13;$i++){
	$date_ref=&get("select last_day ('2015-$i-01')");
	print "<td align=right>$date_ref</td>";
}
for ($i=1;$i<10;$i++){
	$date_ref=&get("select last_day ('2016-$i-01')");
	print "<td align=right>$date_ref</td>";
}
print "</tr>";
foreach $client (@base_liste){
	$j=0;
	print "<tR><td><span style=font-weight:bold>$client</td><td>&nbsp;</td>";
	for ($j=1;$j<15;$j++){
		$stock=&get("select stock from ctl_stck_tmp where base='$client' and j=$j-1")+0;
		$variation=&get("select achat-vendu from ctl_stck_tmp where base='$client' and j=$j")+0;
		$variation+=$stock;
		print "<td align=right>$variation</td>";
		$variation[$j]+=$variation;
	}
	print "</tr>";
	print "<tr style=background-color:pink><td><span style=font-weight:bold>Ecart</td><td>&nbsp;</td>";
	for ($j=1;$j<15;$j++){
		$stock=&get("select stock from ctl_stck_tmp where base='$client' and j=$j-1")+0;
		$variation=&get("select achat-vendu from ctl_stck_tmp where base='$client' and j=$j")+0;
		$variation+=$stock;
		$stock_theo=&get("select stock from ctl_stck_tmp where base='$client' and j=$j")+0;
        $ecart=$variation-$stock_theo;
		print "<td align=right>$ecart</td>";
		$variation[$j]+=$variation;
	}
	print "</tr>";
	
}
print "<tr style=font-weight:bold><td>&nbsp;</td>";
for ($j=0;$j<15;$j++){
	print "<td align=right>".$variation[$j]."</td>";
}
print "</tr>";	


print "</table>";


print "		
</div>";

