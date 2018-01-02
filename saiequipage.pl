#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
# initialisation des variables
$client=$html->param("client");
$appro=$html->param("appro");
$rotation=$html->param("rotation");
$cc=$html->param(cc);
$pnc1=$html->param(pnc1);
$pnc2=$html->param(pnc2);
$pnc3=$html->param(pnc3);
$pnc4=$html->param(pnc4);
$pnc5=$html->param(pnc5);
$pnc6=$html->param(pnc6);
$pnc7=$html->param(pnc7);
$pnc8=$html->param(pnc8);
$pnc9=$html->param(pnc9);

if (($appro ne "")&& ($client ne "") && ($pnc1 eq "")){
	$query="select eq_cc,eq_equipage from equipagesql where eq_code='$appro' and eq_rot='$rotation'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cc,$equipe)=$sth->fetchrow_array;
        ($null,$pnc1,$pnc2,$pnc3,$pnc4,$pnc5,$pnc6,$pnc7,$pnc8,$pnc9)=split(/;/,$equipe);
}
if (($appro ne "")&& ($client ne "") && ($pnc1 ne "")){
	$query="replace into equipagesql values ('$appro','$rotation','$cc',';$pnc1;$pnc2;$pnc3;$pnc4;$pnc5;$pnc6;$pnc7;$pnc8;$pnc9')";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$query="select eq_cc,eq_equipage from equipagesql where eq_code='$appro' and eq_rot='$rotation'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cc,$equipe)=$sth->fetchrow_array;
        ($null,$pnc1,$pnc2,$pnc3,$pnc4,$pnc5,$pnc6,$pnc7,$pnc8,$pnc9)=split(/;/,$equipe);

}

print "<SCRIPT>function res()\n{document.equipe.cc.value='';\ndocument.equipe.pnc1.value='';document.equipe.pnc2.value='';document.equipe.pnc3.value='';document.equipe.pnc4.value='';document.equipe.pnc5.value='';document.equipe.pnc6.value='';document.equipe.pnc7.value='';document.equipe.pnc8.value='';document.equipe.pnc9.value='';}</script>";
print "<body><form name=equipe>Client <input type=text name=client value=$client Onchange=res()><br>";
print "Appro <input type=text name=appro value=$appro OnChange=res()><br>Rotation <input type=text name=rotation value=$rotation Onchange=res()><br>";
if ($cc ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$cc'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_cc)=$sth->fetchrow_array){}else {$hot_cc="inconnu";}
}
print "C/C <input type=text name=cc value=$cc> $hot_cc<br>";

if ($pnc1 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc1'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom1)=$sth->fetchrow_array){}else {$hot_nom1="inconnu";}
}
if ($pnc2 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc2'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom2)=$sth->fetchrow_array){}else {$hot_nom2="inconnu";}
}
if ($pnc3 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc3'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom3)=$sth->fetchrow_array){}else {$hot_nom3="inconnu";}
}
if ($pnc4 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc4'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom4)=$sth->fetchrow_array){}else {$hot_nom4="inconnu";}
}
if ($pnc5 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc5'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom5)=$sth->fetchrow_array){}else {$hot_nom5="inconnu";}
}
if ($pnc6 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc6'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom6)=$sth->fetchrow_array){}else {$hot_nom6="inconnu";}
}
if ($pnc7 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc7'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom7)=$sth->fetchrow_array){}else {$hot_nom7="inconnu";}
}
if ($pnc8 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc8'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom8)=$sth->fetchrow_array){}else {$hot_nom8="inconnu";}
}
if ($pnc9 ne ""){
	$query="select hot_nom from hotesse where hot_cd_cl='$client' and hot_tri='$pnc9'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	if (($hot_nom9)=$sth->fetchrow_array){}else {$hot_nom9="inconnu";}
}

print "PNC <input type=text name=pnc1 value=$pnc1> $hot_nom1<br>";
print "PNC <input type=text name=pnc2 value=$pnc2> $hot_nom2<br>";
print "PNC <input type=text name=pnc3 value=$pnc3> $hot_nom3<br>";
print "PNC <input type=text name=pnc4 value=$pnc4> $hot_nom4<br>";
print "PNC <input type=text name=pnc5 value=$pnc5> $hot_nom5<br>";
print "PNC <input type=text name=pnc6 value=$pnc6> $hot_nom6<br>";
print "PNC <input type=text name=pnc7 value=$pnc7> $hot_nom7<br>";
print "PNC <input type=text name=pnc8 value=$pnc8> $hot_nom8<br>";
print "PNC <input type=text name=pnc9 value=$pnc9> $hot_nom9<br>";
print "<input type=submit>";
print "</form>";
print "</html>";
print "</body>";

# -E saisie des equipages fly
