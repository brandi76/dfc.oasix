print "<title>Statitique par bon</title>";
$devise="Eu";
$appro_1=$html->param("appro_1");
$appro_2=$html->param("appro_2");
$dest=$html->param("dest");
$famille=$html->param("famille");
$avecliste=$html->param("avecliste");

if ($famille eq ""){$famille=-1;}
if ($appro_2 eq $appro_1){$appro_2=$appro_1;}
print "<center><form> <table border=1 cellspacing=0 cellpadding=10 style=font-size:9pt;><tr><th>Premier bon d'appro</th><th>Dernier bon d'appro</th><th>Destination (facultatif)</th><th>Famille</th>";
print "</tr> ";
print "<tr><td><input type=texte name=appro_1 size=5 value='$appro_1'></td><td><input type=texte name=appro_2 size=5  value='$appro_2'></td><td><input type=texte name=dest size=5  value='$dest'></td><td>";
$query="select fa_id,fa_desi from famille order by fa_id";
$sth = $dbh->prepare($query);
$sth->execute;
%table_famille=();
while (($fa_id,$desi_famille) = $sth->fetchrow_array) {
	$table_famille{$fa_id}="$desi_famille";
}
print "<select name=famille>";
print "<option value=-1";
if ($famille == -1) { print " selected";}
print ">Toutes</option>";
foreach $i (keys(%table_famille)){
	print "<option value=$i";
	if ($i == $famille) { print " selected";}
	print ">$table_famille{$i}</option><br>";
}
print "</select>";

print "</td></tr> ";
print "</table>";
require ("form_hidden.src");

print "Avec la liste <input type=checkbox name=avecliste><input type=hidden name=action value=go ><input type=submit ></form>";

if ($appro_1 ne "") {
	$query="select distinct v_code from vol where v_code>='$appro_1' and v_code<='$appro_2' and v_dest like \"%$dest%\"";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code)=$sth->fetchrow_array){
		push (@liste,$v_code);
		$nb_de_vol++;
		$query="select ro_cd_pr,sum(ro_qte),pr_type,ap_prix,ap_qte0 from rotation,produit,appro where ro_code='$v_code'  and ro_cd_pr=pr_cd_pr and ap_cd_pr=pr_cd_pr and ap_code=ro_code group by ro_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$pass=0;
		while (($ro_cd_pr,$ro_qte,$pr_type,$ap_prix,$ap_qte0)=$sth2->fetchrow_array){
			$pr_famille=&get("select pr_famille from produit_plus where pr_cd_pr='$ro_cd_pr'")+0;
			if ($famille !=-1){ 
				if ($pr_famille!=$famille){next;}
				$pr_famille=$ro_cd_pr;
				if ($ro_qte==$ap_qte0){$rupture{$pr_famille}=$rupture{$pr_famille}+1;}else{$rupture{$pr_famille}=$rupture{$pr_famille}+0;}
			}
			$vente{$pr_famille}+=int($ro_qte/100);
			$total_qte+=int($ro_qte/100);
			$ca{$pr_famille}+=int($ro_qte*$ap_prix/10000);
			$total_ca+=int($ro_qte*$ap_prix/10000);
			if (($pass==0)&&($ap_prix!=0)){$pass++;$nb_avec_ca++;}
		}
	}
	$ca_moyen=0;
	if ($nb_avec_ca!=0) {$ca_moyen=int($total_ca/$nb_avec_ca);}
	$nb_zero=$nb_de_vol-$nb_avec_ca;
	print " Nombre de bon traite:$nb_de_vol Nombre de bon a zero:$nb_zero Moyenne:$ca_moyen <br><br>";
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}	
	print " <div id=\"chart_div\" ></div><br>";
	print " <div id=\"chart2_div\"></div><br>";

	if ($avecliste eq "on"){
	print  "<table id=\"petit\" border=1 cellspacing=0 cellpadding=0><tr bgcolor=#5580ab><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Troncon</th></tr>";
	foreach $v_code (@liste){
		$query="select v_date_jl,v_vol,v_cd_cl,v_troltype,v_dest from vol where v_code='$v_code' and  v_rot=1";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($v_date,$v_vol,$v_cd_cl,$v_troltype,$v_dest)=$sth2->fetchrow_array ;
		$datef=&julian($v_date,"yyyy/mm/dd");
		print  "<tr><td><b>";
		($cl_nom)=split(/;/,$client_dat{$v_cd_cl});
		print  $cl_nom;
		print  "</td>";
		$query="select lot_conteneur from lot where lot_nolot=$v_troltype";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($lot_conteneur)=$sth3->fetchrow_array;
		print  "<td align=center><font>$v_code $v_vol $datef</a></td><td align=center>$v_troltype $lot_conteneur</td>";
		print "<td >";
		print "$v_dest ";
		print &get("select v_vol from vol where v_code='$v_code' and v_rot=2");
		print " ";
		print &get("select v_vol from vol where v_code='$v_code' and v_rot=3");
		print "</td></tr>";
		print  "</tr>\n";
	}
	print "</table>";
	}
	print "fin";
	
print "
	 <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>
    <script type=\"text/javascript\">

      // Load the Visualization API and the piechart package.
      google.load('visualization', '1.0', {'packages':['corechart']});

      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawChart);

      function drawChart() {

        // Create the data table.
        var data = new google.visualization.DataTable();
       data.addColumn('string', 'Topping');
	data.addColumn('number', 'Slices');
        data.addRows([";
foreach $cle (sort(keys(%vente))){
	if ($famille==-1){
		$desi=&get("select fa_desi from famille where fa_id='$cle'");
	}
	else
	{
			$desi=&get("select pr_desi from produit where pr_cd_pr='$cle'");
			$pour=0;
			if ($total_qte !=0){$pour=int($vente{$cle}*100/$total_qte);}
			$desi="$desi $pour % rup:$rupture{$cle}";
	}
	print "['$desi', $vente{$cle}],";
}
print "
        ]);

        // Set chart options
	
        var options = {'title':'Repartition par famille total qte:$total_qte',
			legend:{position: 'right', textStyle: {fontSize: 10}},
			chartArea:{left:5,top:20,width:\"100%\",height:\"95%\"},
			backgroundColor:{strokeWidth:2},
                       'width':800,
                       'height':400};

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
        data.sort({column:1,desc:true});
        chart.draw(data, options);
       
	var data2 = new google.visualization.DataTable();
	data2.addColumn('string', 'Topping');
	data2.addColumn('number', 'Slices');
	data2.addRows([";
foreach $cle (keys(%ca)){
	if ($famille==-1){
		$desi=&get("select fa_desi from famille where fa_id='$cle'");
	}
	else
	{
			$desi=&get("select pr_desi from produit where pr_cd_pr='$cle'");
			$pour=0;
			if ($total_qte !=0){$pour=int($vente{$cle}*100/$total_qte);}
			$desi="$desi $pour %";
	}
	print "['$desi', $ca{$cle}],";
}
print "
        ]);

        // Set chart options
        var options = {'title':'Repartition par chiffre d affaire ca:$total_ca',
			legend:{position: 'right', textStyle: {fontSize: 10}},
			chartArea:{left:5,top:20,width:\"100%\",height:\"95%\"},
			backgroundColor:{strokeWidth:2},
                       'width':800,
                       'height':400};

        // Instantiate and draw our chart, passing in some options.
        var chart2 = new google.visualization.PieChart(document.getElementById('chart2_div'));
        data2.sort({column:1,desc:true});
       chart2.draw(data2, options);
        
        
      }
</script>";

print "</center>";
	
}
;1
