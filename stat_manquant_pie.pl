print "<title>Statitique par bon</title>";
$devise="Eu";
$appro_1=$html->param("appro_1");
$appro_2=$html->param("appro_2");
$dest=$html->param("dest");
$type=$html->param("type");
$famille=$html->param("famille");
$avecliste=$html->param("avecliste");
$option=$html->param("option");
$marge=$html->param("marge");

if ($type eq "") {$type="v_troltype";}
if ($famille eq ""){$famille=-1;}
if ($appro_2 eq $appro_1){$appro_2=$appro_1;}
print "<center><form> <table border=1 cellspacing=0 cellpadding=10 style=font-size:9pt;><tr><th>Premier bon d'appro</th><th>Dernier bon d'appro</th><th>Destination(facultatif)</th><th>Trolley type (facultatif)</th>";
print "</tr> ";
print "<tr><td><input type=texte name=appro_1 size=5 value='$appro_1'></td><td><input type=texte name=appro_2 size=5  value='$appro_2'></td><td><input type=texte name=dest size=5  value='$dest'></td><td><input type=texte name=type size=5 ";
if ($type ne "v_troltype"){print " value='$type'";}
print "></td>";

print "</tr> ";
print "</table>";
require ("form_hidden.src");

print "Avec la liste <input type=checkbox name=avecliste><input type=hidden name=action value=go ><input type=submit ></form>";

if ($appro_1 ne "") {
	$query="select distinct v_code,v_troltype from vol where v_code>='$appro_1' and v_code<='$appro_2' and v_dest like \"%$dest%\" and v_troltype=$type and v_rot=1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_troltype)=$sth->fetchrow_array){
		push (@liste,$v_code);
		$nb_de_vol++;
 		$mag=&get("select lot_mag from lot where lot_nolot='$v_troltype' and lot_mag in (select mag from mag)");
		$query="select tr_cd_pr from trolley where tr_code=$v_troltype";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$manquant=0;
		$nb=0;
		while (($tr_cd_pr)=$sth2->fetchrow_array){
			if ($mag ne ""){
			  $check=&get("select count(*) from mag where mag='$mag' and code='$tr_cd_pr'","af")+0;
			  if ($check==0){next;}
			}  
			$qte=&get("select ap_qte0 from appro where ap_code='$v_code' and ap_cd_pr='$tr_cd_pr'")+0;
			if ($qte==0){$manquant++;}
			$nb+=$qte/100;
		}	
#  		print "$v_code $nb $manquant<br>";
		if ($nb >0){
		  $ratio=int($manquant*100/$nb);
		  if ($ratio > 50){$vente{">50%"}++;}
		  elsif ($ratio >30){$vente{">30%"}++;}
		  elsif ($ratio >20){$vente{">20%"}++;}
		  elsif ($ratio >10){$vente{">10%"}++;}
		  elsif ($ratio >5){$vente{">5%"}++;}
		  elsif ($ratio >2){$vente{">2%"}++;}
		  else {$vente{"<=2%"}++;}
		  $appro{"$v_code"}=$ratio;
		}  
	}
	print " Nombre de bon traite:$nb_de_vol <br><br>";
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}	
 	if ($avecliste eq "on"){
 	print  "<table id=\"petit\" border=1 cellspacing=0 cellpadding=0><tr bgcolor=#5580ab><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Troncon</th><th>manquant/Nb produit</th></tr>";
 	foreach $v_code (@liste){
		$query="select v_date_jl,v_vol,v_cd_cl,v_troltype,v_dest, v_troltype from vol where v_code='$v_code' and  v_rot=1";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($v_date,$v_vol,$v_cd_cl,$v_troltype,$v_dest,$v_troltype)=$sth2->fetchrow_array ;
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
		print "$v_dest $v_troltype ";
		print &get("select v_vol from vol where v_code='$v_code' and v_rot=2");
		print " ";
		print &get("select v_vol from vol where v_code='$v_code' and v_rot=3");
		print "</td><td>";
		print $appro{"$v_code"};
		print "%</td><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&option=liste&appro_1=$appro_1&appro_2=$appro_2&dest=$dest&type=$type&avecliste=$avecliste&action=go&appro=$v_code&troltype=$v_troltype>Liste</a></td></tr>";
		print  "</tr>\n";
	}
	print "</table><br>";
	}
	
	
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
	print "['$cle', $vente{$cle}],";
}
print "
        ]);

        // Set chart options
	
        var options = {'title':'Pourcentage de manquant par rapport au nombre de produit embarqué sur  les vols',
			legend:{position: 'right', textStyle: {fontSize: 10}},
			chartArea:{left:5,top:20,width:\"100%\",height:\"95%\"},
			backgroundColor:{strokeWidth:2},
                       'width':800,
                       'height':400};

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
        data.sort({column:1,desc:true});
        chart.draw(data, options);
       
         
        
      }
</script>";
	print " <div id=\"chart_div\" ></div><br>";

print "</center>";
if ($option eq "liste"){
		print "Liste des manquants<br>";
		$troltype=$html->param("troltype");
		$appro=$html->param("appro");
		$query="select tr_cd_pr,pr_desi,tr_qte/100 from trolley,produit where tr_code='$troltype' and tr_cd_pr=pr_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($tr_cd_pr,$pr_desi,$tr_qte)=$sth2->fetchrow_array){
			$qte=&get("select ap_qte0 from appro where ap_code='$appro' and ap_cd_pr='$tr_cd_pr'")+0;
			if ($qte==0){
				print "$tr_cd_pr $pr_desi $tr_qte<br>";
			}	
		}	
}
	
}
;1
