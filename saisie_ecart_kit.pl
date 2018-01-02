print "<title>saisie des ecarts</title>";

require "./src/connect.src";


$action=$html->param("action");
for ($i=1;$i<10;$i++){
	${ex."$i"}=$html->param("ex$i");
	${def."$i"}=$html->param("def$i");
	${qte."$i"}=$html->param("qte$i");
	${ca."$i"}=$html->param("ca$i");
	${qtec."$i"}=$html->param("qtec$i");
}
$nodepart=$html->param("nodepart");

if ($nodepart eq ""){
	$query = "select max(liv_dep)from listevol ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$nodepart=$sth->fetchrow_array;
}

# $stock_new=35;$packing=24;$plat_new="";$carton_new=1;$detail_new=11;$casse=3;$plus="";$moins="";$nom="sylvain";$justificatif="";$action="valider";

if ($action eq ""){
  	print "<center><h2>Saisie des ecarts du depart no:$nodepart</h2><form>";
  	require ("form_hidden.src");
  	print "<br><table border=1 cellspacing=0><caption><h3>Inversion</h3></caption><tr><th>Code produit en excedant +<br>Code produit en trop<br>Credit</th><th>Code produit en deficit -<br>Code produit en moins<br>Debit</th><th>qte</th></tr>";
  	print "<tr><td><input type=text name=ex1 size=6></td><td><input type=text name=def1 size=6></td><td><input type=text name=qte1 size=3></td></tr>";
	print "<tr><td><input type=text name=ex2 size=6></td><td><input type=text name=def2 size=6></td><td><input type=text name=qte2 size=3></td></tr>";
  	print "<tr><td><input type=text name=ex3 size=6></td><td><input type=text name=def3 size=6></td><td><input type=text name=qte3 size=3></td></tr>";
  	print "<tr><td><input type=text name=ex4 size=6></td><td><input type=text name=def4 size=6></td><td><input type=text name=qte4 size=3></td></tr>";
  	print "<tr><td><input type=text name=ex5 size=6></td><td><input type=text name=def5 size=6></td><td><input type=text name=qte5 size=3></td></tr>";
  	print "<tr><td><input type=text name=ex6 size=6></td><td><input type=text name=def6 size=6></td><td><input type=text name=qte6 size=3></td></tr>";
  	print "<tr><td><input type=text name=ex7 size=6></td><td><input type=text name=def7 size=6></td><td><input type=text name=qte7 size=3></td></tr>";
  	print "<tr><td><input type=text name=ex8 size=6></td><td><input type=text name=def8 size=6></td><td><input type=text name=qte8 size=3></td></tr>";
  	print "<tr><td><input type=text name=ex9 size=6></td><td><input type=text name=def9 size=6></td><td><input type=text name=qte9 size=3></td></tr>";
        print "</table>";
	
	print "<br><table><caption><h3>Casse</h3></caption><tr><th>Code produit</th><th>qte</th></tr>";
  	print "<tr><td><input type=text name=ca1 size=6></td><td><input type=text name=qtec1 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca2 size=6></td><td><input type=text name=qtec2 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca3 size=6></td><td><input type=text name=qtec3 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca4 size=6></td><td><input type=text name=qtec4 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca5 size=6></td><td><input type=text name=qtec5 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca6 size=6></td><td><input type=text name=qtec6 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca7 size=6></td><td><input type=text name=qtec7 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca8 size=6></td><td><input type=text name=qtec8 size=3></td></tr>";
  	print "<tr><td><input type=text name=ca9 size=6></td><td><input type=text name=qtec9 size=3></td></tr>";
        print "</table>";
    	print "<br>\n<br><input type=hidden name=action value=go><input type=submit value= envoie></form>";
    	# print "<input type=button onclick=window.print()>";
}
	

if ($action eq "go"){
	print "<center>";
	print `date`;
	print "<br><h3>depart $nodepart</h3><br>";
	print "<table border=1 cellspacing=0><caption><h3>inversion </h3></caption>";
	for ($i=1;$i<10;$i++){
		if ( ${ex."$i"} eq ""){next;}
		if ( ${def."$i"} eq ""){next;}
		if ( ${qte."$i"} <= 0){next;}

		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=${ex.\"$i\"}");
		if ($pr_desi eq "") {next;}
		$query="select erdep_qte from errdep where erdep_cd_pr=${ex.\"$i\"} and erdep_depart='$nodepart' and erdep_code=''";
		$sth2=$dbh->prepare("$query");
		$sth2->execute();
		($erdep_qte)=$sth2->fetchrow_array;
		$erdep_qte+=${qte."$i"};
		&save("replace into errdep values (${ex.\"$i\"},'$nodepart','','$erdep_qte')");
		%stock=&stock(${ex."$i"},'','');
		$pr_stre=$stock{"stock"}+0;  # stock reel entrepot 
		print "<tr><td>${ex.\"$i\"}</td><td>$pr_desi $pr_stre</td><td>+${qte.\"$i\"}</td>";
		print "<td align=right>";
		&carton(${ex."$i"},$pr_stre);
		print "</td><td><input type=checkbox></tD></tr>";

		$erdep_qte*=100;
		&save("replace into trace_jour values (now(),'9',${ex.\"$i\"},'$erdep_qte','inversion','inversion','$nodepart')","af"); 			
		
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=${def.\"$i\"}");
		$query="select erdep_qte from errdep where erdep_cd_pr=${def.\"$i\"} and erdep_depart='$nodepart' and erdep_code=''";
		$sth2=$dbh->prepare("$query");
		$sth2->execute();
		($erdep_qte)=$sth2->fetchrow_array;
		$erdep_qte-=${qte."$i"};
		&save("replace into errdep values (${def.\"$i\"},'$nodepart','','$erdep_qte')");
		%stock=&stock(${def."$i"},'','');
		$pr_stre=$stock{"stock"}+0;  # stock reel entrepot 
		print "<tr><td>${def.\"$i\"}</td><td>$pr_desi</td><td>-${qte.\"$i\"}</td>";
		print "<td align=right>";
		&carton(${def."$i"},$pr_stre);
		print "</td><td><input type=checkbox></tD></tr>";
		$erdep_qte*=100;
		&save("replace into trace_jour values (now(),'9',${ex.\"$i\"},'$erdep_qte','inversion','inversion','$nodepart')","af"); 			
		$passe++;
	}	
	print "</table>";
	if ($passe==0){print "pas d'inversion";}
	$passe=0;	
	print "<center><table border=1 cellspacing=0><caption><h3>Casse</h3></caption>";
	for ($i=1;$i<10;$i++){
		if ( ${ca."$i"} eq ""){next;}
		if ( ${qtec."$i"}+0 == 0){next;}
		$casse=${qtec."$i"}*100;
		$pr_cd_pr=${ca."$i"};
		&save("update produit set pr_casse=pr_casse+$casse where pr_cd_pr='$pr_cd_pr'","aff");
		&save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
		&save("replace into trace_jour values (now(),'5','$pr_cd_pr','$casse','','','')","aff"); 			
		$pr_desi=&get("select pr_desi from produit where pr_cd_pr=${ca.\"$i\"}","aff");
		%stock=&stock(${ca."$i"},'','');
		$pr_stre=$stock{"stock"}+0;  # stock reel entrepot 
		$casse/=100;
		print "<tr><td>${ca.\"$i\"}</td><td>$pr_desi</td><td>+$casse</td>";
		print "<td align=right>";
		&carton(${ca."$i"},$pr_stre);
		print "</td><td><input type=checkbox></tD></tr>";
		$passe++;
	}	
	print "</table>";
	if ($passe==0){print "pas de casse";}
}

;1
