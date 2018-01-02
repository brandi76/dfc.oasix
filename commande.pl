#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";

$html=new CGI;

# print $html->header;
require "./src/connect.src";
print $html->header();
$nocde=$html->param("nocde");
$four=$html->param("four");
if ($four eq ""){$four=$html->param("fourmanu");}
$action=$html->param("action");
$prod=$html->param("prod");
$livraison=$html->param("livraison");


if (($action eq "double")&&($livraison eq "")) {

  print "<form method=POST> Adresse de livraison<br><select name=livraison><option value=1>Dieppe</option><option value=2>Lome</option><option value=3>Enlevement</option></select>";
  print "<input type=hidden name=action value=double><input type=hidden name=nocde value=$nocde><br><br><input type=submit></form>";
  exit;
}



if ($action eq "sup") {
	$query="delete from commande where com2_no=$nocde and com2_cd_pr=$prod";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<font color=red>ligne produit $prod de la commande $nocde supprimée<br>";
	$action="";
}
if ($action eq "") {
	$query="select sum(com2_qte*pr_prac)/10000 from commande,produit where pr_cd_pr=com2_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($valeur)=$sth->fetchrow_array;

	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo order by com2_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th><th>date</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		print "<tr><td><a href=?action=entree&nocde=$com2_no>$com2_no</a></td><td>$com2_cd_fo</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td>$com2_qte</td><td>$com2_date</td><td><a href=?action=sup&prod=$com2_cd_pr&nocde=$com2_no>sup</a></td></tr>";
	}
	print "</table>";
	print "<br> valeur:$valeur";
	print "<form method=POST>";
  	print "<br><select name=four><option value=''></option>";
  	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
    	$sth2->execute;
    	while (my @four = $sth2->fetchrow_array) {
       		next if $four eq $four[0];
       		($four[1])=split(/\*/,$four[1]);
       		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
    	}
  	
  	print "</select><br><input type=text name=fourmanu size=4><br><input type=hidden name=action value=creation><input type=submit value='nouvelle commande'></form>"; 
	
}
if ($action eq "entree") {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form method=POST>";
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th><th>date</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date,$pr_refour)=$sth->fetchrow_array){
		if (($com2_cd_fo==1020)||($com2_cd_fo==3036)||($com2_cd_fo==1021)||($com2_cd_fo==1230)||($com2_cd_fo=1008)){$sous_douane=1;}
		($fo2_add)=split(/\*/,$fo2_add);
		print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td><input type=text name=qte$com2_cd_pr value=$com2_qte></td><td>$com2_date</td><td><input type=checkbox name=$com2_cd_pr></td></tr>";
	}
	print "</table>";
	print "<input type=hidden name=action value=ok>";
	print "<input type=hidden name=nocde value=$nocde>";
	if ($sous_douane){
		print "Provenance <input type=text name=provenance><br>";
		print "Type et numero du document <input type=text name=document><br>";
		print "Lieu <input type=text name=lieu><br>";
		print "<input type=hidden name=sous_douane value=on>";
	}
	print "<br> <input type=submit value=\"Ok pour faire l'entree ?\"></form>";
	print "<a href=?action=verif&nocde=$nocde>Verification</a><br>";
	print "<a href=?action=double&nocde=$nocde>Reedition</a>";

}

if ($action eq "ok") {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour,pr_prac/100,pr_prx_rev,com2_prac from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$date=`/bin/date +%d/%m/%y`;
	$dateenso=`/bin/date +%Y%m%d`;
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an=`/bin/date '+%Y'`;
	chop($jour);
	chop($mois);
	chop($an);
	chop($dateenso);
	chop($date);
	$datejl=nb_jour($jour,$mois,$an);
	$sous_douane=$html->param('sous_douane');
	if ($sous_douane eq "on"){
		$query="update atadsql set dt_no=dt_no+1 where dt_cd_dt=206";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$query="select dt_no from atadsql where dt_cd_dt=206";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($no)=$sth2->fetchrow_array;
		$provenance=$html->param('provenance');
		$document=$html->param('document');
		$lieu=$html->param('lieu');
		print "<pre>
IBS France                                             02 32 14 06 91
BP 143
76204 DIEPPE CEDEX

Tel:03 32 14 02 88 FAx 02 35 06 14 69


                         TELECOPIE

DE LA PART DE: I.B.S France
DESTINATAIRE : DOUANE DE DIEPPE
DATE         :$date
No D'ORDRE   :   $no

Messieurs,

Nous vous informons de l'arrivee dans nos entrepots du camion Numero:
Groupage



Entree no:   $no
Provenance:  $provenance
Document:    $document
Lieu:        $lieu
</pre>";
		}
	else{
		$query="update atadsql set dt_no=dt_no+1 where dt_cd_dt=207";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$query="select dt_no from atadsql where dt_cd_dt=207";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($no)=$sth2->fetchrow_array;
		print "Date d'entree:$date<br>";
		print "Numero d'entree:$no<br>";
	}
	$query="replace into enthead values ('$no','$datejl','$scelle','$provenance','$document','$lieu')";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	$total=0;
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>Prix</th><th>Valeur</th><th>qte à entrer</th><th>stock restant</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date,$pr_refour,$pr_prac,$remise,$com2_prac)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		if ($html->param("$com2_cd_pr") eq "on"){
			$qte=$html->param("qte$com2_cd_pr");
			$remise_four=$remise;
			print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right>";
			print "$pr_prac</td><td align=right>";
			$val=$pr_prac*$qte;
			$total+=$val;
			print "$val</td><td align=right>";
			&carton($com2_cd_pr,$qte);
			print "</td>";
			$qte*=100;
			# $qte=$com2_qte*100;
			$query="replace into enso values ('$com2_cd_pr','$no','$dateenso','0','$qte','10')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$query="update produit set pr_stre=pr_stre+$qte where pr_cd_pr='$com2_cd_pr'";
&save("insert ignore into traceur values (now(),\"$ENV{\"REQUEST_URI\"}\",\"$ENV{\"REMOTE_USER\"}\",\"$ENV{\"REMOTE_ADDR\"}\")");
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			$query="replace into entbody values ('$no','$com2_cd_pr','$qte')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			if ($qte==($com2_qte*100)){
				$query="delete from commande where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr";
				$date_commande="2".substr($com2_date,1,3)."-".substr($com2_date,4,2)."-".substr($com2_date,6,2);
  				$delai=&get("select datediff(now(),'$date_commande')");
				&save("replace into commandearch values ('$com2_no','$com2_cd_fo','$com2_cd_pr','$qte','$com2_prac','0','$com2_date','$delai')");
			}
			else
			{
				$query="update commande set com2_qte=$com2_qte-$qte where com2_no=$com2_no and com2_cd_pr=$com2_cd_pr";
			}
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			%stock=&stock($com2_cd_pr,"","");
			$pr_stre=$stock{"stock"};
			print "<td>";
			&carton($com2_cd_pr,$pr_stre);
			print "</td><td><input type=checkbox></td></tr>";
		}
	}
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
	print "Total :".&deci($total)."<br>";

	if ($sous_douane eq "on"){
		print "<pre>Nous vous remercions et vous prions d'agreer, Messieurs,Nos sinceres salutations.</pre>";
	}
	else {print "fin";}
}


if ($action eq "verif") {
	$date=`/bin/date +%d/%m/%y`;
	print "le $date<br>";
	$dateenso=`/bin/date +%Y%m%d`;
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an=`/bin/date '+%Y'`;
	chop($jour);
	chop($mois);
	chop($an);
	chop($dateenso);
	chop($date);
	$datejl=nb_jour($jour,$mois,$an);
	$total=0;

	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour,pr_prac/100,pr_prx_rev,com2_prac from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
# 	print "$query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte à entrer</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date,$pr_refour,$pr_prac,$remise,$com2_prac)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$pr_desi</td><td>";
		&digit("$com2_cd_pr");
		print "</td><td align=right>";
		&carton($com2_cd_pr,$com2_qte);
		print "</td><td><input type=checkbox></td></tr>";
	}
	print "</table><br>";
}

if ($action eq "imprimer") {
	$date=&get("select enh_date from enthead where enh_no='$nocde'");
	$date=&julian($date);
	print "Date d'entree:$date<br>";
	print "Numero d'entree:$nocde<br>";
	$query="select enb_no,pr_four,fo2_add,enb_cdpr,pr_desi,enb_quantite/100,pr_refour,pr_prac/100,pr_prx_rev from entbody,produit,fournis where pr_cd_pr=enb_cdpr and fo2_cd_fo=pr_four and enb_no='$nocde' order by pr_refour";
	# print "$query<br>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>Prix</th><th>Valeur</th><th>qte à entrer</th><th>stock restant</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$qte,$pr_refour,$pr_prac,$remise)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		$remise_four=$remise;
		print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right>";
		print "$pr_prac</td><td align=right>";
		$val=$pr_prac*$qte;
		$total+=$val;
		print "$val</td><td align=right>";
		&carton($com2_cd_pr,$qte);
		print "</td>";
		$qte*=100;
		%stock=&stock($com2_cd_pr,"","");
		$pr_stre=$stock{"stock"};
		print "<td>";
		&carton($com2_cd_pr,$pr_stre);
		print "</td><td><input type=checkbox></td></tr>";
	}
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
	print "Total :".&deci($total)."<br>";
}


if ($action eq "creation") {
	$query="select fo2_cd_fo,fo2_add,pr_cd_pr,pr_desi from produit,fournis where pr_four='$four' and fo2_cd_fo='$four' and pr_sup!=2 order by pr_cd_pr";
	# special pons
	if ($four==3036){
	$query="select fo2_cd_fo,fo2_add,pr_cd_pr,pr_desi from produit,fournis where pr_four='1020' and fo2_cd_fo='$four' order by pr_cd_pr";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	print "<form method=POST>";
	print "<table cellspacing=0 border=1><tr><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th></tr>";
	while (($fo2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		$query="select car_carton from carton where car_cd_pr=$com2_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($car_carton)=$sth2->fetchrow_array;
		print "<tr><td>$fo2_cd_fo</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td>$car_carton</td><td><input type=text name=$com2_cd_pr></td></tr>";
	}
	print "</table>";
	print "<br> Adresse de livraison<br><select name=livraison><option value=1>Dieppe</option><option value=2>Lome</option><option value=3>Enlevement</option></select><br>";
  	print "<input type=hidden name=action value=creer>";
	print "<input type=hidden name=four value=$four>";
	print "<br><input type=submit value=\"Ok pour faire la commande\"></form>";
}
if ($action eq "creer") {
	$query="select dt_no from atadsql where dt_cd_dt=205";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($commande)=$sth->fetchrow_array;
	 $commande+=1;
	 $query="update atadsql set dt_no=$commande where dt_cd_dt=205";
	 $sth=$dbh->prepare($query);
	 $sth->execute();
	$date=`/bin/date +%d/%m/%y`;
	$datesimple="10".`/bin/date +%y%m%d`;

	print "<html ><head><style type=text/css><!--#header {position: absolute;color: navy;font-size: 10pt;top: 0;}#footer {position: absolute;color: navy;bottom: -200;}--></style></head><body>";
	print "<div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>DFC<br>1 PASSAGE DU GRAND CERF<br>75002 PARIS<b><font color=navy><br>Tel +01 46 66 83 66/06 98 37 94 94</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>";
	print "<pre>";
	print "                                                Lome le $date<br></pre>";
	$query="select * from fournis where fo2_cd_fo='$four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	print "<pre>                                                <b>$nom</b>
	                                        $rue
	                                        $ville
	                                        
	                                        
A l'attention de $fo2_contact fax:<b>$fo2_fax</b> $fo2_email";
	print "<br>";
	print "Commande No:$commande<br>";
	print "veuillez prendre la commande suivante:</pre>";

	$query="select pr_cd_pr,pr_desi,pr_refour,pr_prac/100,pr_type,pr_prx_rev from produit where pr_four='$four' order by pr_refour";
	# special pons
	if ($four==3036){
		$query="select pr_cd_pr,pr_desi,pr_refour,pr_prac/100,pr_type from produit where pr_four='1020' order by pr_cd_pr";
}

	$sth=$dbh->prepare($query);
	$sth->execute();
	$parf=0;
	print "<form method=POST>";
	$total=0;
	print "<table cellspacing=0 border=1 style=\"font-size: 8pt;font-family: Cortoba\"><tr><th>code produit interne</th><th>Code produit</th><th>produit</th><th>qte</th><th>Prix</th><th>Total</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_refour,$pr_prac,$pr_type,$remise)=$sth->fetchrow_array){
		if (($html->param("$pr_cd_pr") ne "")&&($html->param("$pr_cd_pr")!=0)){
			$remise_four=$remise;
			print "<tr><td>$pr_cd_pr</td><td>$pr_refour </td><td>$pr_desi</td><td>";
			print $html->param("$pr_cd_pr");
			$qte=$html->param("$pr_cd_pr")*100;
			$val=$qte*$pr_prac/100;
			$total+=$val;
			print "</td><td align=right>$pr_prac</td><td>$val</td></tr>";
			if ($pr_type==1 || $pr_type==5){$parf=1;}
	
			$query="replace into commande values ('$commande','$four','$pr_cd_pr','$qte','$pr_prac','','$datesimple','')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	
		}
	}
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
	print "<pre>Total :".&deci($total)."<br>";


	if ($parf==1){
	print "<br>Merci d'ajouter produits factices,testeurs,echantillons,mouillettes<br>"; }
 
	  if ($livraison==1){
print "<br>LIVRAISON DE 8h30 A 17h30
IBS FRANCE
BP 143 DIEPPE
Zone Industrielle Rouxmenils Bouteilles Zone jaune
76200 DIEPPE
Tel:02.32.14.02.88
Fax:02.35.40.14.69
</pre>";
}
	  if ($livraison==2){
print "<br><pre>Adresse de Livraison 
LOME
</pre>";
}
if ($livraison==3){
print "<br><pre>Enlevement par nos soins
</pre>";

}
}

if ($action eq "double") {
	$date=`/bin/date +%d/%m/%y`;
	$datesimple="10".`/bin/date +%y%m%d`;
	$commande=$nocde;
	$four=&get("select com2_cd_fo from commande where com2_no='$commande'");
	print "<html ><head><style type=text/css><!--#header {position: absolute;color: navy;font-size: 10pt;top: 0;}#footer {position: absolute;color: navy;bottom: -200;}--></style></head><body>";
	print "<div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE<b><font color=navy><br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>";
	print "<pre>";
	print "                                                Lome le $date<br></pre>";
	$query="select * from fournis where fo2_cd_fo='$four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	print "<pre>                                                <b>$nom</b>
	                                        $rue
	                                        $ville
	                                        
	                                        
A l'attention de $fo2_contact fax:<b>$fo2_fax</b> $fo2_email";
	print "<br>";
	print "Commande No:$commande<br>";
	print "veuillez prendre la commande suivante:</pre>";

	$query="select pr_cd_pr,pr_desi,pr_refour,pr_prac/100,pr_type,pr_prx_rev,com2_qte/100 from produit,commande where com2_no='$commande' and com2_cd_pr=pr_cd_pr order by pr_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$parf=0;
	$total=0;
	print "<table cellspacing=0 border=1 style=\"font-size: 8pt;font-family: Cortoba\"><tr><th>code produit interne</th><th>Code produit</th><th>produit</th><th>qte</th><th>Prix</th><th>Total</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_refour,$pr_prac,$pr_type,$remise,$qte)=$sth->fetchrow_array){
	      $remise_four=$remise;
	      print "<tr><td>$pr_cd_pr</td><td>$pr_refour </td><td>$pr_desi</td><td>$qte";
	      $val=$qte*$pr_prac;
	      $total+=$val;
	      print "</td><td align=right>$pr_prac</td><td align=right>$val</td></tr>";
	      if ($pr_type==1 || $pr_type==5){$parf=1;}
	}
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
	print "<pre>Total :".&deci($total)."<br>";


	if ($parf==1){
	print "<br>Merci d'ajouter produits factices,testeurs,echantillons,mouillettes<br>"; }
  if ($livraison==1){
print "<br>LIVRAISON DE 8h30 A 17h30
IBS FRANCE
BP 143 DIEPPE
Zone Industrielle Rouxmenils Bouteilles Zone jaune
76200 DIEPPE
Tel:02.32.14.02.88
Fax:02.35.40.14.69
</pre>";
}
  if ($livraison==2){
print "<br><pre>Adresse de Livraison 
CIF TRANSIT
Parc activité les jonquière
RN 368
13170 LES PENNES MIRABEAU

Les colis où palettes sont à mettre au nom de notre sous-traitant qui est : 
SARL BRACCONI & FILS 
Zi Tragone 
20620 BIGUGLIA
</pre>";
}
if ($livraison==3){
print "<br><pre>Enlevement par nos soins
</pre>";
}
}



if ($action eq "reedition") {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date,pr_refour,pr_prac/100,pr_prx_rev,com2_prac from commandearch,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde' order by pr_refour";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$date=`/bin/date +%d/%m/%y`;
	$jour=`/bin/date '+%d'`;
	$mois=`/bin/date '+%m'`;
	$an=`/bin/date '+%Y'`;
	chop($jour);
	chop($mois);
	chop($an);
	chop($dateenso);
	chop($date);
	$datejl=nb_jour($jour,$mois,$an);
	$total=0;
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>Prix</th><th>Valeur</th><th>qte à entrer</th><th>stock restant</th><th>check</th></tr>";
while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$qte,$com2_date,$pr_refour,$pr_prac,$remise,$com2_prac)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		$remise_four=$remise;
		print "<tr><td>$com2_no</td><td>$pr_refour</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td align=right>";
		print "$pr_prac</td><td align=right>";
		$val=$pr_prac*$qte;
		$total+=$val;
		print "$val</td><td align=right>";
		&carton($com2_cd_pr,$qte);
		print "</td>";
		$qte*=100;
		%stock=&stock($com2_cd_pr,"","");
		$pr_stre=$stock{"stock"};
		print "<td>";
		&carton($com2_cd_pr,$pr_stre);
		print "</td><td><input type=checkbox></td></tr>";
	}
	print "</table><br>";
	if ($remise_four!=0){ 
		$remise=$total*$remise_four/10000;
		print "Total :$total<br>";
		print "Remise:".&deci($remise)."<br>";
		$total-=$remise;
	}
	print "Total :".&deci($total)."<br>";

}


# FONCTION : nb_jour(jour,mois,annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : le jour mois annee (yyyy)
# SORTIE : le nombre de seconde

sub nb_jour{
	my ($jour)=$_[0];
	my ($mois)=$_[1];
	my ($annee)=$_[2];

	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}
sub nb_jour_an
{
	my ($annee)=$_[0];
	my ($n)=0;
	for (my($i)=1970; $i<$annee; $i++) {
		$n += 365; 
		if (&bissextile($i)){$n++;}
	}
	return($n);
}

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
}


# -E gestion des commades
