print "<title>import oasix</title>";
$action=$html->param("action");
$oa_serial=$html->param("tpe");
$oa_date=$html->param("date");
$appro=$html->param("appro");
$parappro=$html->param("parappro");
$suraction=$html->param("suraction");

require "./src/connect.src";
	

if ($parappro ne ""){	
    $oa_serial=&get("select oaa_serial from oasix_appro where oaa_appro='$parappro'");
    $oa_date=&get("select oaa_date from oasix_appro where oaa_appro='$parappro'");
    $action="import";
    }

if ($suraction eq "del"){
	print "delete from oasix where oa_serial='$oa_serial' and oa_date_import='$oa_date'<br>";
	print "delete from oasix_appro where oaa_serial='$oa_serial' and oaa_date='$oa_date'<br>";
}
if (($action eq "affec")&&($appro ne "")){
	&save("replace into oasix_appro values ('$oa_serial','$oa_date','$appro')","af");
	$num=&get("select oa_num from oasix_tpe where oa_serial='$oa_serial'","af");
	&save("delete from vendusql where vdu_appro='$appro' and vdu_tpe='$num'","af");
	$sth = $dbh->prepare("select * from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import='$oa_date'");
    	$sth->execute;
    	
    	while ((@ligne) = $sth->fetchrow_array) {
		$oa_cd_pr=&get("select oa_cd_pr from oasix_prod where oa_desi='$ligne[5]'","af");
		if ($oa_cd_pr eq ""){
			print "produit non repertorié:$ligne[5]<br>";
		}
		if ($ligne[6]>0){
                $enplus=1;}
 		else { 
 			$enplus=-1;
 			$ligne[6]=0-$ligne[6]; 
 		}
 		
 		$total+=$enplus*$ligne[6];
    		$qte=&get("select vdu_qte from vendusql where vdu_appro='$appro' and vdu_tpe='$num' and vdu_cd_pr='$oa_cd_pr'","af")+$enplus;
    		$qte=&save ("replace into vendusql values ('$appro','$num','$oa_cd_pr','$qte','$ligne[6]')","af");
    	}
	$action="import";
}


if ($action eq "choixdate"){
	print "<center><div class=titre>Date des fichiers disponibles</div><br>";
	print "<form>";
  	require ("form_hidden.src");
	print "<br>Choisir une date <select name=date>\n";
	$query="select distinct oa_date_import from oasix where oa_type='p' and oa_serial='$oa_serial' order by oa_date_import desc";
	$sth = $dbh->prepare($query);
    	if ($sth->execute >0){
		while (($oa_date) = $sth->fetchrow_array) {
			print "<option value=$oa_date>";
			print "$oa_date\n";
		}
		print "</select><br>\n";
		print "<br><input type=hidden name=tpe value=$oa_serial>";
		print "<br><input type=hidden name=action value=import><input type=submit value=submit></form>";
	}
	else 
	{ 
		print "<font color=red> Aucune donnée ne correspond à votre demande</font><br>";
		$action="";
	}
}

if ($action eq ""){
	print "<center><div class=titre>Importation oasix</div><br>";
	print "<img src=/kit/images/tpe.jpg>";
	print "<br> Numero de tpe";
	print "<form>";
  	require ("form_hidden.src");
	$sth = $dbh->prepare("select oa_num,oa_serial from oasix_tpe");
    	$sth->execute;
   	print "<br><select name=tpe>\n";
    	while (($oa_num,$oa_serial) = $sth->fetchrow_array) {
       		print "<option value=$oa_serial>";
       		print "$oa_num\n";
       	}
    	print "</select><br>\n";
	print "ou Numéro d'appro:<input type=text name=parappro><br>";
    	print "<br><input type=hidden name=action value=choixdate><input type=submit value=submit></form>";
}
    	
if ($action eq "import"){
	$query="select distinct oa_rotation from oasix where oa_serial='$oa_serial' and oa_date_import='$oa_date' order by oa_rotation";
    	$sth = $dbh->prepare($query);
    	if ($sth->execute==0){
    		print "<font color=red>Aucune donnée trouvée</font>";
    		}
    	else {
		while (($oa_rotation) = $sth->fetchrow_array)
			{ 
				push (@rot_tab,$oa_rotation);
			}
	}
	foreach (@rot_tab){
		&etat_rotation($_);
	}
	print "<br>";
  	$lien=$ENV{"REQUEST_URI"}."&suraction=del";
 	print "<Input type=button value='suppression des données' onClick=\"verif('Vous êtes sur de vous?','$lien');\">";
}

sub etat_rotation{
	$rot_file=$_[0];
	$rot=substr($rot_file,5,1);
    	print "<center><div class=titre>Rotation $rot</div><table border=1 cellspacing=0 width=80%>";
     	print "<tr><td>";
    	$appro=&get("select oaa_appro from oasix_appro where oaa_serial='$oa_serial' and oaa_date='$oa_date'","af");
    	if ($appro ne "")
    	{
		$query="select v_vol,v_dest,v_date,v_cd_cl from vol where v_code='$appro' and v_rot='$rot'"; 
		$sth = $dbh->prepare($query);
		$sth->execute;
		($v_vol,$v_dest,$v_date,$v_cd_cl) = $sth->fetchrow_array;
		print "<b>appro:$appro</b><br> vol:$v_vol dest:$v_dest du $v_date<br>"; 
     	}
     	else
     	{
		print "<form>";
		require ("form_hidden.src");
		print "<input type=hidden name=action value=affec>";
		print "<input type=hidden name=tpe value='$oa_serial'>";
		print "<input type=hidden name=date value='$oa_date'>";
		print "affectation au bon d'appro:<input type=texte name=appro><input type=submit value=submit></form><br>";
     	}
     	print "Equipage<br>";
    	$query="select oa_col2 from oasix where oa_type='h' and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'";
    	$sth = $dbh->prepare($query);
    	$sth->execute;
     	while (($oa_col2) = $sth->fetchrow_array) 
  
   #  	while (($oa_serial,$oa_date,$oa_ind,$oa_type,$oa_col1,$oa_col2,$oa_col3,$oa_col4,$oa_date_import,$oa_rotation) = $sth->fetchrow_array) 
     	{
 		print "<b>$oa_col2 </b>";
 		print &get("select hot_nom from hotesse where hot_tri='$oa_col2' and hot_cd_cl=$v_cd_cl");
 		print "<br>";
     	}
     	print "</td><td>Date de l'ouverture tpe<br><b>";
     	print &get("select oa_date from oasix where  oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file' order by oa_date limit 1");
	print "</b><br>Date du retour tpe:<b>$oa_date</b>";
	print "<table border=1 cellspacing=0 width=100%><caption><b>Caisse</b></caption>";
	$qte=&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=0 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'","af");
	if ($qte==0){$color="#dcdcdc";}else{$color="white";}
	print "<tr><td>Espece</td><td align=right bgcolor=$color>$qte</td></tr>";
	$qte=&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=1 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'","af");
	if ($qte==0){$color="#dcdcdc";}else{$color="white";}
	print "</tr><tr bgcolor=$color><td>Carte</td><td align=right>$qte</td></tr>";
	$qte=&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=2 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'","af");
	if ($qte==0){$color="#dcdcdc";}else{$color="white";}
	print "</tr><tr bgcolor=$color><td>Cheque</td><td align=right>$qte</td></tr>";
	$qte=&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=3 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'","af");
	if ($qte==0){$color="#dcdcdc";}else{$color="white";}
	print "</tr><tr bgcolor=$color><td>Devise</td><td align=right>$qte</td></tr>";
	$qte=&get("select sum(oa_col2) from oasix where oa_type='c' and oa_col3=4 and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'","af");
	if ($qte==0){$color="#dcdcdc";}else{$color="white";}
	print "</tr><tr bgcolor=$color><td>Papillon</td><td align=right>$qte</td></tr>";
	
	print "</tr><tr><td>Total caisse</td><td align=right><b>";
	print &get("select sum(oa_col3) from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'","af");
	print "</td></tr></table>";
	print "</td></tr><tr><td colspan=2>";
	$query="select oa_col1,oa_col2,oa_col3 from oasix where oa_type='p' and oa_serial='$oa_serial' and oa_date_import='$oa_date' and oa_rotation='$rot_file'";
    	$sth = $dbh->prepare($query);
    	$sth->execute;
     	while (($oa_col1,$oa_col2,$oa_col3) = $sth->fetchrow_array) 
     	{
 		print "ticket:$oa_col1;$oa_col2;$oa_col3;";
 		if ($oa_col3<0){print "<font color=red> Annulation</font>";}
 		print "<br>";
     	}    	
     	print "</td><tr>";
	print "</table>";
}
;1
