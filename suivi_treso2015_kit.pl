print "Achat=Date d'echeance<br>";
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	&save("create temporary table enso_$client (
 `es_cd_pr` bigint(16) NOT NULL DEFAULT '0',
 `es_no_do` int(11) NOT NULL DEFAULT '0',
  `es_dt` date NOT NULL,
  `es_qte` int(11) NOT NULL DEFAULT '0',
  `pr_prac` decimal(8,0) NOT NULL DEFAULT '0',
  
  PRIMARY KEY (`es_cd_pr`,`es_no_do`,`es_dt`)
)");
	&save("insert into enso_$client select  es_cd_pr,es_no_do,adddate(es_dt,interval fo_delai_pai day),es_qte_en,pr_prac from $client.enso,dfc.fournis,$client.produit where es_cd_pr=pr_cd_pr and pr_four=fo2_cd_fo and es_qte_en>0");
}
$maxi=12;

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
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	print " 	  
        var data = google.visualization.arrayToDataTable([
          ['Mois', 'Achat', 'Vente','43% vente'],";
&run();

print <<EOF;
		  ]);

        var options = {
          title: 'Cumul Achat et Vente par mois $client',
          legend: { position: 'bottom' }
        };

        var chart = new google.visualization.LineChart(document.getElementById('$client'));
        chart.draw(data, options);
EOF
}

print " 	  
        var data = google.visualization.arrayToDataTable([
          ['Mois', 'Achat', 'Vente','43% vente'],";
&run_cumul();
print <<EOF;
		  ]);

        var options = {
          title: 'Cumul Achat et Vente par mois Cumul',
          legend: { position: 'bottom' }
        };

        var chart = new google.visualization.LineChart(document.getElementById('cumul'));
        chart.draw(data, options);
EOF
	
print "}</script>";
foreach $client (@bases_client){
	if ($client eq "dfc"){next;}
	print "<div id=\"$client\" style=\"width: 900px; height: 500px\"></div>";
}	
print "<div id=\"cumul\" style=\"width: 900px; height: 500px\"></div>";

sub run(){
	$ca=$achat=0;
	for ($mois=1;$mois<=$maxi;$mois++){
		$ca+=&get("select sum(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=2015 and month(v_date_sql)='$mois'");
		$achat+=&get("select sum(es_qte*pr_prac/10000) from enso_$client where year(es_dt)=2015 and month(es_dt)='$mois'");
		$q=43*$ca/100;
		print "['$mois',$achat,$ca,$q],";
	}	

}	

sub run_cumul(){
	$ca=$achat=0;
	for ($mois=1;$mois<=$maxi;$mois++){
		foreach $client (@bases_client){
			if ($client eq "dfc"){next;}
			$ca+=&get("select sum(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=2015 and month(v_date_sql)='$mois'");
			$achat+=&get("select sum(es_qte*pr_prac/10000) from enso_$client where year(es_dt)=2015 and month(es_dt)='$mois' ");
		}
		$q=43*$ca/100;
		print "['$mois',$achat,$ca,$q],";
	}	
}	

;1
