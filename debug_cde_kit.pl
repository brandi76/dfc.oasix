&param();
print "<form>";
&form_hidden();
print "No de livraisson ?";
print "<input name=liv>
<input type=submit>
</form>";
if ($liv ne ""){
$cde=&get("select liv_code from  livraison where liv_no=$liv");
print "Commande (livraison) :$cde<br>";
($base,$user)=&get("select livh_base,livh_user from  livraison_h where livh_id=$liv");
print "Base:$base<br>";
print "User:$user<br>";
($cde_base)=&get("select com2_no from $base.commande where com2_no_liv=$liv");
print "Commande (commande) :$cde_base<br>";
($cde_base_arch)=&get("select com2_no from $base.commandearch where com2_no_liv=$liv");
print "Commande (commandearch) :$cde_base_arch<br>";
($enh_no)=&get("select enh_no from $base.enthead where enh_document='$liv'");
print "No entree :$enh_no<br>";
($trac_date,$trac_url,$trac_login)=&get("select * from $base.traceur where trac_url like '%liv_id=$liv%'");
print "Traceur<br>";
print "$trac_date,$trac_url,$trac_login";
}

;1
