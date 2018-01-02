$code=$html->param("code");
$rot=$html->param("rot");
$cc=$html->param("cc");

if ($action eq "maj"){
	$eq_equipage=";";
	for ($i=0;$i<20;$i++){
		if ($html->param("pnc$i") ne ""){
			$eq_equipage.=$html->param("pnc$i").";";
		}
	}	
	&save("replace into equipagesql values ('$code','$rot','$cc','$eq_equipage')","af");
	print "<p style=background:lightgreen>Mise a jour effectuee</p>";
	$action="go";
}

if ($action eq "go"){
	$query="select v_vol,v_date_sql from vol where v_code='$code' and v_rot='$rot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($v_vol,$v_date_sql)=$sth->fetchrow_array;
    if ($v_vol eq ""){print "<p style=background:pink>Vol inconu</p>";$action="";}
	else {
		print "<strong>$code $v_vol $v_date_sql</strong><br>";
		print "<form>";
		&form_hidden();
		$query="select eq_cc,eq_equipage from equipagesql where eq_code='$code' and eq_rot='$rot'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($eq_cc,$eq_equipage)=$sth->fetchrow_array;
        print "Chef de cabine <input type=text size=4 name=cc value=$eq_cc>:";
		$hot_nom=&get("select hot_nom from hotesse where hot_tri='$eq_cc'");
		if ($hot_nom eq ""){$hot_nom="Inconnu"};
		print $hot_nom;
		print "<br>";
		(@equipe)=split(/;/,$eq_equipage);
		$i=1;
		foreach (@equipe){
			if ($_ eq ""){next;}
			print "Pnc $i <input type=text name=pnc$i value='$_' size=4> "; 
			$hot_nom=&get("select hot_nom from hotesse where hot_tri='$_'");
			if ($hot_nom eq ""){$hot_nom="Inconnu"};
			print "$hot_nom<br>";
			$i++;
		}	
		print "<form>";
		print "Pnc $i <input type=text name=pnc$i size=4><br>";
		$i++;
		print "Pnc $i <input type=text name=pnc$i size=4><br>";
		$i++;
		print "Pnc $i <input type=text name=pnc$i size=4><br>";
		$i++;
		print "Pnc $i <input type=text name=pnc$i size=4><br>";
		$i++;
		print "Pnc $i <input type=text name=pnc$i size=4><br>";
		$i++;
		print "Pnc $i <input type=text name=pnc$i size=4><br>";
		$i++;
		print "Pnc $i <input type=text name=pnc$i size=4><br>";

		print "<input type=hidden name=action value=maj>";
		print "<input type=hidden name=code value=$code>";
		print "<input type=hidden name=rot value=$rot>";
		
		print "<input type=submit>";
		print "</form>";
	}	
	
}


if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "code<input type=text name=code value='$code'><br><br>"; 	
	print "rotation<input type=text name=rot value=1 size=2><br><br>"; 	
	print "<input type=hidden name=action value=go>";
	print "<input type=submit>";
	print "</form>";
}
;1