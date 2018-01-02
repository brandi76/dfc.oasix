$four=$html->param("four");
$desi=$html->param("desi");
$trolley=$html->param("trolley");
if ($four eq ""){$four="pr_four";}
if ($trolley eq ""){$trolley="v_troltype";}
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

if ($action eq ""){&premiere();}
if ($action eq "go"){&go();}

sub premiere{
	print "<center>Concours<br><form>";
	&form_hidden();
	print "<br> <br>Premiere date (incluse) <input id=\"datepicker\" type=text name=firstdate size=12>";
    print "<br> <br>Derniere date (incluse) <input id=\"datepicker2\" type=text name=lastdate size=12>";
	print "<br>Produit commencant par:<input type=text name=desi><br>";
	 print "et/Ou Code Fournisseur ";
	 print "<select name=four>"; 
	 $query="select distinct fo2_cd_fo,fo2_add from fournis,trolley,produit where tr_cd_pr=pr_cd_pr and pr_four=fo2_cd_fo order by fo2_cd_fo ";
	 $sth=$dbh->prepare($query);
	 $sth->execute();
	 while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array){
		 ($nom)=split(/\*/,$fo2_add);
		 print "<option value=$fo2_cd_fo>$fo2_cd_fo $nom</option>";
	 }
	 print "<option value=''></option>";
	 print "</select><br>";
	 print "et/ou No trolley <input type=text name=trolley><br>";
	print "<br>"; 	
	print " <input type=submit>"; 
	print "<input type=hidden name=action value=go>";
	print "</form>";	
}

sub go{
	&save("create temporary table concours_tmp (tri varchar(5),ca decimal(8,2),nb_vol int(5), primary key (tri))");
	$query="select v_code,v_rot from vol where v_date_sql>='$firstdate'  and v_date_sql<='$lastdate' and v_troltype=$trolley";
	#rint $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<h3><font color=navy>Concours du $firstdate au $lastdate ";
	print "</h3></font><br><br>";
	while (($v_code,$v_rot)=$sth->fetchrow_array){
		$ca_fly=&get("select ca_fly/100 from caisse where ca_code='$v_code' and ca_rot='$v_rot'")+0;
		if ($ca_fly==0){next;}
		$first=1;
		$total=0;
		$valeur=0;
		$query="select eq_cc,eq_equipage from equipagesql where eq_code=$v_code and eq_rot=$v_rot";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($eq_cc,$equipage)=$sth3->fetchrow_array;
		(@equip)=split(/;/,$equipage);
		push(@equip,$eq_cc);
		foreach $tri (@equip){
			if (length($tri)>=3){
				&save("insert ignore into concours_tmp values ('$tri','0','0')");
				&save("update concours_tmp set nb_vol=nb_vol+1 where tri='$tri'");
			}
		}	
		if ($desi ne ""){
			$query="select ro_cd_pr,floor(ro_qte/100),ap_prix/100 from rotation,produit,appro where ro_code=ap_code and ro_cd_pr=ap_cd_pr and ro_cd_pr=pr_cd_pr and pr_desi like '$desi%' and ro_code='$v_code'";
			# print "$query<br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($pr_cd_pr,$qte,$prix)=$sth2->fetchrow_array){
				$ca=$qte*$prix;
				# print "$pr_cd_pr $pr_desi $qte $prix $ca<br>";	
				foreach $tri (@equip){
					&save("update concours_tmp set ca=ca+$ca where tri='$tri'","af");
				}	
			}		
		}
		else{
			foreach $tri (@equip){
				&save("update concours_tmp set ca=ca+$ca_fly where tri='$tri'","af");
			}	
	   }
	}  
	print "</b><br><table border=1 cellspacing=0><tr><th>Trigramme</th><th>Ca</th><th>Nb vol</th><th>CA par vol</th></tr>";
	$query="select *,ca/nb_vol as moy from concours_tmp order by moy desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($tri,$ca,$nb_vol)=$sth->fetchrow_array){
		$query="select hot_nom from hotesse where hot_tri='$tri'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($nom)=$sth2->fetchrow_array;
		$moyenne=int($ca/$nb_vol);
		$ca=int($ca);
		print "<tr><td>$tri $nom </td><td align=right>$ca</td><td align=right>$nb_vol</td><td align=right>$moyenne</td></tr>";
	}
	print "</table>";
}

;1