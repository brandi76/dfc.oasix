#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";

print $html->header;
print "<title>Dispatch</title>";
require "./src/connect.src";
$action=$html->param("action");
$produit=$html->param("produit");

$today=`date +%y%m%d`;
$nbjtoday=&nbjour($today);

$query="select ic2_no,ic2_date from infococ2 where ic2_cd_cl=500 and ic2_fact=0 order by ic2_no";   
$sth=$dbh->prepare($query);
$sth->execute();
while (($ic2_no,$ic2_date)=$sth->fetchrow_array){
	$an=substr($ic2_date,1,2);
	$mois=substr($ic2_date,3,2);
	$jour=substr($ic2_date,5,2);
	$date=$jour.$mois.$jour;
	$ancien=&nbjour($date);
	if ($ancien >$nbjtoday+7){next;}
	$val{"$ic2_no"}=$html->param("$ic2_no");
	$qte=$html->param("$ic2_no")*100;
	if ($action eq "validation"){
		&save("replace into comcli value ('$ic2_no','$produit','$qte','0','0','0','$qte')","af");
# 		print "replace into comcli value ('$ic2_no','$produit','$qte','0','0','0','$qte')";

	}
}


if ($action eq ""){
	print "<h2>dispatch d'un produit sur les navires</h2>";
	print "<form>produit <input type=text name=produit> <input type=submit value=go name=action></form>";
}
	


if (($action eq "go")||($action eq "recalcul")||($action eq "validation")){
	%stock=&stock($produit,'','');
	$stock=$stock{"stock"};
	$query="select pr_cd_pr,pr_desi from produit where pr_cd_pr='$produit'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_cd_pr,$pr_desi)=$sth->fetchrow_array;
	print "$pr_cd_pr $pr_desi stock entrepot:<b>$stock</b><br>";
	$reste=$stock;
	print "commande en cours:";
	print "<form><table border=1 cellspacing=0><tr><th>No de commande</th><th>navire</th><th>qte</th></tr>";
	$query="select ic2_date,ic2_no,ic2_com1 from infococ2 where ic2_cd_cl=500 and ic2_fact=0 order by ic2_no";   
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($ic2_date,$ic2_no,$ic2_com1)=$sth->fetchrow_array){
		$an=substr($ic2_date,1,2);
		$mois=substr($ic2_date,3,2);
		$jour=substr($ic2_date,5,2);
		$date=$jour.$mois.$jour;
		$ancien=&nbjour($date);
		if ($ancien >$nbjtoday+7){next;}
		$qte=$val{"$ic2_no"};
		if ($qte eq ""){
			$qte=&get("select coc_qte/100 from comcli where coc_no=$ic2_no and coc_cd_pr='$produit'");
			$qte=int($qte);
		}
		print "<tr><td>$ic2_no</td><td>$ic2_com1</td><td><input type=text name=$ic2_no size=3 value='$qte'></td></tr>";
		$reste-=$qte;
	}
	print "</table>";
	print "<input type=hidden name=produit value='$produit'>";
	print "Reste :$reste<input type=submit name=action value=recalcul><br><br><br><input type=submit name=action value=validation></form>";
}