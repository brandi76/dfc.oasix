#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";

@bases_client=("aircotedivoire");
$an_1=2016;
$an=2017;

print <<EOF;	
 <script type="text/javascript"
          src="https://www.google.com/jsapi?autoload={
            'modules':[{
              'name':'visualization',
              'version':'1',
              'packages':['corechart']
            }]
          }"></script>

    <script type="text/javascript">
      google.setOnLoadCallback(drawChart);

      function drawChart() {
EOF
	print " 	  
        var data = google.visualization.arrayToDataTable([
          ['Mois'";
	foreach $client (@bases_client){
		print",'$client'";
	}
	print "	],";
&run();

print <<EOF;
		  ]);

        var options = {
          title: 'CA moyen par vol $client',
		  curveType: 'function',
		  hAxis: {textStyle: { fontSize: 8}},
		  legend: { position: 'bottom' }
        };

        var chart = new google.visualization.LineChart(document.getElementById('graph'));
        chart.draw(data, options);
EOF

	
print "}</script>";

print "<div id=\"graph\" style=\"width: 900px; height: 500px\"></div>";

sub run(){
	$ca=$achat=0;
	for ($mois=0;$mois<=53;$mois++){
		print "['$mois/$an_1'";
		foreach $client (@bases_client){
			print "ici";
			$ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an_1 and weekofyear(v_date_sql)='$mois' and ca_total!=0","aff")+0;
			print ",$ca";
		}
		print "],";
	}
	for ($mois=0;$mois<=53;$mois++){
		print "['$mois/$an'";
		foreach $client (@bases_client){
			$ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an and weekofyear(v_date_sql)='$mois' and ca_total!=0 '")+0;
			print ",$ca";
		}
		print "],";
	}	

}	


;1
