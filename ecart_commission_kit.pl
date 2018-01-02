$appro=$html->param("appro");
$rot=$html->param("rot");
$montant=$html->param("montant");

print "<center>";
 if ($appro ne "") {
	if ($montant ==0){
		&save("delete from ecart_commision where ecc_code='$appro' and ecc_rot='$rot'","af");
	}
	else
	{
	  &save("replace into ecart_commision value ('$appro','$rot','$montant')","af");
	}  
	print "<font color=red>enregistrement effectué</font>";
}	
print "<div class=titre>Saisie ecarts à imputer aux pnc</div><br>";
print "<form>";
require ("form_hidden.src");
print "<br>Appro<br><input type=text name=appro><br>";
print "<br>Rotation<br><input type=text name=rot value=1><br>";
print "<br>Montant<br><input type=text name=montant><br>";
	print "<br><input type=submit></form><br><br>"; 
;1	
