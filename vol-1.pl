#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;

# print $html->header;
require "./src/connect.src";
print $html->header();
$nocde=$html->param("nocde");
$four=$html->param("four");
$action=$html->param("action");


if ($action eq "") {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo order by com2_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th><th>date</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		print "<tr><td><a href=?action=entree&nocde=$com2_no>$com2_no</a></td><td>$com2_cd_fo</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td>$com2_qte</td><td>$com2_date</td></tr>";
	}
	print "</table>";
}
if ($action eq "entree") {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form>";
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th><th>date</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		print "<tr><td>$com2_no</td><td>$com2_cd_fo</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td>$com2_qte</td><td>$com2_date</td><td><input type=checkbox name=$com2_cd_pr checked></td></tr>";
	}
	print "</table>";
	print "<input type=hidden name=action value=ok>";
	print "<input type=hidden name=nocde value=$nocde>";
	print "<br> <input type=submit value=\"Ok pour faire l'entree ?\"</form>";
}

if ($action eq "ok") {
	$query="select com2_no,com2_cd_fo,fo2_add,com2_cd_pr,pr_desi,com2_qte/100,com2_date from commande,produit,fournis where pr_cd_pr=com2_cd_pr and fo2_cd_fo=com2_cd_fo and com2_no='$nocde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form>";
	print "<table cellspacing=0 border=1><tr><th>No de commande</th><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th><th>date</th><th>check</th></tr>";
	while (($com2_no,$com2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi,$com2_qte,$com2_date)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		if ($html->param("$com2_cd_pr") eq "on"){
		print "<tr><td>$com2_no</td><td>$com2_cd_fo</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td>$com2_qte</td><td>$com2_date</td><td><input type=checkbox name=$com2_cd_pr checked></td></tr>";
		}
	}
	print "</table>";
	print "<input type=hidden name=action value=ok>";
	print "<br> <input type=submit value=\"Ok pour faire l'entree ?\"</form>";
}

if ($action eq "creation") {
	$query="select fo2_cd_fo,fo2_add,pr_cd_pr,pr_desi from produit,fournis where pr_four='$four' and fo2_cd_fo='$four' order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form>";
	print "<table cellspacing=0 border=1><tr><th>code fournisseur</th><th>fournisseur</th><th>code produit</th><th>produit</th><th>qte</th></tr>";
	while (($fo2_cd_fo,$fo2_add,$com2_cd_pr,$pr_desi)=$sth->fetchrow_array){
		($fo2_add)=split(/\*/,$fo2_add);
		print "<tr><td>$fo2_cd_fo</td><td>$fo2_add</td><td>$com2_cd_pr</td><td>$pr_desi</td><td><input type=text name=$com2_cd_pr></td></tr>";
	}
	print "</table>";
	print "<input type=hidden name=action value=creer>";
	print "<input type=hidden name=four value=$four>";
	print "<br><input type=submit value=\"Ok pour faire la commande\"</form>";
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
	$datesimple=`/bin/date +%y%m%d`;

	print "<html ><head><style type=text/css><!--#header {position: absolute;color: navy;top: 0;}#footer {position: absolute;color: navy;bottom: 0;}--></style></head><body>";
	print "<div id=header><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>Ibs France<br>Bp 143<br>76204 DIEPPE</td><td align=right><b><font color=navy><br>Fax +33 235 401 469</td></tr></table></div><div id=footer><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td align=left><b><font color=navy>SAS au capital de 500 000 €</td><td align=right><b><font color=navy>RCS DIEPPE 393 966 460</td></tr></table></div>";
	print "<br><br><br><br><br><br><pre>";
	print "                                                Dieppe le $date<br></pre>";
	$query="select * from fournis where fo2_cd_fo='$four'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	print "<pre>                                                <b>$nom</b>
	                                        $rue
	                                        $ville
	                                        
	                                        
A l'attention de $fo2_contact fax:<b>$fo2_fax</b>
	</pre>";
	print "<br>";
	print "Commande No:$commande<br>";
	print "veuillez prendre la commande suivante:<bR>";
	$query="select pr_cd_pr,pr_desi,pr_refour,pr_prac from produit where pr_four='$four' order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<form>";
	print "<table cellspacing=0 border=1><tr><th>code produit interne</th><th>Code produit</th><th>produit</th><th>qte</th></tr>";
	while (($pr_cd_pr,$pr_desi,$pr_refour,$pr_prac)=$sth->fetchrow_array){
		if (($html->param("$pr_cd_pr") ne "")&&($html->param("$pr_cd_pr")>0)){
			print "<tr><td>$pr_cd_pr</td><td>$pr_refour</td><td>$pr_desi</td><td>";
			print $html->param("$pr_cd_pr");
			$qte=$html->param("$pr_cd_pr")*100;
			print "</td></tr>";
			$query="replace into commande values ('$commande','$four','$pr_cd_pr','$qte','$pr_prac','','$datesimple','')";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
	
		}
	}
	print "</table>";
	print "<br><pre>LIVRAISON DE 8h30 A 17h30
DIEPPE
IBS FRANCE
BP 143 DIEPPE
Zone Industrielle Rouxmenils Bouteilles Zone jaune
76200 DIEPPE
Tel:02.32.14.02.88
Fax:02.35.40.14.69
</pre>";
}


# -E gestion des commades