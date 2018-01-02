$firstdate=$html->param("firstdate");
$lastdate=$html->param("lastdate");
if (grep(/\//,$firstdate)) {
	($jj,$mm,$aa)=split(/\//,$firstdate);
	$firstdate=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$lastdate)) {
	($jj,$mm,$aa)=split(/\//,$lastdate);
	$lastdate=$aa."-".$mm."-".$jj;
}


if ($action eq ""){
  print "Copie du planning<br><form>";
  &form_hidden();
  print "<br>Premiere date du planning<input id=\"datepicker\" type=text name=firstdate size=12>";
  print "<br>copier jusqu'a <input id=\"datepicker2\" type=text name=lastdate size=12>";
  print "<br><input type=submit>"; 
  print "<input type=hidden name=action value=go>";
  print "</form>";	
}

  
if ($action eq "go"){
  if ($lastdate eq ""){exit;}
  for($i=0;$i<7;$i++){
    $daterun=&get("select adddate('$firstdate',$i)");
    $query="select * from flyhead where fl_date_sql='$daterun'";
    $dayname=&get("select dayname('$daterun')");
    print "<strong>$dayname $daterun</strong><br>";
  
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($fl_date,$fl_vol,$fl_cd_cl,$fl_nbrot,$fl_troltype,$fl_nbtrol,$fl_troltypebis,$fl_nolot,$fl_part,$fl_apcode,$fl_date_sql)=$sth->fetchrow_array){
      $dateanc=$daterun;
      $datenewsql=&get("select adddate('$dateanc',7)");
      while (&get("select datediff('$datenewsql','$lastdate')")<=0){
	($an,$mois,$jour)=split(/-/,$datenewsql);
	$datejl=&nb_jour($jour,$mois,$an);
        &save("insert ignore into flyhead values ('$datejl','$fl_vol','$fl_cd_cl','$fl_nbrot','$fl_troltype','$fl_nbtrol','$fl_troltypebis','','$fl_part','','$datenewsql')","af");
# 	print "insert ignore into flyhead values ('$datejl','$fl_vol','$fl_cd_cl','$fl_nbrot','$fl_troltype','$fl_nbtrol','$fl_troltypebis','','$fl_part','','$datenewsql')<br>";
	print "$datenewsql $fl_vol<br>";
	$query="select * from flybody where flb_vol='$fl_vol' and flb_date=$fl_date";  
	$sth3=$dbh->prepare($query);
	$sth3->execute();
	while (($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=$sth3->fetchrow_array){
	  $datetrjl=$datejl+$flb_datetr-$flb_date;
    	&save("insert ignore into flybody values ('$datejl','$flb_vol','$flb_rot','$datetrjl','$flb_voltr','$flb_depart','$flb_arrivee','$flb_tridep','$flb_triret','$flb_nolot')","af");
# 	  print "insert ignore into flybody values ('$datejl','$flb_vol','$flb_rot','$datetrjl','$flb_voltr','$flb_depart','$flb_arrivee','$flb_tridep','$flb_triret','$flb_nolot')<br>";
	}
	$datenewsql=&get("select adddate('$datenewsql',7)");
      }  
    }
  }    
}
;1
