#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
&tetehtml();
$client=$html->param("client");
$appro=$html->param("appro");
$rot=$html->param("rot");
$cc=$html->param("cc");
$pnc1=$html->param("pnc1");
$pnc2=$html->param("pnc2");
$pnc3=$html->param("pnc3");
$pnc4=$html->param("pnc4");
$pnc5=$html->param("pnc5");
$pnc6=$html->param("pnc6");
$pnc7=$html->param("pnc7");
$pnc8=$html->param("pnc8");
$pnc9=$html->param("pnc9");
$action=$html->param("action");
$cherche=$html->param("cherche");

if ($cherche ne "") {
	$query="select hot_tri from hotesse where hot_cd_cl='$client' and hot_tri like '$cherche'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<br><br><h3>Resultat de la recherche:";
	while (($hot_tri)=$sth->fetchrow_array){print "$hot_tri ";}
	print "</h3><br><br>";
}	
	
if (($client ne "")&&($appro ne "")&&($rot ne "")){
	$query="select eq_cc,eq_equipage from equipagesql  where eq_code=$appro and eq_rot=$rot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($eq_cc,$eq_equipage)=$sth->fetchrow_array;
	($null,$pn1,$pn2,$pn3,$pn4,$pn5,$pn6,$pn7,$pn8,$pn9)=split(/;/,$eq_equipage);
	if ($cc ne ""){$eq_cc=$cc;}
	if ($pnc1 ne ""){$pn1=$pnc1;}
	if ($pnc2 ne ""){$pn2=$pnc2;}
	if ($pnc3 ne ""){$pn3=$pnc3;}
	if ($pnc4 ne ""){$pn4=$pnc4;}
	if ($pnc5 ne ""){$pn5=$pnc5;}
	if ($pnc6 ne ""){$pn6=$pnc6;}
	if ($pnc7 ne ""){$pn7=$pnc7;}
	if ($pnc8 ne ""){$pn8=$pnc8;}
	if ($pnc9 ne ""){$pn9=$pnc9;}
	if ($eq_cc eq "NULL"){$eq_cc="";}
	if ($pn1 eq "NULL"){$pn1="";}
	if ($pn2 eq "NULL"){$pn2="";}
	if ($pn3 eq "NULL"){$pn3="";}
	if ($pn4 eq "NULL"){$pn4="";}
	if ($pn5 eq "NULL"){$pn5="";}
	if ($pn6 eq "NULL"){$pn6="";}
	if ($pn7 eq "NULL"){$pn7="";}
	if ($pn8 eq "NULL"){$pn8="";}
	if ($pn9 eq "NULL"){$pn9="";}
	$eq_equipage=";".$pn1.";".$pn2.";".$pn3.";".$pn4.";".$pn5.";".$pn6.";".$pn7.";".$pn8.";".$pn9.";";
	$query="replace into equipagesql values ('$appro','$rot','$eq_cc','$eq_equipage')";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
}
print "<center><br><br>Mettre NULL pour enlever un PNC</br><form><table border=1 cellspacing=0><tr><td class=gauche>Client<input type=text name=client value=$client><br>";
print "Appro<input type=text name=appro value=$appro><br><br>"; 	
print "rotation<input type=text name=rot value=$rot><br><br>"; 	
print "C/C<input type=text name=cc value=$eq_cc>";
if ($eq_cc ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$eq_cc' or hot_mat='$eq_cc') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc1<input type=text name=pnc1 value=$pn1>";
if ($pn1 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn1' or hot_mat='$pn1') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc2<input type=text name=pnc2 value=$pn2>";
if ($pn2 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn2' or hot_mat='$pn2') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc3<input type=text name=pnc3 value=$pn3>";
if ($pn3 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn3' or hot_mat='$pn3') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc4<input type=text name=pnc4 value=$pn4>";
if ($pn4 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn4' or hot_mat='$pn4') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc5<input type=text name=pnc5 value=$pn5>";
if ($pn5 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn5' or hot_mat='$pn5') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc6<input type=text name=pnc6 value=$pn6>";
if ($pn6 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn6' or hot_mat='$pn6') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc7<input type=text name=pnc7 value=$pn7>";
if ($pn7 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn7' or hot_mat='$pn7') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc8<input type=text name=pnc8 value=$pn8>";
if ($pn8 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn8' or hot_mat='$pn8') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";
print "Pnc9<input type=text name=pnc9 value=$pn9>";
if ($pn9 ne ""){
	$query="select hot_nom from hotesse where (hot_tri='$pn9' or hot_mat='$pn9') and hot_cd_cl='$client'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	if ($hot_nom eq ""){$hot_nom="<font color=red>Inconnu</font>";}
	print " $hot_nom";
}
print "<br>";

print "</td></tr></table><br><br><input type=submit class=bouton><br>"; 
print "</div><a href=equipage.pl?client='$client'>Nouvel equipage</a>";
print "<br>Recherche <input type=text name=cherche size=3>"; 

print "</form>";	

sub tetehtml()
{
	print "<html><head><style type=\"text/css\">
	body {color=white;}
	td {font-weight:bold;text-align:left;font-size:larger;}
	th {font-weight:bold;background-color:yellow;text-align:center;color=black;}
	
	.gauche {
		td {font-weight:bold;text-align:left;}
	}
	
	<!--
	.ombre {
	filter:shadow(color=black, direction=120 , strength=2);
	width:800px;}
	.ombre2 {
	filter:shadow(color=white, direction=120 , strength=3);
	width:800px;}
		
	.bouton {border-width=3pt;color:black;background-color:white;font-weight:bold;}
	-->
	</style></head>";

	print "<body background=../fond2.jpg link=white alink=white vlink=white><center><div class=ombre><font size=+5>Saisie des equipages</font>";
}

