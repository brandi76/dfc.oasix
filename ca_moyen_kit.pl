@bases_client=("camairco","aircotedivoire","togo","tacv");
print "<form>";
&form_hidden();
print "Filtrer par rapport à une destination (trigramme) <input type=texte name=dest size=3><br>";
print "<input type=submit></form>";
$dest=$html->param("dest");
print "<h3>$dest</h3>";
$maxi=&get("select month(curdate())");
$maxi-=1;
$maxi=12 if ($maxi==-1);
$an=&get("select year(curdate())");
if ($maxi==1){$an-=1;}
$an_1=$an-1;

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
	for ($mois=1;$mois<=12;$mois++){
		print "['$mois/$an_1'";
		foreach $client (@bases_client){
			$ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an_1 and month(v_date_sql)='$mois' and ca_total!=0 and v_dest like '%$dest%'")+0;
			print ",$ca";
		}
		print "],";
	}
	for ($mois=1;$mois<=$maxi;$mois++){
		print "['$mois/$an'";
		foreach $client (@bases_client){
			$ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an and month(v_date_sql)='$mois' and ca_total!=0 and v_dest like '%$dest%'")+0;
			print ",$ca";
		}
		print "],";
	}	

}	


;1
