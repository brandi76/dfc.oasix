#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
# require "../oasix/outils_perl.lib";

print $html->header;
print "<html><head><Meta http-equiv=\"Pragma\" content=\"no-cache\"></head><body>";
$today=$html->param('today');
$nodepart=$html->param('nodepart');
$pr_cd_pr=$html->param('pr_cd_pr');
$action=$html->param('action');


require "./src/connect.src";

if ($action eq "modifier"){
	$query="select fl_troltype from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 group by fl_troltype";
	$sth=$dbh->prepare($query);	
	$sth->execute();
	while (($troltype)=$sth->fetchrow_array){
		$qte=$html->param("$troltype");
		if ($qte ne ""){
			$qte*=100;
			$query="replace into ecartrol values('$troltype','$pr_cd_pr','$qte','')";
			print $query;
			print "<font color=red>Qte du trolley type $troltype modifiée</font><br>";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
		}
	}
}
print "<center><h1>$nodepart</h1>";
$query="select fl_troltype,count(*) from listevol,flyhead where liv_dep=$nodepart and fl_date=liv_date and fl_vol=liv_vol and liv_nolot=0 group by fl_troltype";
$sth=$dbh->prepare($query);	
$sth->execute();
@liste=();
while (($fl_troltype,$nb)=$sth->fetchrow_array){
	if (($fl_troltype!=3303)&&($fl_troltype!=3353)&&($fl_troltype!=3302)){push (@liste,"$fl_troltype;$nb");}
}
$query="select pr_desi from produit where pr_cd_pr=$pr_cd_pr";
$sth=$dbh->prepare($query);	
$sth->execute();
($pr_desi)=$sth->fetchrow_array;

$total=0;
print "<form>";
print "<table border=1><tr><th>$pr_cd_pr</th><th>$pr_desi</th></tr><tr><th>Trolley type</th><th>Nb trolley</th><th>Qte</th><th>Total</th></tr>";
foreach (@liste){
	($troltype,$nb)=split(/;/,$_);
	$sth2=$dbh->prepare("select sum(tr_qte)/100 from trolley where tr_code=$troltype and tr_cd_pr=$pr_cd_pr");
	$sth2->execute();
	($qte)=$sth2->fetchrow_array;
	$sth2=$dbh->prepare("select ecr_qte/100 from ecartrol where ecr_cdtrol=$troltype and ecr_cd_pr=$pr_cd_pr");
	$sth2->execute();
	($ecr_qte)=$sth2->fetchrow_array;
	if ($ecr_qte eq ""){$ecr_qte=$qte;}
	$ecr_qte+=0;
	print "<tr><td align=right>$troltype</td><td align=right>$nb</td><td align=right><input type=texte name=$troltype value=$ecr_qte></td><td align=right>".$ecr_qte*$nb."</td></tr>";
	$total+=$ecr_qte*$nb;
}
	
print "<tr><th colspan=3>Total</th><th align=right>$total</th></tr></table>";
print "<input type=hidden name=pr_cd_pr value=$pr_cd_pr>";
print "<input type=hidden name=today value=$today>";
print "<input type=hidden name=nodepart value=$nodepart>";
print "<input type=submit name=action value=modifier></form>";
