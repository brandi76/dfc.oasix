#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
$four=$html->param("four");
$premier=$html->param("premier");
$dernier=$html->param("dernier");
$action=$html->param("action");
require "./src/connect.src";
if ($action eq ""){&premiere();}
if ($action eq "go"){&go();}
if ($action eq "fournisseur"){&fournisseur();}

sub premiere{

print "<center>Concours<br><form>Premiere date (MMAA):<input type=text name=premier> Dermiere date (MMAA):<input type=text name=dernier><br>";
print " <a href=concours.pl?action=client><a href=concours.pl?action=fournisseur> Fournisseur</a>:<input type=text name=four><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";	

}


sub fournisseur{
$query="select distinct fo2_cd_fo,fo2_add from fournis,trolley,produit where tr_cd_pr=pr_cd_pr and pr_four=fo2_cd_fo order by fo2_cd_fo ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array){
	print "$fo2_cd_fo $fo2_add <br>";
}
}


sub go{
$query="select v_code,v_date,v_vol,v_cd_cl from vol,rotation,produit where v_date%1000>=$premier  and v_date%1000<$dernier and ro_cd_pr=pr_cd_pr and pr_four=$four and ro_code=v_code group by v_code ";
$sth=$dbh->prepare($query);
$sth->execute();
$query="select fo2_add from fournis where fo2_cd_fo=$four";
$sth3=$dbh->prepare($query);
$sth3->execute();
($fo_nom)=$sth3->fetchrow_array;
($fo_nom)=split(/\*/,$fo_nom);
print "<h3><font color=navy>Vente $fo_nom du $premier au $dernier</h3></font><br><br>";
while (($v_code,$v_date,$v_vol,$v_cd_cl)=$sth->fetchrow_array){
	$first=1;
	$total=0;
	$query="select ro_cd_pr,pr_desi,floor(ro_qte/100) from rotation,produit where ro_cd_pr=pr_cd_pr and pr_four=$four and ro_code=$v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$pr_desi,$qte)=$sth2->fetchrow_array){
		$totalgen{$pr_cd_pr}+=$qte;
	}
}
foreach $cle (keys(%totalgen)){
	$query="select pr_desi from produit where pr_cd_pr='$cle'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($pr_desi)=$sth2->fetchrow_array;
	print "$cle $pr_desi $totalgen{$cle} <br>";
}
}
