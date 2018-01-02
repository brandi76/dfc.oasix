#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");

@base_liste=("togo","aircotedivoire","camairco","tacv","cameshop","dutyfreeambassade");

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
print "<th>Stock</th>";

for ($i=7;$i<13;$i++){
	$date_ref=&get("select last_day ('2015-$i-01')");
	print "<td align=right>$date_ref</td>";
}
for ($i=1;$i<13;$i++){
	$date_ref=&get("select last_day ('2016-$i-01')");
	print "<td align=right>$date_ref</td>";
}

for ($i=1;$i<12;$i++){
	$date_ref=&get("select last_day ('2017-$i-01')");
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
		$j++;
	}
	for ($i=1;$i<13;$i++){
		$date_ref=&get("select last_day ('2016-$i-01')");
		$stock=&get("select sum(qte*prac) from dfc.stock_mensuel where base='$client' and date='$date_ref'");
		$stock=int($stock);
		#$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where an=2016 and mois=$i")+0);
		print "<td align=right>$stock</td>";
		$stock[$j]+=$stock;
		$j++;
	}
	for ($i=1;$i<12;$i++){
		$date_ref=&get("select last_day ('2017-$i-01')");
		$stock=&get("select sum(qte*prac) from dfc.stock_mensuel where base='$client' and date='$date_ref'");
		$stock=int($stock);
		#$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where an=2016 and mois=$i")+0);
		print "<td align=right>$stock</td>";
		$stock[$j]+=$stock;
		$j++;
	}
	
	print "</tr>";
}
print "<tr style=font-weight:bold><td>&nbsp;</td>";
for ($j=0;$j<29;$j++){
	print "<td align=right>".$stock[$j]."</td>";
}
print "</tr>";

print "<thead>";
print "<tr class=\"info\">";
print "<th>Vendu</th>";

for ($i=7;$i<13;$i++){
	$date_ref=&get("select last_day ('2015-$i-01')");
	print "<td align=right>$date_ref</td>";
}
for ($i=1;$i<13;$i++){
	$date_ref=&get("select last_day ('2016-$i-01')");
	print "<td align=right>$date_ref</td>";
}
for ($i=1;$i<11;$i++){
	$date_ref=&get("select last_day ('2017-$i-01')");
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
		$j++;
	}
	for ($i=1;$i<13;$i++){
		$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where base='$client' and an=2016 and mois=$i")+0);
		$vendu=int($vendu);
		print "<td align=right>$stock</td>";
		$vendu[$j]+=$vendu;
		$j++;
	}
	for ($i=1;$i<12;$i++){
		$vendu=int(&get("select sum(qte*prac) from vendu_mensuel where base='$client' and an=2017 and mois=$i")+0);
		$vendu=int($vendu);
		print "<td align=right>$stock</td>";
		$vendu[$j]+=$vendu;
		$j++;
	}
	
	print "</tr>";
}
print "<tr style=font-weight:bold><td>&nbsp;</td>";
for ($j=0;$j<15;$j++){
	print "<td align=right>".$vendu[$j]."</td>";
}
print "</tr>";


print "</table>";

print "		
</div>";

