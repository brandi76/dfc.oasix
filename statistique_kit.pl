print "<title>statistique</title>";
$client=$html->param("client");
$four=$html->param("four");
$action=$html->param("action");
$option=$html->param("option");
$famille=$html->param("famille");
$graphique=$html->param("graphique");
$vol=uc($html->param("vol"));
$trolley=$html->param("trolley");
$escale=$html->param("escale");
$ca=$html->param("ca");

$premiere=$html->param("premiere");
$derniere=$html->param("derniere");

($an,$mois,$jour)=split('-',$premiere);
$premiere_jl=&nb_jour($jour,$mois,$an);
($an,$mois,$jour)=split('-',$derniere);
$derniere_jl=&nb_jour($jour,$mois,$an);

while ($famille=~s/"//){};

$mois=$html->param("mois");

if (($famille eq "tout")||($action eq "histogramme")){$famille="%";}
if ($mois eq "tout"){$mois="vdu_mois";}
if ($client eq "tout"){$client="v_cd_cl";}
if ($four eq "tout"){$four="pr_four";}
if ($vol eq "TOUT"){$vol="%";}
if ($trolley eq "TOUT"){$trolley="%";}
$dest="%";
if ($escale eq "on"){$dest="LYS%' or v_dest like 'MRS%";}

require "./src/connect.src";
my(@liste)=("Tout","Parfum","Alcool","Cigarette","Boutique","Cosmetique");
if ($action eq ""){
	print "<center><div class=titre>statistique</div> <br><form>";
	require ("form_hidden.src");
	print "<table border=2 width=70% cellspacing=0><tr><td align=center>";
	$sth = $dbh->prepare("select distinct cl_cd_cl,cl_nom from client,vol where cl_cd_cl=v_cd_cl ");
    	$sth->execute;
   	print "<br>Client<br><select name=client>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[1]\n";
       	}
  	print "<option SELECTED value=tout>TOUT\n";
    	print "</select><br>\n";
    	
   	print "<br>Famille <br><select name=famille>\n";
    	for (my($i)=1;$i<=$#liste;$i++){
		print "<option value=$i";
		print ">$liste[$i] $i</option><br>";
       	}
  	print "<option SELECTED value=tout>TOUT\n";
    	print "</select><br>\n";
	print "<br>Fournisseur<br><select name=four><option value='tout'>TOUT</option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
	print "</select><br>\n";
    	    	
	print "<br>No Vol <input type=texte name=vol value=TOUT><br>";
    	print "<br>Trolley type<input type=texte name=trolley value=TOUT><br>";
    	print "<br>Escale <input type=checkbox name=escale><br>";
    	
    	$now=&get("select curdate()");
	$now2=&get("select DATE_ADD(curdate(),INTERVAL 5 DAY)");
	print "
	<br>premiere date AAAA-MM-JJ :<input type=text size=10 name=premiere value=$now>
	<br>
	derniere date AAAA-MM-JJ :<input type=text size=10 name=derniere value=$now2>
	<br>";
    	print "<br>classement par chiffre d'affaire <input type=checkbox name=ca><br>";
    	print "Graphique <input type=checkbox name=graphique><br>";
    	print "<input type=submit name=action value=ranking>";
    	print " <input type=submit name=action value=histogramme></form>";
	print "</td></tr></table>";
}
if (($action eq "ranking")||($action eq "histogramme")){
    	$cl_nom=&get("select cl_nom from client,vol where cl_cd_cl=$client and cl_cd_cl=v_cd_cl","af");
    	if ($client eq "v_cd_cl"){$cl_nom="TOUT";}
	$four2=$four;
    	if ($four eq "pr_four"){$four2=0;}
    	$fo_add=&get("select fo2_add from fournis where fo2_cd_fo=$four2","af");
	if ($four eq "pr_four"){$fo_add="TOUT";}
    	print "<center><div class=titre>$action @liste[$famille] pour le client:$cl_nom du $premiere au $derniere et le fournisseur:$fo_add</div><br><br>";

    	if ($action eq "ranking") {
		$query="select pr_cd_pr,pr_desi,sum(ro_qte)/100 as qte from rotation,vol,produit where ro_code=v_code and v_rot=1 and ro_cd_pr=pr_cd_pr and v_cd_cl=$client and pr_four=$four and v_date_sql>='$premiere' and v_date_sql<='$derniere' and pr_type like '$famille' and v_vol like '$vol' and v_troltype like '$trolley' and (v_dest like '$dest') group by ro_cd_pr order by qte desc";
		if ($ca eq "on") {$query="select pr_cd_pr,pr_desi,floor(sum(ap_prix*ro_qte)/10000) as qte,floor(sum(ro_qte)/100) from rotation,vol,produit,appro where ro_code=v_code and v_rot=1 and ro_cd_pr=pr_cd_pr and v_cd_cl=$client and pr_four=$four and v_date_jl>='$premiere_jl' and v_date_jl<='$derniere_jl' and pr_type like '$famille' and v_vol like '$vol' and v_troltype like '$trolley' and (v_dest like '$dest') and ap_code=ro_code and ap_cd_pr=ro_cd_pr group by ro_cd_pr order by qte desc";}
#  		print "$query";
		$sth = $dbh->prepare($query);
		$sth->execute;
		if ($graphique eq "on"){
		  print "<table border=0 cellspacing=2 cellpadding=0>";
		  while (($pr_cd_pr,$pr_desi,$qte,$qte2) = $sth->fetchrow_array) {
			  if ($max==0){$max=$qte;}
			  if ($qte<=0){$qte=1;}
			  $width=$qte*450/$max;
			  # print "$qte $width $max<br>";                                                                                                                                        
			  print "<tr><td width=250><div class=trespetit>$pr_cd_pr,$pr_desi</div></td><td width=450><table border=0 cellspacing=0 cellpadding=0 width=$width><tr><td background=\"/kit/images/rank.jpg\" align=left>&nbsp;$qte</td><td align=left>$qte2</td></tr></table></td></tr>";
		  }
		  print "</table>";	
		}
		else
		{
		  print "<table border=1 cellspacing=0 cellpadding=0><tr><th>Code</th><th>Designation</th><th>Qte</th><th>Ca</th></tr>";
		  while (($pr_cd_pr,$pr_desi,$qte,$qte2) = $sth->fetchrow_array) {
			if ($qte<=0){$qte=1;}
			$qte=int($qte);
			print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=left>$qte</td><td align=left>$qte2</td></tr>";
		  }
		  print "</table>";	
		}
	}
	if ($action eq "histogramme") {
		foreach ($i=1;$i<=$#liste;$i++){
			$somme[$i]=0+&get("select sum(ro_qte)/100 as qte from rotation,vol,produit where ro_code=v_code and v_rot=1 and ro_cd_pr=pr_cd_pr and v_cd_cl=$client and pr_four=$four and v_date_jl>='$premiere_jl' and v_date_jl<='$derniere_jl' and pr_type like '$i' and v_vol like '$vol' and v_troltype like '$trolley' and (v_dest like '$dest') group by pr_type","af");
			# print "$liste[$i] $somme[$i] <br>";
			$total+=$somme[$i];
		}
		foreach ($i=1;$i<=$#somme;$i++){
			$pour=0;
			if ($total!=0){
				$pour=int($somme[$i]*100/$total);
			}
			if (($pour==0)&&($somme[$i]>0)){$pour=1;}
			if ($somme[$i]!=0){$param.=$liste[$i]."+$pour=".$somme[$i]."&";}
		}
		print "<img src=\"http://ibs.oasix.fr/Artichow-php5/examples/pie-009.php?".$param.">";
	}
	$query="select v_code,v_vol,v_date from vol where v_rot=1  and v_cd_cl=$client and v_date_jl>='$premiere_jl' and v_date_jl<='$derniere_jl' and v_vol like '$vol' and v_troltype like '$trolley' and (v_dest like '$dest') order by v_code";
	$sth = $dbh->prepare($query);
	$sth->execute;
	print "<br><br>";
	print "<table border=1 cellspacing=0><tr><th>Appro</th><th>No de vol</th><th>date</th><th>Valeur CA</th>";
	while (($v_code,$v_vol,$v_date) = $sth->fetchrow_array) {
		# $ca=&get("select sum(ca_total) from caissesql where ca_code='$v_code'","af")+0;
		#modifié par philippe le 24/08/2013
		$ca=&get("select sum((ret_qtepnc-ret_retour)*ret_prix) from retoursql where ret_code=$v_code")+0;
		if ($ca==0) {next;}
		print "<tr><td>$v_code</td><td>$v_vol</td><td>$v_date</td><td>";
		print "$ca</td></tr>";
		$nbvol++;
		$totalg+=$ca;
	}
	if ($nbvol!=0){
		$moy=int($totalg/$nbvol);
	}
	print "<tr><th>Nombre de vol</th><th>$nbvol</th><th>moyenne</th><th>$moy</th></tr></table>";

=pod
cammenbert a 12 part
	$total=0;
	$i=0;
	$query="select pr_cd_pr,pr_desi,sum(ro_qte)/100 as qte from rotation,vol,produit where ro_code=v_code and v_rot=1 and ro_cd_pr=pr_cd_pr and v_cd_cl='$client' and v_date_jl>='$premiere_jl' and v_date_jl<='$derniere_jl' and pr_type like '$famille' group by ro_cd_pr order by qte desc";
	print $query;
	$sth = $dbh->prepare($query);
	$sth->execute;
	while (($pr_cd_pr,$pr_desi,$qte) = $sth->fetchrow_array) {
		if ($i<12){
			while ($pr_desi=~s/ /_/){};
			$histo{$pr_desi}=$qte;
		}
		else
		{
			$histo{"autres"}+=$qte;
		}
		$total+=$qte;
		$i++;
	}
	foreach $cle (%histo){
		$pour=int($histo{$cle}*100/$total);
		if (($pour==0)&&($histo{$cle}>0)){$pour=1;}
		if ($histo{$cle}!=0){$param.=$cle."+$pour=".$histo{$cle}."&";}
	}
	print "<img src=\"http://ibs.oasix.fr/Artichow-php5/examples/pie-009.php?".$param.">";
=cut
}
;1
        
