#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;
print "<title>debug stock</title>";
require "./src/connect.src";


$action=$html->param("action");
$pr_cd_pr=$html->param("produit");
$ventil=$html->param("ventil");
if ($ventil ne "") { $action = "null";}

if ($action eq ""){

      	print "<form>code produit <input type=text size=15 name=produit>";
	print "<br>Liste (15 cig) (6 alcool) <input type=text name=ventil>";
print "<br>\n<br><input type=hidden name=action value=visu><input type=submit value= envoie></form></body>";
}
	
if ($action eq "visu"){
	print "<table border=1 cellspacing=0 cellppadding=0><tr><th>produit</th><th>Douane</th><th>- vol</th><th> - casse</th><th>+ diff</th><th>+ nonsai</th><th>- pastouch</th><th>+ errdep </th><th>entrepot</th></tr>";
	$query="select pr_cd_pr , pr_desi,pr_stanc,pr_stre,pr_ventil,pr_deg,pr_pdn from produit where pr_cd_pr=$pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($pr_cd_pr,$pr_desi,$pr_stanc,$pr_stre,$pr_ventil,$pr_deg,$pr_pdn)=$sth->fetchrow_array;
	%stock=&stock($pr_cd_pr,"","","");
	print "<tr><td>$pr_cd_pr $pr_desi</td><td>$stock{'stre'}</td><td>$stock{'vol'}</td><td>$stock{'casse'}</td><td>$stock{'diff'}</td><td>$stock{'nonsai'}</td><td>$stock{'pastouch'}</td><td>$stock{'errdep'}</td><td>$stock{'stock'}</td></tr>";
	;
	$query="select pr_cd_pr , pr_desi,pr_stanc,pr_stre from produit where pr_acquit!=1 and pr_ventil='$pr_ventil' and pr_deg='$pr_deg' and pr_pdn='$pr_pdn' and pr_cd_pr!='$pr_cd_pr'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stanc,$pr_stre)=$sth->fetchrow_array){
	    %stock=&stock($pr_cd_pr,"","","");
	    print "<tr><td>$pr_cd_pr $pr_desi</td><td>$stock{'stre'}</td><td>$stock{'vol'}</td><td>$stock{'casse'}</td><td>$stock{'diff'}</td><td>$stock{'nonsai'}</td><td>$stock{'pastouch'}</td><td>$stock{'errdep'}</td><td>$stock{'stock'}</td></tr>";
	    }
	
	print "</table>";
}

if ($ventil==15){
	print "<table border=1 cellspacing=0 cellppadding=0 s><tr><th>produit</th><th>Douane</th><th>- vol</th><th> - casse</th><th>+ diff</th><th>+ nonsai</th><th>- pastouch</th><th>+ errdep </th><th>entrepot</th></tr>";
	$query="select pr_cd_pr , pr_desi,pr_stanc,pr_stre from produit";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stanc,$pr_stre)=$sth->fetchrow_array){
	    if (($pr_stanc==0)&&($pr_stre==0)){next;}
	    %stock=&stock($pr_cd_pr,"","","");
	    print "<tr><td>$pr_cd_pr $pr_desi</td><td>$stock{'stre'}</td><td>$stock{'vol'}</td><td>$stock{'casse'}</td><td>$stock{'diff'}</td><td>$stock{'nonsai'}</td><td>$stock{'pastouch'}</td><td>$stock{'errdep'}</td><td>$stock{'stock'}</td></tr>";
	    }
	print "</table>";
}	
if ($ventil==6){
	print "<table border=1 cellspacing=0 cellppadding=0><tr><th>produit</th><th>Douane</th><th>- vol</th><th> - casse</th><th>+ diff</th><th>+ nonsai</th><th>- pastouch</th><th>+ errdep </th><th>entrepot</th></tr>";
	$query="select pr_cd_pr,pr_desi,pr_stanc,pr_stre from produit where pr_stvol!=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_stanc,$pr_stre)=$sth->fetchrow_array){
	    if (($pr_stanc==0)&&($pr_stre==0)){next;}
	    %stock=&stock($pr_cd_pr,"","","");
	    print "<tr><td>$pr_cd_pr $pr_desi</td><td>$stock{'stre'}</td><td>$stock{'vol'}</td><td>$stock{'casse'}</td><td>$stock{'diff'}</td><td>$stock{'nonsai'}</td><td>$stock{'pastouch'}</td><td>$stock{'errdep'}</td><td>$stock{'stock'}</td></tr>";
	    }
	print "</table>";
}	

