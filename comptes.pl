#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$action=$html->param("action");
$mois=$html->param("mois");
$type=$html->param("type");
$sens=$html->param("sens");
$val=$html->param("val");
$detail=$html->param("detail");

print "<center>";
if  (($action eq "modif")&&(($sens eq "debit")||($sens eq "credit"))){
	$query="insert into comptes (co_mois,co_sens,co_type,co_val,co_part) values ('$mois','$sens','$type','$val',0)";
	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
}
print "<form>";
print "<select name=type>";
$query="select id,libelle from type order by id";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$libelle)=$sth->fetchrow_array){
	print "<option value=$id";
	if ($id==2){print " selected";}
	print ">$libelle</option>";
}
print "</select><br><br>";
print "val <input type=text name=val><br><br>";
print "mois AAMM <input type=text name=mois value=$mois><br><br>";
print "debit <input type=radio name=sens value=debit checked> ";
print "credit <input type=radio name=sens value=credit><br><br>";

print "<input type=submit value='go'>";
print "<input type=hidden name=action value=modif>";
print "</form>";


print "</center><b>Dépenses:</b><br>";
$query="select id,libelle,round(sum(co_val),2) from comptes,type where co_mois=$mois and co_part!=1 and co_sens='debit' and id=co_type group by co_type";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$libelle,$val)=$sth->fetchrow_array){
	print "<a href=?mois=$mois&detail=$id>$libelle:$val</a><br>";
	$debit+=$val;
}
print "<b>Total:$debit</b><br><br>";

print "<b>Recettes:</b><br>";
$query="select id,libelle,round(sum(co_val),2) from comptes,type where co_mois=$mois and co_part!=1 and co_sens='credit' and id=co_type group by co_type";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$libelle,$val)=$sth->fetchrow_array){
	print "<a href=?mois=$mois&detail=$id>$libelle</a>:$val<br>";
	$credit+=$val;
}
print "<b>Total:$credit</b><br><br>";
$ecart=$credit-$debit;
print "<b>ecart:</b>$ecart<br>";

if ($detail ne ""){
        $debit=0;
	print "</center><b>Dépenses:</b><br>";
	$query="select libelle,co_val from comptes,type where co_mois=$mois and co_part!=1 and co_sens='debit' and id=co_type and co_type=$detail";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($libelle,$val)=$sth->fetchrow_array){
		print "$libelle:$val<br>";
		$debit+=$val;
	}
	print "<b>Total:$debit</b><br><br>";
        $credit=0;
	print "</center><b>Recettes:</b><br>";
	$query="select libelle,co_val from comptes,type where co_mois=$mois and co_part!=1 and co_sens='credit' and id=co_type and co_type=$detail";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($libelle,$val)=$sth->fetchrow_array){
		print "$libelle:$val<br>";
		$credit+=$val;
	}
	print "<b>Total:$credit</b><br><br>";
	
}
print "</body></html>";

