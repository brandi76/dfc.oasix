if ($action eq ""){
  print "<form>";
  &form_hidden();
  foreach $client (@bases_client){
    if ($client ne "dfc"){
      print "$client <input type=checkbox name=$client><br>";
    }
  }
  print "Periode de l'etude, les derniers <input type=text size=3 name=periode value=120> jours<br>";
  print "Best sellers ratio vente/presence > <input type=text size=3 name=best value=0.3>%<br>";
  print "Stock mort ratio vente/presence < <input type=text size=3 name=mort value=0.1>%<br>";
  print "Avec le detail <input type=checkbox name=detail><BR>";
  print "<input type=hidden name=action value=go>";
  print "<input type=submit>";
  print "</form>";
}

if ($action eq "go"){
  $first=1;
  $best=$html->param("best");
  $mort=$html->param("mort");
  $periode=$html->param("periode");
  $detail=$html->param("detail");
  if ($detail eq "on"){$detail="block";}else{$detail="none";}
  foreach $client (@bases_client){
    if ($client eq "dfc"){next;}
    if ($html->param("$client") eq "on"){
	print "<table style=display:$detail><tr><td width=200 bgcolor=yellow>&nbsp;</td><td>Best seller ratio>$best (0.33 = vendu au moins 1 fois sur 3)</td></tr>";
	print "<td bgcolor=lightgreen>&nbsp;</td><td>Stock mort ratio<$mort (0.1 = vendu moins d'une fois sur 10 )</td></tr>";
	print "<td bgcolor=white>&nbsp;</td><td>Colone A:Nb de fois present sur un vol au cours des $periode derniers jours</td></tr>";
	print "<td bgcolor=white>&nbsp;</td><td>Colone B:Nb de fois present avec au moins une vente au cours des $periode derniers jours</td></tr>";
	print "</table>";
	print "<table style=display:$detail><tr><th>Etat</th><th>Designation</th><th>Actif</th><th>A</th><th>B</th><th>Stock</th><th>Prix</th><th>Valeur</th><th>Ratio</th></tr>";
	$query="select pr_cd_pr,pr_desi,pr_stre,pr_prac from $client.produit where pr_stre>0 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$pr_desi,$pr_stre,$pr_prac)=$sth->fetchrow_array){
	  $pr_prac/=100;
	  $pr_stre/=100;
	  $actif=&actif($code);
	  $mis=&put_stck($code);
	  $vendu=&get_stck($code);
	  $etat="";
	  $valeur=$pr_prac*$pr_stre;
	  if (($actif==0)&&($mis>10)){$etat="destockage";}
	  if (($actif==0)&&($mis==0)){$etat="delisté";}
	  if (($actif==1)&&($mis==0)){$etat="new";}
	  $color="white";
	  if ($mis>0){$ratio=int($vendu*100/$mis)/100;if ($ratio >0.3){$color="yellow";}if ($ratio <0.1){$color="lightgreen";}}
	  print "<tr bgcolor=$color><td>$etat</td><td>$pr_desi</td><td>$actif</td><td>$mis</td><td>$vendu</td><td>$pr_stre</td><td>$pr_prac</td><td>$valeur</td><td>$ratio</td></tr>";
	  if ($color eq "white"){$moyen{"$client"}+=$valeur;}
	  if ($color eq "lightgreen"){$bas{"$client"}+=$valeur;}
	  if ($color eq "yellow"){$haut{"$client"}+=$valeur;}
	}
	print "</table>";
    }
  }
  foreach $client (@bases_client){
    if ($client eq "dfc"){next;}
    if ($html->param("$client") eq "on"){
      $val_haut=$haut{"$client"}+0;
      $val_moyen=$moyen{"$client"}+0;
      $val_bas=$bas{"$client"}+0;
      if ($first){
      print "
      <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>
      <script type=\"text/javascript\">
      google.load('visualization', '1.0', {'packages':['corechart']});
      google.setOnLoadCallback(drawChart);
      function drawChart() {";
      }
      print "
      var data$client = new google.visualization.DataTable();
      data$client.addColumn('string', 'Topping');
      data$client.addColumn('number', 'Slices');
      data$client.addRows([['Best sellers',$val_haut],['Moyen sellers',$val_moyen],['Stock mort',$val_bas]]);
      var options = {'title':'$client',
		      legend:{position: 'right', textStyle: {fontSize: 10}},
		      chartArea:{left:5,top:20,width:\"100%\",height:\"95%\"},
		      backgroundColor:{strokeWidth:2},
		      'width':600,
		      'height':400};

      var chart$client = new google.visualization.PieChart(document.getElementById('chart$client'));
      data$client.sort({column:1,desc:true});
      chart$client.draw(data$client, options);
      ";
      if ($first){
      print "}
      </script>";
      }
      $first=1;
    }
  }
  foreach $client (@bases_client){
    if ($client eq "dfc"){next;}
    if ($html->param("$client") eq "on"){
      print " <div id=\"chart$client\" ></div><br>";
    }
 }   
}






sub actif(){
    my ($code)=$_[0];
    my ($nb)=0;
    $nb=&get("select count(*) from $client.trolley,$client.lot where lot_nolot=tr_code and lot_flag=1 and tr_qte>0 and tr_cd_pr=$code","af")+0;
    if ($nb >0){$nb=1;}
    return($nb);
}

sub put_stck(){
    my ($code)=$_[0];
    my ($delai)=$_[1];
    if ($delai+0==0){$delai=120;}
    my ($nb)=0;
    $nb=&get("select count(*) from $client.appro,$client.vol where ap_code=v_code and v_rot=1 and ap_cd_pr='$code' and ap_qte0>0 and datediff(curdate(),v_date_sql)<$delai")+0;
    return($nb);
}

sub get_stck(){
    my ($code)=$_[0];
    my ($delai)=$_[1];
    if ($delai+0==0){$delai=120;}
    my ($nb)=0;
    $nb=&get("select count(*) from $client.rotation,$client.vol where ro_code=v_code and v_rot=1 and ro_cd_pr='$code' and datediff(curdate(),v_date_sql)<$delai")+0;
    return($nb);
}
    

;1
  