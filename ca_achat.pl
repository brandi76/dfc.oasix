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
$client=$html->param("client");
$action=$html->param("action");

require "./src/connect.src";
if ($action eq ""){&premiere();}
if ($action eq "go"){&go();}
if ($action eq "fournisseur"){&fournisseur();}
if ($action eq "client"){&clien();}

sub premiere{

print "<center>Concours<br><form>Premiere date (MMAA):<input type=text name=premier> Dermiere date (MMAA):<input type=text name=dernier><br>";
print " <a href=concours.pl?action=client>Code client:</a><input type=text name=client>Produit commencant par:(tous mettre *)<input type=text name=four><br><br>"; 	
print " <input type=submit>"; 
print "<input type=hidden name=action value=go>";
print "</form>";	

}

sub clien{
$query="select distinct cl_cd_cl,cl_nom from client,trolley where floor(tr_code/10)=cl_cd_cl order by cl_cd_cl";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cl_cd_cl,$cl_nom)=$sth->fetchrow_array){
	print "$cl_cd_cl $cl_nom <br>";
}
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
$query="select v_code,v_date,v_vol,v_cd_cl from vol,rotation,produit where v_date%10000>=$premier  and v_date%10000<=$dernier and ro_cd_pr=pr_cd_pr and pr_desi like '$four%' and v_cd_cl=$client and ro_code=v_code group by v_code ";
 print $query;
$sth=$dbh->prepare($query);
$sth->execute();
$query="select cl_nom from client where cl_cd_cl=$client";
$sth3=$dbh->prepare($query);
$sth3->execute();
($cl_nom)=$sth3->fetchrow_array;
# $query="select fo2_add from fournis where fo2_cd_fo=$four";
# $sth3=$dbh->prepare($query);
# $sth3->execute();
# ($fo_nom)=$sth3->fetchrow_array;
# ($fo_nom)=split(/\*/,$fo_nom);
print "<h3><font color=navy>Valeur $four du $premier au $dernier</h3></font><br><br>";
print "<table border=1 cellpadding=0 cellspacing=0><tr><th>appro</th><th>Code</th><th>Produit</th><th>Qte</th><th>Prix achat</th><th>Valeur achat</th><th>Prix de vente</th><th>Ca</th></tr>";
while (($v_code,$v_date,$v_vol,$v_cd_cl)=$sth->fetchrow_array){
	$first=1;
	$total=0;
	$query="select ro_cd_pr,pr_desi,floor(ro_qte/100) from rotation,produit where ro_cd_pr=pr_cd_pr and pr_desi like '$four%' and ro_code=$v_code";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$pr_desi,$qte)=$sth2->fetchrow_array){
		# if ($first){&titre();}
		$pr_prac=&get("select pr_prac from produit where pr_cd_pr=$pr_cd_pr")/100;
		$ret_prix=&get("select ret_prix from retoursql  where ret_code=$v_code and ret_cd_pr=$pr_cd_pr");
		$val_achat=$pr_prac*$qte;
		$valeur=$ret_prix*$qte;
		$totala+=$val_achat;
		$totalv+=$valeur;
		
	print "<tr><td>$v_code</td><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td><td align=center>$pr_prac</td><td align=center>$val_achat</td><td align=center>$ret_prix</td><td align=center>$valeur</td></tr>";
		$total+=$qte;
		$totalgen{$pr_cd_pr}+=$qte;

	}
	#if ($total>0){
	#	print "<tr><th colspan=2>TOTAL</th><th align=right>$total</th></table><br>";
	#	(@equip)=split(/;/,$equipage);
		
	#	foreach (@equip){
	#		if ($_ ne ""){$totalpnc{$_}+=$total;}
	#	}
	#	$totalpnc{$eq_cc}+=$total;
	#	}
}

print "<tr><th></th><th></th><th></th><th></th><th></th><th>$totala</th><th></th><th>$totalv</th></tr>";
print "</table>";
}

