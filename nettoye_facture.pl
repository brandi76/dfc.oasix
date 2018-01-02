#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=dfc;","web","admin",{'RaiseError' => 1});
$action=$html->param("action");
$mag=$html->param("mag");
$digit=$html->param("digit");
$sansdigit=$html->param("sansdigit");

if ($action eq ""){
	print "<form>";
	print "<select name=mag>";
	$query="select distinct mag from facture_pub";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($mag)=$sth->fetchrow_array){
	 print "<option value=$mag>$mag</option>";
	} 
	print "</select>";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit>";
	print "</form>";
}

if ($action eq "save"){
	$mag_tamp=$mag;
	$query="select * from facture_pub where mag='$mag' order by fournisseur,marque";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$i=0;
	while (($base,$mag,$fournisseur,$marque,$no_facture,$date,$montant,$pdf,$date_mail,$groupement)=$sth->fetchrow_array){
		if (($sansdigit ne "")&&($html->param("$pdf") eq "$sansdigit")){
			$digit="";
			}
		$no_facture=$html->param("$pdf").$digit;
		&save("replace into facture_pubB values ('$base','$mag','$fournisseur','$marque','$no_facture','$date','$montant','$pdf','$date_mail','$groupement')","af");
	}
	$action="go";	
	$mag=$mag_tamp;

}

if ($action eq "go"){
print <<EOF;
<script language="javascript">
function incremente(ele){
	var taille = document.forms['maform'].elements.length;
	var valeur=eval(document.forms['maform'].elements[ele].value)+1;
	for(i=ele+1; i < taille-4; i++){
		document.forms['maform'].elements[i].value=valeur++;
		//console.log(document.forms['maform'].elements[i].value);
	}
}
</script>
EOF

	print "<form name=maform><table border=1>";
	$mag_tamp=$mag;
	$query="select * from facture_pub where mag='$mag' order by fournisseur,marque";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$i=0;
	while (($base,$mag,$fournisseur,$marque,$no_facture,$date,$montant,$pdf,$date_mail,$groupement)=$sth->fetchrow_array){
		$factureB=&get("select no_facture from facture_pubB where base='$base' and mag='$mag' and fournisseur='$fournisseur' and marque='$marque'");
		print "<tr><td>$base</td><td>$mag</td><td>$fournisseur</td><td>$marque</td><td bgcolor=lightyellow>";
		print "<input type=text name=$pdf value=$no_facture onchange=incremente($i)></td><td>$factureB</td><td>$date</td><td>$montant</td></tr>";
		$i++;
	}
	print "</table>";
	print "digit <input type=texte name=digit size=1>";
	print "sans digit a apartir de <input type=texte name=sansdigit>";
	
	print "<input type=hidden name=action value=save>";
	print "<input type=hidden name=mag value='$mag_tamp'>";
	print "<input type=submit>";
	print "<a href=?>retour</a>";
	print "</form>";
}	


