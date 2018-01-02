#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";

print $html->header;
require "./src/connect.src";
$produit=$html->param("produit");
if ($html->param("produit2") ne ""){$produit=$html->param("produit2");}
$qte=$html->param("qte");
$qte*=100;
if ($produit eq ""){
		print "<center><h2>Bascule d'un stock navire vers un stock avion</h3><br><br>";
		$query="select pr_cd_pr,pr_desi from ordre,produit where pr_cd_pr=ord_cd_pr and (pr_type=1 or pr_type=5) order by ord_ordre";
		$sth2=$dbh->prepare($query);
		$sth2->execute;
	      	print "<form><select name=produit>\n";
	       	while (my @tables = $sth2->fetchrow_array) {
	      		next if $table eq $tables[0];
	       		print "<option value=\"$tables[0]\">$tables[0] $tables[1]\n";
	    	}
	    	print "</select>&nbsp;";
	    	print "ou code produit (6 chiffres) <input type=text size=18 name=produit2>";
	    	print "<br>\n";
		print "qte <input type=text name=qte><br>";
		print "<input type=submit value=validation><br>";
		print "</form>";
}
else {
	$query="select pr_codebarre,pr_stre,pr_desi from produit where pr_cd_pr='$produit'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_codebarre,$pr_stre,$pr_desi)=$sth->fetchrow_array;
	if ($pr_codebarre eq ""){ print "<font color=red>$produit produit introuvable</font>";exit;}
	# if ($pr_stre<$qte){ print "<font color=red>$produit $pr_desi stock insuffisant</font>";exit;}
	$query="update produit set pr_stre=pr_stre-$qte where pr_cd_pr=$pr_codebarre;";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$qten=$0-$qte;
	$query="select es_qte from enso where es_cd_pr=$pr_codebarre and es_no_do='' and es_dt=curdate()+0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($qte_ancien)=$sth->fetchrow_array+0;
	$qte_new=$qte_ancien+$qte;
	$query="replace into enso values ($pr_codebarre,'',curdate()+0,'$qte_new','0','24')";	
	$sth=$dbh->prepare($query);
	$sth->execute();
	$query="update produit set pr_stre=pr_stre+$qte where pr_cd_pr='$produit';";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$query="select es_qte from enso where es_cd_pr=$produit and es_no_do='' and es_dt=curdate()+0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($qte_ancien)=$sth->fetchrow_array+0;
	$qte_new=$qte_ancien+$qteen;
	$query="replace into enso values ('$produit','',curdate()+0,'$qten','0','24')";	
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "$pr_codebarre $pr_desi  stock modifié";	
	print "<br><br><a href=http://ibs.oasix.fr/cgi-bin/switch.pl>debut</a>";	

}