#!/usr/bin/perl
use CGI;
use DBI();
       
$html=new CGI;
print $html->header();
print "<title>Brevet</title>";
#require "../oasix/outils_perl2.lib";
$action=$html->param('action');
$rep1c=$html->param('rep1');
$rep2c=$html->param('rep2');
$rep3c=$html->param('rep3');
$rep4c=$html->param('rep4');
$no=$html->param('no');
$res=$html->param('res');
$total=$html->param('total');
$nom=$html->param('nom');
# $niveau=$html->param('niveau');
$choix=$html->param('choix');
if ($choix eq ""){
	$choix=$html->param('choixcheck');
	if ($choix eq "on"){$choix=1;}else {$choix=0;}
}
require "./src/connect.src";
if ("$nom" eq ""){
	print "<center><h3>Révise ton brevet avec le professeur goël</h3><br><img src=../IMG/jpg/gael-face.gif> <br>Bonjour entre ton nom , je vais t'interroger sur les questions auxquelles tu n'a pas encore répondues et celles sur lesquelles tu as fait une erreur <br>
	Tu peux t'arrêter quand tu veux , ta note et les réponses seront affichées au fur et à mesure, bon courage .<br><form><br>ton nom <input type=text name=nom>";
# 	print "<br>Votre niveau <br>";
# 	print "initial <input type=radio name=niveau value=1> pilote <input type=radio name=niveau value=2> confirmé <input type=radio name=niveau value=3>";
	
	print "<br>Uniquement les questions sur lesquelles tu as fait une erreur <input type=checkbox name=choixcheck><br><br><input type=submit>";
	print "</form>";
}
else
{
print "<center><br><br><br>";

if ($action eq "") {
	$query="select * from brevet  where no not in (select no from pilote where nom='$nom' and flag=$choix) order by rand() limit 1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($type,$no,$question,$rep1,$val1,$rep2,$val2,$rep3,$val3,$rep4,$val4)=$sth->fetchrow_array;
	if ($no eq "") {
		print "<img src=../IMG/jpg/gael-face.gif><br><br> Bravo tu as bien répondu à toutes les questions , j'ai remis à zéro ton compte , comme ça tu peux recommencer à t'entrainer <br> ";
		print "<form><input type=hidden name=nom value='$nom'><input type=submit></form>";
		&save("delete from pilote where nom='$nom'");
	}
	else
	{
		if (grep /parapente/,$type) {
			print "<img src=../IMG/jpg/parapente.jpg><br>";		
		} 
		print "<form><table>";
		print "<tr bgcolor=#66CCFF colspan=2><td><b>$question </b></td></tr>";
		print "<tr><td>$rep1</td><td><input type=checkbox name=rep1></td></tr>"; 
		print "<tr><td>$rep2</td><td><input type=checkbox name=rep2></td></tr>"; 
		print "<tr><td>$rep3</td><td><input type=checkbox name=rep3></td></tr>"; 
		if ($rep4 ne ""){
			print "<tr><td>$rep4</td><td><input type=checkbox name=rep4></td></tr>"; 
		}
		print "</table><input type=hidden name=no value='$no'><input type=hidden name=action value=go><input type=submit>";
		print "<input type=hidden name=res value='$res'><input type=hidden name=total value='$total'>";
		print "<input type=hidden name=choix value='$choix'>";
		print "<input type=hidden name=nom value='$nom'><input type=hidden name=niveau value='$niveau'></form>";
	}
}
if ($action eq "go"){
	$note=0;
	$query="select * from brevet where no='$no'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($type,$no,$question,$rep1,$val1,$rep2,$val2,$rep3,$val3,$rep4,$val4)=$sth->fetchrow_array;
	print "<form><table>";
	print "<tr bgcolor=#66CCFF colspan=2><td><b>$question </b></td></tr>";
	$color="white";
	if (($val1<0)&&($rep1c eq "on")){$color="#FFCCFF";$note+=$val1;}
	if (($val1>0)&&($rep1c ne "on")){$color="#FFCCFF";}
	if (($val1>0)&&($rep1c eq "on")){$note+=$val1;}

	print "<tr bgcolor=$color><td>$rep1</td><td align=right>$val1</td></tr>"; 
	$color="white";
	if (($val2<0)&&($rep2c eq "on")){$color="#FFCCFF";$note+=$val2;}
	if (($val2>0)&&($rep2c ne "on")){$color="#FFCCFF";}
	if (($val2>0)&&($rep2c eq "on")){$note+=$val2;}

	print "<tr bgcolor=$color><td>$rep2</td><td  align=right>$val2</td></tr>"; 
	$color="white";
	if (($val3<0)&&($rep3c eq "on")){$color="#FFCCFF";$note+=$val3;}
	if (($val3>0)&&($rep3c ne "on")){$color="#FFCCFF";}
	if (($val3>0)&&($rep3c eq "on")){$note+=$val3;}

	print "<tr bgcolor=$color><td>$rep3</td><td  align=right>$val3</td></tr>"; 
	$color="white";
	if ($rep4 ne ""){
		if (($val4<0)&&($rep4c eq "on")){$color="#FFCCFF";$note+=$val4;}
		if (($val4>0)&&($rep4c ne "on")){$color="#FFCCFF";}
		if (($val4>0)&&($rep4c eq "on")){$note+=$val4;}
		print "<tr bgcolor=$color><td>$rep4</td><td align=right>$val4</td></tr>"; 
	}
	print "</table><input type=submit value=suivante>";
	if ($note<0){$note=0;}
	if ($note==6){  
		$existe=&get("select count(*) from pilote where nom='$nom' and no='$no' and flag=0")+0;
		if ($existe==0){	
			&save("insert ignore into pilote value ('$nom' ,'$no','0')");
		}
	}
	else {
		&save("insert ignore into pilote value ('$nom' ,'$no','1')");
		print "<br><br><img src=../IMG/jpg/gael-mech.gif>";
	}
	$res+=$note;
	$total+=6;
	$valeur=int($res*20/$total);
	print "<br><br><font size=+3>$valeur/20</font>";
	print "<input type=hidden name=res value='$res'><input type=hidden name=total value='$total'>";
	print "<input type=hidden name=nom value='$nom'><input type=hidden name=niveau value='$niveau'>";
	print "<input type=hidden name=choix value='$choix'>";
	$nb=&get("select count(*) from pilote where nom='$nom' and flag=0");
	print "<br>Nombre de bonne réponses:$nb/583";
	print "</form>";
}

}
sub get()
{
	if ($_[1] eq "aff"){print "$_[0]<br>";}
	my ($sth)=$dbh->prepare($_[0]);
	$sth->execute() or die (print $query);
	return ($sth->fetchrow_array);
}
	
# FONCTION : save
# DESCRIPTION : sauvegarde mysql
# ENTREE : query, option (aff affiche la requete)
# SORTIE :rien
	
sub save()
{
	if ($_[1] eq "aff"){print "$_[0]<br>";}
	my ($sth)=$dbh->prepare($_[0]);
	$sth->execute() or die (print $query);
}
